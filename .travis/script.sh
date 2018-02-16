#!/usr/bin/env bash
set -e

# Clone the OR-Tools repository
if [ ! -d project ]; then
	git clone --single-branch https://github.com/google/or-tools.git project;
fi

# Native build using Makefile
if [ "${DISTRO}" == native ]; then
	set -x
	if [ "${TRAVIS_OS_NAME}" == linux ]; then
		export PATH="${HOME}"/swig/bin:"${PATH}";
		pyenv global system 3.6;
	fi
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
		if [ "${TRAVIS_OS_NAME}" == linux ]; then
			make detect JDK_DIRECTORY=/usr UNIX_PYTHON_VER=3.6
		else
			make detect UNIX_PYTHON_VER=3.6
		fi
		make third_party
		make "${LANGUAGE}"
		make test_"${LANGUAGE}"
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
fi
