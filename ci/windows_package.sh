#!/usr/bin/env bash
cd /home/runner/work/oq-builders/oq-builders/installers/windows/nsis
# build the docker to use for installer
docker build --build-arg uid=$(id -u) --rm=true -t wine -f docker/Dockerfile docker
#
docker run -e GEM_SET_BRANCH=master -e GEM_SET_BRANCH_TOOLS=master -v $(pwd):/io --rm wine  /io/docker/build.sh

