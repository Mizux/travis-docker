#!/usr/bin/env bash
set -e

# Clone the OR-Tools repository
if [ ! -d project ]; then
	git clone --single-branch https://github.com/google/or-tools.git project;
fi

# Native build using Makefile
if [ "${DISTRO}" == native ]; then
  if [ "${TRAVIS_OS_NAME}" == linux ]; then
		export JAVA_HOME=/usr/bin
		export PATH="${HOME}"/swig/bin:"${PATH}"
		pyenv global system 3.6;
	fi
	set -x
	git --version;
	clang --version || true;
	gcc --version || true;
	cmake --version || true;
	swig -version || true;
	python3.6 --version || true;
	python3.6 -m pip --version || true;
	set +x

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
		cmake --build build --target all
		cmake --build build --target test -- CTEST_OUTPUT_ON_FAILURE=1
	fi
	# Linux Docker build using CMake
elif [ "${TRAVIS_OS_NAME}" == linux ] && [ "${BUILDER}" == cmake ]; then
	CURRENT_DIR=$(dirname "$(readlink -f "$0")")
	MAKE="make -f ${CURRENT_DIR}/Makefile"
	set -x
	${MAKE} print-ROOT_DIR
	${MAKE} docker_"${DISTRO}"
	${MAKE} configure_"${DISTRO}"
	${MAKE} build_"${DISTRO}"
	${MAKE} test_"${DISTRO}"
	${MAKE} install_"${DISTRO}"
fi
