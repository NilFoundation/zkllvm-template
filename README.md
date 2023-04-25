# zkLLVM Template

Tutorial and a template repository for a zk-enabled application project
based on the [zkLLVM toolchain](https://github.com/nilfoundation/zkllvm).

Use it to learn about developing zk-enabled apps with zkLLVM step-by-step.

Code in `./src` is an example of BLS12-381 signature verification via zkLLVM using
[Crypto3 C++ cryptography suite](https://github.com/nilfoundation/crypto3) as an SDK.

# Preparing environment with zkLLVM

## 1. Clone the template repository and submodules

First, clone this repository with all its submodules:

```
git clone --recurse-submodules git@github.com:NilFoundation/zkllvm-template.git
cd zkllvm-template
```

## 2. Run a Docker container

For tutorial purposes, we will do everything in Docker.

First, run a new container named `zkllvm`
and mount this project's directory in it:

```console
$ docker run --name zkllvm \
  --platform=linux/amd64 -it \
  -v $(pwd):/opt/zkllvm-template \
  ubuntu:latest
  
# cd /opt/zkllvm-template
```

## 3. Install zkLLVM and dependencies

zkLLVM is distributed as a deb package, but we need to setup the repository first:

```
echo 'deb [trusted=yes]  http://deb.nil.foundation/ubuntu/ all main' >>/etc/apt/sources.list
apt update
apt install -y zkllvm cmake libboost-all-dev
```

Note that zkLLVM replaces original clang, being a fully compatible drop-in replacement:
```
# clang --version
clang version 16.0.0 (https://github.com/NilFoundation/zkllvm-circifier.git bf352a2e14522504a0c832f2b66f73268c95e621)
Target: x86_64-unknown-linux-gnu
Thread model: posix
InstalledDir: /usr/bin
```

## 4. Stop and restart container when needed

This new Docker container persists when you exit it.
Restart it when you need it again,
and you won't need to reinstall zkLLVM and other dependencies every time.

```console
$ docker container start -i zkllvm
 
root@9ef17682eaca:/# cd /opt/zkllvm-template
```

# Zero-knowledge proof workflow

# Step 1 : Build the intermediate representation (IR) file
``` 
mkdir build && cd build
cmake .. && make zkllvm_zkllvm
```
You should have a circuit IR file called `zkllvm_zkllvm.ll` 

# Step 2: Setup proof market user/toolchain
Please navigate out of the `zkllvm-template` repository

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

# Step 3 :Prepare circuit to publish to Proof Market
```
python3 scripts/prepare_statement.py -c=/root/tmp/zkllvm/build/examples/arithmetics_example.ll -o=arithmetic.json -n=arithmetic -t=placeholder-zkllvm
```

# Step 4: See All Published circuits
```
python3 scripts/statement_tools.py get
```

# Step 5: Push a Bid
```
python3 scripts/bid_tools.py push --cost <cost of the bid> --file <json file with public_input> --key <key of the statement> 
```

# Step 6: Push an Ask
```
python3 scripts/ask_tools.py push --cost <cost of the ask> --key <key of the statement> 
```

# Step 7 : Fetch statements/inputs for proof generation
```
python3 scripts/statement_tools.py get --key <key of the statement> -o <output file>
python3 scripts/public_input_get.py --key <bid key> -o <output file path> 
```

# Step 8 : Generate Proof
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

# Step 9: Publish Proof
```
python3 scripts/proof_tools.py push --bid_key <key of the bid> --ask_key <key of the ask> --file <file with the proof> 
```


# Common issues

## Compilation Errors
If you have more than one compiler installed i.e g++ & clang++. The make system might pick up the former. You can explicitly force usage of 
clang++ by finding the path and passing it in the variable below.

```
`which clang++`  
cmake .. -DCMAKE_CXX_COMPILER=<path to clang++ from above>
```

## Submodule management
Git maintains a few places where submodule details are cached. Sometimes updates do not come through. ex: Deletion , updating
a url of a previously checked out submodule.It is advisable to check these locations for remains or try a new checkout.
- .gitmodules
- .git/config
- .git/modules/*
