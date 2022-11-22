#!/usr/bin/env bash
# Create zip files to use with installer for windows
PYTHON_MAJOR=39
PYTHON_VERSION=3.9.11
#
echo "create  zip files to use with installer for windows"
apt update
apt install -y zip
cd /opt/wineprefix/drive_c/Python${PYTHON_MAJOR}
zip -r -1 python-${PYTHON_VERSION}-win64.zip .
#
