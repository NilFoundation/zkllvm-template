Steps to reproduce the issue:

0. `sudo mv /usr/include/nil /usr/include/nil-backup` < --- this ensures the build would not pick crypto3 installed with zkllvm (rather the one imported via submodules))
1. make tests-run <---- rebuilds build system with tests enabled, builds `tests` target and runs ctest

What I'm trying to achieve:
1. Extract circuit implementation into a separate "library"
2. Run tests against the library.
3. Have tests live outside `src` folder.