#!/bin/bash
# -*- coding: utf-8 -*-
# vim: tabstop=4 shiftwidth=4 softtabstop=4
#
# Copyright (C) 2017-2025 GEM Foundation
#
# OpenQuake is free software: you can redistribute it and/or modify it
# under the terms of the GNU Affero General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# OpenQuake is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with OpenQuake. If not, see <http://www.gnu.org/licenses/>.

if [ "$GEM_SET_DEBUG" ]; then
    set -x
fi

if [ "$GEM_SET_BRANCH" ]; then
    OQ_BRANCH=$GEM_SET_BRANCH
else
    OQ_BRANCH=master
fi

if [ "$GEM_SET_OUTPUT" ]; then
    OQ_OUTPUT=$GEM_SET_OUTPUT
else
    OQ_OUTPUT="exe"
fi

if [ "$GEM_SET_BRANCH_TOOLS" ]; then
    TOOLS_BRANCH=$GEM_SET_BRANCH_TOOLS
else
    TOOLS_BRANCH=$OQ_BRANCH
fi

if [[ $GEM_SET_RELEASE =~ ^[0-9]+$ ]]; then
    PKG_REL=$GEM_SET_RELEASE
fi

function fix-scripts {
	for f in $*; do
		sed -i 's/Z:\\io\\python-dist\\python3\\//g' "$f"
	done
}


# Default software distribution
PY="3.11.6"
PY_ZIP="python-${PY}-win64.zip"
PIP="get-pip.py"


DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
cd $DIR && echo "Working in: $(pwd)"
ls -lrt

# pre-cleanup
rm -Rf *.zip *.exe
rm -Rf src/oq-*
rm -Rf python-dist/python3/*
rm -Rf demos/*

cd src

if [ ! -f $PY_ZIP ]; then
    PY_ZIP=${HOME}/${PY_ZIP}
fi
unzip -q $PY_ZIP -d ../python-dist/python3

if [ ! -f $PIP ]; then
    PIP=${HOME}/${PIP}
fi
# test wine and NSIS
wine ${HOME}/.wine/drive_c/Program\ Files\ \(x86\)/NSIS/makensis.exe /VERSION
#
wine ../python-dist/python3/python.exe $PIP

# Extract wheels to be included in the installation
# Make sure symlinks are ignored to retain compatibility with WINE/Windows
git config --global core.symlinks false
## Core apps
echo "Downloading core apps"
for app in oq-engine; do
    git clone -b $OQ_BRANCH --depth=1 https://github.com/gem/${app}.git
    git -C ${app} status
    wine ../python-dist/python3/python.exe -m pip wheel --disable-pip-version-check --no-deps -w ../oq-dist/engine ./${app}
done

## Standalone apps
echo "Downloading standalone apps"
for app in oq-platform-standalone oq-platform-ipt oq-platform-taxtweb oq-platform-taxonomy; do
    git clone -b $TOOLS_BRANCH --depth=1 https://github.com/gem/${app}.git
    wine ../python-dist/python3/python.exe -m pip wheel --disable-pip-version-check --no-deps -w ../oq-dist/tools ./${app}
    if [ "$app" = "oq-platform-taxtweb" ]; then
        export PYBUILD_NAME="oq-taxonomy"
        wine ../python-dist/python3/python.exe -m pip wheel --disable-pip-version-check --no-deps -w ../oq-dist/tools ./${app}
        unset PYBUILD_NAME
    fi
done

echo "Extracting python wheels"
wine ../python-dist/python3/python.exe -m pip install --disable-pip-version-check --no-warn-script-location --force-reinstall --ignore-installed --upgrade --no-deps --no-index -r oq-engine/requirements-py311-win64.txt
#
if [ $GEM_SET_BUILD_SCIENCE == 1 ]; then
    wine ../python-dist/python3/python.exe -m pip install build
    echo "Downloading ScienceTools apps"
    git clone -b master --depth=1 https://github.com/GEMScienceTools/oq-mbtk.git
    echo "Extracting python wheels for oq-mbtk"
    wine ../python-dist/python3/python.exe -m pip install --disable-pip-version-check --no-warn-script-location -r oq-mbtk/requirements_win64.txt
	cd oq-mbtk
    wine ../../python-dist/python3/python.exe  -m build -x -w . -o ../../oq-dist/oq-mbtk
	cd ..
    echo "Extracting python wheels for VMTK-Vulnerability-Modellers-ToolKit"
    git clone -b master --depth=1 https://github.com/GEMScienceTools/VMTK-Vulnerability-Modellers-ToolKit.git $(pwd)/oq-vmtk
    wine ../python-dist/python3/python.exe -m pip install --disable-pip-version-check --no-warn-script-location -r oq-vmtk/requirements_win64.txt
fi

cd $DIR/oq-dist
for d in *; do
	ls $d | grep whl > $d/index.txt
done

cd $DIR

fix-scripts ${DIR}/python-dist/python3/Scripts/*.exe

ini_vers="$(cat src/oq-engine/openquake/baselib/__init__.py | sed -n "s/^__version__[  ]*=[    ]*['\"]\([^'\"]\+\)['\"].*/\1/gp")"
git_time="$(date -d @$(git -C src/oq-engine log --format=%ct -1) '+%y%m%d%H%M')"

