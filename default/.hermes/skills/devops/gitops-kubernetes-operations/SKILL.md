---
name: gitops-kubernetes-operations
description: "Operate Kubernetes clusters through GitOps: diagnose live state, edit manifests, push changes, reconcile with Flux, and verify rollout."
version: 1.0.0
author: Hermes Agent
license: MIT
platforms: [linux, macos]
metadata:
  hermes:
    tags: [gitops, kubernetes, flux, cnpg, troubleshooting, deployment]
    related_skills: [systematic-debugging, opencode, github-pr-workflow]
---

# GitOps Kubernetes Operations

## When to Use

Use this skill when the user asks to inspect, fix, migrate, or deploy Kubernetes resources that are managed by GitOps, especially with Flux and repository manifests.

Examples:
- "Flux/kubectl로 동기화 상태 봐줘"
- "GitOps 방식으로 고쳐줘"
- "클러스터 리소스 문제 진단하고 repo에 반영해줘"
- CNPG, HelmRelease, Kustomization, object storage backup, or controller migration work

## Core Rule

**Live-cluster fixes must flow back through Git unless the user explicitly asks for an emergency imperative patch.**

For GitOps-managed resources:
1. Diagnose live state with `kubectl`/`flux`.
2. Find the owning repo/path from Flux objects and labels.
3. Edit manifests in the repo.
4. Validate local render.
5. Commit/push if the user asked for actual GitOps completion.
6. Reconcile Flux.
7. Verify the live cluster, not just the commit.

## Standard Workflow

### 1. Confirm Context and Ownership

For winetree94's clusters, first check `references/winetree94-cluster-map.md` for the known kube context → GitOps repository → host alias mapping. Treat that reference as a starting point, then verify live context and repo state before making changes.

```bash
kubectl config current-context
kubectl get nodes
flux get kustomizations -A
flux get sources git -A
```

For a resource, inspect labels/owner GitOps path:

```bash
kubectl get <kind> <name> -n <ns> -o yaml | sed -n '1,120p'
```

Look for labels such as:

```yaml
kustomize.toolkit.fluxcd.io/name: <flux-kustomization>
kustomize.toolkit.fluxcd.io/namespace: flux-system
```

Then inspect the Flux Kustomization:

```bash
kubectl get kustomization.kustomize.toolkit.fluxcd.io -n flux-system <name> -o yaml
```

### 2. Diagnose Before Editing

Gather evidence first:

```bash
kubectl get pods -A --field-selector=status.phase!=Running,status.phase!=Succeeded -o wide
kubectl get events -A --sort-by=.lastTimestamp | tail -n 80
flux get all -A --status-selector ready=false
```

For CRDs/controllers:

```bash
kubectl get <crd-kind> -A
kubectl describe <resource> -n <ns> <name>
kubectl logs -n <ns> deploy/<controller> --since=1h
```

### 3. Edit Manifests in the Repo

Prefer the user's project layout and existing conventions. If coding edits are non-trivial and the user prefers OpenCode, delegate bounded manifest changes to OpenCode, then inspect/verify the diff yourself.

Preserve unrelated dirty files. Before editing:

```bash
git status --short --branch
git diff -- <possibly-unrelated-file>
```

Stage only intentional files.

### 4. Validate Locally

Render the exact kustomize paths Flux applies:

```bash
kubectl kustomize infrastructure/base/<component> >/tmp/component.yaml
kubectl kustomize apps/base/<app> >/tmp/app.yaml
git diff --check
```

Use server-side dry-run when CRDs already exist or after rendering an installer bundle that includes the CRDs:

```bash
kubectl apply --server-side --dry-run=server --field-manager=kustomize-controller -f /tmp/component.yaml
```

Pitfall: plain `kubectl apply --dry-run=server` on large CRDs can fail due to `last-applied-configuration` annotation size or field-manager conflicts. Prefer server-side apply dry-run with `--field-manager=kustomize-controller` for Flux-managed resources.

### 5. Commit, Push, Reconcile

When the user asks to complete GitOps work, commit and push the manifest changes.

```bash
git add <intentional-files>
git commit -m "fix: describe gitops change"
git push origin HEAD
```

Then reconcile in dependency order:

```bash
flux reconcile source git flux-system -n flux-system
flux reconcile kustomization <infra-parent> -n flux-system --with-source
flux reconcile kustomization <component> -n flux-system --with-source
flux reconcile kustomization <app> -n flux-system --with-source
```

### 6. Verify Live State

Do not stop at `applied revision`. Verify the actual controllers/pods/conditions:

```bash
flux get kustomizations -A
kubectl get pods -A --field-selector=status.phase!=Running,status.phase!=Succeeded -o wide
kubectl wait --for=condition=Ready <resource> -n <ns> <name> --timeout=300s
kubectl get <resource> -n <ns> <name> -o json | jq '{conditions:.status.conditions}'
```

For backups or migrations, perform one safe verification action if appropriate (e.g. on-demand backup) and wait for completion.

## CNPG Barman Cloud Plugin Migration

For CloudNativePG clusters moving from in-tree `barmanObjectStore` to the Barman Cloud plugin, see `references/cnpg-barman-cloud-plugin-migration.md`.

## MariaDB Operator HelmRelease Restore Stalls

For `mariadb-operator` HelmReleases stuck because a MariaDB CR is `Restoring backup` / `RestoreBackup`, see `references/mariadb-operator-helmrelease-restore-stalls.md`. In particular, render the chart to check whether `backups[].name` is prefixed differently from `mariadb.bootstrapFrom.backupRef.name`, and remember that stale Restore CRs plus Helm `RetriesExceeded` may require cleanup and remediation retries after the GitOps values are fixed.

## Database Operator Upgrades

For coordinated CNPG, Barman Cloud Plugin, MariaDB Operator, CRD, and `mariadb-cluster` chart upgrades, see `references/database-operator-upgrades.md`. Key pitfall: before upgrading `mariadb-cluster`, compare live immutable fields with rendered chart output; newer charts may default `rootPasswordSecretKeyRef.generate: true`, while existing clusters may require an explicit `generate: false` to avoid immutable-field upgrade failures.

## Pitfalls

For Flux/HelmRelease failures around MariaDB Operator resources stuck in `Restoring backup`, `InProgress`, or `Backup not found`, see `references/mariadb-operator-restore-debugging.md`. In particular, the `mariadb-cluster` Helm chart prefixes generated `Backup` resource names with the release fullname, while `mariadb.bootstrapFrom.backupRef.name` is passed through verbatim; always compare rendered names against the live `Restore` error before proposing a fix.

## Pitfalls

- A Flux Kustomization can be `Ready=True` while an application-level function such as backups is broken. Check domain-specific CR conditions.
- Old failed CRs may remain after the fix; distinguish stale historical failures from new plugin-based resources.
- Plugin/controller installation may add sidecars and roll pods. Wait for the workload to return to Ready before testing.
- Scheduled resources only prove future runs. Trigger an on-demand operation when you need immediate proof that the new path works.
- In repos with disabled/commented overlay entries, base-manifest changes may be valid but not live. Verify rendered production overlays and live resources before calling something deployed.
- Do not record transient cluster revision, PR number, or backup object names as persistent memory; keep those in the session/report only.

## Success Criteria

A GitOps Kubernetes fix is complete when:
- The intended manifests are committed and pushed, if requested.
- Flux has reconciled the pushed revision.
- Relevant controllers/pods/CR conditions are healthy.
- A domain-specific verification confirms the original failure mode is gone.
