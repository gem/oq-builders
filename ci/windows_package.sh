#!/usr/bin/env bash
cd /home/runner/work/oq-builders/oq-builders/installers/windows/nsis
# build the docker to use for installer
docker build --build-arg uid=$(id -u) --rm=true -t wine -f docker/Dockerfile docker
#
docker run -e GEM_SET_DEBUG=1 -e GEM_SET_BRANCH=master -e GEM_SET_BRANCH_TOOLS=master -v $(pwd):/io --rm wine  /io/docker/build.sh
ls -lrt *OpenQuake_Engine*
#
echo "move output to folder for upload artifacts"
mkdir /home/runner/work/oq-builders/oq-builders/out
mv *OpenQuake_Engine* /home/runner/work/oq-builders/oq-builders/out
#Generate SHA-256 Hashes for Files
cd /home/runner/work/oq-builders/oq-builders/out
for pkg in *; do
	sha256sum $pkg > $pkg.sha256
done
