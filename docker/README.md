
![OpenQuake Logo](https://github.com/gem/oq-infrastructure/raw/master/logos/oq-logo.png)

# OpenQuake Dockerfiles

We provide a sample Dockerfiles that you can deploy Openquake engine and other tools.

To build an image with docker:

docker build . --build-arg oq_branch=master --tag hazard:tools  -f Dockerfile.tools 

docker build . --build-arg oq_branch=master --tag openquake:tools  -f Dockerfile.oqtools 
