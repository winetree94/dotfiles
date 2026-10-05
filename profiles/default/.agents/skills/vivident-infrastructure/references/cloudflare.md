# Cloudflare

회사의 도메인, DNS, 서버리스 인프라는 Cloudflare 로 운영한다.
Cloudflare 관리는 `cf` CLI 도구를 사용해 관리하며, `vivident` Auth 프로필을 사용해야 한다.

작업 전 반드시 다음처럼 `vivident` 프로필인지를 점검한다.

```bash
$ cf auth whoami
🍊☁️  cf · v0.8.0
─────────────────
Active profile: vivident
```

프로필이 다른 경우 `vivident` 의 존재를 점검하고 활성화한 후 이어서 진행한다.

```bash
# 인증된 Auth 프로필 목록 확인
$ cf auth list

# vivident Auth 프로필 활성화
$ cf auth activate vivident
```

`vivident` Auth 프로필이 없거나 인증이 만료된 경우, 작업을 중단하고 사용자에게 다음의 인증 절차를 안내한다.

```
# Auth Context 생성 및 로그인
$ cf auth create vivident
```

