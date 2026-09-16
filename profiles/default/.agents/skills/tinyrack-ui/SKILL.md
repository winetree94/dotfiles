---
name: tinyrack-ui
description: Build and maintain React and Flutter interfaces using the published @tinyrack/ui npm package or tinyrack_ui pub package from tinyrack-net/design. Use for component integration, themes and design tokens, accessibility, package upgrades, visual parity, or upstream UI fixes, additions, releases, and consumer reintegration.
---

# Tinyrack UI

## Select the platform

Identify the consumer from its manifests, lockfiles, imports, and requested scope.
Flutter web is a Flutter consumer, not a React consumer.

- For React and `@tinyrack/ui`, read [references/react.md](references/react.md).
- For Flutter and `tinyrack_ui`, read [references/flutter.md](references/flutter.md).
- Read both only when the task intentionally spans both platforms, such as
  shared tokens or visual parity. A shared repository does not require changing
  or publishing both packages.
- For reusable package bugs or missing system capabilities, also read
  [references/contributing.md](references/contributing.md). Ordinary consumer
  integration does not require the upstream workflow.

For `@tinyrack/docs` site configuration or documentation integration, also use
`tinyrack-docs`. Packages from `tinyrack-net/dart-packages` use
`tinyrack-dart-packages`; `tinyrack_ui` belongs to this skill instead.

## Shared design contract

- Inspect the installed release's documentation and public exports before
  editing. Do not infer available APIs from memory or an unreleased checkout.
- Keep product policy and orchestration in the application; keep reusable
  components, themes, tokens, and component semantics in Tinyrack.
- Use published packages and public APIs. Do not patch `node_modules` or the
  pub cache to bypass a required upstream release.
- Preserve light/dark behavior, visible focus, contrast, keyboard operation,
  accessible naming, and affected interactive states.
- Preserve IBM Plex typography, including English, Korean, and Japanese support,
  through each platform's documented font integration.
- Preserve deliberate cross-platform design parity while retaining native
  lifecycle, editing, and platform behavior. React's literal-design-value ban
  and Flutter's package-value preference are distinct rules in their references.

Finish consumer work with the platform's relevant validation and the project's
own required checks. Upstream work is complete only after the scoped release is
verified and the original consumer integration is finished.
