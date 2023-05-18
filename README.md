
[![Tutorial check](https://github.com/NilFoundation/zkllvm-template/actions/workflows/main.yml/badge.svg)](https://github.com/NilFoundation/zkllvm-template/actions/workflows/main.yml)

# zkLLVM Tutorial and template project

Tutorial and a template repository for a zk-enabled application project
based on the [zkLLVM toolchain](https://github.com/nilfoundation/zkllvm).
Use it to learn about developing zk-enabled apps with zkLLVM step-by-step.

For this tutorial, you will need an amd64 machine with Docker (on Linux) or Docker Desktop (on macOS).


<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**

- [Preparing environment for the tutorial](#preparing-environment-for-the-tutorial)
  - [1. Clone the template repository and submodules](#1-clone-the-template-repository-and-submodules)
  - [2. Get the Docker images with =nil; toolchain](#2-get-the-docker-images-with-nil-toolchain)
- [Part 1. Local development workflow](#part-1-local-development-workflow)
  - [Step 1: Compile a circuit](#step-1-compile-a-circuit)
  - [Step 2: Build a circuit statement](#step-2-build-a-circuit-statement)
  - [Step 3: Produce and verify a proof locally](#step-3-produce-and-verify-a-proof-locally)
- [Part 2. Proof Market workflow](#part-2-proof-market-workflow)
  - [Step 2: Setup proof market user/toolchain](#step-2-setup-proof-market-usertoolchain)
  - [Step 2: Prepare circuit to publish to Proof Market](#step-2-prepare-circuit-to-publish-to-proof-market)
  - [Step 4: See All Published circuits](#step-4-see-all-published-circuits)
  - [Step 5: Push a Bid](#step-5-push-a-bid)
  - [Step 6: Push an Ask](#step-6-push-an-ask)
  - [Step 7 : Fetch statements/inputs for proof generation](#step-7--fetch-statementsinputs-for-proof-generation)
  - [Step 8 : Generate Proof](#step-8--generate-proof)
  - [Step 9: Publish Proof](#step-9-publish-proof)
- [Common issues](#common-issues)
  - [Compilation errors](#compilation-errors)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


# Preparing environment for the tutorial

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

We've prepared Docker images with parts of the `=nil;` toolchain 
that you'll need to run through all development stages with this template.
We recommend using them because they're tested for compatibility,
and they save you time on installing and compiling everything.

* `nilfoundation/zkllvm-template` has the zkLLVM part of the toolchain:
  the zkLLVM compiler (`clang`), `assigner`, and `tranpiler` binaries.
* `nilfoundation/proof-market-toolchain` has all you need to make an account on 
  the `=nil;` Proof Market, put your circuit on it, and order a proof.

These images are versioned according to the products they contain.
In the tutorial, we'll use the latest versions that are compatible with each other.

```bash
export ZKLLVM_VERSION=0.0.58
export TOOLCHAIN_VERSION=0.0.31
docker pull ghcr.io/nilfoundation/zkllvm-template:${ZKLLVM_VERSION}
docker pull ghcr.io/nilfoundation/proof-market-toolchain:${TOOLCHAIN_VERSION}
```

# Part 1. Local development workflow

In the first part of this tutorial, we'll walk through the development workflow on
a local machine, without using the Proof Market.
We will build a circuit, pack it into a circuit statement,
and then use it to verify a proof for a particular input. 

You will run each step as a command, conveniently wrapped in the `./scripts/run.sh` script.
We recommend using it when you go through the tutorial for the first time.

Once you've completed the tutorial, you can repeat it by running all commands manually in the console.
Look at the `[manual mode]` instructions in collapsed blocks.

Code in `./src` is an example of BLS12-381 signature verification via zkLLVM using
[Crypto3 C++ cryptography suite](https://github.com/nilfoundation/crypto3) as an SDK.

## Step 1: Compile a circuit

In `./src/main.cpp`, we have a function starting with `[[circuit]]`.
This code definition is what we call the circuit itself.
We will use zkLLVM compiler to make a byte-code representation of this circuit.

Run the script from the root of your project.

```bash
./scripts/run.sh --docker compile
```

The `compile` command does the following:

1. Starts a Docker container based on `nilfoundation/zkllvm-template`. 
2. Makes a clean `./build` directory and initializes `cmake`.
3. Compiles the code into a circuit.

<details>
  <summary><code>[manual mode]</code></summary>

Start a Docker container with zkLLVM toolchain:

```bash
docker run -it --rm \
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
./scripts/run.sh --docker build_statement
```

The `build_statement` command does the following:

1. Runs a new container based on `nilfoundation/proof-market-toolchain`.
2. In the container, runs `prepare_statement.py` to produce a circuit statement.

<details>
  <summary><code>[manual mode]</code></summary>

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
    --user $(id -u ${USER}):$(id -g ${USER}) \
    ghcr.io/nilfoundation/proof-market-toolchain:0.0.31
```

> The `.config` directory is where you will put the credentials to the Proof Market later on.
Two extra volume mounts make this directory available in places where
parts of the Proof Market toolchain might look for it.

Now pack the circuit into a statement:

```bash
cd /opt/zkllvm-template/
python3 \
    /proof-market-toolchain/scripts/prepare_statement.py \
    -c /opt/zkllvm-template/build/src/template.ll \
    -o /opt/zkllvm-template/build/template.json \
    -n template \
    -t placeholder-zkllvm
  
# -c: path to the circuit file
# -o: path to write the statement file
# -n: statement name
# -t: type of proofs that will be generated with this statement
# (Placeholder is the name of our proof system, see
# https://crypto3.nil.foundation/papers/placeholder.pdf)
```
</details>

As a result, we have the circuit statement file `./build/template.json`.
Later we will use it to generate a proof locally.
We will also push this circuit statement to the Proof Market.

## Step 3: Produce and verify a proof locally

Now we have everything ready to produce our first proof.
We'll use the `proof-generator` CLI, which is a part of the Proof Market toolchain.

```bash
./scripts/run.sh --docker prove
```

<details>
  <summary><code>[manual mode]</code></summary>

Continue in the `proof-market-toolchain` container that you made in step 2.

First, create an empty configuration file in your user's directory.
Later you will put the Proof Market credentials in it.

```bash
touch /opt/zkllvm-template/.config/config.ini
```

Next, run the `proof-generator` binary to generate a proof:

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


# Part 2. Proof Market workflow

In this part, we will interact with the Proof Market in two roles:

* As a circuit developer, who puts a circuit on the market.
* As a zkApp developer, who orders proofs from the market.

## Step 2: Setup proof market user/toolchain
Please navigate out of the `zkllvm-tfemplate` repository

Clone the proof-market-toolchain repository

```
git clone --recurse-submodules git@github.com:NilFoundation/proof-market-toolchain.git
cd proof-market-toolchain
```

- Create a new user
All access to market requires authentication. Please ensure you have a valid username/password. If you have not registered , please look at instructions on how to here via front end .
Or , you can use the below command line in the proof-market-toolchain repository.

```
python3 signup.py -u <username> -p <password> -e <e-mail>
```

Create a .user and a .secret file and add your username and password to it,
You should do this inside the scripts directory in the proof market tool-chain repository.
.user file should consist of your username (without newline)

```
username
```
.secret file should consist of your password(without newline)
```
password
```

## Step 2: Prepare circuit to publish to Proof Market
```
python3 scripts/prepare_statement.py -c=/root/tmp/zkllvm/build/examples/arithmetics_example.ll -o=arithmetic.json -n=arithmetic -t=placeholder-zkllvm
```
  
## Step 4: See All Published circuits
```
python3 scripts/statement_tools.py get
```

## Step 5: Push a Bid
```
python3 scripts/bid_tools.py push --cost <cost of the bid> --file <json file with public_input> --key <key of the statement> 
```

## Step 6: Push an Ask
```
python3 scripts/ask_tools.py push --cost <cost of the ask> --key <key of the statement> 
```

## Step 7 : Fetch statements/inputs for proof generation
```
python3 scripts/statement_tools.py get --key <key of the statement> -o <output file>
python3 scripts/public_input_get.py --key <bid key> -o <output file path> 
```

## Step 8 : Generate Proof
- Build proof generator
```
mkdir build && cd build
cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_COMPILER=/usr/bin/clang-12 -DCMAKE_CXX_COMPILER=/usr/bin/clang++-12 ..
# Single-threaded version
cmake --build . -t proof-generator
```
- Generate Proof!
```
./bin/proof-generator/proof-generator --proof_out=/root/workshop/arith_proof.out --circuit_input=/root/tmp/proof-market-toolchain/arithmetic.json --public_input=/root/tmp/proof-market-toolchain/example/input/arithmetic_example/input.json
```

## Step 9: Publish Proof
```
python3 scripts/proof_tools.py push --bid_key <key of the bid> --ask_key <key of the ask> --file <file with the proof> 
```


# Common issues

## Compilation errors

If you have more than one compiler installed, for example, g++ & clang++, `cmake` might pick up the former.
You can explicitly force usage of clang++ by finding the path and passing it in a variable:

```bash
`which clang++`  
cmake .. -DCMAKE_CXX_COMPILER=<path to clang++ from above>
```
