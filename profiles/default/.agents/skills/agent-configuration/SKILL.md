---
name: agent-configuration
description: Manage shared global agent instructions and skills across harnesses such as Codex and Claude. Use when creating, editing, installing, moving, or repairing global AGENTS.md/CLAUDE.md files, global skills, or their discovery links. Keep canonical sources in ~/.agents and use symlinks for harness-specific paths. Excludes ordinary project-local instructions and unrelated model, credential, or MCP settings.
---

# Agent Configuration

## Canonical sources

All harnesses share these sources of truth:

| Content | Only canonical location |
| --- | --- |
| Global agent instructions | `~/.agents/AGENTS.md` |
| Global skills and their supporting files | `~/.agents/skills/<skill-name>/` |

Create and edit global instructions and skills only at these canonical paths.
Do not create independent copies, generated mirrors, or harness-specific forks.
When a skill installer or authoring guide defaults to another directory, override
its destination to `~/.agents/skills`. Use `skill-creator` for skill authoring
when available, while retaining this canonical location.

## Harness integration

| Harness entrypoint | Required integration |
| --- | --- |
| `~/.codex/AGENTS.md` | Symlink to `~/.agents/AGENTS.md` |
| `~/.claude/CLAUDE.md` | Symlink to `~/.agents/AGENTS.md` |
| Codex global skill discovery | Automatically discovers `~/.agents/skills`; no duplicate copy or additional link needed |
| `~/.claude/skills` | Directory symlink to `~/.agents/skills` |

For other harnesses, establish the supported global entrypoint first, then link
it to the same canonical file or directory. Relative or absolute symlinks are
acceptable if they resolve correctly. Do not store a literal unexpanded `~` in
a symlink target, link the canonical path back to a harness, or create cycles.

Codex's harness-provided system skills and plugin assets are not separately
maintained user-global skills. Do not replace the entire `~/.codex/skills`
directory or move built-in/plugin-managed assets as part of configuring discovery.
User-managed global skills belong in `~/.agents/skills`.

## Changes and migration

1. Inspect canonical content, destination file types, and symlink targets before
   changes. Edit canonical files directly; avoid editors or replacement operations
   that would turn harness entrypoint symlinks into regular files.
2. Leave a correct symlink unchanged. For a missing entrypoint, create its parent
   directory as needed and create the symlink to the canonical source.
3. If an entrypoint is a regular file/directory or points elsewhere, compare its
   contents with the canonical source. Preserve unique instructions and skills
   before replacing it. Do not use force-linking or recursive deletion to discard
   content; resolve conflicting instructions with the user when intent is unclear.
4. When migration is in scope, move approved unique content into the canonical
   location and retain a recoverable backup of displaced content outside active
   discovery paths. Replace only the reconciled entrypoint with a symlink.
5. Update skill descriptions and references when renaming or consolidating skills.
   Put selection criteria in each skill's description and task-specific cross-skill
   guidance in its body. Do not duplicate a skill-routing catalog in global
   instructions; reserve those instructions for rules that apply across tasks.

This policy concerns global instructions and skills. Preserve project-local
instructions and skills, harness runtime configuration, credentials, and MCP
settings unless the user explicitly includes them in the task. Required tool or
authentication failures follow the canonical AGENTS.md's blocked-prerequisite rule.

## Verification

Check symlink type and resolved target, not only matching contents. For example,
use `test -L`, `readlink`, and `realpath` on the three known linked entrypoints.
Confirm each resolves to the intended canonical source and that referenced skill
files exist. Validate new or changed skills with the available skill validator.
Report file/link validation separately from actual harness discovery; do not
claim a running session reloaded the changes unless that was verified.
