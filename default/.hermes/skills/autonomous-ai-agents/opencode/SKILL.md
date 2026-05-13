---
name: opencode
description: "Delegate coding to OpenCode CLI (features, PR review)."
version: 1.2.0
author: Hermes Agent
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [Coding-Agent, OpenCode, Autonomous, Refactoring, Code-Review]
    related_skills: [claude-code, codex, hermes-agent]
---

# OpenCode CLI

Use [OpenCode](https://opencode.ai) as an autonomous coding worker orchestrated by Hermes terminal/process tools. OpenCode is a provider-agnostic, open-source AI coding agent with a TUI and CLI.

## When to Use

- User explicitly asks to use OpenCode
- You want an external coding agent to implement/refactor/review code
- You need long-running coding sessions with progress checks
- You want parallel task execution in isolated workdirs/worktrees

## Prerequisites

- OpenCode installed: `npm i -g opencode-ai@latest` or `brew install anomalyco/tap/opencode`
- Auth configured: `opencode auth login` or set provider env vars (OPENROUTER_API_KEY, etc.)
- Verify: `opencode auth list` should show at least one provider
- Git repository for code tasks (recommended)
- `pty=true` for interactive TUI sessions

## Binary Resolution & Model Selection (Important)

Shell environments may resolve different OpenCode binaries. If behavior differs between your terminal and Hermes, check:

```
terminal(command="which -a opencode")
terminal(command="opencode --version")
```

If needed, pin an explicit binary path:

```
terminal(command="$HOME/.opencode/bin/opencode run '...'", workdir="~/project", pty=true)
```

Verify auth/providers before forcing a model:

```
terminal(command="opencode auth list")
terminal(command="opencode run --help")
```

Do not guess provider/model IDs from credential display names. For example, an "OpenCode Go" credential may expose provider `opencode-go`, not model `opencode/go`; forcing the wrong `--model` can return `Model not found`. Prefer the configured default model unless a known-good `provider/model` ID has been verified.

## One-Shot Tasks

Use `opencode run` for bounded, non-interactive tasks:

```
terminal(command="opencode run 'Add retry logic to API calls and update tests'", workdir="~/project")
```

### Plan-Backed TDD Implementation

When the user asks to “plan well and have OpenCode fix it” or the change has review-risk/concurrency-risk:

1. Write a short implementation plan in `.hermes/plans/YYYY-MM-DD-topic.md` with exact files, RED/GREEN test commands, verification commands, and commit message.
2. Invoke OpenCode with the plan attached **after** the prompt:
   ```
   opencode run 'Implement the plan in .hermes/plans/YYYY-MM-DD-topic.md using strict TDD. Write RED tests first, run them and capture expected failure, implement minimal code, run targeted tests, then run full verification. Do not commit or push. Report RED/GREEN evidence and changed files.' -f .hermes/plans/YYYY-MM-DD-topic.md --variant high
   ```
3. If OpenCode times out during long verification but has made useful edits, inspect `git status`, `git diff`, and rerun the remaining verification manually instead of starting over.
4. Remove or avoid committing `.hermes/plans/` unless the user explicitly wants the plan committed.
5. After verification, commit/push yourself with the planned conventional commit message if the user requested the fix to be finished.


Attach context files with `-f` **after the prompt**:

```
terminal(command="opencode run 'Review this config for security issues' -f config.yaml -f .env.example", workdir="~/project")
```

Do not put `--file`/`-f` before the prompt for `opencode run`; some versions parse the remaining prompt text as a file path and fail with `File not found: <prompt>`.

Show model thinking with `--thinking`:

```
terminal(command="opencode run 'Debug why tests fail in CI' --thinking", workdir="~/project")
```

Force a specific model:

```
terminal(command="opencode run 'Refactor auth module' --model openrouter/anthropic/claude-sonnet-4", workdir="~/project")
```

## Interactive Sessions (Background)

For iterative work requiring multiple exchanges, start the TUI in background:

```
terminal(command="opencode", workdir="~/project", background=true, pty=true)
# Returns session_id

# Send a prompt
process(action="submit", session_id="<id>", data="Implement OAuth refresh flow and add tests")

# Monitor progress
process(action="poll", session_id="<id>")
process(action="log", session_id="<id>")

# Send follow-up input
process(action="submit", session_id="<id>", data="Now add error handling for token expiry")

# Exit cleanly — Ctrl+C
process(action="write", session_id="<id>", data="\x03")
# Or just kill the process
process(action="kill", session_id="<id>")
```

**Important:** Do NOT use `/exit` — it is not a valid OpenCode command and will open an agent selector dialog instead. Use Ctrl+C (`\x03`) or `process(action="kill")` to exit.

### TUI Keybindings

| Key | Action |
|-----|--------|
| `Enter` | Submit message (press twice if needed) |
| `Tab` | Switch between agents (build/plan) |
| `Ctrl+P` | Open command palette |
| `Ctrl+X L` | Switch session |
| `Ctrl+X M` | Switch model |
| `Ctrl+X N` | New session |
| `Ctrl+X E` | Open editor |
| `Ctrl+C` | Exit OpenCode |

### Resuming Sessions

After exiting, OpenCode prints a session ID. Resume with:

```
terminal(command="opencode -c", workdir="~/project", background=true, pty=true)  # Continue last session
terminal(command="opencode -s ses_abc123", workdir="~/project", background=true, pty=true)  # Specific session
```

## Common Flags

| Flag | Use |
|------|-----|
| `run 'prompt'` | One-shot execution and exit |
| `--continue` / `-c` | Continue the last OpenCode session |
| `--session <id>` / `-s` | Continue a specific session |
| `--agent <name>` | Choose OpenCode agent (build or plan) |
| `--model provider/model` | Force specific model |
| `--format json` | Machine-readable output/events |
| `--file <path>` / `-f` | Attach file(s) to the message |
| `--thinking` | Show model thinking blocks |
| `--variant <level>` | Reasoning effort (high, max, minimal) |
| `--title <name>` | Name the session |
| `--attach <url>` | Connect to a running opencode server |

## Procedure

1. Verify tool readiness:
   - `terminal(command="opencode --version")`
   - `terminal(command="opencode auth list")`
2. For bounded tasks, use `opencode run '...'` (no pty needed).
3. For iterative tasks, start `opencode` with `background=true, pty=true`.
4. Monitor long tasks with `process(action="poll"|"log")`.
- If OpenCode asks for input, respond via `process(action="submit", ...)`.
- If a long `opencode run` times out after doing useful work, do not assume it failed. Inspect sessions with `opencode session list`, then resume the relevant session with a narrow follow-up such as `opencode run -s <session_id> 'Using only the context already gathered, produce the final report; do not run more commands.' --variant minimal`.
- Exit with `process(action="write", data="\x03")` or `process(action="kill")`.
- Summarize file changes, test results, and next steps back to user.

## PR Review Workflow

OpenCode has a built-in PR command:

```
terminal(command="opencode pr 42", workdir="~/project", pty=true)
```

Or review in a temporary clone for isolation:

```
terminal(command="REVIEW=$(mktemp -d) && git clone https://github.com/user/repo.git $REVIEW && cd $REVIEW && opencode run 'Review this PR vs main. Report bugs, security risks, test gaps, and style issues.' -f $(git diff origin/main --name-only | head -20 | tr '\n' ' ')", pty=true)
```

For PR evaluation or pre-merge review, combine OpenCode's code-quality findings with Hermes-owned release hygiene checks before reporting:

1. Check PR metadata/mergeability (`gh pr view <num> --json mergeable,mergeStateStatus,statusCheckRollup,headRefName,baseRefName,url`).
2. Fetch base/head and inspect the actual diff (`git diff origin/<base>...HEAD` or checked-out PR branch), not only the PR description.
3. Run the repo's relevant verification command(s) locally when feasible, and report exact pass/fail counts.
4. Look for non-product artifacts accidentally included by agent workflows (for example `.hermes/plans/`, scratch notes, debug logs) and recommend removing them unless intentionally committed.
5. If mergeability is dirty/conflicting, identify likely conflict files and make conflict resolution/rebase the top blocker even when code review is otherwise clean.
6. Report in severity buckets: Blocker/Major/Minor/Suggestions/Looks Good, with concrete commands for the next step.

## Parallel Work Pattern

Use separate workdirs/worktrees to avoid collisions:

```
terminal(command="opencode run 'Fix issue #101 and commit'", workdir="/tmp/issue-101", background=true, pty=true)
terminal(command="opencode run 'Add parser regression tests and commit'", workdir="/tmp/issue-102", background=true, pty=true)
process(action="list")
```

## Session & Cost Management

List past sessions:

```
terminal(command="opencode session list")
```

Check token usage and costs:

```
terminal(command="opencode stats")
terminal(command="opencode stats --days 7 --models anthropic/claude-sonnet-4")
```

## Pitfalls

- Interactive `opencode` (TUI) sessions require `pty=true`. The `opencode run` command does NOT need pty.
- `/exit` is NOT a valid command — it opens an agent selector. Use Ctrl+C to exit the TUI.
- PATH mismatch can select the wrong OpenCode binary/model config.
- If OpenCode appears stuck, inspect logs before killing:
  - `process(action="log", session_id="<id>")`
- Avoid sharing one working directory across parallel OpenCode sessions.
- If `opencode run` times out or exits non-zero after making edits, inspect `git status`/`git diff` and run the targeted tests before retrying. It may have left useful RED tests, partial implementation, or verification output; continue from the actual worktree state rather than starting over or assuming no changes were made. Preserve the RED failure transcript/results in the final report when it proves TDD was followed.
- Enter may need to be pressed twice to submit in the TUI (once to finalize text, once to send).

## Verification

Smoke test:

```
terminal(command="opencode run 'Respond with exactly: OPENCODE_SMOKE_OK'")
```

Success criteria:
- Output includes `OPENCODE_SMOKE_OK`
- Command exits without provider/model errors
- For code tasks: expected files changed and tests pass

## Rules

1. Prefer `opencode run` for one-shot automation — it's simpler and doesn't need pty.
2. Use interactive background mode only when iteration is needed.
3. Always scope OpenCode sessions to a single repo/workdir.
4. For long tasks, provide progress updates from `process` logs.
5. Report concrete outcomes (files changed, tests, remaining risks).
6. Exit interactive sessions with Ctrl+C or kill, never `/exit`.
