# Role Development

Read the repository's current `AGENTS.md` and the affected tests for detailed conventions and package-specific exceptions. This reference records the structural rules, not a second package/version catalog.

## Structure and execution

- Use one role per user-facing application. Keep OS-wide prerequisites in the existing `platform_prerequisites` bundle and application-specific dependencies with their application.
- Use the existing `tasks/main.yml` OS dispatcher with `debian.yml`, `darwin.yml`, and `windows.yml`. Missing support is a missing OS file, not a substitute application or a shared `default.yml` fallback.
- Reuse `brew.yml` for meaningful Unix duplication. Keep shared helper roles such as `winget`, `brew_tap`, and `mas` in their established caller-driven form rather than inventing new dispatch layers.
- Register roles and matching tags in `playbooks/setup.yml` in dependency order. Preserve `always` tags for OS classification, GUI detection, and GUI grouping so filtered runs still work.
- Use `ansible_facts[...]` for remote identity, paths, and OS checks. Controller-side environment lookups are not target-host paths. Keep privilege escalation task-scoped; Homebrew tasks must not run as root.

## Installation and state

For new Ubuntu integrations, prefer the Ubuntu archive, then the vendor's signed APT repository; use Flathub for suitable GUI apps, then Snap, Homebrew formulae, and fetched official installers as the documented fallback order. Do not migrate unrelated existing roles solely to enforce this order. macOS normally uses core formulae/casks, vendor taps, then MAS; preserve documented vendor-artifact exceptions. Cross-platform version equality is not a goal.

Windows installs must use the shared winget role, including its community, Store, or checksum-pinned local-manifest paths. Do not invoke installers directly or reintroduce Chocolatey/Scoop. Third-party Homebrew taps use `brew_tap` so trust is established before loading the tap.

Reuse installed-state snapshots and their per-source facts rather than probing every package repeatedly. Retain fallback behavior when snapshots were skipped by tags. Follow existing role-specific update-mode behavior instead of making every ordinary apply a global upgrade. Keep direct downloads verifiable and idempotent; do not introduce piped remote shell installers.

Dotweave role changes must preserve its managed-repository identity checks, fast-forward-only updates, age-key handling, and cleanup of temporary identity files. Global agent instruction/skill paths remain subject to `agent-configuration` even when dotfiles are restored.

## Verification

Update the relevant `tests/validate_*.yml` in the same change as the roles they assert on. Cover OS support and intentional omissions, dependencies, tags, snapshot gates, check mode, and repeated-apply behavior where affected. Use existing focused tests rather than copying the full application matrix into the skill.

Run the unfiltered repository verification, then the main skill's scoped device workflow when deployment is requested. Validate supported platforms affected by a shared change when targets are available; distinguish static coverage from real platform testing. Do not claim cross-platform runtime validation from testing only one device.
