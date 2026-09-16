---
name: development-machines
description: Manage personal development devices through Ansible in ~/Workspaces/winetree94/dev-machines. Use for developer tool installation, workstation configuration, package updates, new-device onboarding, and changes to this repository's roles or inventory on Ubuntu, macOS, Windows, and WSL. Excludes CI runner provisioning, NAS/Proxmox administration, and the ubuntu-b70 GPU server.
---

# Development Machines

## Resolve the target

Repository: `~/Workspaces/winetree94/dev-machines`. Read its current `AGENTS.md`, `readme.md`, Makefile, inventory, and relevant roles before work. Inspect branch and working-tree changes and preserve unrelated edits.

Resolve the requested device from the active `inventories/hosts.yml`, not a historical README table, SSH alias alone, or commented-out entry. Verify its OS group and applicable host variables; do not keep a second device/IP catalog in this skill. State the selected inventory hosts and intended change before remote execution. Ask for a target when it cannot be resolved from the request and context.

- For onboarding, connection setup, OS behavior, and WSL, read [references/platforms.md](references/platforms.md).
- For new tools, role changes, or cross-platform support, read [references/role-conventions.md](references/role-conventions.md).

Keep persistent workstation changes in this repository's Ansible, not ad hoc SSH commands. A request to install or configure something on a named device normally includes scoped application and verification. A code-only, planning, or diagnostic request does not authorize deployment.

## Change, apply, and verify

1. Inspect the selected role and its dependencies, current variables, and tests. Make the smallest reproducible repository change and update the relevant validation tests.
2. Run `make verify ANSIBLE_ARGS=` without host or tag filters. This covers syntax, local validation playbooks, and lint; filters can silently skip the local tests.
3. Run `make ping ANSIBLE_ARGS="--limit <host>"`, then `make check ANSIBLE_ARGS="--limit <host>"`. For a tool-specific change, add appropriate role/dependency tags to check and apply after inspecting their prerequisites. Keep connectivity checks unfiltered by role tags.
4. Review the check output for intended scope before `make apply ANSIBLE_ARGS="--limit <host>"` with the same selected tags. `apply` does not run `verify`, `ping`, or `check` automatically.
5. Repeat the same scoped apply to verify convergence, then check the requested tool or service actually works. Investigate repeated unexpected changes rather than assuming a successful exit proves idempotency. Report check-mode predictions separately from real execution evidence.

Always specify an inventory limit for remote actions. Use the explicit requested host set for multi-device work; do not touch the full inventory unless all devices were requested. Preview the actual task graph when tags are involved: shared tags can include GUI companions, and filtering out bootstrap dependencies can make a fresh-host run incomplete. Do not widen a single-tool task into full provisioning without establishing that the broader change is intended.

Check mode is a preview, not proof of a successful or idempotent apply. Some package-manager tasks cannot fully predict first-time installation. Do not silently bypass failed prerequisite checks by running a broad apply.

## Updates and other side effects

`make update-check ANSIBLE_ARGS="--limit <host>"` previews the update playbook; `make update ANSIBLE_ARGS="--limit <host>"` performs it. Updating reuses the setup graph with update mode enabled, repairs missing packages, and can upgrade whole package-manager inventories and Mise runtimes. Use this path only for an explicit update task, not as a substitute for ordinary installation. Inspect platform effects and active work before upgrades or restarts; do not assume update also authorizes a reboot.

The Dotweave role does more than install a CLI: it initializes or fast-forwards the managed dotfiles checkout and runs `dotweave pull --yes` to restore tracked files into the user's home. Account for that effect before including it. Preserve an inconsistent or divergent checkout for investigation rather than resetting it.

Retain repository changes for reproducibility. Commit and push only within the user's requested Git workflow. Report target hosts, changed roles/configuration, applied scope, convergence and functional checks, and outstanding human-only steps; distinguish code validation from device validation.

## Ownership boundaries

Use `homelab-infrastructure` for personal CI runner configuration, NAS/Proxmox, and `ubuntu-gpu` managed by `tinyrack/ubuntu-b70`; use `vivident-infrastructure` for company runners. A machine serving multiple roles does not transfer ownership of those configurations into this repository.

Installing an agent harness is workstation provisioning; changing shared global instructions or skills uses `agent-configuration`. Dotweave application development is separate from deploying its workstation role and is outside this skill.
