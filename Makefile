DOCKER_IMAGE_NAME := "docker-machine-hypriot-build"
DOCKER_CONTAINER_NAME := "docker-machine-hypriot-build-container"

build:
test: build
%:
		docker build -t $(DOCKER_IMAGE_NAME) .

		test -z '$(shell docker ps -a | grep $(DOCKER_CONTAINER_NAME))' || docker rm -f $(DOCKER_CONTAINER_NAME)

		docker run --name $(DOCKER_CONTAINER_NAME) \
		    -e DEBUG \
		    -e STATIC \
		    -e VERBOSE \
		    -e BUILDTAGS \
		    -e PARALLEL \
		    -e COVERAGE_DIR \
		    -e TARGET_OS \
		    -e TARGET_ARCH \
		    -e PREFIX \
		    $(DOCKER_IMAGE_NAME) \
		    go build -i -o docker-machine-hypriot ./bin

		test ! -d bin || rm -Rf bin
		test -z "$(findstring build,$(patsubst cross,build,$@))" || docker cp $(DOCKER_CONTAINER_NAME):/go/src/github.com/docker/machine/bin bin

build-local:
	GOGC=off go build -i -o ./bin/docker-machine-driver-hypriot_$(shell uname -s)-$(shell uname -m) ./bin

install: bin/docker-machine-driver-hypriot_$(shell uname -s)-$(shell uname -m)
	cp -f ./bin/docker-machine-driver-hypriot_$(shell uname -s)-$(shell uname -m) $(GOPATH)/bin/docker-machine-driver-hypriot

test-acceptance:
	test/integration/run-bats.sh test/integration/bats/
