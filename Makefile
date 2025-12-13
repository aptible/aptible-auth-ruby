
export COMPOSE_IGNORE_ORPHANS ?= true
export RUBY_VERSION ?= 2.3.1
export COMPOSE_PROJECT_NAME ?= aptible-auth-ruby-$(subst .,_,$(RUBY_VERSION))

default: help

## Show this help message
help:
	@echo "\n\033[1;34mAvailable targets:\033[0m\n"
	@awk 'BEGIN {FS = ":"; prev = ""} \
					/^## / {prev = substr($$0, 4); next} \
					/^[a-zA-Z_-]+:/ {if (prev != "") printf "  \033[1;36m%-20s\033[0m %s\n", $$1, prev; prev = ""} \
					{prev = ""}' $(MAKEFILE_LIST) | sort
	@echo

## Build and pull docker compose images
build:
	docker compose build --pull

## Open shell in a docker container, supports CMD=
bash: build
	$(MAKE) run CMD=bash

CMD ?= bash
## Run command in a docker container, supports CMD=
run:
	docker compose run runner $(CMD)

## Run tests in a docker container, supports ARGS=
test: build
	$(MAKE) test-direct ARGS="$(ARGS)"

## Run tests in a docker container without building, supports ARGS=
test-direct:
	docker compose run runner bundle exec rspec $(ARGS)

## Run rubocop in a docker container, supports ARGS=
lint: build
	$(MAKE) lint-direct ARGS="$(ARGS)"

## Run rubocop in a docker container without building, supports ARGS=
lint-direct:
	docker compose run runner bundle exec rake rubocop $(ARGS)

## Clean up docker compose resources
clean:
	docker compose down --remove-orphans --volumes

.PHONY: build bash test
