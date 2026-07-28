# Skill Routing

- For requests that resolve a known project, service, Kubernetes context, or host to a repository or environment, or that involve Kubernetes, GitOps, or infrastructure operations, load `gitops-kubernetes-operations`.
- For n8n workflow creation, updates, debugging, or instance operations, load `n8n-cli`.
- For React interface work that uses `@tinyrack/ui`, including component integration, design-token compliance, package upgrades, or upstream component fixes and additions, load `tinyrack-ui`.
- For documentation sites that use `@tinyrack/docs`, including setup, MDX or TSX routes, navigation, localization, builds, package upgrades, or upstream docs-package changes, load `tinyrack-docs`.
- For Dart or Flutter projects that use packages from `tinyrack-net/dart-packages`, including `cliweave`, `dartage`, and `shipworld`, load `tinyrack-dart-packages` for integration, upgrades, debugging, or upstream package changes and releases.
- When a task spans more than one of these package boundaries, load every applicable skill; for example, load both `tinyrack-docs` and `tinyrack-ui` when changing shared UI integration in a Tinyrack documentation site.
