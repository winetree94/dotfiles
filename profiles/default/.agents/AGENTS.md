# Skill Routing

- For requests that resolve a known project, service, Kubernetes context, or host to a repository or environment, or that involve Kubernetes, GitOps, or infrastructure operations, load `gitops-kubernetes-operations`.
- For n8n workflow creation, updates, debugging, or instance operations, load `n8n-cli`.
- For Oshiz (오시즈) metrics, funnels, retention, revenue, user behavior, events, chats, Idolive, cohorts, or other production database analysis, load `oshiz-data-analysis`.
- For React web interface work that uses the npm package `@tinyrack/ui`, including component integration, design-token compliance, package upgrades, or upstream component fixes, additions, and releases, load `tinyrack-web-ui`.
- For Flutter interface work that uses the pub package `tinyrack_ui`, including widget or theme integration, design-token compliance, package upgrades, cross-platform validation, or upstream component fixes, additions, and releases, load `tinyrack-flutter-ui`.
- For documentation sites that use `@tinyrack/docs`, including setup, MDX or TSX routes, navigation, localization, builds, package upgrades, or upstream docs-package changes, load `tinyrack-docs`.
- For Dart or Flutter projects that use packages from `tinyrack-net/dart-packages`, including `cliweave`, `dartage`, and `shipworld`, load `tinyrack-dart-packages` for integration, upgrades, debugging, or upstream package changes and releases. Do not load it for `tinyrack_ui`, which belongs to `tinyrack-net/design` and uses `tinyrack-flutter-ui`.
- When a task spans more than one package boundary, load every applicable skill. For example, load both `tinyrack-docs` and `tinyrack-web-ui` when changing shared web UI integration in a Tinyrack documentation site, and load both UI skills only for work that intentionally spans React and Flutter, such as visual parity.
