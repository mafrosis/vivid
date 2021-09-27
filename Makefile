export DOCKER_BUILDKIT=1

bin:
	mkdir bin

.PHONY: clean
clean:
	@rm -rf bin

.PHONY: build
build: bin/vivid-armv7 bin/vivid-armv6

bin/vivid-armv7: bin
	docker build \
		--build-arg TARGETPLATFORM=armv7 \
		-t mafrosis/vivid-builder-armv7 .
	docker run --rm \
		-v $$(pwd)/bin:/build \
		mafrosis/vivid-builder-armv7

bin/vivid-armv6: bin
	docker build \
		--build-arg TARGETPLATFORM=armv6 \
		-t mafrosis/vivid-builder-armv6 .
	docker run --rm \
		-v $$(pwd)/bin:/build \
		mafrosis/vivid-builder-armv6
