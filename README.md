# zkLLVM Template

This is a template of a project using the zkLLVM compiler.

The repository contains template code to prove a BLS signature via zkLLVM using
[Crypto3 C++ cryptography suite](https://github.com/nilfoundation/crypto3) as an SDK.

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Step 1. Get zkLLVM](#step-1-get-zkllvm)
  - [Build from source](#build-from-source)
- [Step 2. Build the project](#step-2-build-the-project)
- [Common build issues](#common-build-issues)
  - [Compilation Errors](#compilation-errors)
  - [Submodule management](#submodule-management)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Step 1. Get zkLLVM

Debian packages for zkLLVM are coming soon.
Meanwhile, you can build it from source.

## Build zkLLVM from source

1.  Install the following packages:
  
    - [Boost](https://www.boost.org/) >= 1.76.0
    - [cmake](https://cmake.org/) >= 3.5
    - [clang](https://clang.llvm.org/) >= 14.0.6

    On Debian systems, everything except Boost can be installed with the following command:
    
    ```bash
    sudo apt install build-essential libssl-dev cmake clang git
    ```

1.  Build the zkLLVM compiler

    ```bash
    git clone --recurse-submodules https://github.com/nilfoundation/zkllvm.git
    cd zkllvm
    cmake -G "Unix Makefiles" -B ${ZKLLVM_BUILD:-build} -DCMAKE_BUILD_TYPE=Release -DCIRCUIT_ASSEMBLY_OUTPUT=TRUE .
    make -C ${ZKLLVM_BUILD:-build} assigner clang -j$(nproc)
    ```
    
    In case of errors, refer to [common build issues](#common-build-issues).

# Step 2. Build the project

1.  Clone the template repo

    ```bash
    # with SSH, if you have set up SSH keys with GitHub
    git clone --recurese-submodules git@github.com:NilFoundation/zkllvm-template.git
    # with HTTPS
    git clone --recurese-submodules https://github.com/NilFoundation/zkllvm-template.git
    cd zkllvm-template
    ```

1.  Build the project

    The template code is ready to be built with zkLLVM.
  
    ```bash
    mkdir build && cd build
    cmake .. && make
    ```

1.  Run the executable:

    ```bash
    ./src/bls/bls_sig
    ./src/bls_weighted_threshold_sig/bls_weighted_threshold_sig
    ```

# Common build issues

## Compilation Errors

If you have more than one compiler installed, for example, g++ & clang++,
the `cmake` system might pick up the former. You can explicitly force usage of 
clang++ by finding the path and passing it in the variable below.

```bash
which clang++
cmake .. -DCMAKE_CXX_COMPILER=<path to clang++ from above>
```

## Submodule management

If you have troubles updating the submodules, check these locations for remains or make a fresh clone:

- `.gitmodules`
- `.git/config`
- `.git/modules/*`
