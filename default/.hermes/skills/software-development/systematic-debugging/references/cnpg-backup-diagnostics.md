# CNPG backup diagnostics: Barman object store failures

Use this reference when diagnosing CloudNativePG (CNPG) backup / WAL archive issues in Kubernetes clusters.

## Fast triage commands

```bash
# Confirm context and CNPG resources
kubectl config current-context
kubectl get clusters.postgresql.cnpg.io -A
kubectl get scheduledbackups.postgresql.cnpg.io -A
kubectl get backups.postgresql.cnpg.io -A

# Summarize backup phases and latest examples
kubectl get backups.postgresql.cnpg.io -n <namespace> -o json \
  | jq -r '[.items[] | {name:.metadata.name, creation:.metadata.creationTimestamp, phase:(.status.phase//"<none>"), error:(.status.error//""), started:(.status.startedAt//""), stopped:(.status.stoppedAt//"")}] | group_by(.phase)[] | {phase:.[0].phase,count:length,latest:(max_by(.creation))} | @json'

# Inspect cluster backup status/conditions without dumping secrets
kubectl get cluster.postgresql.cnpg.io -n <namespace> <cluster> -o json \
  | jq '{spec_backup:.spec.backup, status:{phase:.status.phase,conditions:.status.conditions,firstRecoverabilityPoint:.status.firstRecoverabilityPoint,lastSuccessfulBackup:.status.lastSuccessfulBackup,lastFailedBackup:.status.lastFailedBackup,currentPrimary:.status.currentPrimary,instances:.status.instances,readyInstances:.status.readyInstances}}'

# Inspect latest backup objects and relevant operator logs
kubectl describe backup.postgresql.cnpg.io -n <namespace> <backup-name>
kubectl logs -n cnpg-system deploy/cnpg-controller-manager --since=24h \
  | grep -Ei 'backup|barman|wal|archive|<cluster>|error|fail' | tail -n 200

# Inspect Postgres pod logs and image contents
kubectl get pod -n <namespace> <cluster-pod> -o json \
  | jq '{images:[.spec.containers[]|{name,image,command,args}], initImages:[.spec.initContainers[]?|{name,image}], annotations:.metadata.annotations, labels:.metadata.labels}'
kubectl exec -n <namespace> <cluster-pod> -c postgres -- sh -c \
  'echo POD_PATH=$PATH; command -v barman-cloud-backup || echo no-backup; command -v barman-cloud-wal-archive || echo no-wal-archive; find / -name "barman-cloud-*" 2>/dev/null | head -20'
kubectl logs -n <namespace> <cluster-pod> -c postgres --since=3h \
  | grep -Ei 'barman|archive|backup|wal|error|failed|executable' | tail -n 120
```

## Interpretation pattern

- `Cluster in healthy state` only means the database cluster is running; it does **not** prove backups or PITR are healthy.
- Treat `status.conditions` as authoritative for backup health:
  - `ContinuousArchiving=False` or reason `ContinuousArchivingFailing` means WAL archiving is currently broken.
  - `LastBackupSucceeded=False` or reason `LastBackupFailed` means base backup is currently broken.
  - `lastSuccessfulBackup` is the last reliable base backup timestamp.
- A large number of Backup CRs with `phase: <none>` plus operator logs saying `A backup is already in progress or waiting to be started, retrying` usually means one stuck/running/failing backup is blocking the queue.
- Errors like `exec: "barman-cloud-backup": executable file not found in $PATH` and `exec: "barman-cloud-wal-archive": executable file not found in $PATH` identify an image/tooling mismatch, not S3 credential failure.

## CNPG Barman image/plugin nuance

Recent CNPG operand images are split roughly into:

- `minimal`: minimal packages for CNPG
- `standard`: minimal plus common tools such as PGAudit; Barman Cloud tools may not be present
- `system`: equivalent to older images and includes Barman Cloud tools, but is deprecated for long-term use

If a cluster uses in-core `spec.backup.barmanObjectStore`, the Postgres container must have the required `barman-cloud-*` executables available, or backups/WAL archive fail. Longer-term, prefer migrating to the Barman Cloud CNPG-I plugin: define an ObjectStore, remove/replace in-core `spec.backup.barmanObjectStore`, and configure `spec.plugins` with the Barman Cloud plugin as WAL archiver.

## Reporting checklist

When reporting, separate these explicitly:

1. Database availability/cluster health.
2. ScheduledBackup creation health.
3. Base backup success timestamp and current `LastBackupSucceeded` condition.
4. WAL archive condition and current error.
5. Root-cause evidence from pod image + missing/present binaries.
6. Remediation options, clearly labeled as short-term workaround vs recommended long-term path.
