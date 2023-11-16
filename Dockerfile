# build to ghcr.io/nilfoundation/toolchain:latest
FROM ghcr.io/nilfoundation/proof-market-toolchain:base

ARG ZKLLVM_VERSION=0.1.7
ARG PROOF_GENERATOR_VERSION=0.1.1

RUN DEBIAN_FRONTEND=noninteractive \
    echo 'deb [trusted=yes]  http://deb.nil.foundation/ubuntu/ all main' >> /etc/apt/sources.list \
    && apt-get update \
    && apt-get -y --no-install-recommends --no-install-suggests install \
      build-essential \
      cmake \
      git \
      zkllvm=${ZKLLVM_VERSION} \
      proof-generator=${PROOF_GENERATOR_VERSION} \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir /root/.config \
    && touch /root/.config/config.ini

WORKDIR /opt/zkllvm-template