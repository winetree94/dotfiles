# CNPG Barman Cloud Plugin Migration

Use this reference when a CloudNativePG cluster uses a `standard` PostgreSQL image and in-tree `spec.backup.barmanObjectStore` backups are failing because `barman-cloud-*` executables are not present in the PostgreSQL container.

## Symptom Pattern

Live cluster evidence can include:

```text
exec: "barman-cloud-backup": executable file not found in $PATH
exec: "barman-cloud-wal-archive": executable file not found in $PATH
ContinuousArchiving=False
LastBackupSucceeded=False
```

Confirm image and missing binaries:

```bash
kubectl get pod -n <ns> <cluster-pod> -o json | jq '.spec.containers[] | {name,image}'
kubectl exec -n <ns> <cluster-pod> -c postgres -- sh -c \
  'echo PATH=$PATH; command -v barman-cloud-backup || echo no-backup; command -v barman-cloud-wal-archive || echo no-wal-archive'
```

`ghcr.io/cloudnative-pg/postgresql:*standard*` images do not include the old in-tree Barman Cloud tools. The preferred fix is the CNPG Barman Cloud Plugin rather than switching back to deprecated `system` images.

## GitOps Manifest Changes

### 1. Install the plugin with the CNPG operator

Add the plugin release manifest to the same kustomization that installs CNPG. The plugin must be installed in the same namespace as the CNPG operator, typically `cnpg-system`.

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/release-1.28/releases/cnpg-1.28.0.yaml
  - https://github.com/cloudnative-pg/plugin-barman-cloud/releases/download/v0.12.0/manifest.yaml
```

If using Flux and cert-manager is managed separately, ensure the CNPG/plugin Kustomization depends on cert-manager because the plugin manifest creates `Certificate` resources:

```yaml
spec:
  dependsOn:
    - name: longhorn
    - name: cert-manager
```

### 2. Convert `barmanObjectStore` to `ObjectStore`

Move the old `.spec.backup.barmanObjectStore` content under `ObjectStore.spec.configuration`.

Important migration nuance: plugin retention policy belongs to `ObjectStore.spec.retentionPolicy`, not `Cluster.spec.backup.retentionPolicy`.

```yaml
apiVersion: barmancloud.cnpg.io/v1
kind: ObjectStore
metadata:
  name: my-db-backup-store
  namespace: app-system
spec:
  retentionPolicy: 30d
  configuration:
    destinationPath: s3://bucket/path
    endpointURL: https://s3-compatible.example.com
    s3Credentials:
      accessKeyId:
        name: s3-secret
        key: AWS_ACCESS_KEY_ID
      secretAccessKey:
        name: s3-secret
        key: AWS_SECRET_ACCESS_KEY
    data:
      compression: gzip
    wal:
      compression: gzip
      maxParallel: 8
```

Do not set `serverName` in the `ObjectStore`; plugin docs retain it only for API compatibility and recommend leaving it empty. Use plugin parameters for server name where needed.

### 3. Update the Cluster

Remove `spec.backup.barmanObjectStore`. If `spec.backup` becomes empty, remove the entire `backup` section.

Add plugin WAL archiving:

```yaml
spec:
  plugins:
    - name: barman-cloud.cloudnative-pg.io
      isWALArchiver: true
      parameters:
        barmanObjectName: my-db-backup-store
```

For recovery/external clusters, replace `barmanObjectStore` with plugin configuration:

```yaml
spec:
  externalClusters:
    - name: old-server-name
      plugin:
        name: barman-cloud.cloudnative-pg.io
        parameters:
          barmanObjectName: my-db-backup-store
          serverName: old-server-name
```

### 4. Update ScheduledBackup

```yaml
apiVersion: postgresql.cnpg.io/v1
kind: ScheduledBackup
metadata:
  name: my-db-backup
  namespace: app-system
spec:
  schedule: "0 0 */4 * * *"
  backupOwnerReference: self
  method: plugin
  pluginConfiguration:
    name: barman-cloud.cloudnative-pg.io
  cluster:
    name: my-db-cluster
```

## Bulk Migration Across Many CNPG Clusters

When a repo has many `*.database.yaml` files using the same `barmanObjectStore` pattern, migrate all base manifests for consistency, but verify what the production overlay actually deploys. A base file can be correctly migrated in Git while its app/infrastructure entry is commented out in the overlay, so no live `ObjectStore`, sidecar, or `ScheduledBackup.method: plugin` will appear until that component is enabled.

Useful discovery checks:

```bash
# Find all candidate manifests in the repo.
rg -n "barmanObjectStore|method: barmanObjectStore|ScheduledBackup" .

