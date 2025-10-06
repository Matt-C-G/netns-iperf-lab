#!/usr/bin/env bash
set -euo pipefail
echo "== ip/ss versions =="
ip -V || true
ss -V || true
echo "== kernel =="
uname -a
echo "== iperf3 =="
iperf3 -v | head -n1 || true
echo "== ns check =="
for ns in ns1 ns2; do
  if sudo ip netns list | grep -q "^$ns\b"; then
    echo " [$ns] up"
    sudo ip netns exec "$ns" bash -c '
      set -e
      echo "  addr:"; ip -br a
      echo "  qdisc:"; tc qdisc show
      echo "  tcp cc:"; sysctl -n net.ipv4.tcp_congestion_control
      echo "  fq present?"; modprobe -n sch_fq 2>/dev/null || true
    '
  else
    echo " [$ns] missing"
  fi
done
