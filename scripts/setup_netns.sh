#!/usr/bin/env bash
set -euo pipefail

# Create namespaces and veth pair
sudo ip netns add ns1 || true
sudo ip netns add ns2 || true
sudo ip link add veth1 type veth peer name veth2 || true
sudo ip link set veth1 netns ns1
sudo ip link set veth2 netns ns2

# Bring links up and give simple IPs
sudo ip netns exec ns1 ip addr add 10.0.0.1/24 dev veth1 || true
sudo ip netns exec ns2 ip addr add 10.0.0.2/24 dev veth2 || true
sudo ip netns exec ns1 ip link set veth1 up
sudo ip netns exec ns2 ip link set veth2 up
sudo ip netns exec ns1 ip link set lo up
sudo ip netns exec ns2 ip link set lo up

# Enable BBR + fq qdisc inside each namespace
for ns in ns1 ns2; do
  sudo ip netns exec "$ns" sysctl -w net.ipv4.tcp_congestion_control=bbr >/dev/null
done
sudo ip netns exec ns1 tc qdisc replace dev veth1 root fq
sudo ip netns exec ns2 tc qdisc replace dev veth2 root fq

echo "Namespaces ready: ns1<->ns2 (10.0.0.1 <-> 10.0.0.2), BBR+fq set."
