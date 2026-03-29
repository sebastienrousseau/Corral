SHELL := /usr/bin/env bash
SCRIPT := clone-gh-repos.sh

.PHONY: lint check all

all: check

lint:
	shellcheck $(SCRIPT)

check: lint
	bash -n $(SCRIPT)
	@echo "All checks passed."
