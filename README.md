
[![Tutorial check](https://github.com/NilFoundation/zkllvm-template/actions/workflows/main.yml/badge.svg)](https://github.com/NilFoundation/zkllvm-template/actions/workflows/main.yml)

# zkLLVM Tutorial and Template Project

This repository serves as both a tutorial and a template project for creating an 
application based on the [zkLLVM toolchain](https://github.com/nilfoundation/zkllvm).
Use it to learn about developing zk-enabled apps with zkLLVM step-by-step.

##  Prerequisites

For this tutorial, ensure you have an amd64 machine equipped with Docker or Podman (Linux) or Docker Desktop (macOS).
For Windows users, Docker in WSL is recommended.
While Docker Desktop may work on Windows, it is not officially supported in this tutorial.

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**

- [Introduction](#introduction)
- [Getting started](#getting-started)
  - [1. Repository setup](#1-repository-setup)
  - [2. Using the image `ghcr.io/nilfoundation/toolchain`](#2-using-the-image-ghcrionilfoundationtoolchain)
- [Part 1. Circuit development workflow](#part-1-circuit-development-workflow)
  - [Step 1: Compile a circuit](#step-1-compile-a-circuit)
  - [Step 2: Build a circuit file and an assignment table](#step-2-build-a-circuit-file-and-an-assignment-table)
  - [Step 3: Produce and verify a proof locally](#step-3-produce-and-verify-a-proof-locally)
  - [Step 4: Make an account on the Proof Market](#step-4-make-an-account-on-the-proof-market)
  - [Step 5: Build a circuit statement](#step-5-build-a-circuit-statement)
  - [Step 6: Publish the circuit statement](#step-6-publish-the-circuit-statement)
  - [Step 7: Check the information about your statement](#step-7-check-the-information-about-your-statement)
- [Part 2. Application developer workflow](#part-2-application-developer-workflow)
  - [Step 1: See the statements available on the Proof Market](#step-1-see-the-statements-available-on-the-proof-market)
  - [Step 2: Post a proof request](#step-2-post-a-proof-request)
  - [Step 3: Check if the proof is ready](#step-3-check-if-the-proof-is-ready)
  - [Step 4: Download the proof](#step-4-download-the-proof)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Introduction

This tutorial is structured into sequential steps, 
each executed as a command within the `scripts/run.sh` script.
For first-time users, we strongly recommend utilizing this script. 


After completing the tutorial, you can revisit the steps by manually executing commands in the console.
Detailed explanations of commands, parameters, file formats, and more can be found
under the `🧰 [manual mode]` sections in the collapsed blocks.

# Getting started

## 1. Repository setup

Begin by cloning the repository and its submodules:

```bash
git clone --recurse-submodules https://github.com/NilFoundation/zkllvm-template.git
cd zkllvm-template
```

If you initially cloned without `--recurse-submodules`, update submodules explicitly:

```bash
git submodule update --init --recursive
```

<!-- ## 2. Using the image `ghcr.io/nilfoundation/toolchain`

Throughout this tutorial, we'll utilize a Docker image containing the `=nil;` toolchain:

```bash
docker pull ghcr.io/nilfoundation/toolchain:latest
```

We recommend this specific image as it integrates compatible toolchain components, streamlining the setup process.
This image is tagged according to zkLLVM compiler versions, with `latest` tag always having the latest zkLLVM version.
Typically, using the `latest` image is an optimal choice.
For a list of available tags, visit ghcr.io/nilfounation/toolchain. -->

## 2. Toolchain installation

zkLLVM is distributed as a deb package, so you can install it using the following commands (Ubuntu 20.04):

```bash
echo 'deb [trusted=yes]  http://deb.nil.foundation/ubuntu/ all main' >>/etc/apt/sources.list
apt update
apt install -y zkllvm proof-producer
```

The packages `cmake` and `libboost-all-dev` are required for building the template project:
```bash
apt install -y cmake libboost-all-dev
```

For the additional installation options, check [our docs](https://docs.nil.foundation/zkllvm/starting-first-project/installation).

# Circuit development workflow

In the first part of this tutorial, we'll walk through the development workflow
of a circuit developer.
Most operations will be done on a local machine, without using the Proof Market.
We will build a circuit, pack it into a circuit statement,
and then use it to build a proof for a particular input.
Last thing, we'll post the statement on the Proof Market,
so that zk application developers will be able to request proofs with this statement.

Code in `./src` implements the logic of a storage proof on Ethereum by validating Merkle Tree path of the commited data.
It reuses algorithms and data structures from the the
[Crypto3 C++ high efficiency cryptography library](https://github.com/nilfoundation/crypto3).

## Step 0: Check the toolchain versions

To check the versions of the tools that we will use, run the following commands:

```bash
assigner --version
clang-zkllvm --version
proof-generator-multi-threaded --version
proof-generator-single-threaded --version
```

## Step 1: Configure the project and compile the circuit

In `./src/main.cpp`, we have a function starting with `[[circuit]]`.
This code definition is what we call the circuit itself.
We will use zkLLVM compiler to make a byte-code representation of this circuit.

Run the commands from the root of your project.

Configure the project with `cmake`:
```bash
cmake -G "Unix Makefiles" -B ${ZKLLVM_BUILD:-build} -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER=clang-zkllvm .
```

Compile the circuit:
```bash
make -C ${ZKLLVM_BUILD:-build} template
```

This will create a  `template.ll` file in the `build/src` directory. This file contains the compiled
circuit intermediate representation.

## Step 2: Build a circuit file and an assignment table

Next step is to make a compiled circuit and assignment table.

```bash
assigner -b build/src/template.ll \
         -i src/main-input.json \
         --circuit template.crct \
         --assignment-table template.tbl \
         -e pallas
```

On this step, we run the `assigner`, giving it the circuit in LLVM IR format (`template.ll`)
and the input data (`./src/main-input.json`).
The `assigner` produces two following files:

* Circuit file `template.crct` is the circuit in a binary format that is
  usable by the `proof-generator`.
* Assignment table `template.tbl` is a representation of input data,
  prepared for proof computation with this particular circuit.

## Step 3: Produce and verify a proof locally

Now we have everything ready to produce our first proof.
As a circuit developer, we want to first build it locally, to check that our circuit is working.
We'll use the `proof-generator-single-threaded` CLI, which is a part of the =nil; toolchain.

```bash
proof-generator-single-threaded \
    --circuit="template.crct" \
    --assignment-table="template.tbl" \
    --proof="proof.bin"
```

Note the following lines in the build log:

```
Preprocessing public data...
Preprocessing private data...
Generating proof...
Proof generated
Proof is verified
...
```

In the first lines, `proof-generator` creates a proof, and in the last one it verifies the proof.
The resulting proof is in the file `./proof.bin`.

Congratulations!
You've produced a non-interactive zero-knowledge proof, or, formally speaking, 
a zero-knowledge succinct non-interactive argument of knowledge
([zk-SNARK](https://en.wikipedia.org/wiki/Non-interactive_zero-knowledge_proof)).

<!-- Now it's time to work with the `=nil;` Proof Market. -->

<!-- ## Step 4: Make an account on the Proof Market

To publish statements and order proofs from the Proof Market, you need an account.
We'll use the command line tools to create a new one.

First, run a Docker container with the Proof Market toolchain:

```bash
cd /opt/zkllvm-template
scripts/run.sh run_proof_market_toolchain
```

Great, now you're in the container's console.
Time to make an account:

```bash
cd /proof-market-toolchain
python3 scripts/signup.py user \
    -u <username> \
    -p <password> \
    -e <email>
```

It should return something like this:

```json
{"user":"zkdev","active":true,"extra":{},"error":false,"code":201}
```

This command will save your username and password in two files in the container:
* `/proof-market-toolchain/scripts/.user`
* `/proof-market-toolchain/scripts/.secret`

These files in the container are mounted to `.config/.user` and `.config/.secret` on your machine.
This way, when you stop the container, the files will persist until you run it again.

## Step 5: Build a circuit statement

The Proof Market works with circuits in the form of circuit statements.
A statement is basically a JSON containing the circuit and various metadata
that identifies it.

The `build_statement` command will build a circuit statement from the circuit
that we compiled earlier:

```bash
scripts/run.sh --docker build_statement
```

The `build_statement` command does the following:

1. Runs a new container based on `nilfoundation/proof-market-toolchain`.
2. In the container, runs `prepare_statement.py` to produce a circuit statement.

<details>
  <summary><code>🧰 [manual mode]</code></summary>

To build a statement, we will use the `prepare_statement.py` script,
which is a part of the [Proof Market toolchain](https://github.com/nilfoundation/proof-market-toolchain).

First, start a new container with the Proof Market toolchain.
Remember to exit the `zkllvm` container with `exit` command or start a new console session:

```bash
docker run -it --rm \
    --platform=linux/amd64 \
    --volume $(pwd):/opt/zkllvm-template \
    --volume $(pwd)/.config:/.config/ \
    --volume $(pwd)/.config:/root/.config/ \
    --volume $(pwd)/.config/.user:/proof-market-toolchain/scripts/.user \
    --volume $(pwd)/.config/.secret:/proof-market-toolchain/scripts/.secret \
    --volume $(pwd)/../proof-market-toolchain:/proof-market-toolchain/ \
    --user $(id -u ${USER}):$(id -g ${USER}) \
    ghcr.io/nilfoundation/proof-market-toolchain:0.0.33
```

> The `.config` directory is where you will put the credentials to the Proof Market later on.
Two extra volume mounts make this directory available in places where
parts of the Proof Market toolchain might look for it.

Now pack the circuit into a statement:

```bash
cd /opt/zkllvm-template/
python3 \
    /proof-market-toolchain/scripts/prepare_statement.py \
    --circuit /opt/zkllvm-template/build/src/template.ll \
    --name template \
    --type placeholder-zkllvm \
    --private \
    --output /opt/zkllvm-template/build/template.json
  
# -c, --circuit: path to the circuit file
# -n, --name: statement name
# -o, --output: path to write the statement file
# --private: make the statement private, as it's not intended for production usage
# -t, --type: type of proofs that will be generated with this statement
# (Placeholder is the name of our proof system, see
# https://crypto3.nil.foundation/papers/placeholder.pdf)
```
</details>

As a result, we have the circuit statement file `./build/template.json`.
Later we will use it to generate a proof locally.
We will also push this circuit statement to the Proof Market.


## Step 6: Publish the circuit statement

Remember the statement that we've packed in step 2?
Let's publish it on the Proof Market.

```bash
python3 scripts/statement_tools.py push \
    --file /opt/zkllvm-template/build/template.json
```

This command will return the following output with your statement's ID (key):
```
Statement from /opt/zkllvm-template/build/template.json was pushed with key 12345678.
```

## Step 7: Check the information about your statement

Let's see how the statement is published:

```bash
python3 scripts/statement_tools.py get \
    --key 12345678
```

You should see all the details of your statement in response.

Congratulations! You've built a zkLLVM circuit and published it on the Proof Market.
Now it's time to have a look at how developers of zero-knowledge applications 
use the Proof Market. -->

# Application developer workflow

In this part, we will act as a developer of a zk application.
Our task is to order a proof on the Proof Market:

1. Find a circuit statement.
   We will be using one that has active proof producers,
   who will respond to our request.
2. Post a request for a proof with given statement and particular input.
3. Check that a request was matched and the proof is ready.
4. Download the proof.

All commands in this section run in the container `nilfoundation/proof-market-toolchain`:

```bash
cd /opt/zkllvm-template
scripts/run.sh run_proof_market_toolchain
```

## Step 1: See the statements available on the Proof Market

First, let's see what statements are available on the Proof Market.

```bash
python3 scripts/statement_tools.py get
```

If you're on a live workshop by `=nil;`, use the statement with id `96079532`.
It's built from the circuit code in this template, and accepts input from
`./src/main-input.json`.

## Step 2: Post a proof request

```bash
python3 scripts/request_tools.py push \
    --key 96079532 \
    --cost 10 \
    --file /opt/zkllvm-template/src/main-input.json
```

The output will look like the following, but with different key values.

```
Limit request:	 {
    "_key": "99887766",
    "statement_key": "96079532",
    "cost": 10,
    "sender": "zkdev",
    "status": "created"
}
```

## Step 3: Check if the proof is ready

You can check the request status at any time:

```console
python3 scripts/request_tools.py get --key 99887766
```

You should see almost the same output as before.
Note the `status` field: it reflects whether the Proof Market has assigned
your request to a particular producer, and whether they have provided the proof.

```
Limit request:	 {
    "_key": "99887766",
    "statement_key": "96079532",
    "cost": 10,
    "sender": "zkdev",
    "status": "created"
}
```

## Step 4: Download the proof

When the proof is ready, download it:

```bash
python3 scripts/proof_tools.py get \ 
    --request_key 99887766 \
    --file /tmp/example.proof

ls -l /tmp/example.proof
```

Now the proof can be verified, both off-chain and on-chain.
These steps will be added soon.
