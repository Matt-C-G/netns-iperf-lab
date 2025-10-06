SHELL := /usr/bin/env bash

# Defaults (override as: make run MTU=9000 P=4 Z=Z DUR=15)
MTU ?= 9000
P   ?= 4
Z   ?= Z
DUR ?= 10

.PHONY: all setup run summary plot matrix verify clean help

all: summary plot ## rebuild CSV + plots from existing JSON

setup: ## create ns1<->ns2 with BBR + fq
	./scripts/setup_netns.sh

run: ## run one iperf3 test (uses MTU/P/Z/DUR; override via make VAR=)
	env MTU=$(MTU) P=$(P) Z=$(Z) DUR=$(DUR) ./scripts/run_iperf.sh

summary: ## rebuild data/summary.csv from JSON
	./scripts/make_summary.sh

plot: ## generate analysis/*.png from summary.csv
	python3 analysis/plot_summary.py

matrix: ## sweep MTU {1500,9000} × Z/noZ × P {1,2,4,6,8,10}; then build CSV+plots
	@for mtu in 1500 9000; do \
	  for z in Z noZ; do \
	    for p in 1 2 4 6 8 10; do \
	      env MTU=$$mtu Z=$$z P=$$p DUR=10 ./scripts/run_iperf.sh; \
	    done; \
	  done; \
	done
	./scripts/make_summary.sh
	python3 analysis/plot_summary.py

verify: ## print kernel/iproute/BBR/qdisc + ns wiring
	./scripts/verify_env.sh

clean: ## tear down namespaces (safe if absent)
	./scripts/clean_netns.sh

help: ## list targets
	@grep -E '^[a-zA-Z_-]+:.*##' $(MAKEFILE_LIST) | sed 's/:.*##/\t- /'
