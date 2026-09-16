# Mail Delivery and Network Diagnosis

Read the current repository README, Stalwart/Bulwark manifests, Services, ingress routes, Cilium policies, and Ansible network configuration. Treat addresses and protocol configuration in those sources as current desired state, then compare with read-only observations.

## Traffic and identity

- The primary mail hostname is `mail.winetree94.com`. Inspect and manage Cloudflare DNS with `cf`, selecting the correct account/profile and `winetree94.com` zone after checking current CLI help. Do not assume SMTP/IMAP can use a standard HTTP proxy or impose another environment's Tunnel-only policy. PTR configuration belongs to the IP provider; Cloudflare DNS management does not imply ownership of reverse DNS.
- Stalwart exposes SMTP/submission, IMAP, POP3, and ManageSieve through its LoadBalancer Service; Traefik handles the web/admin surface. Inspect Service definitions for actual ports rather than opening an assumed set.
- Ansible configures a Hetzner Floating IP persistently on the mail host. Stalwart's external IPv4 traffic is intended to use it. The mail hostname A record and Floating IP PTR must agree, and the documented EHLO hostname is `mail.winetree94.com`.
- The documented Stalwart routing sends local domains to `local` and external domains to IPv4-only `mx`. Verify runtime settings against the repository before changing routing.

## Investigation

For inbound failures, trace recipient-domain MX resolution, destination addresses, listener/TLS connectivity, firewall verdicts, and Stalwart acceptance/local delivery. For outbound failures, inspect queue status and SMTP response codes, DNS/MX resolution, selected route, egress IP/PTR/EHLO, and relevant sender-domain SPF/DKIM/DMARC configuration. Distinguish transport rejection from authentication or reputation problems.

For webmail failures, check Bulwark, its JMAP endpoint, TLS, and the configured ingress route rather than assuming the SMTP listener is responsible. Prefer metadata and narrowly scoped logs over dumping user messages or secrets.

Fix the owning configuration source and verify reconciliation plus the original failing path. Sending a test email is an external action: do it only when the user has explicitly authorized sending, with the intended sender and recipient established. Otherwise report the non-sending checks completed and the delivery test still outstanding.
