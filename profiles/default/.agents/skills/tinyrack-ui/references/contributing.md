# Upstream Contributions

Read this only for reusable bugs or missing components, widgets, tokens,
variants, or theme capabilities in `tinyrack-net/design`.

## Establish scope

When a consumer requirement cannot be met by the published package, pause the
dependent consumer change and explain why composition is insufficient. Propose
the public API, behavior, states, variants, tokens, affected platforms, parity
impact, tests, and semantic-version increment. Obtain explicit approval for
upstream changes if the current request or earlier session authorization does
not already cover them. Do not ask again for an already authorized contribution.

Select only the affected packages. A React-only or Flutter-only change does not
require modifying or releasing the other package. Shared-token or parity work
requires both platform references and checks for the affected packages.

## Worktree and implementation

Use `~/Workspaces/tinyrack/design` as the canonical checkout. Fetch current
`origin/main` and create a fresh named worktree without modifying that checkout:

```bash
cd ~/Workspaces/tinyrack/design
git fetch origin main
git worktree add -b ui-<change-slug> ../design-<change-slug> origin/main
cd ../design-<change-slug>
pnpm install
```

Use `flutter-<change-slug>` as the branch prefix for Flutter-only work. For Flutter
changes, also run `flutter pub get` in `packages/tinyrack_ui`.

Read upstream `AGENTS.md`, triggered repository skills, affected manifests,
exports, neighboring components, and CI/publish workflows before editing.
Apply [react.md](react.md) or [flutter.md](flutter.md) implementation rules and
checks as appropriate. For shared component appearance or interaction changes,
also run from the repository root:

```bash
pnpm --filter @tinyrack/homepage test:visual-parity
```

## PR and release

1. Determine each affected package's semantic version from its current manifest,
   registry, and tag state. Include its version/changelog updates and relevant
   API documentation/examples in the PR.
2. Open the PR against `tinyrack-net/design` `main`. Address review and required
   CI, platform, preview, and parity checks in new commits. Merge only after
   approval and green checks, honoring authorization already provided.
3. Read the merged manifest and current publish workflow before tagging. Tag the
   exact merge commit and monitor the workflow for that exact release. Never
   move or reuse a pushed release tag.

| Package | Release tag | Publish verification |
| --- | --- | --- |
| `@tinyrack/ui` | `ui-v<X>.<Y>.<Z>` | npm workflow and exact-version registry metadata |
| `tinyrack_ui` | Annotated `tinyrack_ui-v<X>.<Y>.<Z>` | `.github/workflows/publish-flutter.yml` and exact release on pub.dev |

For npm, verify the published version and artifact metadata:

```bash
npm view @tinyrack/ui@<version> version dist.tarball dist.integrity repository --json
```

Confirm the expected dist-tag as well when the workflow publishes to it; do not
use a moving `latest` tag as the sole evidence for the release.

## Return to the consumer

After the scoped release is verified, remove the completed worktree without
discarding unfinished changes. Upgrade the consumer to the published version,
update its lockfile (`flutter pub get` for Flutter), and complete the original
integration and platform-specific consumer checks. Do not bypass a failed or
pending release with package-cache edits or Flutter dependency overrides.
