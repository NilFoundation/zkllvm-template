# zkLLVM Template

This is a template of a project using zkLLVM compiler.

The repository contains template code to prove a BLS signature via zkLLVM using
[Crypto3 C++ cryptography suite](https://github.com/nilfoundation/crypto3) as an SDK.

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Step 1. Get zkLLVM](#step-1-get-zkllvm)
  - [Install zkLLVM from a .deb package](#install-zkllvm-from-a-deb-package)
  - [Build zkLLVM from source](#build-zkllvm-from-source)
- [Step 2. Build the project](#step-2-build-the-project)
- [Common build issues](#common-build-issues)
  - [Compilation Errors](#compilation-errors)
  - [Submodule management](#submodule-management)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Step 1. Get zkLLVM

## Install zkLLVM from a .deb package

On Debian-like systems with AMD64 architecture you can install zkLLVM from a package.

1.  [Download the latest release](https://github.com/NilFoundation/zkllvm/releases/) from GitHub.

    ```
    wget https://github.com/NilFoundation/zkllvm/releases/download/v0.0.44/zkllvm-16.0.0-Linux.deb
    ```

2.  Install the package
    
    ```
    dpkg -i zkllvm-16.0.0-Linux.deb
    ```
    
    When installed from a package, zkLLVM will replace the system-default clang.

    ```console
    $ clang --version
    clang version 16.0.0 (git@github.com:NilFoundation/zkllvm-circifier.git 4d230ed398898e2328862fbde0e76a377d7d8884)
    Target: x86_64-unknown-linux-gnu
    Thread model: posix
    InstalledDir: /usr/bin
    ```

## Build zkLLVM from source

1.  Install the following packages:
  
    - [Boost](https://www.boost.org/) >= 1.76.0
    - [cmake](https://cmake.org/) >= 3.5
    - [clang](https://clang.llvm.org/) >= 14.0.6

    On Debian systems, everything except Boost can be installed with the following command:
    
    ```
    sudo apt install build-essential libssl-dev cmake clang git
    ```


1.  Build the zkLLVM compiler

    ```
    git clone --recurse-submodules https://github.com/nilfoundation/zkllvm.git
    cd zkllvm
    cmake -G "Unix Makefiles" -B ${ZKLLVM_BUILD:-build} -DCMAKE_BUILD_TYPE=Release -DCIRCUIT_ASSEMBLY_OUTPUT=TRUE .
    make -C ${ZKLLVM_BUILD:-build} assigner clang -j$(nproc)
    ```
    
    In case of errors, refer to [common build issues](#common-build-issues).

# Step 2. Build the project

1.  Clone the template repo

    ```
    # with SSH, if you have set up SSH keys with GitHub
    git clone --recurese-submodules git@github.com:NilFoundation/zkllvm-template.git
    # with HTTPS
    git clone --recurese-submodules https://github.com/NilFoundation/zkllvm-template.git
    cd zkllvm-template
    ```

1.  Build the project

    The template code is ready to be built with zkLLVM.
  
    ``` 
    mkdir build && cd build
    cmake .. && make
    ```

1.  Run the executable:

    ``` 
    ./src/bls/bls_sig
    ./src/bls_weighted_threshold_sig/bls_weighted_threshold_sig
    ```

# Common build issues

## Compilation Errors

If you have more than one compiler installed, for example, g++ & clang++,
the `cmake` system might pick up the former. You can explicitly force usage of 
clang++ by finding the path and passing it in the variable below.

```
which clang++
cmake .. -DCMAKE_CXX_COMPILER=<path to clang++ from above>
```

## Submodule management

Git maintains a few places where submodule details are cached.
Sometimes updates do not come through.
Examples are deleting submodule and updating the url of a previously checked out submodule.
It is advisable to check these locations for remains or try a new checkout:

- `.gitmodules`
- `.git/config`
- `.git/modules/*`
