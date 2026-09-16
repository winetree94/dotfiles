# Mail Server Recovery

Use `~/Workspaces/tinyrack/mail-server/readme.md`, `ansible/`, and current service backup manifests. Recovery must preserve both configuration and mail/application data.

1. Establish the replacement Hetzner host and recovery scope with `hcloud --context winetree94`, distinguishing it from the Tinyrack server in the same context. Use `hcloud` for provider-side assignment of the existing mail Floating IP, checking its identity and preserving delete protection. Configure that IP inside the guest and install K3s through Ansible using the established cluster/service CIDRs. The Floating IP is a secondary address; preserve Hetzner-managed primary addressing, default routing, DHCP, and IPv6 configuration.
2. Bootstrap Cilium using `infrastructure/base/cilium/values.yaml`, shared by Ansible and Flux. Read current Ansible inventory and execute the documented preflight/check/apply/verify workflow, with a second apply to check idempotency.
3. Restore the single expected Sealed Secrets key from Vault before reconciling encrypted resources. The playbook refuses mismatched keys or additional active keys; investigate instead of overwriting or deleting key material.
4. After Ansible verification, bootstrap Flux against `tinyrack-net/mail-server`, branch `main`, path `clusters/production`. Flux adopts the existing Cilium release. Wait for infrastructure readiness and check app reconciliation.
5. Inspect backup objects with `rclone` under `hetzner_fsn:tinyrack-prod/clusters/public/`: Stalwart database backups are under `apps/stalwart/`, and Longhorn backups under `longhorn/`. Preserve the other cluster's prefixes in this shared bucket. Restore through Longhorn or database-native procedures as appropriate; a reconciled workload or an object copy does not prove that mail or database data has been recovered. Control external traffic during recovery as required by the affected service.
6. Verify Flux, Sealed Secrets, certificates, storage, database health, ingress, and mail protocols. Check Floating IP/DNS/PTR consistency and Stalwart web/admin access. Delivery checks must respect the sending authorization rule in [mail-delivery.md](mail-delivery.md).

Follow the README for sealing-key rotation: back up a replacement key, re-seal and verify all manifests, then retire the old key. A suspected key compromise also requires rotation of the underlying credentials. Do not perform rotation as an incidental part of ordinary recovery.

Keep Vault passwords and plaintext keys outside Git and logs. Use `homelab-infrastructure` when recovery depends on a homelab destination that itself needs repair.
