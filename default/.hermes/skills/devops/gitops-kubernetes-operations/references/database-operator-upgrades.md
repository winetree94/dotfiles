# Database Operator Upgrades via GitOps

Use this reference for coordinated CloudNativePG (CNPG), CNPG Barman Cloud Plugin, MariaDB Operator, and `mariadb-cluster` chart upgrades across Flux-managed clusters.

## Scope and Discovery

Start by enumerating target clusters and explicitly excluding any cluster the user excludes. For each target context:

```bash
kubectl --context <ctx> get deploy -n cnpg-system cnpg-controller-manager -o jsonpath='{.spec.template.spec.containers[*].image}{"\n"}' || true
kubectl --context <ctx> get deploy -n mariadb-operator-system mariadb-operator -o jsonpath='{.spec.template.spec.containers[*].image}{"\n"}' || true
flux --context <ctx> get kustomizations -A
flux --context <ctx> get helmreleases -A
kubectl --context <ctx> get clusters.postgresql.cnpg.io -A
kubectl --context <ctx> get mariadbs.k8s.mariadb.com -A
```

Find the GitOps manifests rather than patching live resources. Common files:

```text
infrastructure/base/cloudnative-pg/kustomization.yaml
infrastructure/base/mariadb-operator/operator/*.helm-release.yaml
infrastructure/base/mariadb-operator/crds/*.helm-release.yaml
apps/base/*/*.database.yaml
```

## Version Lookup

Use upstream/current sources rather than guessing:

```bash
# CNPG release tags / manifests
curl -fsSL https://api.github.com/repos/cloudnative-pg/cloudnative-pg/releases/latest | jq -r '.tag_name,.html_url'

# Barman Cloud Plugin release
curl -fsSL https://api.github.com/repos/cloudnative-pg/plugin-barman-cloud/releases/latest | jq -r '.tag_name,.html_url'

# MariaDB Operator charts
helm repo add mariadb-operator https://helm.mariadb.com/mariadb-operator || true
helm repo update mariadb-operator
helm search repo mariadb-operator/mariadb-operator --versions | head
helm search repo mariadb-operator/mariadb-operator-crds --versions | head
helm search repo mariadb-operator/mariadb-cluster --versions | head
```

## Manifest Changes

### CNPG

Update the CNPG release manifest URL in the CNPG base kustomization, preserving the Barman Cloud Plugin manifest if already installed:

```yaml
resources:
  - https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/release-<minor>/releases/cnpg-<version>.yaml
  - https://github.com/cloudnative-pg/plugin-barman-cloud/releases/download/<plugin-version>/manifest.yaml
```

If app manifests include `ObjectStore` resources, ensure their Flux Kustomizations depend on the CNPG/plugin Kustomization so the CRD is installed first.

### MariaDB Operator and Cluster Chart

Upgrade the operator and CRD HelmRelease chart versions together. Upgrade app `mariadb-cluster` chart versions only after checking rendered values against live immutable fields.

Important pitfall: newer `mariadb-cluster` charts may default `rootPasswordSecretKeyRef.generate: true`. Existing MariaDB CRs may have `generate: false`, and `spec.rootPasswordSecretKeyRef` is immutable. Preserve the live value explicitly in GitOps values before upgrading:

```yaml
mariadb:
  rootPasswordSecretKeyRef:
    name: <existing-root-secret>
    key: mysql-root-password
    generate: false
```

Check live value first:

```bash
kubectl --context <ctx> get mariadb -n <ns> <name> -o json \
  | jq '.spec.rootPasswordSecretKeyRef'
```

Render the chart with repo values and compare immutable fields before applying:

```bash
helm template <release> mariadb-operator/mariadb-cluster \
  --version <target-version> -n <ns> -f /tmp/values.yaml \
  | yq 'select(.kind=="MariaDB") | .spec.rootPasswordSecretKeyRef'
```

## Validation

Render each Flux entrypoint and run server-side dry-run with Flux-like field manager:

```bash
kubectl kustomize infrastructure/overlays/production >/tmp/infra.yaml
kubectl kustomize apps/overlays/production >/tmp/apps.yaml
git diff --check
kubectl --context <ctx> apply --server-side --dry-run=server --field-manager=kustomize-controller -f /tmp/infra.yaml
kubectl --context <ctx> apply --server-side --dry-run=server --field-manager=kustomize-controller -f /tmp/apps.yaml
```

Commit and push only intentional files, then reconcile source and dependent Kustomizations/HelmReleases in dependency order.

## Rollout Verification

After Flux reconciliation, verify there are no unhealthy Flux objects, then inspect domain resources and controller images:

```bash
flux --context <ctx> get all -A --status-selector ready=false
kubectl --context <ctx> get pods -A --field-selector=status.phase!=Running,status.phase!=Succeeded
kubectl --context <ctx> get clusters.postgresql.cnpg.io -A
kubectl --context <ctx> get mariadbs.k8s.mariadb.com -A
kubectl --context <ctx> get helmreleases -A | grep -Ei 'mariadb|ghost|database'

kubectl --context <ctx> get deploy -n cnpg-system cnpg-controller-manager -o jsonpath='{.spec.template.spec.containers[*].image}{"\n"}'
kubectl --context <ctx> get deploy -n cnpg-system barman-cloud -o jsonpath='{.spec.template.spec.containers[*].image}{"\n"}' || true
kubectl --context <ctx> get deploy -n mariadb-operator-system mariadb-operator -o jsonpath='{.spec.template.spec.containers[*].image}{"\n"}' || true
```

For CNPG clusters with Barman Cloud Plugin, verify database pods return with the plugin sidecar and perform a safe on-demand backup when the task concerns backup health:

```bash
kubectl --context <ctx> get pods -n <app-ns> -l cnpg.io/cluster=<cluster> -o wide
kubectl --context <ctx> cnpg backup -n <app-ns> <cluster> --method=plugin --plugin-name=barman-cloud.cloudnative-pg.io
```

## Failure Handling

- If MariaDB HelmRelease fails on an immutable field, compare the live CR spec to rendered chart output. Fix values in Git, commit/push, reconcile again. Do not live-patch immutable specs.
- If a Flux Kustomization is `Ready=True`, still check CNPG/MariaDB CR conditions; app-level health can fail independently of Git sync.
- If HelmRelease is `Stalled` after a previous failed upgrade, add or use remediation retries in GitOps values where appropriate, reconcile, and verify Helm history/conditions recover.
