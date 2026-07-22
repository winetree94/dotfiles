# Project and Environment Mappings

Use `~/Workspaces` as the project root unless the user provides another path.

## Projects

| Project | Repository | Kubernetes context | Host alias | Durable conventions |
| --- | --- | --- | --- | --- |
| `tinyrack/auth` | `~/Workspaces/tinyrack/auth` | - | - | Authentication-related Tinyrack repository. |
| `tinyrack/tinyauth` | `~/Workspaces/tinyrack/tinyauth` | - | - | Respond in Korean unless requested otherwise. Trust and commit MikroORM-generated compiled-functions artifacts when builds regenerate them. |
| `tinyrack/dotweave` | `~/Workspaces/tinyrack/dotweave` | - | - | Use strict TDD and report RED/GREEN evidence. Normalize profile names with trim-only semantics; do not lowercase them. |
| `tinyrack/homelab` | `~/Workspaces/tinyrack/homelab` | `homelab` | `xeon` | Homelab Kubernetes GitOps repository. |
| `tinyrack/proxy` | `~/Workspaces/tinyrack/proxy` | `homelab-proxy` | `proxy-server` | Proxy Kubernetes GitOps repository. |
| `tinyrack/mail-server` | `~/Workspaces/tinyrack/mail-server` | `mail-server` | `mail-server` | Mail-server Kubernetes and GitOps repository. |
| `tinyrack/infrastructure` | `~/Workspaces/tinyrack/infrastructure` | `tinyrack` | `tinyrack-server` | Tinyrack infrastructure repository. |
| `vivident/eevee` | `~/Workspaces/vivident/eevee` | `vivident-intranet` | Unconfirmed | Do not assume `vivident-intranet` is a valid SSH host alias without checking current configuration. |
| `winetree94/dev-machines` | `~/Workspaces/winetree94/dev-machines` | - | - | Development-machine configuration repository. |

## Context lookup

| Kubernetes context | Repository | Host alias |
| --- | --- | --- |
| `homelab` | `~/Workspaces/tinyrack/homelab` | `xeon` |
| `homelab-proxy` | `~/Workspaces/tinyrack/proxy` | `proxy-server` |
| `mail-server` | `~/Workspaces/tinyrack/mail-server` | `mail-server` |
| `tinyrack` | `~/Workspaces/tinyrack/infrastructure` | `tinyrack-server` |
| `vivident-intranet` | `~/Workspaces/vivident/eevee` | Unconfirmed |
