# Sentry 관리

운영 서비스의 오류·성능·네이티브 크래시를 Sentry 로 추적한다.
Sentry 조직 slug 는 `vivident` 이며, 저장소에서 확인되는 주요 프로젝트는 다음과 같다.
Sentry 설정 변경이나 이벤트 조회는 Sentry 웹 콘솔 또는 `sentry-cli`를 사용한다.

## 인증과 대상 확인

작업 전에 Sentry CLI가 설치되어 있고, `dev@vivident.xyz` 계정으로 로그인 되어 있는지 확인한다.

```bash
$ sentry-cli --version

$ sentry-cli info
Sentry Server: https://sentry.io
Default Organization: -
Default Project: -

Authentication Info:
  Method: Auth Token
  User: dev@vivident.xyz
```

인증이 없거나 다른 계정으로 로그인되어 있으면 작업을 중단하고, 사용자에게 인증 절차를 인증한다.

```bash
$ sentry-cli login
```

## 사용 방법

Sentry 명령어 사용 시 조직과 프로젝트를 반드시 명시해 사용한다. 기본 설정을 신뢰하지 않는다.
조직명은 반드시 `vivident`를 사용한다.

```bash
sentry-cli --org vivident --project <project> <command>
```

조직의 프로젝트 목록은 다음의 명령어로 확인한다.

## 이벤트·릴리스 확인

오류를 조사할 때는 먼저 Sentry 콘솔에서 프로젝트와 환경(`development`, `staging`, `production` 등)을 확인한다.

