#!/usr/bin/env bash
set -euo pipefail

MTU="${MTU:-9000}"          # override: MTU=1500 ./scripts/run_iperf.sh ...
P="${P:-4}"                 # parallel streams
Z="${Z:-Z}"                 # Z or noZ
DUR="${DUR:-10}"            # seconds
SRV_IP="${SRV_IP:-10.10.0.2}"   # iperf3 server in ns2 (matches setup_netns.sh)

OUT_DIR="data/json"
mkdir -p "$OUT_DIR"

# Apply MTU
sudo ip netns exec ns1 ip link set dev veth1 mtu "$MTU"
sudo ip netns exec ns2 ip link set dev veth2 mtu "$MTU"

# Start iperf3 server
sudo ip netns exec ns2 pkill -f iperf3 || true
sudo ip netns exec ns2 sh -c "nohup iperf3 -s >/dev/null 2>&1 &"

# Build flags
ZEROFLAG=""
if [ "$Z" = "Z" ]; then ZEROFLAG="--zerocopy"; fi

STAMP="$(date +%Y%m%d-%H%M%S)"
OUT="${OUT_DIR}/iperf_mtu${MTU}_${Z}_P${P}_${STAMP}.json"

# Run client from ns1 → ns2
sudo ip netns exec ns1 iperf3 -c "$SRV_IP" -t "$DUR" -P "$P" $ZEROFLAG --json > "$OUT"

echo "Wrote $OUT"
