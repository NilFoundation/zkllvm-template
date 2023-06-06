#/usr/bin/env bash
set -euxo pipefail

# podman is a safer option for using on CI machines
if ! command -v podman; then
    DOCKER="docker"
    DOCKER_OPTS=""
else
    DOCKER="podman"
    DOCKER_OPTS='--detach-keys= --userns=keep-id'
fi

$DOCKER run $DOCKER_OPTS \
  --rm \
  --platform=linux/amd64 \
  --user $(id -u ${USER}):$(id -g ${USER}) \
  --volume $(pwd):/opt/zkllvm-template \
  ghcr.io/nilfoundation/zkllvm-template:latest \
  sh -c "bash ./scripts/build-circuit-ll.sh"
