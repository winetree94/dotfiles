# General Project Locations

Use this reference for the named projects below, not as an infrastructure router. Paths are under `~/Workspaces` unless the user supplies another location. Read the target repository's current instructions before work; an explicit user path is authoritative.

These entries were migrated from the former GitOps skill's `references/environments.md` on 2026-09-16. The project-specific conventions below preserve that source's recorded guidance; they are not newly inferred requirements and must be checked against current user and repository instructions.

| Project | Repository | Status and recorded guidance |
| --- | --- | --- |
| `tinyrack/auth` | `~/Workspaces/tinyrack/auth` | Previously recorded authentication repository; this local path was absent during migration. Locate the current checkout before use; do not create or assume it exists. |
| `tinyrack/tinyauth` | `~/Workspaces/tinyrack/tinyauth` | Local path absent during migration. Prior guidance: respond in Korean unless requested otherwise; trust and commit MikroORM-generated compiled-functions artifacts when builds regenerate them. Reconfirm applicability when locating the project. |
| `tinyrack/dotweave` | `~/Workspaces/tinyrack/dotweave` | Existing checkout. Prior guidance: strict TDD with RED/GREEN evidence; normalize profile names by trimming only, without lowercasing. Read the repository's current AGENTS.md and validation requirements as well. |
| `winetree94/dev-machines` | `~/Workspaces/winetree94/dev-machines` | Existing development-machine configuration repository; read its own Ansible and platform instructions. Distinct from the personal and company CI runner repositories. |
| `vivident/eevee` | `~/Workspaces/vivident/eevee` | Application repository. Company intranet deployments belong to `~/Workspaces/vivident/intranet`; use `vivident-infrastructure` for those infrastructure tasks, not for unrelated application edits. |

Do not select an infrastructure skill merely because a project belongs to the Tinyrack or Vivident organization. Use the environment skills' descriptions and their target mappings when a task actually involves infrastructure.
