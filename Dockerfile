FROM ubuntu:22.04

RUN DEBIAN_FRONTEND=noninteractive \
    set -xe \
    && echo 'deb [trusted=yes]  http://deb.nil.foundation/ubuntu/ all main' >> /etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends --no-install-suggests \
      zkllvm \
      cmake \
      libboost-all-dev
