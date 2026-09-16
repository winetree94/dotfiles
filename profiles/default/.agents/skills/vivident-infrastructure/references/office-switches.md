# Vivident office switches

## Main-office topology

Use the inventory and port mapping below to locate devices; recheck live configuration before changes.

| Device or port | Role |
| --- | --- |
| Dell S4148T-ON | Main-office core switch running OS10; check the current version with `show version` |
| Dell ethernet1/1/54 | Asus PN42 OPNsense router, `vivident-firewall`, LAN `re1`, `10.78.142.1/16`; access VLAN 10; check current link speed and negotiation |
| Dell ethernet1/1/53 | HP 1930 8-port switch serving wireless devices |
| Dell ethernet1/1/51 and 1/1/52 | NAS links, port-channel 1; do not repurpose as ordinary access ports |
| Other active Dell access ports | Wired workstations and servers |

The legacy office has a Dell N1548 on the separate `10.79.0.0/16` network. Do not use main-office management or port mappings for it.

Topology and local access notes: `~/Obsidian/Vivident/Memo/switch.md`. Treat older diagrams as inventory hints, not proof of current router or multi-WAN configuration.

## Management access

### Dell S4148T-ON

- Management address: `192.168.1.254`; use Telnet and verify reachability when connecting.
- Credentials: company Bitwarden item `Dell S4148T (Telnet)`, searchable by `S4148T`. Use `bw-vivident` in an alias-loading shell, for example `zsh -lic 'bw-vivident status'`. Pass credentials directly to the client without logging passwords or session tokens.
- The documented local path uses a PC on the same office LAN with an unused `192.168.1.x/24` address; the note suggests `192.168.1.100`, with no gateway. Check for conflicts before assigning it. Address configuration is a device change, not a read-only diagnostic.
- Do not assume the management subnet is routed through Tailscale or reachable from the normal `10.78.0.0/16` source address.

For an authorized router-assisted connection, a temporary secondary address on `re1` can provide a directly connected route. However, the router's LAN outbound NAT can translate even explicitly bound `192.168.1.100` connections into `10.78.142.1`. Check current routes, `pfctl -sn`, and packet headers before diagnosing a Telnet timeout as a switch failure. Successful ARP resolution alone does not prove TCP reachability.

If a temporary NAT exception is needed, limit it to the chosen management source, `192.168.1.254`, TCP port 23, and `re1`, before the matching LAN NAT rule. Preserve existing rules and dynamic anchors, validate syntax, and never load a lone exception as the entire ruleset or flush unrelated states. After access, remove only the task's exception and secondary address and verify cleanup. This access procedure does not itself authorize router configuration changes.

With the secondary address and required NAT handling in place, use a source-bound connection on the router:

```sh
telnet -s 192.168.1.100 192.168.1.254
```

### HP 1930 and wireless management

The office note lists:

- Switch UI: `https://wireless.switch.intranet.moelive.tech`
- Wireless management: `https://wifi.intranet.moelive.tech`
- Company Bitwarden searches: `wireless` or `wifi`, using `bw-vivident`.

These URLs come from the note; verify resolution and access when used.

## Read-only Dell diagnostics

OS10 diagnostic commands; check command help for the installed version:

```text
terminal length 0
show version
show clock
show interface status
show running-configuration interface ethernet 1/1/54
show interface ethernet 1/1/54
show interface ethernet 1/1/54 eee
show mac address-table address <current-router-re1-mac>
show spanning-tree interface ethernet 1/1/54 detail
show logging log-file 100
show processes cpu
```

Replace `<current-router-re1-mac>` with the router's current `re1` address before using the MAC lookup to confirm a port. `terminal length 0` affects pagination for the management session.

- Bound log reads by count. Unbounded log reads and broad historical filtering can cause high CLI-process CPU usage. Check logging command syntax for the installed OS10 version; do not assume `show logging last 40` is supported.
- Compare switch and router clocks before correlating events. Do not interpret the displayed timezone as proof of correct time.
- Interface counters can span months. Record their reset age and compare deltas; accumulated drops or throttles alone do not establish an incident's cause.
- Check link state, CRC/errors, traffic direction, flow control, MAC learning, and STP together. A forwarding state observed after recovery does not prove the state during an outage.
- For automated sessions, match the actual CLI prompt and configuration-mode suffix explicitly. A generic prompt pattern ending in `>` can mistake a syslog severity prefix for a prompt. Suppress credential echo in captured output.

For authorized changes, distinguish running configuration from startup configuration and report whether persistence was requested and performed. Link-affecting commands may interrupt the management session; reconnect and verify the actual result before retrying a mutation.
