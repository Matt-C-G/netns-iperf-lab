SHELL := /usr/bin/env bash

# Defaults (can be overridden: MTU=1500 make run, etc.)
MTU ?= 9000
P   ?= 4
Z   ?= Z
DUR ?= 10

.PHONY: all setup run summary plot matrix clean reset

all: summary plot

setup:
	# tolerate already-existing namespaces
	./scripts/setup_netns.sh || true

run:
	# use env-style overrides
	MTU=$(MTU) P=$(P) Z=$(Z) DUR=$(DUR) ./scripts/run_iperf.sh

summary:
	./scripts/make_summary.sh

plot:
	python3 analysis/plot_summary.py

matrix:
	for mtu in 1500 9000; do \
	  for z in Z noZ; do \
	    for p in 1 2 4 6 8 10; do \
	      MTU=$$mtu Z=$$z P=$$p DUR=$(DUR) ./scripts/run_iperf.sh; \
	    done; \
	  done; \
	done ; \
	$(MAKE) summary plot

clean:
	./scripts/clean_netns.sh

# handy: blow away and recreate namespaces
reset: clean setup
