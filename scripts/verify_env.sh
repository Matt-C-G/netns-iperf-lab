#!/usr/bin/env bash
set -euo pipefail
need() { command -v "$1" >/dev/null 2>&1 || { echo "Missing: $1"; exit 1; }; }
need iperf3; need jq; need tc; need ip

for ns in ns1 ns2; do
  if sudo ip netns list | grep -qw "$ns"; then
    cctl=$(sudo ip netns exec "$ns" sysctl -n net.ipv4.tcp_congestion_control 2>/dev/null || echo n/a)
    echo "[$ns] tcp_congestion_control: $cctl"
  else
    echo "[$ns] not present"
  fi
done

echo "[ns1] qdisc on veth1:"
sudo ip netns exec ns1 tc qdisc show dev veth1 2>/dev/null || true
echo "[ns2] qdisc on veth2:"
sudo ip netns exec ns2 tc qdisc show dev veth2 2>/dev/null || true
