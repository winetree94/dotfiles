# Local Hosts and CI Runners

## Local infrastructure

Check these SSH aliases against current local SSH configuration before use.

| Device | SSH alias | Configuration ownership |
| --- | --- | --- |
| Home OPNsense | `opnsense` | Device configuration; no canonical configuration repository confirmed |
| OpenMediaVault NAS | `openmediavault` | Device configuration; no canonical configuration repository confirmed |
| Proxmox host | `xeon` | Device configuration; no canonical configuration repository confirmed |
| Homelab K3s host | `homelab` | `~/Workspaces/tinyrack/homelab/ansible` for supported host preparation |
| Dual Intel Arc Pro B70 server | `ubuntu-gpu` | `~/Workspaces/tinyrack/ubuntu-b70` through Ansible |

The SSH aliases and corresponding homelab proxy manifests identify these devices. They do not establish a GitOps management mechanism for the appliances. Inspect the actual configuration and supported management interface before planning changes; do not invent a repository, assume every local machine is managed here, or edit generated appliance files blindly. Identify backups and recovery access before network or storage changes that could interrupt access or data availability.

OPNsense must deny direct external access to itself and local services. Keep administration on trusted internal/private connections. Open inbound port forwarding only for required VPN endpoints; determine their ports and protocols from existing VPN configuration and do not add web, SSH, NAS, or hypervisor exceptions. Public services use outbound Cloudflare Tunnel, with Cloudflare-side settings managed through `cf`. Recovery access must preserve this boundary.

General workstation configuration belongs to `~/Workspaces/winetree94/dev-machines`; use `development-machines` for its Ansible provisioning, configuration, and updates. The CI tooling below has separate ownership even when a machine also serves as a workstation.

## OpenMediaVault NAS and storage

Garage and Syncthing are Docker-hosted on `ssh openmediavault` (NAS address `10.132.245.8`). These are host services, not Kubernetes workloads.

- Garage containers are `garage-garaged-1` and `garage-webui`; Syncthing runs as `syncthing`. Discover current Compose sources using the containers' `com.docker.compose.project.working_dir` and `com.docker.compose.project.config_files` labels, including override files, rather than editing a running container.
- The mounted data disk contains `docker-configs/garage`, `docker-configs/syncthing`, `docker-data/garaged/{meta,data,garage.toml}`, and `docker-data/syncthing/config`. Syncthing maps the disk's `winetree94-nas` directory to `/data`. Resolve the actual `/srv/dev-disk-by-uuid-*` mount through `findmnt` and container mounts rather than guessing a disk UUID.
- Garage uses region `home` and replication factor `1`; replication is not an offsite backup. Its host configuration is mounted as `/etc/garage.toml`. Inspect only required non-secret fields, not full configuration/environment dumps.
- Homelab's `apps/base/proxies/garage.proxy.yaml` routes `storage.intranet.winetree94.com` and bucket subdomains through Traefik to NAS port `3900`. The same manifest routes the Garage console to `3909` and website hosting to `3902`; inspect its sibling Cilium policy for connectivity changes. Manage buckets/objects with `rclone homelab_garage:`, following the main skill, not by editing Garage's data files.

### Offsite backups

`/etc/borgmatic/config.yaml` configures Borg over SSH to a Hetzner Storage Box (`your-storagebox.de`, port `23`, repository path `/./borg-repository`), not Hetzner S3 object storage. Resolve the account-specific hostname from the current config. Read `borgmatic.timer` and the Borgmatic configuration for the current schedule and retention policy.

Resolve backup sources from `/etc/borgmatic/config.yaml` and disk mounts from `findmnt`. Borgmatic provides file-level backups; do not infer whole-machine or OS-disk coverage from a NAS data-disk source. Check source expansion, exclusions, mount state, and database/application consistency before asserting complete coverage. Check recent backup results and available restore-test evidence separately; a successful backup job does not prove recoverability.

Use read-only timer/service status and configuration inspection for diagnosis. Backup creation, pruning, consistency checks with repair, and restores are separate operations, not part of a documentation check. Keep NAS disk backups distinct from the cluster's CNPG and Longhorn backups stored inside Garage.

