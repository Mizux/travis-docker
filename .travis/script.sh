#!/usr/bin/env bash
set -e

# On linux build inside docker to test several distro.
# also it means we can test locally.
if [ "${TRAVIS_OS_NAME}" == linux ]; then
	make docker_"${DISTRO}";
	make build_"${DISTRO}";
elif [ "${TRAVIS_OS_NAME}" == osx ]; then
	# work around https://github.com/travis-ci/travis-ci/issues/8552
	sudo chown -R "$(whoami)" /usr/local;
	brew update;
	brew install swig;
	brew install python3;
else
	echo "OS name \"${TRAVIS_OS_NAME}\" unknown" && false;
fi

# On MacOS build natively since macos container is not so simple.
if [ "${DISTRO}" == native ] || [ "${TRAVIS_OS_NAME}" == osx ]; then
	git --version;
	clang --version || gcc --version;
	cmake --version;
	git clone --single-branch --depth 2 https://github.com/google/or-tools.git project;
	cd project;
fi

if [ "${BUILD_TYPE}" == make ]; then
	make detect
	make third_party
	make cc && make test_cc
	make python && make test_python
	make csharp && make test_csharp
	make java && make test_java
	make
fi
