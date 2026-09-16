# Local Hosts and CI Runners

## Local infrastructure

These SSH aliases were verified against local SSH configuration; check current configuration before use.

| Device | SSH alias | Configuration ownership |
| --- | --- | --- |
| Home OPNsense | `opnsense` | Device configuration; no canonical configuration repository confirmed |
| OpenMediaVault NAS | `openmediavault` | Device configuration; no canonical configuration repository confirmed |
| Proxmox host | `xeon` | Device configuration; no canonical configuration repository confirmed |
| Homelab K3s host | `homelab` | `~/Workspaces/tinyrack/homelab/ansible` for supported host preparation |

The SSH aliases and corresponding homelab proxy manifests identify these devices. They do not establish a GitOps management mechanism for the appliances. Inspect the actual configuration and supported management interface before planning changes; do not invent a repository, assume every local machine is managed here, or edit generated appliance files blindly. Identify backups and recovery access before network or storage changes that could interrupt access or data availability.

OPNsense must deny direct external access to itself and local services. Keep administration on trusted internal/private connections. Open inbound port forwarding only for required VPN endpoints; determine their ports and protocols from existing VPN configuration and do not add web, SSH, NAS, or hypervisor exceptions. Public services use outbound Cloudflare Tunnel, with Cloudflare-side settings managed through `cf`. Recovery access must preserve this boundary.

General workstation configuration belongs to `~/Workspaces/winetree94/dev-machines`; read its instructions when a task actually targets that repository. The CI tooling below has separate ownership even when a machine also serves as a workstation.

## Personal GitHub Actions machines

Repository: `~/Workspaces/tinyrack/ansible-github-actions-runners`.

Read its README, Makefile, inventory, and affected role. The known machines are `ubuntu-ci`, `macmini`, and `windows-ci`; the inventory is authoritative for connection details and platform groups. These are `tinyrack-net` organization runners in the `homelab` group, not the Vivident runners.

- Make reproducible configuration changes through the existing Ansible roles/playbooks and Git workflow. Preserve the repository's Vault-based privilege escalation; never print vault secrets or commit plaintext credentials.
- Validate with the relevant `make syntax`, `make lint`, `make preflight`, and `make check` targets. Apply with an explicit inventory limit when appropriate, repeat the apply to verify idempotency, and use `make verify` to check tools, services, and GitHub online/group/label status.
- Custom labels use the `tinyrack-` prefix to avoid capturing workflows intended for GitHub-hosted runners. Inspect inventory for runner names and directories rather than copying a fixed runner count.
- `make update` is a separate, intentional package-maintenance operation. It does not reboot; report pending reboots. Check job activity and macmini workstation use before updates that can replace in-use tools or apps.
- Decommissioning requires both the host and runner identity (or explicit `all`). Follow the README's check/decommission flow on idle runners, then remove the inventory entry so a later apply does not recreate them. Do not decommission as a side effect of diagnosis.

Human-only prerequisites such as Apple ID sign-in remain delegated as documented in the repository. Read current instructions instead of reproducing obsolete platform setup steps.
