
.PHONY: build
build: 
	# https://docs.docker.com/engine/reference/commandline/buildx_build/#output
	docker buildx build --platform linux/amd64,linux/arm64,linux/386  -o . . 

.PHONY: clean
clean:
	rm -rf ./linux_amd64 ./linux_arm64 ./linux_386
