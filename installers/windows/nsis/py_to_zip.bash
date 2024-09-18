#!/usr/bin/env bash
# Create zip files to use with installer for windows
PYTHON_MAJOR=311
PYTHON_VERSION=3.11.9
#
echo "create  zip files to use with installer for windows"
apt update
apt install -y zip
cd /opt/wineprefix/drive_c/Python
zip -r -1 python-${PYTHON_VERSION}-win64.zip .
mv python-${PYTHON_VERSION}-win64.zip /io
#