# After edits, render both active overlays and individual base paths touched.
kubectl kustomize apps/overlays/production >/tmp/apps.yaml
kubectl kustomize infrastructure/overlays/production >/tmp/infra.yaml
rg -n "barmanObjectStore|method: barmanObjectStore" /tmp/apps.yaml /tmp/infra.yaml
```

Live verification should separate active resources from disabled manifests:

```bash
kubectl get objectstores.barmancloud.cnpg.io -A
kubectl get scheduledbackups.postgresql.cnpg.io -A \
  -o json | jq -r '.items[] | [.metadata.namespace,.metadata.name,.spec.method,(.spec.pluginConfiguration.name//"")] | @tsv'

kubectl get clusters.postgresql.cnpg.io -A -o json | jq -r '
  .items[] |
  [.metadata.namespace,.metadata.name,
   (.status.conditions[]? | select(.type=="Ready") | .status),
   ((.status.conditions[]? | select(.type=="ContinuousArchiving") | .status) + "/" + (.status.conditions[]? | select(.type=="ContinuousArchiving") | .reason)),
   ((.status.conditions[]? | select(.type=="LastBackupSucceeded") | .status) + "/" + (.status.conditions[]? | select(.type=="LastBackupSucceeded") | .reason))]
  | @tsv'
```

If a scheduled backup fires during the migration window, it may create a stale `method: barmanObjectStore` Backup that fails with `cluster has no backup section` after `spec.backup` was removed. Treat that as historical if a new on-demand `method: plugin` Backup completes and the cluster conditions recover.

## Verification Commands

Render locally:

```bash
kubectl kustomize infrastructure/base/cloudnative-pg >/tmp/cnpg.yaml
kubectl kustomize apps/base/<app> >/tmp/app.yaml
git diff --check
```

Dry-run installer bundle with Flux-like field manager:

```bash
kubectl apply --server-side --dry-run=server --field-manager=kustomize-controller -f /tmp/cnpg.yaml
```

After push and Flux reconcile:

```bash
kubectl rollout status -n cnpg-system deploy/barman-cloud --timeout=180s
kubectl get objectstores.barmancloud.cnpg.io -n <app-ns>
kubectl wait --for=condition=Ready cluster.postgresql.cnpg.io/<cluster> -n <app-ns> --timeout=300s
kubectl get cluster.postgresql.cnpg.io -n <app-ns> <cluster> -o json \
  | jq '{phase:.status.phase, conditions:.status.conditions}'
```

Expect:

```text
Ready=True
ContinuousArchiving=True / Continuous archiving is working
```

Trigger an immediate backup to prove the plugin path, rather than waiting for the next schedule:

```bash
kubectl cnpg backup -n <app-ns> <cluster> \
  --method=plugin \
  --plugin-name=barman-cloud.cloudnative-pg.io

kubectl get backups.postgresql.cnpg.io -n <app-ns> <backup-name> -o yaml
```

Expected Backup status:

```yaml
spec:
  method: plugin
  pluginConfiguration:
    name: barman-cloud.cloudnative-pg.io
status:
  method: plugin
  phase: completed
  pluginMetadata:
    name: barman-cloud.cloudnative-pg.io
```

Check plugin sidecar logs:

```bash
kubectl logs -n <app-ns> <cluster-pod> -c plugin-barman-cloud --since=10m \
  | grep -Ei 'Starting barman-cloud-backup|Completed barman-cloud-backup|Backup completed|Archived WAL file|error|failed'
```

## Known Pitfalls

- Existing old `Backup` CRs with `method: barmanObjectStore` may remain failed after migration. They are historical. Verify new `method: plugin` backups.
- Immediately after applying the cluster change, the pod may restart and the plugin may briefly be unavailable. Wait for the DB pod to return as `2/2 Running`.
- CNPG status fields such as `lastSuccessfulBackup` may lag or refer to historical in-tree backups; trust the newest plugin `Backup` resource and `LastBackupSucceeded=True` condition.
- If dry-run against rendered app manifests fails because `ObjectStore` CRD is not installed yet, dry-run the CNPG/plugin installer first, then validate app resources after Flux applies the CRD.
- If app-level Flux Kustomizations render `ObjectStore` resources, add an explicit `dependsOn` from those app Kustomizations to the `cloudnative-pg` Kustomization so Flux installs the plugin CRD before applying app manifests.
