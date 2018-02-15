help:
	@echo "usage:"
	@echo "make docker: generate docker devel images"
	@echo "make configure: execute 'make third_party' using the devel image container"
	@echo "make cc: execute 'make cc' using the devel image container"
	@echo "make python: execute 'make python' using the devel image container"
	@echo "make install: execute the cmake target install using the devel image container,\
 then create an install image with it"
	@echo "make test_install: configure a sample project against it using the install image container"
	@echo "make clean: execute the cmake target clean"
	@echo "make distclean: execute clean and also remove all docker images"
	@echo ""
	@echo "note: Currently test are done on alpine and ubuntu,\
 you can add \"_<distro>\" at end of the previous targets to run only test on this distro\
 (e.g make test_install_alpine)."
	@echo "note: All generated code will be located in the cache/ folder, use distclean to remove it"
	@echo "make print-VAR: print value of VAR for debug purpose"

# Need to add cmd_distro to PHONY otherwise target are ignored since they don't
# contain recipe (using FORCE don't work here)
.PHONY: help all
all: build

ROOT_DIR := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
PROJECT_DIR=${ROOT_DIR}/../project

IMAGE := ortools
UID := $(shell id -u)
GID := $(shell id -g)
#DOCKER_DEVEL_CMD := docker run --rm -it -v ${PWD}:/project -w /project --user ${UID}:${GID}
DOCKER_DEVEL_CMD := docker run --rm --user ${UID}:${GID} -it -v ${PROJECT_DIR}:/project -w /project
DOCKER_INSTALL_CMD := docker run --rm -it -v ${PROJECT_DIR}/cmake/sample:/project -w /project

# $* stem
# $< first prerequist
# $@ target name

# DOCKER
.PHONY: docker docker_alpine docker_ubuntu
docker: docker_alpine docker_ubuntu
docker_alpine: ${ROOT_DIR}/cache/alpine/docker_devel.tar
docker_ubuntu: ${ROOT_DIR}/cache/ubuntu/docker_devel.tar
${ROOT_DIR}/cache/%/docker_devel.tar: ${ROOT_DIR}/docker/%/Dockerfile ${ROOT_DIR}/docker/%/setup.sh
	mkdir -p ${ROOT_DIR}/cache/$*
	@docker image rm -f ${IMAGE}_$*:devel 2>/dev/null
	docker build --no-cache -t ${IMAGE}_$*:devel -f $< ${ROOT_DIR}/docker/$*
	docker save ${IMAGE}_$*:devel -o $@

# DOCKER BASH
.PHONY: bash_alpine bash_ubuntu
bash_alpine: ${ROOT_DIR}/cache/alpine/docker_devel.tar
	${DOCKER_DEVEL_CMD} ${IMAGE}_alpine:devel /bin/sh
bash_ubuntu: ${ROOT_DIR}/cache/ubuntu/docker_devel.tar
	${DOCKER_DEVEL_CMD} ${IMAGE}_ubuntu:devel /bin/bash

