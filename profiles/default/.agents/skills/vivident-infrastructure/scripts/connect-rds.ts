#!/usr/bin/env bun
import { lookup } from "node:dns/promises";
import { createConnection } from "node:net";

const PORT = 5432;
const fail = (m: string): never => {
  console.error("오류: " + m);
  process.exit(1);
};
let runtimeOptions: ReturnType<typeof args>;
function args(argv: string[]) {
  if (argv.includes("--help")) {
    console.log(
      "사용법: bun connect-rds.ts --proxy-prefix <접두사> --db-name <이름> --db-user <사용자> [옵션]\n옵션: --profile <AWS 프로필> --region <AWS 리전> --check --query SQL --file 파일 --statement-timeout 밀리초\nSQL 입력 옵션 생략 시 stdin을 읽습니다.",
    );
    process.exit(0);
  }
  let proxyPrefix: string | undefined;
  let dbName: string | undefined;
  let dbUser: string | undefined;
  let profile = "vivident";
  let region = "us-west-2";
  let mode = "stdin",
    sql = "",
    file = "";
  let timeout: number | undefined;
  const seen = new Set<string>();
  for (let i = 0; i < argv.length; i++) {
    const option = argv[i];
    if (seen.has(option)) fail("중복 옵션: " + option);
    seen.add(option);
    if (option === "--check") {
      if (mode !== "stdin") fail("입력 모드는 하나만 지정하세요.");
      mode = "check";
      continue;
    }
    if (
      ![
        "--proxy-prefix",
        "--db-name",
        "--db-user",
        "--profile",
        "--region",
        "--query",
        "--file",
        "--statement-timeout",
      ].includes(option)
    )
      fail("알 수 없는 옵션: " + option);
    const value = argv[++i];
    if (!value || value.startsWith("--")) fail(option + " 값이 필요합니다.");
    if (option === "--proxy-prefix") proxyPrefix = value;
    if (option === "--db-name") dbName = value;
    if (option === "--db-user") dbUser = value;
    if (option === "--profile") profile = value;
    if (option === "--region") region = value;
    if (option === "--query" || option === "--file") {
      if (mode !== "stdin") fail("입력 모드는 하나만 지정하세요.");
      mode = option === "--query" ? "query" : "file";
      if (mode === "query") sql = value;
      else file = value;
    }
    if (option === "--statement-timeout") {
      timeout = Number(value);
      if (
        !/^\d+$/.test(value) ||
        !Number.isSafeInteger(timeout) ||
        timeout <= 0 ||
        timeout > 2147483647
      )
        fail("statement-timeout은 1~2147483647 사이의 정수 밀리초여야 합니다.");
    }
  }
  if (!proxyPrefix || !dbName || !dbUser)
    fail("--proxy-prefix, --db-name, --db-user가 필요합니다.");
  if (mode === "check" && timeout !== undefined)
    fail("--check에는 statement-timeout을 지정하지 않습니다.");
  return {
    proxyPrefix,
    dbName,
    dbUser,
    profile,
    region,
    m: mode,
    sql,
    file,
    t: timeout,
  };
}

