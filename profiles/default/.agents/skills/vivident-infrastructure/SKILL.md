---
name: vivident-infrastructure
description: Manage Vivident (비비던트) infrastructure, including the Argo CD intranet Kubernetes cluster, OPNsense routers, Caddy, Tailscale site routing, and company GitHub self-hosted runners. Use for vivident-intranet, vivident-firewall, vivident-firewall-legacy, intranet.moelive.tech services, or vivident intranet and ansible-actions-runner repositories. The homelab-hosted vivident-tailscale-router belongs to homelab-infrastructure.
---

# Vivident Infrastructure

## Intranet Kubernetes

Company intranet services run on a self-hosted Kubernetes cluster.

| Resource | Target |
| --- | --- |
| Kubernetes context | `vivident-intranet` |
| GitOps repository | `~/Workspaces/vivident/intranet` |
| Cluster host | `ssh vivident-intranet` |

Honor explicit user targets; otherwise use this mapping and state the resolved target before infrastructure commands. Service names such as n8n or SearXNG can exist in other environments; determine the intended deployment before choosing a cluster. The `vivident/eevee` application repository is not the intranet GitOps source.

Use `kubectl --context vivident-intranet ...` to target the cluster explicitly. The standard command to switch the current context is:

```sh
kubectl config use-context vivident-intranet
```

- Inspect repository instructions, README, branch, and working-tree changes before editing. Preserve unrelated changes. All persistent Kubernetes resources must be managed and delivered through this GitOps repository.
- Do not directly apply or otherwise mutate persistent cluster resources with kubectl, Helm, or another live API client. Only temporary debugging work is an exception; keep it scoped and remove temporary resources afterward.
- Use read-only cluster queries and SSH inspection for diagnosis. For changes, edit the repository, validate the relevant manifests, follow its existing GitOps delivery process, and verify reconciliation and service health.
- If work on the cluster host requires sudo, delegate those commands to the user. Explain the purpose and provide the exact commands, then use the returned results to continue. Do not run sudo yourself, including passwordless sudo, or bypass this rule with another privileged execution path.
- These Vivident-specific rules take precedence over generic guidance that permits emergency live mutation or passwordless privileged host commands.

### Argo CD and validation

This repository uses Argo CD, not Flux. The `apps/overlays/production` and `infra/overlays/production` directories define Argo CD Applications, generally referencing the corresponding `apps/base/<name>` and `infra/base/<name>` directories. Read each affected Application's source, target revision, destination, and sync policy; some use Helm sources or multiple sources rather than a local base.

Render the changed Kustomize base with `kubectl kustomize` when applicable and validate the Application or Helm configuration separately. Do not assume overlay directories are Kustomize roots. Deliver through the repository's Git workflow and verify Argo CD's reconciled revision, Sync/Health status, workload rollout, and service health. Do not bypass GitOps by applying the rendered manifests directly. Bootstrap or recovery requires its own scoped procedure; privileged cluster-host steps still belong to the user.

Seal new secrets with the repository's `vivident-intranet.key.pub` certificate before committing. Inspect resource kinds because encrypted SealedSecrets may use ordinary secret filenames. Never print or commit plaintext credentials or private sealing keys.

## Object storage

Manage buckets and objects through `rclone`. Live CNPG ObjectStores and the Longhorn BackupTarget checked on 2026-09-16 use AWS S3 bucket `vivident-intranet`, region `ap-northeast-2`, endpoint `https://s3.ap-northeast-2.amazonaws.com`. Database backup prefixes are under `apps/` and `infra/`; Longhorn uses `longhorn/`. Read the current ObjectStore/BackupTarget for the exact prefix before operations.

Use the configured `vivident_intranet_s3:` rclone remote for this bucket. It uses `type = s3`, `provider = Other`, `env_auth = true`, region `ap-northeast-2`, the AWS endpoint above, and private object/bucket ACLs. Supply the appropriate AWS credentials through the environment without printing or persisting them in this skill or Git; do not substitute Garage or Hetzner remotes or assume shared credentials.

| Purpose | rclone path |
| --- | --- |
| Application database backups | `vivident_intranet_s3:vivident-intranet/apps/` |
| Infrastructure database backups | `vivident_intranet_s3:vivident-intranet/infra/` |
| Longhorn backups | `vivident_intranet_s3:vivident-intranet/longhorn/` |

For a scoped read-only listing, use `rclone lsf vivident_intranet_s3:vivident-intranet/apps/ --dirs-only`. Keep bucket access private and scope operations to the requested prefix. Kubernetes backup configuration still goes through GitOps, and database/volume restoration uses its owning operator's recovery procedure.

## Network and Reverse Proxy

Both company routers run OPNsense. Use the main router unless the user specifies the legacy site or the task clearly targets its subnet.

| Site | SSH access | Internal subnet |
| --- | --- | --- |
| Main, default | `ssh vivident-firewall` | `10.78.0.0/16` |
| Legacy, physically separate network | `ssh vivident-firewall-legacy` | `10.79.0.0/16` |

Retain relevant private/internal IP addresses and subnet CIDRs in this skill and its references. Do not record external public IP addresses or public address ranges. Identify public-facing resources by context, SSH alias, or hostname and resolve their addresses from current configuration when needed. Verify internal addresses and subnets against current router or repository configuration before changes.

The routers are linked through Tailscale, allowing routing between the two networks. Do not treat them as a single local subnet or assume the legacy router serves the main site's proxy configuration.

Intranet services are reverse-proxied by Caddy on the main router to Kubernetes. Example hostname: `outline.k8s.intranet.moelive.tech`.

For service connectivity problems, inspect the relevant DNS resolution, client route, OPNsense firewall and Tailscale routing, main-router Caddy configuration, and Kubernetes service/endpoints. Determine which hop fails before making changes. Discover actual proxy upstreams and deployment configuration from current state; do not invent IP addresses, ports, namespaces, or configuration paths.

The `vivident-tailscale-router` workload on the personal homelab is owned by `homelab-infrastructure`, in context `homelab`. Load that skill when investigating the home side of company connectivity. Do not select the company cluster just because the workload name contains Vivident.

## GitHub Self-Hosted Runners

Manage self-hosted runner machines with Ansible from:

```text
~/Workspaces/vivident/ansible-actions-runner
```

- SSH may be used for read-only diagnosis. Do not make ad hoc machine changes over SSH.
- Implement machine changes in this repository's Ansible inventory, playbooks, roles, or templates, following its existing conventions. Do not substitute manual shell changes for Ansible-managed configuration.
- Inspect the inventory to identify the intended machines, validate the affected Ansible configuration, and apply through the repository's documented Ansible workflow. Use check/diff mode where supported, without exposing secrets.
- Commit and push the task's Ansible changes to preserve reproducibility and idempotency. Preserve unrelated working-tree changes. If push or execution is blocked, report what remains incomplete.
- Verify runner health after applying and check idempotency where practical.

Use the runner inventory for host aliases; the personal `tinyrack/ansible-github-actions-runners` repository is a different environment owned by `homelab-infrastructure`. The cluster-host sudo delegation rule above is not a blanket prohibition on the runner repository's existing Ansible privilege escalation.

Report the resolved target, Git changes, any temporary debugging or device changes, and verification evidence. Confirm the exact scope of destructive or production-impacting operations before execution; avoid exposing secrets in all modes.