## Xeon Proxmox host

`ssh xeon` is the hypervisor for the homelab cluster and virtualized CI machines. Use this guest mapping to locate the relevant configuration owner:

| VM ID | Guest | Guest configuration owner |
| --- | --- | --- |
| `100` | `homelab` | Homelab GitOps repository and its host-preparation Ansible |
| `101` | `windows-ci` | Personal GitHub Actions Ansible repository below |
| `102` | `ubuntu-ci` | Personal GitHub Actions Ansible repository below |

Recheck `qm list`, `pct list`, and the selected guest's configuration before operations; VM IDs and runtime state can change. Do not infer that every CI inventory host, such as `macmini`, is a Proxmox guest.

Proxmox owns VM hardware, disks, and lifecycle; the guest repositories own their OS/workloads. Resolve guest disk placement from the selected VM configuration and current Proxmox storage configuration, including `local-lvm`. Proxmox storage `nas` is a CIFS mount of the NAS's `proxmox` share at `/mnt/pve/nas`, configured for backups and other content. A configured backup destination does not prove a scheduled or successful VM backup. Check current storage, backup jobs, and guest activity before host maintenance or disk/VM changes.

## Intel B70 GPU server

`ssh ubuntu-gpu` is a separate Ubuntu GPU/LLM server with two Intel Arc Pro B70 cards, managed by `~/Workspaces/tinyrack/ubuntu-b70`. Inspect the current OS version, GPU inventory, and Docker/Alloy service status when needed for diagnosis.

Make persistent changes through this repository's Ansible and Git workflow, not ad hoc SSH edits. Read its `AGENTS.md`, README, Makefile, inventory, affected roles, and selected `profiles/<model>/` manifest/Compose files. Profiles own pinned model revisions, checksums, and container images; inspect current configuration instead of assuming a fixed inference model or GPU parallelism mode.

Use `make models` to discover profiles. The documented deployment workflow is `make verify`, `make ping`, `make check MODEL=<profile>`, then `make apply MODEL=<profile>`; `apply` runs the validation sequence and `test-api` itself. These are deployment instructions, not commands to run during read-only inspection. Retain the repository's encrypted Ansible Vault/become integration. Firewall and TLS management are outside this repository.

Alloy exports host, inference, and per-GPU metrics to the shared monitoring backend; dashboard changes belong to homelab Grafana through `gcx`. Benchmark/experiment targets can replace the live inference service and interrupt API traffic: use an explicitly planned maintenance window and the repository's recovery procedure, not a benchmark as a harmless health check.

## Personal GitHub Actions machines

Repository: `~/Workspaces/tinyrack/ansible-github-actions-runners`.

Read its README, Makefile, inventory, and affected role. The known machines are `ubuntu-ci`, `macmini`, and `windows-ci`; the inventory is authoritative for connection details and platform groups. These are `tinyrack-net` organization runners in the `homelab` group, not the Vivident runners.

- Make reproducible configuration changes through the existing Ansible roles/playbooks and Git workflow. Preserve the repository's Vault-based privilege escalation; never print vault secrets or commit plaintext credentials.
- Validate with the relevant `make syntax`, `make lint`, `make preflight`, and `make check` targets. Apply with an explicit inventory limit when appropriate, repeat the apply to verify idempotency, and use `make verify` to check tools, services, and GitHub online/group/label status.
- Custom labels use the `tinyrack-` prefix to avoid capturing workflows intended for GitHub-hosted runners. Inspect inventory for runner names and directories rather than copying a fixed runner count.
- `make update` is a separate, intentional package-maintenance operation. It does not reboot; report pending reboots. Check job activity and macmini workstation use before updates that can replace in-use tools or apps.
- Decommissioning requires both the host and runner identity (or explicit `all`). Follow the README's check/decommission flow on idle runners, then remove the inventory entry so a later apply does not recreate them. Do not decommission as a side effect of diagnosis.

Human-only prerequisites such as Apple ID sign-in remain delegated as documented in the repository. Read current instructions instead of reproducing obsolete platform setup steps.