// 문자열과 주석은 검사에서 제외하고 트랜잭션 탈출·psql 명령을 차단한다.
function validateSql(sql: string): void {
  let code = "",
    i = 0;
  while (i < sql.length) {
    if (sql.startsWith("--", i)) {
      const end = sql.indexOf("\n", i + 2);
      i = end < 0 ? sql.length : end;
      code += " ";
      continue;
    }
    if (sql.startsWith("/*", i)) {
      let depth = 1;
      i += 2;
      while (i < sql.length && depth) {
        if (sql.startsWith("/*", i)) {
          depth++;
          i += 2;
        } else if (sql.startsWith("*/", i)) {
          depth--;
          i += 2;
        } else i++;
      }
      if (depth) fail("닫히지 않은 SQL 주석입니다.");
      code += " ";
      continue;
    }
    const c = sql[i];
    const dollar =
      c === "$"
        ? sql.slice(i).match(/^\$(?:[A-Za-z_][A-Za-z_0-9]*)?\$/)?.[0]
        : undefined;
    if (dollar) {
      const end = sql.indexOf(dollar, i + dollar.length);
      if (end < 0) fail("닫히지 않은 달러 문자열입니다.");
      i = end + dollar.length;
      code += " literal ";
      continue;
    }
    if (c === "'" || c === '"') {
      const escaped = c === "'" && /(?:^|\W)[eE]$/.test(sql.slice(0, i));
      i++;
      let closed = false;
      while (i < sql.length) {
        if (escaped && sql[i] === "\\") {
          i += 2;
          continue;
        }
        if (sql[i] === c) {
          if (sql[i + 1] === c) {
            i += 2;
            continue;
          }
          i++;
          closed = true;
          break;
        }
        i++;
      }
      if (!closed) fail("닫히지 않은 SQL 문자열 또는 식별자입니다.");
      code += " literal ";
      continue;
    }
    if (c === "\\") fail("psql 메타 명령은 허용하지 않습니다.");
    code += c;
    i++;
  }
  const statements = code
    .split(";")
    .map((x) => x.trim())
    .filter(Boolean);
  if (!statements.length) fail("실행할 SQL이 비어 있습니다.");
  for (const statement of statements) {
    if (!/^(select|with|explain)\b/i.test(statement))
      fail("SELECT, WITH 조회, EXPLAIN만 허용합니다.");
    if (
      /\b(alter|create|drop|grant|revoke|insert|update|delete|truncate|merge|call|do|copy|begin|commit|rollback|abort|savepoint|release|prepare|execute|set|reset|discard|vacuum|analyze|reindex|cluster|refresh|lock|listen|notify|unlisten|into)\b/i.test(
        statement,
      )
    )
      fail(
        "변경·트랜잭션·세션·유지보수 명령과 EXPLAIN ANALYZE는 허용하지 않습니다.",
      );
    if (
      /\b(pg_advisory\w*|set_config|nextval|setval|pg_terminate_backend|pg_cancel_backend)\s*\(/i.test(
        statement,
      )
    )
      fail("상태를 변경하는 함수는 허용하지 않습니다.");
  }
}
async function run(
  c: string,
  a: string[],
  env: Record<string, string | undefined> = process.env,
) {
  const x = Bun.which(c);
  if (!x) fail(c + " 명령을 찾을 수 없습니다.");
  let p = Bun.spawn([x!, ...a], {
    env,
    stdout: "pipe",
    stderr: "pipe",
  });
  let [o, s, z] = await Promise.all([
    new Response(p.stdout).text(),
    new Response(p.stderr).text(),
    p.exited,
  ]);
  return { o: o.trim(), s: s.trim(), z };
}
async function aws(a: string[]) {
  let r = await run("aws", [
    "--profile",
    runtimeOptions.profile,
    "--region",
    runtimeOptions.region,
    ...a,
  ]);
  if (r.z)
    fail(
      "AWS 명령이 실패했습니다" + (r.s ? ": " + r.s.replace(/\s+/g, " ") : ""),
    );
  return r.o;
}
async function main() {
  const options = args(process.argv.slice(2));
  runtimeOptions = options;
  let sql = options.sql;
  if (options.m === "file") {
    try {
      sql = await Bun.file(options.file).text();
    } catch {
      fail("SQL 파일을 읽을 수 없습니다: " + options.file);
    }
  } else if (options.m === "stdin") {
    if (process.stdin.isTTY) fail("SQL 입력이 필요합니다.");
    sql = await new Response(Bun.stdin.stream()).text();
  }
  if (options.m !== "check") validateSql(sql);
  for (const command of ["aws", "psql"])
    if (!Bun.which(command)) fail(command + " 명령을 찾을 수 없습니다.");
  const profiles = await run("aws", ["configure", "list-profiles"]);
  if (profiles.z || !profiles.o.split(/\r?\n/).includes(options.profile))
    fail("vivident AWS 프로필을 확인할 수 없습니다.");
  let identity: unknown;
  try {
    identity = JSON.parse(
      await aws(["sts", "get-caller-identity", "--output", "json"]),
    );
  } catch {
    fail("AWS caller identity 결과를 해석할 수 없습니다.");
  }
  if (
    !identity ||
    typeof identity !== "object" ||
    !("Arn" in identity) ||
    !("Account" in identity)
  )
    fail("AWS caller identity를 확인할 수 없습니다.");
  let data: {
    DBProxies?: Array<{
      DBProxyName?: string;
      Endpoint?: string;
    }>;
  } = {};
  try {
    data = JSON.parse(
      await aws(["rds", "describe-db-proxies", "--output", "json"]),
    );
  } catch {
    fail("RDS Proxy 조회 결과를 해석할 수 없습니다.");
  }
  if (!data || !Array.isArray(data.DBProxies))
    fail("RDS Proxy 조회 결과 형식이 올바르지 않습니다.");
  const matches = data.DBProxies!.filter((proxy) =>
    proxy.DBProxyName?.startsWith(options.proxyPrefix!),
  );
  if (!matches.length) fail("지정한 RDS Proxy를 찾을 수 없습니다.");
  if (matches.length > 1) fail("지정한 RDS Proxy가 여러 개 조회되었습니다.");
  const match = matches[0];
  if (!match?.Endpoint || !/^[a-zA-Z0-9.-]+$/.test(match.Endpoint))
    fail("RDS Proxy endpoint가 올바르지 않습니다.");
  const host = match.Endpoint!;
  let addresses: Array<{
    address: string;
    family: number;
  }> = [];
  try {
    addresses = await lookup(host, {
      all: true,
      family: 4,
    });
  } catch {
    fail("Proxy DNS 해석에 실패했습니다.");
  }
  if (
    !addresses.length ||
    !addresses.every((x) =>
      /^(10\.|192\.168\.|172\.(1[6-9]|2[0-9]|3[01])\.)/.test(x.address),
    )
  )
    fail("Proxy가 사설 IPv4로 해석되지 않습니다.");
  await new Promise<void>((resolve, reject) => {
    const socket = createConnection({ host, port: PORT });
    const timer = setTimeout(() => {
      socket.destroy();
      reject(new Error("timeout"));
    }, 5000);
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
  }).catch((error) =>
    fail(
      error.message === "timeout"
        ? "RDS Proxy 연결 시간 초과: Tailscale 상태와 광고 경로를 확인하세요."
        : "RDS Proxy 네트워크 연결에 실패했습니다.",
    ),
  );
  const token = await aws([
    "rds",
    "generate-db-auth-token",
    "--hostname",
    host,
    "--port",
    String(PORT),
    "--username",
    options.dbUser!,
  ]);
  if (!token) fail("IAM 인증 토큰이 비어 있습니다.");
  const conn =
    "host=" +
    host +
    " port=" +
    PORT +
    " dbname=" +
    options.dbName +
    " user=" +
    options.dbUser +
    " sslmode=require";
  const pgEnv = {
    ...process.env,
    PGPASSWORD: token,
    PGOPTIONS: undefined,
    PGSERVICE: undefined,
    PGSERVICEFILE: undefined,
    PGCONNECT_TIMEOUT: "15",
  };
  const check = await run(
    "psql",
    [
      conn,
      "--no-password",
      "--no-psqlrc",
      "--pset",
      "pager=off",
      "--set",
      "ON_ERROR_STOP=1",
      "--tuples-only",
      "--no-align",
      "--command",
      "BEGIN TRANSACTION READ ONLY; SELECT current_database(), current_user, current_setting('transaction_read_only'); ROLLBACK;",
    ],
    pgEnv,
  );
  if (check.z)
    fail(
      "IAM PostgreSQL 연결 검증에 실패했습니다. AWS·DB 사용자 권한과 네트워크를 확인하세요.",
    );
  const rows = check.o
    .split(/\r?\n/)
    .map((x) => x.trim())
    .filter((x) => x && x !== "BEGIN" && x !== "ROLLBACK");
  if (
    rows.length !== 1 ||
    rows[0] !== options.dbName + "|" + options.dbUser + "|on"
  )
    fail("예상한 DB·사용자·읽기 전용 상태가 아닙니다.");
  console.error("RDS 연결 및 읽기 전용 검증 성공");
  if (options.m === "check") return;
  const body =
    "BEGIN TRANSACTION READ ONLY;\n" +
    (options.t ? "SET LOCAL statement_timeout = " + options.t + ";\n" : "") +
    sql +
    "\n;\nROLLBACK;";
  const child = Bun.spawn(
    [
      Bun.which("psql")!,
      conn,
      "--no-password",
      "--no-psqlrc",
      "--pset",
      "pager=off",
      "--set",
      "ON_ERROR_STOP=1",
      "--file",
      "-",
    ],
    {
      env: pgEnv,
      stdin: new TextEncoder().encode(body),
      stdout: "inherit",
      stderr: "inherit",
    },
  );
  process.exit(await child.exited);
}
if (import.meta.main) await main();
export { args, validateSql };