cp installer.nsi.tmpl installer.nsi
sed -i "s/\${MYVERSION}/$ini_vers/g" installer.nsi
if [ $PKG_REL ]; then
    sed -i "s/\${MYTIMESTAMP}/$PKG_REL/g" installer.nsi
else
    sed -i "s/\${MYTIMESTAMP}/$git_time/g" installer.nsi
fi

if [ $GEM_SET_BUILD_SCIENCE == 1 ]; then
    echo "Working in: $(pwd)"
    sed -i '/^#GEM_SET_BUILD_SCIENCE/r science.sec' installer.nsi
    # Get a copy of VMTK master repo
    echo "Clone VMTK repos"
	mkdir $(pwd)/oq-vmtk
    git clone -b master --depth=1 https://github.com/GEMScienceTools/VMTK-Vulnerability-Modellers-ToolKit.git $(pwd)/oq-vmtk
    echo "Clone MBTK repos"
    git clone -b master --depth=1 https://github.com/GEMScienceTools/oq-mbtk.git
    echo "Add GMT "
	wget https://github.com/GenericMappingTools/gmt/releases/download/6.5.0/gmt-6.5.0-win64.zip
	cd $(pwd)
	unzip ./gmt-6.5.0-win64.zip -d ./GMT
fi
# Get the demo and the README
cp -r src/oq-engine/demos .
src/oq-engine/helpers/zipdemos.sh $(pwd)/demos

# create absolute links starting from relatives and resolve '../' paths
sed "s@](\([^:]\+)\)@](https://github.com/gem/oq-engine/blob/${OQ_BRANCH}/\1@g;s@/${OQ_BRANCH}/\.\.@@g" < src/oq-engine/README.md > /tmp/README.$$.md
python3 -m markdown /tmp/README.$$.md > README.html
rm /tmp/README.$$.md

# AE remove on 11/21/24
## Get a copy of the OQ manual if not yet available
#if [ ! -f OpenQuake\ manual.pdf ]; then
#    wget -O- https://docs.openquake.org/manuals/OpenQuake%20Manual%20%28master%29.pdf > OpenQuake\ manual.pdf
#fi


if [[ $OQ_OUTPUT = *"exe"* ]]; then
    echo "Generating NSIS installer"
    wine ${HOME}/.wine/drive_c/Program\ Files\ \(x86\)/NSIS/makensis.exe /V4 installer.nsi
fi

if [[ $OQ_OUTPUT = *"zip"* ]]; then
    cd $DIR/oq-dist
    for d in *; do
		wine ../python-dist/python3/python.exe -m pip install --disable-pip-version-check --no-warn-script-location --force-reinstall --ignore-installed --upgrade --no-deps --no-index $d/*.whl
    done
    fix-scripts ${DIR}/python-dist/python3/Scripts/*.exe
    cp ${DIR}/dist/msvcp/x64/msvcp140.dll ${DIR}/python-dist/python3
    echo "Generating ZIP archive"
    ZIP="OpenQuake_Engine_${ini_vers}_${git_time}.zip"
    cd $DIR/python-dist
    zip -qr $DIR/${ZIP} python3
    cd $DIR
    #zip -qr $DIR/${ZIP} *.bat *.pdf demos README.html LICENSE.txt
    zip -qr $DIR/${ZIP} *.bat demos README.html LICENSE.txt
fi
