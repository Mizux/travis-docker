help:
	@echo "usage:"
	@echo "make docker: generate docker devel images"
	@echo "make configure: execute cmake configure using the devel image container"
	@echo "make build: execute cmake target all using the devel image container"
	@echo "make test: execute cmake target test using the devel image container"
	@echo "make clean: execute the cmake target clean"
	@echo "make distclean: execute clean and also remove all docker images"
	@echo ""
	@echo "note: Currently test are done on alpine and ubuntu,\
 you can add \"_<distro>\" at end of the previous targets to run only test on this distro\
 (e.g make test_alpine)."
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
DOCKER_DEVEL_CMD := docker run --rm --user ${UID}:${GID} -it -v ${PROJECT_DIR}:/project -w /project

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
		"cmake --build build/$* --target all" #-- VERBOSE=1"
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

# CLEAN
.PHONY: clean clean_alpine clean_ubuntu
clean: clean_alpine clean_ubuntu
clean_alpine: clean-alpine
clean_ubuntu: clean-ubuntu
clean-%:: ${ROOT_DIR}/cache/%/docker_devel.tar
	@docker load -i $<
	${DOCKER_DEVEL_CMD} ${IMAGE}_$*:devel /bin/sh -c \
		"cmake --build build/$* --target clean"
	@rm -f ${ROOT_DIR}/cache/$*/configure.log
	@rm -f ${ROOT_DIR}/cache/$*/build.log
	@rm -f ${ROOT_DIR}/cache/$*/test.log

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
	rm -rf ${ROOT_DIR}/cache/$*

# debug purpose
print-%  : ; @echo $* = $($*)
