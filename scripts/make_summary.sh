#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob
JSON_DIR="${1:-data/json}"
OUT="data/summary.csv"
mkdir -p "$(dirname "$OUT")"
printf "file,mtu,zerocopy,P,gbps,retrans\n" > "$OUT"

for mtu in 1500 9000; do
  for f in "$JSON_DIR"/iperf_mtu${mtu}_*.json; do
    [ -f "$f" ] || continue
    Z=$(echo "$f" | grep -o '_\(Z\|noZ\)_' | tr -d '_' || true)
    P=$(echo "$f" | sed -n 's/.*_P\([0-9]\+\)_.*/\1/p')
    GBPS=$(jq -r '.end.sum_sent.bits_per_second / 1e9' "$f")
    RETR=$(jq -r '.end.sum_sent.retransmits' "$f")
    printf "%s,%s,%s,%s,%.3f,%s\n" "$(basename "$f")" "$mtu" "$Z" "$P" "$GBPS" "$RETR" >> "$OUT"
  done
done

for f in "$JSON_DIR"/iperf_mtu9000_Z_P4_long_*.json; do
  [ -f "$f" ] || continue
  GBPS=$(jq -r '.end.sum_sent.bits_per_second / 1e9' "$f")
  RETR=$(jq -r '.end.sum_sent.retransmits' "$f")
  printf "%s,9000,Z,4,%.3f,%s\n" "$(basename "$f")" "$GBPS" "$RETR" >> "$OUT"
done

echo "Wrote $OUT"
