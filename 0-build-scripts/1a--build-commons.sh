#!/bin/bash

# ENABLE DOCKER BUILD OPTIONS
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1
export FS_ROOT='.'
export FS_ROOT_IMAGES="${FS_ROOT}"


mkdir -p "${FS_ROOT}" || exit 126
cd "${FS_ROOT}" || exit 127


# LINTING & CHECK FORMATTING
pre-commit run -a -c "${FS_ROOT}/.pre-commit-config.yaml"


# download Dockerfile's Syntax image
# to provide advanced BuildKit's features
# in all sub-sequent image builds
docker pull docker.io/docker/dockerfile:1.4.3


# abort, if this is not pretty enough
export RES=$?
if [[ ! 0 -eq "${RES}" ]]; then
  exit "${RES}"
fi


# BUILD IMAGES
time docker-compose \
    -f "${FS_ROOT_IMAGES}/docker-compose-common.yml" \
    build utils-w-aws-k8s-cli-latest-versions utils-w-aws-k8s-cli-almost-latest-versions


# TRANSPARENCY ON BUILD
export RES=$?
exit "${RES}"
