# Platforms and Device Onboarding

## Inventory and connection model

The current repository supports Ubuntu 26.04+, macOS, and Windows 10/11. Read the setup playbook's OS assertions before adding a platform; do not bypass them to treat arbitrary Linux distributions as Ubuntu.

Remote hosts belong to static `ubuntu`, `macos`, or `windows` inventory groups so shell and privilege-escalation settings exist before the first connection. Runtime facts verify the group against the actual OS. A hostname such as `desktop` does not imply Windows.

An explicitly enabled `localhost` is classified at runtime and is not assigned a static OS group. Native Windows cannot run ansible-core as the controller. Under WSL, `localhost` means the Linux guest; the Windows host must be a separate OpenSSH target. Do not enable commented inventory entries as a side effect of another task.

| Platform | Important behavior |
| --- | --- |
| Ubuntu | GUI applications are auto-enabled from desktop session detection. Uses the repository's `sudo_wrapped` become plugin; Linux Homebrew is bootstrapped by the playbook. |
| macOS | GUI enabled by default, Homebrew is a prerequisite, and the Xcode role provisions Command Line Tools before common tools. Privileged tasks use sudo. |
| Windows | OpenSSH with PowerShell and `runas`; package installation uses the shared winget role. Privilege escalation needs the account password, not a Windows Hello PIN. |
| WSL | Excluded from GUI auto-detection; VPN roles are disabled by default. Native Ubuntu swap management is skipped because WSL swap belongs to the Windows host. |

Read current group vars, host vars, and playbook gates for overrides. Do not infer GUI or VPN behavior solely from OS names, or automatically enable guest VPN to repair host networking.

## Register a device

1. Confirm the requested device, supported OS, connection identity, and SSH bootstrap. Read the README's platform-specific prerequisites; initial authorized-key installation, macOS Remote Login, Windows OpenSSH/PowerShell setup, and account sign-ins may require user action.
2. Add the host to the matching static group in `inventories/hosts.yml`; put device-specific overrides in `inventories/host_vars/<host>.yml`.
3. Preserve the single encrypted `inventories/group_vars/all/vault.yml` model. Host credentials use `vault_<host>_username` and `vault_<host>_become_password`, replacing hostname hyphens with underscores, mapped onto connection variables in inventory. Other secret mappings belong in `group_vars/all/main.yml`, not directly in roles.
4. Follow the main skill's validation and scoped onboarding workflow. Verify connectivity before setup and actual results after application.

The repository's `.vault_pass` is sourced from the personal Bitwarden item `dev-machines (ansible vault)` using `bw`. Retrieve it only when setup requires it, without printing the value; preserve the repository's ignored, private local password-file mechanism.

SSH key contents flow from `vault_ssh_private_key` through `ansible_private_key` into Ansible's per-run agent (`ssh_agent = auto`). Do not replace this with exported private-key files or SSH password authentication. The tracked public key is also used outside this repository, so its rotation is not a device-local cleanup.

Keep Apple ID/App Store sign-in, VPN authentication, and other documented human-only steps separate from provisioning. Installing VPN or Syncthing software does not imply configuring tunnel credentials, Syncthing devices/folders, or firewall rules. Report missing setup instead of claiming those services are fully usable from package installation alone.
