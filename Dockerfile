# build to ghcr.io/nilfoundation/zkllvm-template:latest
FROM ghcr.io/nilfoundation/build-base:1.76.0

ARG ZKLLVM_VERSION=0.0.84

RUN DEBIAN_FRONTEND=noninteractive \
    echo 'deb [trusted=yes]  http://deb.nil.foundation/ubuntu/ all main' >> /etc/apt/sources.list \
    && apt-get update \
    && apt-get -y --no-install-recommends --no-install-suggests install \
      build-essential \
      cmake \
      git \
      zkllvm=${ZKLLVM_VERSION} \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/zkllvm-template
