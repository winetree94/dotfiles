# Flutter UI

## Consume the package

Inspect the consumer's `pubspec.yaml`, lockfile, resolved package metadata, and
imports. Read the installed package's README, `pubspec.yaml`, documentation, and
public `lib/tinyrack_ui.dart` exports.

Depend on a pub.dev release with an appropriate constraint:

```bash
flutter pub add tinyrack_ui:^<version>
flutter pub get
```

Import the public library:

```dart
import 'package:flutter/material.dart';
import 'package:tinyrack_ui/tinyrack_ui.dart';
```

Do not import `package:tinyrack_ui/src/...`, patch the pub cache, or substitute
path/git dependencies or `dependency_overrides` for a published upstream release.
Use public TR widgets and typed variants before composing lower-level Material
widgets, and configure both themes:

```dart
MaterialApp(
  theme: TinyrackTheme.light(),
  darkTheme: TinyrackTheme.dark(),
  home: const ProductScreen(),
);
```

Preserve widget lifecycle, callbacks, focus, keyboard behavior, semantics,
platform behavior, text direction, and accessibility labels.

## Styling contract

- Use public Tinyrack themes, tokens, variants, typography, and widgets. Avoid
  arbitrary `Color`, `TextStyle`, spacing, radius, or animation literals when
  a package value exists.
- Use the package-bundled IBM Plex fonts for English, Korean, and Japanese;
  do not introduce a competing application font system.
- Prefer typed variants and semantic TR compound parts over reproducing their
  appearance with generic Material widgets.
- Preserve disabled, loading, readonly, invalid, hover, and pointer states
  where applicable, alongside the shared accessibility and theme contract.
- Retain Flutter-specific editing, lifecycle, and platform behavior when
  implementing deliberate React parity.

## Upstream implementation and checks

When upstream work is needed, follow [contributing.md](contributing.md). Read
`packages/tinyrack_ui/pubspec.yaml`, README, public exports, neighboring widgets,
generated-token workflow, tests, and current CI/publish workflows.

Keep public exports under `lib/` and implementation under `lib/src/`. Update API
documentation and examples when public behavior changes. Do not hand-edit
generated tokens; use the current repository generator and parity workflow.

Run focused tests plus the complete package gates for public changes from
`packages/tinyrack_ui`:

```bash
dart format --output=none --set-exit-if-changed lib test example/lib
flutter analyze
flutter test
dart pub publish --dry-run
```

Exercise affected Android, iOS, Linux, macOS, web, or Windows builds when platform
behavior or assets change. Shared appearance/interaction changes also require
the parity check described in the contribution reference.

## Verify the consumer

- Run `dart format .`, `flutter analyze`, and `flutter test`, following stricter
  consumer instructions where present.
- Run the affected app, integration tests, golden tests, and platform builds.
- Verify light/dark themes, supported locales, keyboard and screen-reader
  semantics, text scaling, layout constraints, and affected interaction states.
