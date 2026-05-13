# MariaDB Operator HelmRelease Restore Stalls

Use this when a Flux `HelmRelease` for `mariadb-operator`'s `mariadb-cluster` chart is `Ready=False` / `UpgradeFailed` because the `MariaDB` CR stays `InProgress` or `Restoring backup`.

## Symptom Pattern

```text
Helm upgrade failed ... timeout waiting for: [MariaDB/<ns>/<name> status: 'InProgress']
MariaDB Ready=False Reason=RestoreBackup Message=Restoring backup
Restore/<name>-restore Complete=False Message="Backup.k8s.mariadb.com \"<backup>\" not found"
```

Top-level workloads may still be Running and backups may still be succeeding, but Flux remains unhealthy because Helm waits on the MariaDB CR condition.

## Diagnosis Commands

```bash
flux --context <ctx> get all -A --status-selector ready=false
kubectl --context <ctx> describe helmrelease -n <ns> <hr>
kubectl --context <ctx> describe mariadb -n <ns> <mariadb>
kubectl --context <ctx> get backup,restore,mariadb -n <ns> -o wide
kubectl --context <ctx> logs -n mariadb-operator-system deploy/mariadb-operator --since=2h \
  | grep -Ei '<name>|restore|backup|error|failed'
```

Check rendered chart names. The `mariadb-cluster` Helm chart prefixes `backups[].name` with the release fullname, but `mariadb.bootstrapFrom.backupRef.name` is passed through literally:

```bash
helm template <release> mariadb-operator/mariadb-cluster --version <ver> \
  -n <ns> -f values.yaml \
  | grep -n 'kind: Backup\|kind: MariaDB\|backupRef' -A8 -B5
```

Example mismatch:

```text
Backup CR rendered:       ghost-mariadb-cluster-ghost-backup
bootstrapFrom backupRef:  ghost-backup
```

## Root Cause

If `bootstrapFrom.backupRef.name` points to the un-prefixed chart value, the operator creates a Restore that looks for a non-existent `Backup` CR. The failed Restore can leave the MariaDB status stuck at `RestoreBackup`, causing HelmRelease and parent Flux Kustomizations to remain unhealthy.

## Fix Pattern

For an already-running production database where restore bootstrap is no longer desired:

1. Remove `mariadb.bootstrapFrom` from the GitOps HelmRelease values.
2. Add Helm remediation retries if absent, so a previously stalled HelmRelease can retry after the values change:
   ```yaml
   spec:
     install:
       remediation:
         retries: 3
     upgrade:
       remediation:
         retries: 3
   ```
3. Validate locally:
   ```bash
   kubectl kustomize apps/overlays/production/<app>/deployment >/tmp/<app>.yaml
   kubectl --context <ctx> apply --server-side --dry-run=server \
     --field-manager=kustomize-controller -f /tmp/<app>.yaml
   ```
4. Commit, push, reconcile the owning Kustomization and HelmRelease.
5. If a stale Restore CR remains and the DB pod is verified healthy, delete the stale Restore CR:
   ```bash
   kubectl --context <ctx> exec -n <ns> <mariadb-pod> -- mariadb-admin ping -uroot -p"$(kubectl --context <ctx> get secret -n <ns> <secret> -o jsonpath='{.data.<root-key>}' | base64 -d)"
   kubectl --context <ctx> delete restore.k8s.mariadb.com -n <ns> <restore-name>
   ```
6. Reconcile again and verify:
   ```bash
   flux --context <ctx> reconcile helmrelease <hr> -n <ns> --with-source
   flux --context <ctx> reconcile kustomization <app-kustomization> -n flux-system --with-source
   kubectl --context <ctx> get mariadb,backup,restore -n <ns> -o wide
   flux --context <ctx> get all -A --status-selector ready=false
   ```

## Pitfalls

- Do not assume `backups[].name` equals the actual Backup CR name. Render the Helm chart to confirm names.
- Removing `bootstrapFrom` changes the spec but may not clear an already-created Restore CR or stale status immediately; verify the DB is healthy before deleting stale restore resources.
- A HelmRelease with `RetriesExceeded/Stalled` may not retry after the root cause is removed unless remediation retries or another generation-changing spec update is applied.
- Avoid direct status patching except as a last resort; prefer letting the operator refresh after the stale Restore is gone.
