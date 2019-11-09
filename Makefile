VERSION := $(strip $(shell [ -d .git ] && git describe --always --tags --dirty))
BUILD_DATE := $(shell date -u +"%Y-%m-%dT%H:%M:%S%Z")
VCS_REF := $(strip $(shell [ -d .git ] && git rev-parse --short HEAD))
GO_VERSION=1.13
JSONNET_VERSION=0.14.0
GOLANGCILINT_VERSION=1.20.0
DOCKER_REPO=kakkoyun/go-jsonnet-ci
DOCKER_IMAGE=${DOCKER_REPO}:${VERSION}

.DEFAULT_GOAL := push

.PHONY: build
build:
	docker build \
		--build-arg BUILD_DATE="$(BUILD_DATE)" \
		--build-arg VERSION="$(VERSION)" \
		--build-arg VCS_REF="$(VCS_REF)" \
		--build-arg DOCKERFILE_PATH="/Dockerfile" \
		--build-arg GO_VERSION=${GO_VERSION} \
		--build-arg GOLANGCILINT_VERSION=${GOLANGCILINT_VERSION} \
		--build-arg JSONNET_VERSION=${JSONNET_VERSION} \
		-t ${DOCKER_IMAGE} -t ${DOCKER_REPO}:latest .

.PHONY: push
push: build
	docker push ${DOCKER_REPO}
