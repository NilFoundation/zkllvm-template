
[![Tutorial check](https://github.com/NilFoundation/zkllvm-template/actions/workflows/main.yml/badge.svg)](https://github.com/NilFoundation/zkllvm-template/actions/workflows/main.yml)

# zkLLVM tutorial and template project

Tutorial and a template repository for a zk-enabled application project
based on the [zkLLVM toolchain](https://github.com/nilfoundation/zkllvm).
Use it to learn about developing zk-enabled apps with zkLLVM step-by-step.

For this tutorial, you will need an amd64 machine with Docker or Podman (on Linux)
or Docker Desktop (on macOS).

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**

- [Introduction](#introduction)
- [Getting started](#getting-started)
  - [1. Clone the template repository and submodules](#1-clone-the-template-repository-and-submodules)
  - [2. Get the Docker images with `=nil;` toolchain](#2-get-the-docker-images-with-nil-toolchain)
- [Part 1. Circuit development workflow](#part-1-circuit-development-workflow)
  - [Step 1: Compile a circuit](#step-1-compile-a-circuit)
  - [Step 2: Build a circuit statement](#step-2-build-a-circuit-statement)
  - [Step 3: Produce and verify a proof locally](#step-3-produce-and-verify-a-proof-locally)
  - [Step 4: Make an account on the Proof Market](#step-4-make-an-account-on-the-proof-market)
  - [Step 5: Publish the circuit statement](#step-5-publish-the-circuit-statement)
  - [Step 6: Check the information about your statement](#step-6-check-the-information-about-your-statement)
- [Part 2. Application developer workflow](#part-2-application-developer-workflow)
  - [Step 1: See the statements available on the Proof Market](#step-1-see-the-statements-available-on-the-proof-market)
  - [Step 2: Post a proof request](#step-2-post-a-proof-request)
  - [Step 3: Check if the proof is ready](#step-3-check-if-the-proof-is-ready)
  - [Step 4: Download the proof](#step-4-download-the-proof)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Introduction

You will run each step of this tutorial as a command, conveniently wrapped in the `scripts/run.sh` script.
We recommend using it when you go through the tutorial for the first time.

Once you've completed the tutorial, you can repeat it by running all commands manually in the console.
Look at the `🧰 [manual mode]` instructions in collapsed blocks.
They have all the steps with detailed explanations of commands and their parameters,
file formats and other things.

# Getting started

## 1. Clone the template repository and submodules

First, clone this repository with all its submodules:

```bash
git clone --recurse-submodules git@github.com:NilFoundation/zkllvm-template.git
cd zkllvm-template
```

If you cloned without `--recurse-submodules`, initialize submodules explicitly:

```bash
git submodule update --init --recursive
```

## 2. Get the Docker images with `=nil;` toolchain

In the tutorial, we will use Docker images with parts of the `=nil;` toolchain.
We recommend using them because they're tested for compatibility,
and they save you time on installing and compiling everything:

* The `nilfoundation/zkllvm-template` image has the zkLLVM part of the toolchain,
  including the zkLLVM compiler (`clang`), `assigner`, and `tranpiler` binaries.

* The `nilfoundation/proof-market-toolchain` image has all you need to make an account on 
the `=nil;` Proof Market, put your circuit on it, and order a proof.

Both images are versioned according to the products they contain.
In the tutorial, we'll use the latest compatible versions of both images:

```bash
ZKLLVM_VERSION=0.1.1
docker pull ghcr.io/nilfoundation/zkllvm-template:${ZKLLVM_VERSION}

TOOLCHAIN_VERSION=0.0.37
docker pull ghcr.io/nilfoundation/proof-market-toolchain:${TOOLCHAIN_VERSION}
```

# Part 1. Circuit development workflow

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

## Step 1: Compile a circuit

In `./src/main.cpp`, we have a function starting with `[[circuit]]`.
This code definition is what we call the circuit itself.
We will use zkLLVM compiler to make a byte-code representation of this circuit.

Run the script from the root of your project.

```bash
scripts/run.sh --docker compile
```

The `compile` command does the following:

1. Starts a Docker container based on `nilfoundation/zkllvm-template`. 
2. Makes a clean `./build` directory and initializes `cmake`.
3. Compiles the code into a circuit.

<details>
  <summary><code>🧰 [manual mode]</code></summary>

Start a Docker container with the zkLLVM toolchain:

```bash
docker run --detach --rm \
    --platform=linux/amd64 \
    --volume $(pwd):/opt/zkllvm-template \
    --user $(id -u ${USER}):$(id -g ${USER}) \
    ghcr.io/nilfoundation/zkllvm-template:0.0.58
```
Note that it's a single command, wrapped on several lines.

> The line `--volume $(pwd):/opt/zkllvm-template` mounts the project directory from  
your host machine into the container, so that the source code is available in it.
All the changes will persist on your machine,
so you can stop this container at any time, start a new one, and continue.

> The line `--user $(id -u ${USER}):$(id -g ${USER})` runs container with a user having
the same user and group ID as your own user on the host machine.
With this option, newly created files in the `./build` directory will
belong to your user, and not to the `root`.

Let's check that we have the zkLLVM compiler available in the container.
Note that it replaces the original `clang`, being a fully compatible drop-in replacement:

```console
$ clang --version
clang version 16.0.0 (https://github.com/NilFoundation/zkllvm-circifier.git bf352a2e14522504a0c832f2b66f73268c95e621)
Target: x86_64-unknown-linux-gnu
Thread model: posix
InstalledDir: /usr/bin
```

In the container, create a `./build` directory and compile the code:

```bash
cd /opt/zkllvm-template
rm -rf build && mkdir build && cd build
cmake -DCIRCUIT_ASSEMBLY_OUTPUT=TRUE ..
make template
```

> The extra parameter `DCIRCUIT_ASSEMBLY_OUTPUT=TRUE` is required to produce circuits
in `.ll` format, which is supported by proving tools.
zkLLVM can also produce circuits in another LLVM's IR format, `.bc`, but we won't need it in this tutorial.

</details>

As a result of this step, we get a byte-code file `./build/src/template.ll`.
This is what we call a circuit itself.
It's a binary file in the LLVM's intermediate representation format.

## Step 2: Build a circuit statement

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

## Step 3: Produce and verify a proof locally

Now we have everything ready to produce our first proof.
As a circuit developer, we want to first build it locally, to check that our circuit is working.
We'll use the `proof-generator` CLI, which is a part of the Proof Market toolchain.

```bash
scripts/run.sh --docker prove
```

<details>
  <summary><code>🧰 [manual mode]</code></summary>

Continue in the `proof-market-toolchain` container that you made in step 2.
Run the `proof-generator` binary to generate a proof:

```bash
proof-generator \
    --circuit_input=/opt/zkllvm-template/build/template.json \
    --public_input=/opt/zkllvm-template/src/main-input.json \
    --proof_out=/opt/zkllvm-template/build/template.proof
    
# --circuit_input: path to the circuit statement
# --public_input: path to the file that contains particular input, that we want to make a proof for
# --proof_out: path and name of the proof file
```
</details>

Note the following lines in the build log:

```
generatring zkllvm proof...
Proof is verified
```

In the first line, `proof-generator` creates a proof, and in the second — verifies it.
The resulting proof is in the file `./build/template.proof`.

Congratulations!
You've produced a non-interactive zero-knowledge proof, or, formally speaking, 
a zero-knowledge succinct non-interactive argument of knowledge
([zk-SNARK](https://en.wikipedia.org/wiki/Non-interactive_zero-knowledge_proof)).

Now it's time to work with the `=nil;` Proof Market.

## Step 4: Make an account on the Proof Market

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

## Step 5: Publish the circuit statement

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

## Step 6: Check the information about your statement

Let's see how the statement is published:

```bash
python3 scripts/statement_tools.py get \
    --key 12345678
```

You should see all the details of your statement in response.

Congratulations! You've built a zkLLVM circuit and published it on the Proof Market.
Now it's time to have a look at how developers of zero-knowledge applications 
use the Proof Market.

# Part 2. Application developer workflow

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