# CONFIGURE
.PHONY: configure configure_alpine configure_ubuntu
configure: configure_alpine configure_ubuntu
configure_alpine: ${ROOT_DIR}/cache/alpine/configure.log
configure_ubuntu: ${ROOT_DIR}/cache/ubuntu/configure.log
${ROOT_DIR}/cache/%/configure.log: ${ROOT_DIR}/cache/%/docker_devel.tar \
	${PROJECT_DIR}/CMakeLists.txt ${PROJECT_DIR}/*/CMakeLists.txt \
	${PROJECT_DIR}/cmake/external/*.CMakeLists.txt \
	${PROJECT_DIR}/cmake/*.cmake  ${PROJECT_DIR}/cmake/*Config.cmake.in
	@docker load -i $<
	${DOCKER_DEVEL_CMD} ${IMAGE}_$*:devel /bin/sh -c \
		"cmake -H. -Bbuild/$*"
	@date > $@

# BUILD
.PHONY: build build_alpine build_ubuntu
build: build_alpine build_ubuntu
build_alpine: ${ROOT_DIR}/cache/alpine/build.log
build_ubuntu: ${ROOT_DIR}/cache/ubuntu/build.log
${ROOT_DIR}/cache/%/build.log: ${ROOT_DIR}/cache/%/configure.log ${PROJECT_DIR}/ortools
	${DOCKER_DEVEL_CMD} ${IMAGE}_$*:devel /bin/sh -c \
		"cmake --build build/$* --target all -- VERBOSE=1"
	@date > $@

# TEST
.PHONY: test test_alpine test_ubuntu
test: test_alpine test_ubuntu
test_alpine: ${ROOT_DIR}/cache/alpine/test.log
test_ubuntu: ${ROOT_DIR}/cache/ubuntu/test.log
${ROOT_DIR}/cache/%/test.log: ${ROOT_DIR}/cache/%/build.log
	${DOCKER_DEVEL_CMD} ${IMAGE}_$*:devel /bin/sh -c \
		"cmake --build build/$* --target test -- CTEST_OUTPUT_ON_FAILURE=1"
	@date > $@

# INSTALL
.PHONY: install install_alpine install_ubuntu
install: install_alpine install_ubuntu
install_alpine: ${ROOT_DIR}/cache/alpine/install.log
install_ubuntu: ${ROOT_DIR}/cache/ubuntu/install.log
${ROOT_DIR}/cache/%/install.log: ${ROOT_DIR}/cache/%/build.log
	${DOCKER_DEVEL_CMD} ${IMAGE}_$*:devel /bin/sh -c \
		"cmake --build build/$* --target install -- DESTDIR=install"
	@date > $@

# DOCKER BASH INSTALL
.PHONY: bash_install_alpine bash_install_ubuntu
bash_install_alpine: ${ROOT_DIR}/cache/alpine/install.log
	@docker load -i ${ROOT_DIR}/cache/alpine/docker_install.tar
	${DOCKER_INSTALL_CMD} ${IMAGE}_alpine:install /bin/sh
bash_install_ubuntu: ${ROOT_DIR}/cache/ubuntu/install.log
	@docker load -i ${ROOT_DIR}/cache/ubuntu/docker_install.tar
	${DOCKER_INSTALL_CMD} ${IMAGE}_ubuntu:install /bin/bash

# CLEAN
.PHONY: clean clean_alpine clean_ubuntu
clean: clean_alpine clean_ubuntu
clean_alpine: clean-alpine
clean_ubuntu: clean-ubuntu
clean-%:: ${ROOT_DIR}/cache/%/docker_devel.tar
	@docker load -i $<
	${DOCKER_DEVEL_CMD} ${IMAGE}_$*:devel /bin/sh -c \
		"cmake --build build/$* --target clean"
	${DOCKER_DEVEL_CMD} ${IMAGE}_$*:devel /bin/sh -c \
		"rm -rf build/$*/install"
	@rm -f ${ROOT_DIR}/cache/$*/configure.log
	@rm -f ${ROOT_DIR}/cache/$*/build.log
	@rm -f ${ROOT_DIR}/cache/$*/test.log
	@rm -f ${ROOT_DIR}/cache/$*/install.log

# DISTCLEAN
.PHONY: distclean distclean_alpine distclean_ubuntu
distclean: distclean_alpine distclean_ubuntu
	docker image prune -f
	rmdir ${ROOT_DIR}/cache
distclean_alpine: distclean-alpine
distclean_ubuntu: distclean-ubuntu
distclean-%::
	${DOCKER_DEVEL_CMD} ${IMAGE}_$*:devel /bin/sh -c \
		"rm -rf build/$*"
	docker image rm -f ${IMAGE}_$*:devel 2>/dev/null
	docker image rm -f ${IMAGE}_$*:install 2>/dev/null
	rm -rf ${ROOT_DIR}/cache/$*

# debug purpose
print-%  : ; @echo $* = $($*)
