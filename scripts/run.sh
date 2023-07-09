#!/usr/bin/env bash

# This script has all the commands from the tutorial,
# conveniently running in a Docker or Podman environment.
# You can run them with this script to get the job done quick,
# or enter them manually when you want to get into more detail.
# Besides that, each command is checked in CI, just to make sure that
# everything works for you when you run it yourself.

set -euxo pipefail

# define dirs so that we can run scripts from any directory without shifting filesystem paths
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
REPO_ROOT="$SCRIPT_DIR/.."

# Set image versions in the environment before running this script:
# export ZKLLVM_VERSION=0.0.58
# export TOOLCHAIN_VERSION=0.0.31

# If unset, default values will be used:
echo "using nilfoundation/zkllvm-template:${ZKLLVM_VERSION:=0.0.58}"
echo "using nilfoundation/proof-market-toolchain:${TOOLCHAIN_VERSION:=0.0.31}"

# podman is a safer option for using on CI machines
if ! command -v podman; then
    DOCKER="docker"
    DOCKER_OPTS=""
else
    DOCKER="podman"
    DOCKER_OPTS='--detach-keys= --userns=keep-id'
fi

# checking files that should be produced
# on all steps of the pipeline
check_file_exists() {
    FILE1="${1}"
    if [ ! -e "$FILE1" ]
    then
        echo "File $FILE1 was not created" >&2
        exit 1
    else
        echo "File $FILE1 created successfully"
        ls -hal "$FILE1"
    fi
}

# Compile source code into a circuit
compile() {
    if [ "$USE_DOCKER" = true ] ; then
        cd "$REPO_ROOT"
        $DOCKER run $DOCKER_OPTS \
          --rm \
          --platform=linux/amd64 \
          --user $(id -u ${USER}):$(id -g ${USER}) \
          --volume $(pwd):/opt/zkllvm-template \
          ghcr.io/nilfoundation/zkllvm-template:${ZKLLVM_VERSION} \
          sh -c "bash ./scripts/run.sh compile"
        cd -
    else
        rm -rf "$REPO_ROOT/build"
        mkdir -p "$REPO_ROOT/build"
        cd "$REPO_ROOT/build"
        cmake -DCIRCUIT_ASSEMBLY_OUTPUT=TRUE ..
        VERBOSE=1 make template
        cd -
        check_file_exists "$REPO_ROOT/build/src/template.ll"
    fi
}

# Use assigner to produce a constraint file and an assignment table.
# This is not a part of the basic development workflow,
# but can be used for debugging circuits.
run_assigner() {
    if [ "$USE_DOCKER" = true ] ; then
        cd "$REPO_ROOT"
        $DOCKER run $DOCKER_OPTS \
          --rm \
          --platform=linux/amd64 \
          --user $(id -u ${USER}):$(id -g ${USER}) \
          --volume $(pwd):/opt/zkllvm-template \
          ghcr.io/nilfoundation/zkllvm-template:${ZKLLVM_VERSION} \
          sh -c "bash ./scripts/run.sh run_assigner"
        cd -
    else
        cd "$REPO_ROOT/build"
        assigner \
          -b src/template.ll \
          -i ../src/main.inp \
          -c template.crct \
          -t template.tbl \
          -e pallas
        cd -
        check_file_exists "$REPO_ROOT/build/template.crct"
        check_file_exists "$REPO_ROOT/build/template.tbl"
    fi
  }

# Use the Proof Market toolchain to pack circuit into a statement
# that can later be used to produce a proof locally or sent to the
# Proof Market.
build_statement() {
    if [ "$USE_DOCKER" = true ] ; then
        cd "$REPO_ROOT"
        $DOCKER run $DOCKER_OPTS \
          --rm \
          --platform=linux/amd64 \
          --user $(id -u ${USER}):$(id -g ${USER}) \
          --volume $(pwd):/opt/zkllvm-template \
          ghcr.io/nilfoundation/proof-market-toolchain:${TOOLCHAIN_VERSION}  \
          sh -c "bash /opt/zkllvm-template/scripts/run.sh build_statement"
        cd -
    else
        python3 /proof-market-toolchain/scripts/prepare_statement.py \
            --circuit "$REPO_ROOT/build/src/template.ll" \
            --name template --type placeholder-zkllvm \
            --output "$REPO_ROOT/build/template.json"
        check_file_exists "$REPO_ROOT/build/template.json"
    fi
}

# Prove the circuit with particular input.
# See the input files at:
# ./src/main.inp
# ./src/main-input.json
prove() {
    if [ "$USE_DOCKER" = true ] ; then
        cd "$REPO_ROOT"

        # workaround for https://github.com/NilFoundation/proof-market-toolchain/issues/61
        mkdir -p .config
        touch .config/config.ini

        $DOCKER run $DOCKER_OPTS \
          --rm \
          --platform=linux/amd64 \
          --user $(id -u ${USER}):$(id -g ${USER}) \
          --volume $(pwd):/opt/zkllvm-template \
          --volume $(pwd)/.config:/root/.config \
          --volume $(pwd)/.config:/proof-market-toolchain/.config \
          ghcr.io/nilfoundation/proof-market-toolchain:${TOOLCHAIN_VERSION} \
          sh -c "bash /opt/zkllvm-template/scripts/run.sh prove"
        cd -
    else
        cd "$REPO_ROOT"
        proof-generator \
            --circuit_input="$REPO_ROOT/build/template.json" \
            --public_input="$REPO_ROOT/src/main-input.json" \
            --proof_out="$REPO_ROOT/build/template.proof"
        check_file_exists "$REPO_ROOT/build/template.proof"
    fi
}

run_all() {
    compile
    run_assigner
    build_statement
    prove
}

USE_DOCKER=false
SUBCOMMAND=run_all

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -d|--docker) USE_DOCKER=true ;;
        -v|--verbose) set -x ;;
        all) SUBCOMMAND=run_all ;;
        compile) SUBCOMMAND=compile ;;
        run_assigner) SUBCOMMAND=run_assigner ;;
        build_statement) SUBCOMMAND=build_statement ;;
        prove) SUBCOMMAND=prove ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

echo "Running ${SUBCOMMAND}"
$SUBCOMMAND
