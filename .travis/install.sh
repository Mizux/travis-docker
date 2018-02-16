#!/usr/bin/env bash
set -x
set -e

# Linux Native build using Make or CMake
if [ "${TRAVIS_OS_NAME}" == linux ] && [ "${DISTRO}" == native ]; then
	cd /tmp/ &&	curl -s -J -O -k -L \
		'https://sourceforge.net/projects/swig/files/swig/swig-3.0.12/swig-3.0.12.tar.gz/download' && \
		tar zxf swig-3.0.12.tar.gz && cd swig-3.0.12 && \
		./configure --prefix "${HOME}"/swig/ && make && make install;
	pyenv global system 3.6;
	python3.6 -m pip install virtualenv wheel;
fi

# Linux Native build using Makefile
if [ "${TRAVIS_OS_NAME}" == linux ] && [ "${DISTRO}" == native ] && [ "${BUILDER}" == make ]; then
	sudo apt-get -y install \
		git autoconf libtool zlib1g-dev gawk g++ curl cmake make lsb-release;
	if [ "${LANGUAGE}" == python ];then
		python3.6 -m pip install six;
	elif [ "${LANGUAGE}" == java ];then
		sudo apt-get -y install default-jdk;
	elif [ "${LANGUAGE}" == csharp ];then
		sudo apt-get -y install mono-complete;
	fi
fi

# OSX Native build using Makefile or CMake
if [ "${TRAVIS_OS_NAME}" == osx ] && 	[ "${DISTRO}" == native ]; then
	# work around https://github.com/travis-ci/travis-ci/issues/8552
	sudo chown -R "$(whoami)" /usr/local;
	brew update;
	if [ "${LANGUAGE}" != cc ]; then
		brew install swig;
	fi
	if [ "${LANGUAGE}" == python ];then
		brew install python3;
	elif [ "${LANGUAGE}" == java ];then
		brew cask install java;
	elif [ "${LANGUAGE}" == csharp ];then
		brew install mono;
	fi
fi
