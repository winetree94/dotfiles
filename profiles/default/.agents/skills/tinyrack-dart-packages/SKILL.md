---
name: tinyrack-dart-packages
description: Build and maintain Dart or Flutter projects that consume public packages from tinyrack-net/dart-packages, including cliweave and dartage. Use when adding, upgrading, integrating, or debugging these packages. When a package bug or reusable capability is needed, pauses, proposes the upstream change, and drives a latest-origin/main worktree through PR, CI, merge, pub.dev release, and consumer reintegration.
---

# Tinyrack Dart Packages

Use the published package as the consumer-facing source of truth. Keep reusable
APIs and behavior in `tinyrack-net/dart-packages`; keep product-specific policy,
models, orchestration, and presentation in the consuming project.

The canonical upstream checkout is:

```text
~/Workspaces/tinyrack/dart-packages
```

It is a Dart pub workspace whose packages are independently versioned and
published by the verified `tinyrack.net` publisher. Current packages include:

| Package | Purpose |
|---|---|
| `cliweave` | Typed command routing, help, completion, and terminal output |
| `dartage` | Pure-Dart age v1 encryption and decryption |

Do not assume this table is exhaustive. Inspect the upstream root `pubspec.yaml`
and `packages/*/pubspec.yaml` when package membership matters.

## Consumer Package Usage

1. Inspect the consumer's `pubspec.yaml`, lockfile, resolved package metadata,
   and imported libraries before editing code.
2. Inspect the installed package version's README and public `lib/*.dart`
   entrypoints. Treat that resolved version as authoritative; do not infer APIs
   from memory, an unrelated checkout, or a newer unreleased revision.
3. Depend on a pub.dev release with an appropriate version constraint. Do not
   use git dependencies, path dependencies, `dependency_overrides`, or edits to
   the pub cache as a substitute for an upstream release.
4. Import only public `package:<name>/<library>.dart` entrypoints. Never import
   from another package's `lib/src/` tree.
5. Preserve public types, error semantics, asynchronous behavior, platform
   behavior, and security guarantees. Add product-specific adaptation in the
   consumer rather than leaking product concepts into the shared package.
6. For a `0.x` package, read its changelog and migration guide before upgrading;
   minor releases may contain breaking API changes.

Use the project's existing package manager command. For a pure Dart project:

```bash
dart pub add <package>:^<version>
dart pub get
```

For a Flutter project or a package whose `pubspec.yaml` declares an SDK
dependency on `flutter`:

```bash
flutter pub add <package>:^<version>
flutter pub get
```

Do not introduce Flutter SDK dependencies into a pure-Dart package unless the
package's purpose explicitly requires Flutter.

## Consumer Verification

Follow the consuming repository's `AGENTS.md` and established validation loop
first. At minimum, run the relevant checks after integration.

For Dart:

```bash
dart format .
dart analyze --fatal-infos
dart test
```

For Flutter:

```bash
dart format .
flutter analyze
flutter test
```

Also run the consumer's executable, build, integration tests, or platform tests
that exercise the changed package behavior. Fix integration code in the
consumer; do not patch downloaded package files.

## Upstream Contribution Boundary

Use the contribution workflow when the published package has a bug, lacks a
reusable capability, or needs a public API required by more than one product.
Do not upstream product-specific behavior merely to avoid writing an adapter.

### Step 1: Pause and Propose

- Stop the consumer task at the point where the upstream limitation is found.
- Explain the observed behavior and why consumer-side composition cannot solve
  it correctly.
- Propose the package, public API or behavior change, compatibility impact,
  tests, and expected semantic-version increment.
- Wait for explicit user approval before changing the upstream repository.

### Step 2: Create a Fresh Worktree

Never branch from the canonical checkout's local `main`; it may be stale. Fetch
and create a named feature branch directly from the latest `origin/main`:

```bash
cd ~/Workspaces/tinyrack/dart-packages
git fetch origin main
git worktree add -b <package>-<change-slug> ../dart-packages-<change-slug> origin/main
cd ../dart-packages-<change-slug>
dart pub get
```

Before creating the branch or worktree, check existing branches and worktrees
and choose non-conflicting names. Do not modify, reset, or clean the canonical
checkout to make it current.

