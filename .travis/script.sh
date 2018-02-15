#!/usr/bin/env bash
set -e

# Clone the OR-Tools repository
git clone --single-branch https://github.com/google/or-tools.git project;

# Native build using Makefile
if [ "${DISTRO}" == native ]; then
	git --version;
	clang --version || true;
	gcc --version || true;
	cmake --version || true;
	swig -version || true;
	python3.6 --version || true;
	python3.6 -m pip --version || true;

	cd project;
	if [ "${BUILDER}" == make ]; then
		set -x
		make --version
		make detect UNIX_PYTHON_VER=3.6
		make third_party UNIX_PYTHON_VER=3.6
		make "${LANGUAGE}" UNIX_PYTHON_VER=3.6
		make test_"${LANGUAGE}" UNIX_PYTHON_VER=3.6
	elif [ "${BUILDER}" == cmake ]; then
		set -x
		cmake -H. -Bbuild
		cmake --build build --target all -- VERBOSE=1
		cmake --build build --target test -- CTEST_OUTPUT_ON_FAILURE=1
	fi
	# Linux Docker build using CMake
elif [ "${TRAVIS_OS_NAME}" == linux ] && [ "${BUILDER}" == cmake ]; then
	set -x
	make docker_"${DISTRO}"
	make configure_"${DISTRO}"
	make build_"${DISTRO}"
	make test_"${DISTRO}"
	make install_"${DISTRO}"
	make test_install_"${DISTRO}"
fi
