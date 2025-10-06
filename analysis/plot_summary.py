import csv, os
from collections import defaultdict
import matplotlib.pyplot as plt

csv_path = "data/summary.csv"
if not os.path.exists(csv_path):
    raise SystemExit(f"{csv_path} not found. Run ./scripts/make_summary.sh first.")

groups = defaultdict(list)  # key: (mtu, Z/noZ) -> list of (P, gbps, retr)
with open(csv_path, newline="") as f:
    r = csv.DictReader(f)
    for row in r:
        try:
            mtu = int(row["mtu"])
            z = row["zerocopy"] or ""
            P = int(row["P"]) if row["P"] else None
            gbps = float(row["gbps"]) if row["gbps"] else 0.0
            retr = float(row["retrans"]) if row["retrans"] else 0.0
            if P is None:
                continue
            groups[(mtu, z)].append((P, gbps, retr))
        except Exception:
            # skip malformed rows
            pass

# sort each group by P
for k in list(groups):
    groups[k] = sorted(groups[k], key=lambda t: t[0])

def lineplot(y_index, ylabel, outfile):
    plt.figure()
    for (mtu, z), rows in sorted(groups.items()):
        xs = [p for p, _, _ in rows]
        ys = [ (g if y_index==1 else r) for _, g, r in rows ]
        lbl = f"MTU {mtu} / {z or 'unknown'}"
        plt.plot(xs, ys, marker="o", label=lbl)
    plt.xlabel("Parallel streams (P)")
    plt.ylabel(ylabel)
    plt.title(ylabel + " vs P")
    plt.grid(True, alpha=0.3)
    plt.legend()
    os.makedirs("analysis", exist_ok=True)
    plt.savefig(os.path.join("analysis", outfile), dpi=140, bbox_inches="tight")
    plt.close()

lineplot(1, "Throughput (Gb/s)", "throughput_vs_P.png")
lineplot(2, "Retransmissions (count)", "retrans_vs_P.png")
print("Wrote analysis/throughput_vs_P.png and analysis/retrans_vs_P.png")
