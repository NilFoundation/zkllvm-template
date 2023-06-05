PROJECT_DIR:=.
PROJECT_NAME:=zkllvm_circuit
BUILD_DIR:=${PROJECT_DIR}/build

git-modules-init:
	git submodule update --init --recursive

git-modules-update:
	git pull --recurse-submodules

git-modules-to-master:
	git submodule foreach --recursive git checkout master

git-modules-reset: git-modules-init git-modules-update git-modules-to-master

git-nuke-modules:
	rm -rf .git/modules && rm -rf libs/crypto3 && rm -rf cmake/modules
	$(MAKE) git-modules-reset

cmake-clean:
	rm -rf ${BUILD_DIR}

cmake-gen:
	cmake -S . -B ${BUILD_DIR}

cmake-regen: cmake-clean cmake-gen

bld:
	cmake --build ${BUILD_DIR} --target ${PROJECT_NAME}

tests-build:
	cmake -DBUILD_TESTS=TRUE -S . -B ${BUILD_DIR}
	cmake --build ${BUILD_DIR} --target tests

tests-run: tests-build
	CTEST_OUTPUT_ON_FAILURE=1 cmake --build ${BUILD_DIR} --target test
