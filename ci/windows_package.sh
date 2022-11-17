#!/usr/bin/env bash
cd /home/runner/work/oq-builders/oq-builders/installers/windows/nis
#
docker build --build-arg uid=$(id -u) --rm=true -t wine -f docker/Dockerfile docker
