SHELL := /usr/bin/env bash

.PHONY: all setup run summary clean matrix plot

all: summary plot

setup:
	./scripts/setup_netns.sh

run:
	# Example: MTU=9000 P=4 Z=Z DUR=15 make run
	MTU?=9000 P?=4 Z?=Z DUR?=10 ./scripts/run_iperf.sh

summary:
	./scripts/make_summary.sh

plot:
	python3 analysis/plot_summary.py

matrix:
	# tweak as desired
	for mtu in 1500 9000; do \
	  for z in Z noZ; do \
	    for p in 1 2 4 6 8 10; do \
	      MTU=$$mtu Z=$$z P=$$p DUR=10 ./scripts/run_iperf.sh; \
	    done; \
	  done; \
	done
	./scripts/make_summary.sh
	python3 analysis/plot_summary.py

clean:
	./scripts/clean_netns.sh
