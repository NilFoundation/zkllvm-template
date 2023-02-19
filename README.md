# zkLLVM Template

This repository contains the template repository for the project using zkLLVM as a compiler. 

The repository contains a template code to prove a BLS signature via zkLLVM using [Crypto3 C++ cryptography suite](https://github.com/nilfoundation/crypto3) as an SDK.

# Dependencies

- [Boost](https://www.boost.org/) >= 1.74.0
- [cmake](https://cmake.org/) >= 3.5
- [clang](https://clang.llvm.org/) >= 14.0.6

On *nix systems, the following dependencies need to be present & can be installed using the following command

```
 sudo apt install build-essential libssl-dev libboost-all-dev cmake clang git
```

# Installation 
- Install the zkLLVM compiler
```
git clone --recurse-submodules https://github.com/nilfoundation/zkllvm.git
cd zkllvm
cmake -G "Unix Makefiles" -B ${ZKLLVM_BUILD:-build} -DCMAKE_BUILD_TYPE=Release -DCIRCUIT_ASSEMBLY_OUTPUT=TRUE .
make -C ${ZKLLVM_BUILD:-build} assigner clang -j$(nproc)
```

- Clone the repo 
 ```
git clone https://github.com/NilFoundation/zkllvm-template.git
cd zkllvm-template
```

- Clone all submodules recursively
```
git submodule update --init --recursive
```

- Build 
``` 
mkdir build && cd build
cmake .. && make
```

- Run executable
``` 
./src/bls/bls_sig
./src/bls_weighted_threshold_sig/bls_weighted_threshold_sig
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
