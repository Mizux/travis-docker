#!/usr/bin/env bash
set -x
set -e

# Clone the OR-Tools repository
git clone --single-branch https://github.com/google/or-tools.git project;

# Native build using Makefile
if [ "${DISTRO}" == native ]; then
	git --version;
	clang --version || gcc --version;
	cmake --version;
	swig --version;
  python3.6 --version
  python3.6 -m pip --version

	cd project;
	if [ "${BUILDER}" == make ]; then
		make --version
		make detect
		make third_party
		make "${LANGUAGE}"
		make test_"${LANGUAGE}"
	elif [ "${BUILDER}" == cmake ]; then
		cmake -H. -Bbuild
		cmake --build build --target all -- VERBOSE=1
		cmake --build build --target test -- CTEST_OUTPUT_ON_FAILURE=1
	fi
# Linux Docker build using CMake
elif [ "${TRAVIS_OS_NAME}" == linux ] && [ "${BUILDER}" == cmake ]; then
	make docker_"${DISTRO}"
	make configure_"${DISTRO}"
	make build_"${DISTRO}"
	make test_"${DISTRO}"
	make install_"${DISTRO}"
	make test_install_"${DISTRO}"
fi
