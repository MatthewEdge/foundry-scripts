.DEFAULT_GOAL: help

.PHONY: help
help:
	@echo "Options:\n"
	@sed -n 's|^##||p' ${PWD}/Makefile

## build: Build the AMI used by make start. Should only be run once per base image config change
.PHONY: build
build:
	./build.sh

## start: Run the Terraform provisioning step
.PHONY: start
start:
	./start.sh

## stop: Stop the running Foundry instance and clean up its infra
.PHONY: stop
stop:
	./shutdown.sh
