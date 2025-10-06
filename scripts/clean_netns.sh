#!/usr/bin/env bash
set -euo pipefail
sudo ip netns del ns1 2>/dev/null || true
sudo ip netns del ns2 2>/dev/null || true
# In case veth remained in root ns:
sudo ip link del veth1 2>/dev/null || true
sudo ip link del veth2 2>/dev/null || true
echo "Cleaned namespaces."
