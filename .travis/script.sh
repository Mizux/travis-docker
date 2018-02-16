#!/usr/bin/env bash
set -x
set -e

# Clone the OR-Tools repository since we are an external project...
if [ ! -d project ]; then
	git clone --single-branch https://github.com/google/or-tools.git project;
fi

function checkenv() {
	git --version;
	clang --version || true;
	gcc --version || true;
	make --version
	cmake --version || true;
	swig -version || true;
	python3.6 --version || true;
	python3.6 -m pip --version || true;
}

################
##  MAKEFILE  ##
################
if [ "${BUILDER}" == make ];then
	if [ "${TRAVIS_OS_NAME}" == linux ];then
		if [ "${DISTRO}" == native ];then
			export PATH="${HOME}"/swig/bin:"${PATH}";
			pyenv global system 3.6;
			checkenv
			cd project
			make detect JDK_DIRECTORY="$(dirname "$(dirname "$(which javac)")")" UNIX_PYTHON_VER=3.6
			make third_party
			make "${LANGUAGE}"
			make test_"${LANGUAGE}"
		else
			# Linux Docker Makefile build:
			echo "NOT SUPPORTED"
		fi
	elif [ "${TRAVIS_OS_NAME}" == osx ];then
		if [ "${DISTRO}" == native ];then
			checkenv
			cd project
			make detect UNIX_PYTHON_VER=3.6
			make third_party
			make "${LANGUAGE}"
			make test_"${LANGUAGE}"
		else
			# MacOS Docker Makefile build:
			echo "NOT SUPPORTED"
		fi
	fi
fi

#############
##  CMAKE  ##
#############
if [ "${BUILDER}" == cmake ];then
	if [ "${TRAVIS_OS_NAME}" == linux ];then
		if [ "${DISTRO}" == native ];then
			export PATH="${HOME}"/swig/bin:"${PATH}";
			pyenv global system 3.6;
			checkenv
			cd project
			cmake -H. -Bbuild
			cmake --build build --target all
			cmake --build build --target test -- CTEST_OUTPUT_ON_FAILURE=1
		else
			# We use the .travis/Makefile which orchestrate the Step-by-Step
			# note: we could also only call the last target since dependencies are OK.
			CURRENT_DIR=$(dirname "$(readlink -f "$0")")
			MAKE="make -f ${CURRENT_DIR}/Makefile"
			${MAKE} docker_"${DISTRO}"
			${MAKE} configure_"${DISTRO}"
			${MAKE} build_"${DISTRO}"
			${MAKE} test_"${DISTRO}"
		fi
	elif [ "${TRAVIS_OS_NAME}" == osx ];then
		if [ "${DISTRO}" == native ];then
			checkenv
			cd project
			cmake -H. -Bbuild
			cmake --build build --target all
			cmake --build build --target test -- CTEST_OUTPUT_ON_FAILURE=1
		else
			# MacOS Docker Makefile build:
			echo "NOT SUPPORTED"
		fi
	fi
fi
