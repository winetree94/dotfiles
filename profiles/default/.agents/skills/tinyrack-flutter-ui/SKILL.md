---
name: tinyrack-flutter-ui
description: Build and maintain Flutter interfaces that consume the published tinyrack_ui pub package from tinyrack-net/design. Use for Flutter component or theme integration, design-token compliance, package upgrades, cross-platform UI validation, or upstream Flutter component fixes, additions, pub.dev releases, and consumer reintegration. Do not use for React web interfaces or the @tinyrack/ui npm package.
---

# Tinyrack Flutter UI

Use the published `tinyrack_ui` package for Flutter UI. Keep product policy and
orchestration in the application and reusable widgets, themes, and tokens in
Tinyrack. Use `tinyrack-web-ui` instead for React work.

## Consume the Package

1. Inspect the consumer's `pubspec.yaml`, lockfile, resolved package metadata,
   and existing imports before editing.
2. Inspect the resolved package's README, `pubspec.yaml`, documentation, and
   public `lib/tinyrack_ui.dart` exports. Treat the installed release as the
   source of truth; do not infer APIs from memory or an unreleased checkout.
3. Depend on a pub.dev release with an appropriate version constraint:

   ```bash
   flutter pub add tinyrack_ui:^<version>
   flutter pub get
   ```

4. Import only the public library:

   ```dart
   import 'package:flutter/material.dart';
   import 'package:tinyrack_ui/tinyrack_ui.dart';
   ```

5. Do not import `package:tinyrack_ui/src/...`, patch the pub cache, or use a
   path dependency, git dependency, or `dependency_overrides` in place of a
   published upstream release.
6. Configure both themes and use the package's public TR widgets and typed
   variants before composing lower-level Material widgets:

   ```dart
   MaterialApp(
     theme: TinyrackTheme.light(),
     darkTheme: TinyrackTheme.dark(),
     home: const ProductScreen(),
   );
   ```

Preserve widget lifecycle, callbacks, focus, keyboard behavior, semantics,
platform behavior, text direction, and accessibility labels. Do not substitute
the npm package `@tinyrack/ui` in a Flutter consumer.

## Preserve the Design System

- Use the public Tinyrack theme, tokens, variants, typography, and widgets.
  Avoid arbitrary `Color`, `TextStyle`, spacing, radius, or animation literals
  when a package value exists.
- Preserve light and dark themes and English, Korean, and Japanese typography.
  Use the package-bundled IBM Plex fonts rather than introducing a competing
  application font system.
- Prefer typed component variants and semantic TR compound parts over
  reimplementing their appearance with generic Material widgets.
- Preserve accessible semantics, visible focus, keyboard activation, disabled,
  loading, readonly, invalid, hover, and pointer states where applicable.
- Treat deliberate React parity as a shared design contract while retaining
  Flutter-only editing, lifecycle, and platform behavior.

## Contribute a Missing System Component

When the published package has a reusable bug or lacks a required reusable
widget, token, variant, or theme capability, stop the consumer change. Explain
why consumer composition is insufficient and propose the public API, behavior,
platform impact, parity impact, tests, and semantic-version increment. Wait for
explicit approval before changing upstream.

1. Create a named worktree from current `origin/main`:

   ```bash
   cd ~/Workspaces/tinyrack/design
   git fetch origin main
   git worktree add -b flutter-<change-slug> ../design-<change-slug> origin/main
   cd ../design-<change-slug>
   pnpm install
   cd packages/tinyrack_ui
   flutter pub get
   ```

2. Read the upstream `AGENTS.md`, `packages/tinyrack_ui/pubspec.yaml`, README,
   public export library, neighboring widgets, generated-token workflow, tests,
   and current CI/publish workflows before editing.
3. Keep public exports under `lib/` and implementation details under `lib/src/`.
   Update API documentation, examples, changelog, and package version whenever
   public behavior changes. Do not hand-edit generated tokens; use the current
   repository generator and parity workflow.
4. Run focused tests plus the complete package gates for public changes:

   ```bash
   cd packages/tinyrack_ui
   dart format --output=none --set-exit-if-changed lib test example/lib
   flutter analyze
   flutter test
   dart pub publish --dry-run
   ```

5. Exercise affected Android, iOS, Linux, macOS, web, or Windows builds when
   platform behavior or assets change. For shared React/Flutter component
   appearance or interaction changes, run from the repository root:

   ```bash
   pnpm --filter @tinyrack/homepage test:visual-parity
   ```

6. Open a PR against `tinyrack-net/design` `main`, address review and all
   required Flutter, platform, preview, and parity checks, and merge only after
   approval and green CI.
7. Read the merged `pubspec.yaml` and `.github/workflows/publish-flutter.yml`.
   Create the annotated tag `tinyrack_ui-v<X>.<Y>.<Z>` on the exact merge commit,
   push it, monitor the publish workflow, and confirm the release on pub.dev.
   Never move or reuse a pushed release tag.
8. Remove the completed worktree, upgrade the consumer to the published version,
   run `flutter pub get`, and finish the original integration.

## Verify the Consumer

- Run `dart format .`, `flutter analyze`, and `flutter test`, following stricter
  consumer `AGENTS.md` requirements where present.
- Run the affected application, integration tests, golden tests, and platform
  builds that exercise the changed UI.
- Verify light/dark themes, supported locales, keyboard and screen-reader
  semantics, text scaling, layout constraints, and affected interaction states.

