#!/usr/bin/env bun

import { lookup } from "node:dns/promises";
import { createConnection } from "node:net";

type Environment = "dev" | "staging" | "production";

const AWS_ARGS = ["--profile", "vivident", "--region", "us-west-2"] as const;
const ENVIRONMENTS: Record<Environment, { proxyPrefix: string }> = {
  dev: { proxyPrefix: "eevee-dev-db-proxy-" },
  staging: { proxyPrefix: "eevee-stg-db-proxy-" },
  production: { proxyPrefix: "eevee-prd-db-proxy-" },
};
const DB_USER = "eevee_ro";
const DB_NAME = "eevee";
const DB_PORT = 5432;
const TCP_TIMEOUT_MS = 5_000;

function usage(): never {
  console.error("사용법: bun db-connect.ts <dev|staging|production>");
  process.exit(2);
}

function fail(message: string): never {
  console.error(`오류: ${message}`);
  process.exit(1);
}

async function run(command: string, args: string[], options: {
  env?: Record<string, string | undefined>;
  inherit?: boolean;
} = {}): Promise<{ exitCode: number; stdout: string; stderr: string }> {
  const proc = Bun.spawn([command, ...args], {
    env: options.env ?? process.env,
    stdin: options.inherit ? "inherit" : undefined,
    stdout: options.inherit ? "inherit" : "pipe",
    stderr: options.inherit ? "inherit" : "pipe",
  });

  if (options.inherit) {
    return { exitCode: await proc.exited, stdout: "", stderr: "" };
  }

  const [stdout, stderr, exitCode] = await Promise.all([
    new Response(proc.stdout).text(),
    new Response(proc.stderr).text(),
    proc.exited,
  ]);
  return { exitCode, stdout, stderr };
}

async function aws(args: string[]): Promise<string> {
  let result: { exitCode: number; stdout: string; stderr: string };
  try {
    result = await run("aws", [...AWS_ARGS, ...args]);
  } catch {
    fail("aws CLI를 찾을 수 없습니다. AWS CLI를 설치하고 PATH를 확인하세요.");
  }
  if (result.exitCode !== 0) {
    const detail = result.stderr.trim().replace(/\s+/g, " " );
    fail(`AWS 명령이 실패했습니다${detail ? `: ${detail}` : ""}`);
  }
  return result.stdout.trim();
}

function isPrivateIpv4(address: string): boolean {
  const octets = address.split(".").map(Number);
  if (octets.length !== 4 || octets.some((octet) => !Number.isInteger(octet) || octet < 0 || octet > 255)) {
    return false;
  }
  return octets[0] === 10
    || (octets[0] === 172 && octets[1] >= 16 && octets[1] <= 31)
    || (octets[0] === 192 && octets[1] === 168);
}

async function resolvePrivateIpv4(hostname: string): Promise<string[]> {
  let addresses: Array<{ address: string; family: number }>;
  try {
    addresses = await lookup(hostname, { all: true, family: 4 });
  } catch {
    fail(`Proxy hostname을 IPv4로 해석할 수 없습니다: ${hostname}`);
  }
  const ipv4 = [...new Set(addresses.map(({ address }) => address))];
  const privateIpv4 = ipv4.filter(isPrivateIpv4);
  if (privateIpv4.length === 0) {
    fail(`Proxy hostname이 사설 IPv4를 반환하지 않습니다: ${hostname}`);
  }
  return privateIpv4;
}

async function checkTcp(hostname: string, port: number): Promise<void> {
  await new Promise<void>((resolve, reject) => {
    const socket = createConnection({ host: hostname, port });
    const timer = setTimeout(() => {
      socket.destroy();
      reject(new Error("timeout"));
    }, TCP_TIMEOUT_MS);
    socket.once("connect", () => {
      clearTimeout(timer);
      socket.end();
      resolve();
    });
    socket.once("error", (error) => {
      clearTimeout(timer);
      socket.destroy();
      reject(error);
    });
  }).catch((error: unknown) => {
    const reason = error instanceof Error && error.message === "timeout" ? "시간 초과" : "연결 거부 또는 네트워크 오류";
    fail(`RDS Proxy ${port}번 포트에 연결할 수 없습니다 (${reason}): ${hostname}`);
  });
}

async function psqlCheck(hostname: string, token: string): Promise<void> {
  const result = await run("psql", [
    `host=${hostname} port=${DB_PORT} dbname=${DB_NAME} user=${DB_USER} sslmode=require`,
    "--no-psqlrc",
    "--set",
    "ON_ERROR_STOP=1",
    "--tuples-only",
    "--no-align",
    "--command",
    "begin transaction read only; select current_database(), current_user, current_setting('transaction_read_only'); rollback;",
  ], {
    env: { ...process.env, PGPASSWORD: token, PGCONNECT_TIMEOUT: "15" },
  }).catch(() => fail("psql을 찾을 수 없습니다. PostgreSQL client를 설치하고 PATH를 확인하세요."));

  if (result.exitCode !== 0) {
    fail(`IAM PostgreSQL 연결 검증에 실패했습니다${result.stderr.trim() ? `: ${result.stderr.trim()}` : ""}`);
  }
  const rows = result.stdout
    .split(/\r?\n/)
    .map((line) => line.trim())
    .filter((line) => line && line !== "BEGIN" && line !== "ROLLBACK");
  if (rows.length !== 1 || rows[0] !== `${DB_NAME}|${DB_USER}|on`) {
    fail(`예상하지 못한 DB 검증 결과입니다: ${rows.join(" / ") || "(없음)"}`);
  }
}

async function main(): Promise<void> {
  const environment = process.argv[2] as Environment | undefined;
  if (!environment || !(environment in ENVIRONMENTS) || process.argv.length !== 3) usage();

  const identity = await aws(["sts", "get-caller-identity", "--output", "json"]);
  if (!identity) fail("vivident AWS profile의 caller identity를 확인할 수 없습니다.");

  const proxyPrefix = ENVIRONMENTS[environment].proxyPrefix;
  const proxy = await aws([
    "rds",
    "describe-db-proxies",
    "--query",
    `DBProxies[?starts_with(DBProxyName, \`${proxyPrefix}\`)].Endpoint | [0]`,
    "--output",
    "text",
  ]);
  if (!proxy || proxy === "None") fail(`${environment} 환경의 RDS Proxy를 찾을 수 없습니다.`);

  const addresses = await resolvePrivateIpv4(proxy);
  await checkTcp(proxy, DB_PORT);
  const token = await aws(["rds", "generate-db-auth-token", "--hostname", proxy, "--port", String(DB_PORT), "--username", DB_USER]);
  if (!token) fail("IAM DB 인증 토큰을 발급하지 못했습니다.");
  await psqlCheck(proxy, token);

  console.log(`${environment}: ${proxy} (${addresses.join(", ")})`);
  console.log(`${DB_NAME} / ${DB_USER} / read-only 검증 성공. psql 셸을 엽니다.`);
  const shell = await run("psql", [
    `host=${proxy} port=${DB_PORT} dbname=${DB_NAME} user=${DB_USER} sslmode=require`,
    "--no-psqlrc",
  ], {
    env: { ...process.env, PGPASSWORD: token },
    inherit: true,
  });
  process.exit(shell.exitCode);
}

await main();
