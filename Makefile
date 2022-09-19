PORT ?= 5000
REPO ?= localhost:${PORT}/dazzle
BUILDER_NAME ?= dojo-vcl/builder
REGISTRY_CONTAINER_NAME ?= dojo-vcl-registry
CONTAINER_NAME ?= dojo-vcl-builder
BUILDER_CMD = docker run --rm --privileged \
	--network host \
	-v /var/run/docker.sock:/var/run/docker.sock \
	-v ${PWD}:/work \
	${BUILDER_NAME}

up: builder start-local-registry start-builder

down:
	-$(MAKE) stop-local-registry
	-$(MAKE) stop-builder

start-local-registry:
	docker run -d -p ${PORT}:${PORT} --restart=always --name ${REGISTRY_CONTAINER_NAME} registry:2

stop-local-registry:
	docker rm -f -v ${REGISTRY_CONTAINER_NAME}

builder:
	docker build . -t ${BUILDER_NAME}

stop-builder:
	docker rm -f -v ${CONTAINER_NAME}

start-builder:
	docker run --privileged \
	--network host \
	-d \
	--name ${CONTAINER_NAME} \
	-v /var/run/docker.sock:/var/run/docker.sock \
	-v ${PWD}:/work \
	${BUILDER_NAME} sleep infinity
	$(MAKE) start-buildkitd

start-buildkitd:
	docker exec -d ${CONTAINER_NAME} bash -c "buildkitd --debug "

build-all:
	docker exec ${CONTAINER_NAME} bash -c "cd work && dazzle build ${REPO} --no-cache"
	docker exec ${CONTAINER_NAME} bash -c "cd work && dazzle build ${REPO}"

build:
	docker exec -t ${CONTAINER_NAME} bash -c "cd work && ./build-chunk.sh ${PARAM}"

combine-all:
	- docker exec ${CONTAINER_NAME} bash -c "buildkitd &"
	docker exec ${CONTAINER_NAME} bash -c "cd work && dazzle combine ${REPO} --all"

combine:
	docker exec -t ${CONTAINER_NAME} bash -c "cd work && ./build-combo.sh ${PARAM}"

