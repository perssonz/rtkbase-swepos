# Copyright (C) 2024 Daniel Persson - All Rights Reserved
# You may use, distribute and modify this code under the terms of the MIT
# license.
#
# You should have received a copy of the MIT license with this file. If not,
# please visit https://github.com/perssonz/rtkbase-swepos.

FROM debian:stable-slim

MAINTAINER Daniel Persson <daniel@persson.tech>
LABEL org.opencontainers.image.source=https://github.com/perssonz/rtkbase-swepos

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y rtklib sshpass wget rsync unzip

# crx2rnx, etc.
WORKDIR /tmp
RUN wget https://terras.gsi.go.jp/ja/crx2rnx/RNXCMP_4.1.0_Linux_x86_64bit.tar.gz
RUN tar xf RNXCMP_4.1.0_Linux_x86_64bit.tar.gz
RUN cp /tmp/RNXCMP_4.1.0_Linux_x86_64bit/bin/* /usr/bin/
RUN ln -s /usr/bin/CRX2RNX /usr/bin/crx2rnx

WORKDIR /