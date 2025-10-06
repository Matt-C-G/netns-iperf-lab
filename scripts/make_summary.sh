#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob

JSON_DIR="${1:-data/json}"
OUT="data/summary.csv"
mkdir -p "$(dirname "$OUT")"
printf "file,mtu,zerocopy,P,gbps,retrans\n" > "$OUT"

emit_row () {
  local f="$1" mtu="$2" z="$3" p="$4"

  # Pull bps and retrans safely:
  # - prefer end.sum_sent.* then end.sum_received.*
  # - coalesce null/missing to 0
  # - never fail the script
  read -r BPS RETR < <(
    jq -r '[
      (.end.sum_sent.bits_per_second // .end.sum_received.bits_per_second // 0),
      (.end.sum_sent.retransmits      // .end.sum_received.retransmits      // 0)
    ] | @tsv' "$f" 2>/dev/null || echo -e "0\t0"
  )

  # If P is empty, skip (we want P curves)
  if [[ -z "${p:-}" ]]; then
    echo "skip (no P): $(basename "$f")" >&2
    return 0
  fi

  # Guard against non-numeric BPS
  if ! [[ "$BPS" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
    echo "skip (bad bps): $(basename "$f")" >&2
    return 0
  fi

  # Convert to Gbps
  GBPS=$(awk -v b="$BPS" 'BEGIN{printf "%.3f", (b/1e9)}')

  printf "%s,%s,%s,%s,%s,%s\n" \
    "$(basename "$f")" "$mtu" "$z" "$p" "$GBPS" "$RETR" >> "$OUT"
}

# 1500 group
for f in "$JSON_DIR"/iperf_mtu1500_*.json; do
  mtu=1500
  z=$(echo "$f" | grep -o '_\(Z\|noZ\)_' | tr -d '_' || echo "")
  p=$(echo "$f" | sed -n 's/.*_P\([0-9]\+\)_.*/\1/p')
  emit_row "$f" "$mtu" "$z" "$p"
done

# 9000 group
for f in "$JSON_DIR"/iperf_mtu9000_*.json; do
  mtu=9000
  z=$(echo "$f" | grep -o '_\(Z\|noZ\)_' | tr -d '_' || echo "")
  p=$(echo "$f" | sed -n 's/.*_P\([0-9]\+\)_.*/\1/p')
  emit_row "$f" "$mtu" "$z" "$p"
done

echo "Wrote $OUT"
