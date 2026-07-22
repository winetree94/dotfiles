---
name: gitops-kubernetes-operations
description: Resolve the user's known projects, services, Kubernetes contexts, and host aliases to canonical repositories and environments, and perform Kubernetes, GitOps, or infrastructure diagnosis and changes through a safe repository-first workflow. Use when a request names a Tinyrack or Vivident project, service, mapped context, or host without a path; asks where a project lives; or involves Kubernetes, Helm, Kustomize, GitOps reconciliation, infrastructure configuration, or live cluster or host inspection.
---

# GitOps and Kubernetes Operations

## Resolve the target

Read [references/environments.md](references/environments.md) before selecting a repository, Kubernetes context, or host for a known project or service.

- Treat an explicit path, context, or host supplied by the user as authoritative.
- Otherwise, resolve the target from the environment reference.
- Confirm the resolved repository, context, and host before running infrastructure commands.
- Do not infer an unconfirmed host alias from a matching project or context name.

## Follow the repository-first workflow

1. Inspect the target repository, current branch, working-tree status, and project instructions.
2. Use read-only cluster or host checks to establish current state and confirm symptoms.
3. Prefer changes in the mapped GitOps repository over direct `kubectl`, Helm, or host mutation.
4. Validate with the narrowest relevant checks, such as manifest rendering or diffing, Kustomize or Helm validation, repository tests, `kubectl get/describe/logs`, and service health checks.
5. Reconcile through the normal GitOps path and verify rollout or service health when the requested task includes implementation.

Use direct live mutation only when the user explicitly requests it or when an emergency response clearly requires it. State why a live mutation is necessary before performing it.

## Apply safety boundaries

- Separate observation commands from mutation commands in explanations and reports.
- Confirm the exact scope before destructive, privileged, irreversible, or production-impacting operations.
- Do not run destructive `kubectl`, Helm, Terraform, Ansible, `systemctl`, disk, network, or firewall operations against an ambiguous target.
- Do not ask for or expose sudo passwords by default. Prefer narrowly allowlisted passwordless commands or root-owned wrappers for recurring privileged node operations.
- Avoid printing or persisting secrets.
- Report whether the work was GitOps-only, live observation-only, or live mutation, and include the resolved target and verification evidence.
