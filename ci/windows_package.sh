#!/usr/bin/env bash
cd /home/runner/work/oq-builders/oq-builders/installers/windows/nsis
#
if [ $GEM_SET_BUILD_SCIENCE == 1 ]; then
    echo "Working in: $(pwd)"
    echo "USE OQ Science Console"
    mv oq-science-console.bat oq-console.bat
else
    echo "Working in: $(pwd)"
    echo "USE OQ engine Console"
    mv oq-science-console.bat oq-console.bat
fi
# build the docker to use for installer
docker build --build-arg uid=$(id -u) --rm=true -t wine -f docker/Dockerfile docker
#
docker run -e GEM_SET_DEBUG=1 -e GEM_SET_BUILD_SCIENCE -e GEM_SET_RELEASE -e GEM_SET_BRANCH -e GEM_SET_BRANCH_TOOLS -v $(pwd):/io --rm wine  /io/docker/build.sh
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
