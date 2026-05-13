# winetree94 Kubernetes context map

Use this reference for this user's Kubernetes/GitOps work. Default to GitOps repository edits for Kubernetes changes unless the user explicitly asks for an imperative emergency change.

| kubeconfig context | GitOps repository | Host alias from `~/.ssh/config` |
| --- | --- | --- |
| `homelab` | `~/Workspaces/tinyrack/homelab` | `xeon` |
| `homelab-proxy` | `~/Workspaces/tinyrack/proxy` | `proxy-server` |
| `mail-server` | `~/Workspaces/tinyrack/mail-server` | `mail-server` |
| `tinyrack` | `~/Workspaces/tinyrack/infrastructure` | `tinyrack-server` |
| `vivident-intranet` | `~/Workspaces/vivident/eevee` | no explicit alias found in `~/.ssh/config` during the session |

Notes:
- The repo mapping came from kubeconfig context discovery plus existing `~/Workspaces` layout.
- Host aliases came from `~/.ssh/config`; re-read that file if a connection fails or the mapping may have changed.
- Avoid storing private key paths or hostnames in the skill; use configured aliases instead.
