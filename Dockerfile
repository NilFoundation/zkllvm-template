FROM ubuntu:22.04

RUN DEBIAN_FRONTEND=noninteractive \
    set -xe \
    && echo 'deb [trusted=yes]  http://deb.nil.foundation/ubuntu/ all main' >> /etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends --no-install-suggests \
      zkllvm \
      cmake \
      build-essential \
      wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp
RUN set -xe \
    && wget -q --no-check-certificate \
      https://boostorg.jfrog.io/artifactory/main/release/1.76.0/source/boost_1_76_0.tar.gz \
    && tar -xvf boost_1_76_0.tar.gz \
    && rm boost_1_76_0.tar.gz

WORKDIR /tmp/boost_1_76_0

RUN set -xe \
    && sh ./bootstrap.sh \
    && ./b2 \
    && ./b2 install

WORKDIR /opt/zkllvm-template