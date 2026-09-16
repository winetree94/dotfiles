# Blocked Prerequisites

When a required prerequisite is unavailable, first determine whether it can be repaired safely within the task. Continue automatically with a repair when it is user-local, narrowly scoped, reversible, and does not alter authentication, permissions, shared systems, or the prescribed workflow. Appropriate examples include creating a task-specific virtual environment, installing a clearly identified runtime dependency into that environment, restoring project dependencies from the project's lockfile, creating a temporary directory, or using an already-installed compatible interpreter. Keep generated environments and caches outside repositories unless the repository explicitly manages them, verify the repaired prerequisite, and briefly report the repair.

Stop and ask the user when recovery requires authentication or permission changes, access to an unavailable service, system-wide or privileged installation, persistent shell or operating-system configuration changes, an untrusted or ambiguous dependency, substitution of a different tool or account, bypassing a required check, or another action with material external impact. Do not silently skip the prescribed workflow or weaken its checks.

When blocked, report the failed step, the relevant error without secrets, and the specific action the user must take. Resume after the prerequisite is verified, or follow an alternative explicitly authorized by the user. This rule concerns unavailable prerequisites, not ordinary code or test failures that the requested work is intended to fix.

# Global Agent Configuration

Keep canonical global instructions and user-managed skills only in `~/.agents/AGENTS.md` and `~/.agents/skills`, respectively. Other harness entrypoints must use symlinks, not independent copies. Codex discovers the skill directory automatically.

# Public IP Addresses

When creating or updating skills and their references, retain relevant private/internal IP addresses and subnet CIDRs. Do not embed actual external public IP addresses or public address ranges. Identify public-facing resources by hostname, SSH alias, context, or resource name/ID, and resolve public addresses from current configuration when needed without copying them into skill documentation.

# Secrets

Manage secrets in Bitwarden. Use `bw` for personal secrets and the `bw-vivident` alias for Vivident secrets; do not substitute one vault for the other. Run alias-based commands in a shell that loads the user's aliases, such as `zsh -lic 'bw-vivident status'`. Retrieve only the secrets needed for the task and pass them directly to the consuming tool without exposing secret values or session tokens in conversation, logs, instructions, or Git.
