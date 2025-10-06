# netns-iperf-lab

[![CI](https://github.com/Matt-C-G/netns-iperf-lab/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/Matt-C-G/netns-iperf-lab/actions/workflows/ci.yml)
![License: MIT](https://img.shields.io/badge/license-MIT-blue)

Reproducible `iperf3` experiments using Linux network namespaces, veth, `fq` qdisc, and BBR.  
Includes scripts to **spin up the topology**, **run tests**, **aggregate JSON → CSV**, and **plot** results.

## One-click checks
- `./scripts/verify_env.sh` — prints kernel, qdisc, BBR, ns wiring
- `sudo bpftrace scripts/tcp_retrans.bt` — live retransmit counter (kernel)

## Dev shell (Nix optional)
```bash
nix develop   # gets iperf3, jq, matplotlib, bpftrace, shellcheck
```
## Summary
```bash
make            # builds data/summary.csv and analysis/*.png from existing JSON


# One-time (or after clean):
make setup                     # create ns1↔ns2 with BBR + fq

# Run one test and save JSON:
MTU=9000 P=4 Z=Z DUR=15 make run

# Rebuild CSV + plots from JSON:
make all                       # = make summary && make plot

# If setup complains namespaces exist:
./scripts/clean_netns.sh && make setup

## Result preview
Throughput vs parallel streams (grouped by MTU & zerocopy):

<img src="analysis/throughput_vs_P.png" width="640"/>

(Also generated: analysis/retrans_vs_P.png)

## Repo layout
- scripts/ – setup/run/clean + make_summary.sh (uses jq)
- data/json/ – raw iperf3 JSON
- data/summary.csv – aggregated results
- analysis/ – plots generated from the CSV
- Makefile – one-command workflows
- GitHub Actions – validates JSON→CSV on every push and uploads the CSV artifact

## What I learned (from this box)

- **BBR + fq behaves well as P increases**: throughput grows until ~P=TODO, then tapers.
- **Jumbo frames help**: MTU 9000 beat MTU 1500 by ~**TODO%** at P=4 with zerocopy.
- **Zerocopy helps at higher P**: with MTU 9000, Z vs noZ at P=8 was **TODO Gb/s vs TODO Gb/s**.
- **Retransmissions stayed low** with fq+BBR; spikes only when P≥TODO and MTU=1500.
- The harness makes it easy to **reproduce and compare**: `make matrix` → CSV → plots.


MIT ©