### Step 3: Develop the Package Change

- Read the upstream `AGENTS.md`, root `pubspec.yaml`, package README, changelog,
  public entrypoints, implementation, and tests before editing.
- Keep changes inside the affected package unless workspace configuration, CI,
  or publishing must change.
- Preserve the public/private boundary: exported libraries belong under `lib/`;
  implementation details belong under `lib/src/`.
- Add focused regression or feature tests. Cover platform-specific behavior on
  every supported platform where practical.
- Update user-facing API documentation, examples, README, and migration guidance
  whenever behavior or public API changes.
- Update the affected package's `CHANGELOG.md` and `pubspec.yaml` version in the
  same PR. Use semantic versioning and remember that `0.x` breaking changes
  normally increment the minor version.
- Keep package metadata valid for pub.dev, including description, SDK bounds,
  repository, topics, license visibility, and public API documentation.
- For a new package, add it to the root pub workspace and add appropriate CI and
  tag-triggered publish workflows following the existing package conventions.

For Flutter packages, follow existing Flutter constraints if present and use
Flutter commands for resolution, analysis, tests, and package validation. Do
not convert unrelated pure-Dart workspace packages to Flutter.

### Step 4: Verify the Upstream Change

For every changed pure-Dart package, run from that package directory:

```bash
dart format .
dart analyze --fatal-infos
dart test
dart doc
dart pub publish --dry-run
```

Run `dart pub get` and workspace-wide analysis from the repository root when
workspace metadata or cross-package relationships change.

For `dartage`, run both the offline and reference interoperability suites:

```bash
dart test -x interop
cd test/interop
pnpm install --frozen-lockfile
cd ../..
dart test -t interop
```

For a Flutter package, run its equivalent checks from the package directory:

```bash
dart format .
flutter analyze
flutter test
dart doc
flutter pub publish --dry-run
```

Run any additional commands required by the current upstream `AGENTS.md` and
CI workflows. Fix failures before opening or updating the PR.

### Step 5: Open and Validate the PR

- Inspect `git status`, `git diff`, and recent commits before committing.
- Commit only the intended package and supporting workspace changes.
- Push the feature branch and open a PR against `tinyrack-net/dart-packages`
  `main`.
- Summarize the consumer problem, public API or behavior change, compatibility
  impact, version change, and verification performed.
- Wait for all current required GitHub checks to pass. Inspect the repository's
  workflows rather than relying on remembered job names; they currently cover
  formatting and analysis, package tests across platforms, `dartage` interop,
  documentation, and publish dry runs.
- Address review and CI failures in new commits. Do not bypass checks or
  force-push.

### Step 6: Merge and Release

- Merge only after approval and green required checks.
- Fetch the updated `main` and identify the exact merged commit. Read the
  package version from its merged `pubspec.yaml`; do not invent or reuse a
  version.
- Create the package-specific annotated tag on that merged commit:

  ```bash
  git tag -a <package>-v<X>.<Y>.<Z> <merged-commit> -m "<package> <X>.<Y>.<Z>"
  git push origin <package>-v<X>.<Y>.<Z>
  ```

- Monitor the matching `.github/workflows/publish-<package>.yml` run until it
  succeeds. A merged PR without a successful publish workflow is not a
  completed release.
- Confirm pub.dev serves the exact version through
  `https://pub.dev/api/packages/<package>` before updating the consumer.
- If publishing fails, diagnose and fix the release process upstream. Never
  repoint an existing tag or silently publish a different commit.

### Step 7: Return to the Consumer

- Remove the completed worktree from the canonical upstream checkout:

  ```bash
  cd ~/Workspaces/tinyrack/dart-packages
  git worktree remove ../dart-packages-<change-slug>
  ```

- Return to the original consumer repository and replace its package constraint
  with the newly published version using `dart pub add` or `flutter pub add`.
- Resolve dependencies without overrides and verify the lockfile selected the
  released pub.dev version.
- Resume the consumer change at the point where work paused and run the full
  consumer validation loop, including relevant builds and integration tests.

Do not report the original consumer task complete until the upstream release is
available, the consumer uses it from pub.dev, and both upstream and consumer
verification have passed.
