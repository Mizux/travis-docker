#!/usr/bin/env bash
set -x
set -e

# Linux Native build using Makefile
if [ "${TRAVIS_OS_NAME}" == linux ] && [ "${DISTRO}" == native ] && [ "${BUILDER}" == make ]; then
	if [ "${LANGUAGE}" == cc ]; then
		sudo apt-get -y install git autoconf libtool zlib1g-dev gawk g++ curl cmake make lsb-release;
	elif [ "${LANGUAGE}" == python ];then
		sudo apt-get -y install swig git autoconf libtool zlib1g-dev gawk g++ curl cmake make lsb-release;
		pyenv global system 3.6;
		python3.6 -m pip install virtualenv wheel six;
	elif [ "${LANGUAGE}" == java ];then
		sudo apt-get -y install default-jdk swig git autoconf libtool zlib1g-dev gawk g++ curl cmake make lsb-release;
	elif [ "${LANGUAGE}" == csharp ];then
		sudo apt-get -y install mono-complete swig git autoconf libtool zlib1g-dev gawk g++ curl cmake make lsb-release;
	fi
fi

# Linux Native build using CMake
if [ "${TRAVIS_OS_NAME}" == linux ] && [ "${DISTRO}" == native ] && [ "${BUILDER}" == cmake ]; then
	cd /tmp/ &&	curl -s -J -O -k -L \
		'https://sourceforge.net/projects/swig/files/swig/swig-3.0.12/swig-3.0.12.tar.gz/download' && \
		tar zxf swig-3.0.12.tar.gz && cd swig-3.0.12 && \
		./configure --prefix "${HOME}"/swig/ && make && make install && \
		export PATH="${HOME}"/swig/bin:"${PATH}" && \
		cd "${TRAVIS_BUILD_DIR}";
	pyenv global system 3.6;
	python3.6 -m pip install virtualenv wheel;
fi

# OSX Native build using Makefile or CMake
if [ "${TRAVIS_OS_NAME}" == osx ] && 	[ "${DISTRO}" == native ]; then
	if [ "${LANGUAGE}" == python ];then
		# work around https://github.com/travis-ci/travis-ci/issues/8552
		sudo chown -R "$(whoami)" /usr/local;
		brew update;
		brew install swig;
		brew install python3;
	fi
fi
