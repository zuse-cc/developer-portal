DOCKER_TAG ?= local
PROJECT := developer-portal
DOCKER_PREFIX ?= ghcr.io/zuse-cc
DOCKER_IMAGE := $(DOCKER_PREFIX)/$(PROJECT):$(DOCKER_TAG)

node_modules: package.json yarn.lock
	yarn install --immutable

dist-types: node_modules
	yarn tsc

packages/backend/dist: node_modules dist-types
	yarn build:backend --config ../../app-config.yaml --config ../../app-config.production.yaml

.PHONY: install
install: node_modules

.PHONY: tsc
tsc: dist-types

.PHONY: build
build: packages/backend/dist

.PHONY: run
run:
	yarn start

.PHONY: docker-build
docker-build: packages/backend/dist
	docker image build . -f packages/backend/Dockerfile -t $(DOCKER_IMAGE)

.PHONY: docker-run
docker-run: packages/backend/dist
	docker compose up --build

.PHONY: docker-push
docker-push: docker-build
	docker push $(DOCKER_IMAGE)

.PHONY: clean
clean:
	rm -rf node_modules dist-types packages/backend/dist
