# MariaDB Operator Restore/Backup Debugging

Use this when Flux reports a HelmRelease/Kustomization health failure around a `k8s.mariadb.com` `MariaDB` resource, especially messages like `status: InProgress`, `Restoring backup`, or `Backup not found`.

## Symptom Pattern

Top-level Flux can show an app Kustomization as failed even while pods are running:

```text
HelmRelease/<ns>/<release> status: 'Failed'
Helm upgrade failed ... timeout waiting for: [MariaDB/<ns>/<name> status: 'InProgress']
MariaDB Ready=False Reason=RestoreBackup Message=Restoring backup
Restore status: Backup not found
```

Do not stop at pod status. Inspect the operator CRs:

```bash
flux --context <ctx> get all -A --status-selector ready=false
kubectl --context <ctx> describe helmrelease -n <ns> <hr>
kubectl --context <ctx> describe mariadb -n <ns> <mariadb>
kubectl --context <ctx> get backup,restore,database,user,grant -n <ns> -o wide
kubectl --context <ctx> get restore.k8s.mariadb.com -n <ns> <restore> -o yaml
kubectl --context <ctx> logs -n mariadb-operator-system deploy/mariadb-operator --since=2h \
  | grep -Ei '<app>|restore|backup|error|failed'
```

## Common Root Cause: Helm Chart Backup Name Prefixing

The `mariadb-cluster` Helm chart creates Backup resources with the release fullname prefix:

```text
<release-name>-<backup-values-name>
```

But `mariadb.bootstrapFrom.backupRef.name` is passed through verbatim. This can create a name mismatch:

```yaml
values:
  mariadb:
    bootstrapFrom:
      backupRef:
        name: ghost-backup        # looked up verbatim
  backups:
    - name: ghost-backup          # rendered as <release>-ghost-backup
```

Rendered result:

```yaml
kind: Backup
metadata:
  name: ghost-mariadb-cluster-ghost-backup
---
kind: MariaDB
spec:
  bootstrapFrom:
    backupRef:
      name: ghost-backup
```

The Restore then fails with:

```text
Backup.k8s.mariadb.com "ghost-backup" not found
```

Reproduce/verify with the actual Helm values from the repo:

```bash
# Extract values or create /tmp/values.yaml from spec.values, then render:
helm template <release-name> mariadb-operator/mariadb-cluster \
  --version <chart-version> -n <namespace> -f /tmp/values.yaml \
  | grep -n 'kind: Backup\|kind: MariaDB\|backupRef\|name: .*backup' -A8 -B5
```

## Interpreting Running Pods

A `MariaDB` pod can be `Running` and scheduled backup Jobs can complete even while the MariaDB CR remains `Ready=False` due to a stale/failed restore condition. Always compare:

- `MariaDB.status.conditions`
- `Restore.status.conditions`
- `Backup.status.conditions`
- Recent backup Job logs
- HelmRelease status/history

## Fix Direction

Choose based on operational intent:

1. Existing production DB that should continue in place: remove `mariadb.bootstrapFrom` from GitOps values so the operator stops attempting restore bootstrap.
2. Intentional restore/bootstrap: set `backupRef.name` to the actual rendered Backup CR name, or create/reference the expected Backup CR explicitly.

Apply fixes through GitOps, then reconcile the app HelmRelease/Kustomization and verify the MariaDB/Restore/HelmRelease conditions, not just pod status.
