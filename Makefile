GOCMD=go
GOLINT=golint
GOFMT=gofmt
MAKE=make
FULL_IMAGE_NAME=oszura/$(IMAGE_NAME)

SH_HTTP_PORT=3222
SH_CLI_TCP_PORT=3333
SH_MONGO_URI=mongodb://localhost:27017
SH_MONGO_DB=smarthome
SH_INFLUX_URI=http://localhost:8086

.DEFAULT_GOAL := all

.PHONY: all
all:
	$(MAKE) deps
	$(MAKE) shapi

### Build
.PHONY: deps
deps:
	$(shell cd /; $(GOCMD) get -u golang.org/x/lint/golint)
	$(GOCMD) mod vendor

shapi:
	$(GOCMD) build -mod=vendor -o shapi

### Code quality
.PHONY: test
test:
	$(GOCMD) test -mod=vendor ./...

.PHONY: lint
lint:
	./scripts/gofmt_test.sh
	$(GOLINT) ./... | grep -v vendor/ && exit 1 || exit 0
	$(GOCMD) vet -mod=vendor ./... | grep -v vendor/ && exit 1 || exit 0

.PHONY: fix
fix:
	$(GOFMT) -w .

### Containerization
.PHONY: image
image:
ifdef ENV
	docker build --tag $(FULL_IMAGE_NAME)-$(ENV):$(V) --file=./docker/$(IMAGE_NAME)/$(ENV)/Dockerfile .
else
	docker build --tag $(FULL_IMAGE_NAME):$(V) --file=./docker/$(IMAGE_NAME)/Dockerfile .
endif

.PHONY: run-services
run-services:
	cd docker/sh-api/dev && docker-compose --verbose up

.PHONY: run-container
run-container:
	docker run --network=host -p $(SH_HTTP_PORT):$(SH_HTTP_PORT) -it -v $(shell pwd):/root/go/src/github.com/smart-evolution/shapi \
	    -e SH_MONGO_URI=$(SH_MONGO_URI) \
	    -e SH_MONGO_DB=$(SH_MONGO_DB) \
	    -e SH_HTTP_PORT=$(SH_HTTP_PORT) \
	    -e SH_INFLUX_URI=$(SH_INFLUX_URI) \
	    $(FULL_IMAGE_NAME)-dev

### Deployment
.PHONY: deploy
deploy:
	kubectl apply -f ./kubernetes/deployment.yaml
	kubectl apply -f ./kubernetes/service.yaml

### Utilities
.PHONY: run
run:
	SH_MONGO_URI=$(SH_MONGO_URI) \
	SH_MONGO_DB=$(SH_MONGO_DB) \
	SH_HTTP_PORT=$(SH_HTTP_PORT) \
	SH_INFLUX_URI=$(SH_INFLUX_URI) \
	./shapi

.PHONY: clean
clean:
	rm shapi
	rm -rf vendor

.PHONY: version
version:
	git tag $(V)
	./scripts/changelog.sh
	git add ./docs/changelogs/CHANGELOG_$(V).md
	go generate
	git add ./version.go || true
	sed -i "" "s/APP_VERSION=.*/APP_VERSION=$(V)/g" .travis.yml
	git add .travis.yml
	sed -i "" "s/oszura\/sh-api-prod:.*/oszura\/sh-api-prod:$(V)/g" ./kubernetes/deployment.yaml
	git add ./kubernetes/deployment.yaml
	git commit --allow-empty -m "Build $(V)"
	git tag --delete $(V)
	git tag $(V)

.PHONY: help
help:
	@echo  '=================================='
	@echo  'Available tasks:'
	@echo  '=================================='
	@echo  '* Installation:'
	@echo  '- install         - Phony task that installs all required (client'
	@echo  '                    and server - sided) dependencies'
	@echo  ''
	@echo  '* Quality:'
	@echo  '- lint            - Phony task that runs all linting tasks'
	@echo  '- test            - Phony task that runs all unit tests'
	@echo  '- fix             - Fixes some linting errors
	@echo  ''
	@echo  '* Release:'
	@echo  '- all (default)   - Default phony task that builds (client and'
	@echo  '                    and server - sided) binaries for development.'
	@echo  '                    Takes an obligatory param `mode` with values'
	@echo  '                    `dev` or `production`.'
	@echo  '- version         - Phony task. Creates changelog from latest'
	@echo  '                    git tag till the latest commit. Creates commit'
	@echo  '                    with given version (as argument) and tags'
	@echo  '                    this commit with this version. Version has to'
	@echo  '                    be passed as `V` argument with ex. `v0.0.0`'
	@echo  '                    format'
	@echo  ''


