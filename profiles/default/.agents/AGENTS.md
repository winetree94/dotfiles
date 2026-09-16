# Blocked Prerequisites

When following a skill or instruction, stop the task if a required prerequisite is unavailable, such as failed authentication, insufficient permissions, a missing tool, or an inaccessible required service. Do not silently bypass the prescribed workflow, substitute another tool or account, skip required checks, install missing tools, or change authentication or environment settings to continue.

Report the blocked step, the relevant error without secrets, and the specific action the user must take to resolve it. Request that action and wait for the user's response. Resume after the prerequisite is verified, or follow an alternative explicitly authorized by the user. This rule concerns unavailable prerequisites, not ordinary code or test failures that the requested work is intended to fix; it does not prevent prerequisite repair when the user has explicitly requested that repair.

# Global Agent Configuration

Keep canonical global instructions and user-managed skills only in `~/.agents/AGENTS.md` and `~/.agents/skills`, respectively. Other harness entrypoints must use symlinks, not independent copies. Codex discovers the skill directory automatically.

# Public IP Addresses

When creating or updating skills and their references, retain relevant private/internal IP addresses and subnet CIDRs. Do not embed actual external public IP addresses or public address ranges. Identify public-facing resources by hostname, SSH alias, context, or resource name/ID, and resolve public addresses from current configuration when needed without copying them into skill documentation.

# Secrets

Manage secrets in Bitwarden. Use `bw` for personal secrets and the `bw-vivident` alias for Vivident secrets; do not substitute one vault for the other. Run alias-based commands in a shell that loads the user's aliases, such as `zsh -lic 'bw-vivident status'`. Retrieve only the secrets needed for the task and pass them directly to the consuming tool without exposing secret values or session tokens in conversation, logs, instructions, or Git.
