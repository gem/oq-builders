#!/usr/bin/env bash
cd ~/oq-builders/installers/windows/nis
docker build --build-arg uid=$(id -u) --rm=true -t wine -f docker/Dockerfile docker
