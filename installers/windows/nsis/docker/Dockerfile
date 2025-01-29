# -*- coding: utf-8 -*-
# vim: tabstop=4 shiftwidth=4 softtabstop=4
# vim: syntax=dockerfile
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

FROM fedora:40
LABEL maintainer="GEM Foundation <devops@openquake.org>"

RUN dnf -y install wget python3-markdown git zip unzip && \
    dnf -y install 'dnf-command(config-manager)' && \
	dnf -y config-manager --add-repo https://dl.winehq.org/wine-builds/fedora/39/winehq.repo && \
	dnf -y install winehq-stable

# instead of use ARG use: --build-arg uid=$(id -u)
ARG uid=998
RUN useradd -u $uid builder

USER builder
ENV HOME /home/builder
#ENV PATH /opt/wine-stable/bin:$PATH
ENV WINEDEBUG -all
WORKDIR $HOME

RUN wget --cache=off https://ftp.openquake.org/windows/thirdparties/nsis-3.09-setup.exe  && \
	wget --cache=off https://ftp.openquake.org/windows/thirdparties/python-3.11.6-win64.zip  && \
    wget --cache=off https://ftp.openquake.org/windows/thirdparties/get-pip.py
#

RUN wine nsis-3.09-setup.exe /S && sleep 10

CMD /bin/bash /io/docker/build.sh
