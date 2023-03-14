OCI-IMAGE=ipedrazas/kubectl-oci
IMAGE=ipedrazas/kubectl
TAG=$(shell curl -Ls https://dl.k8s.io/release/stable.txt)

.PHONY: build
build:
	docker buildx build --build-arg KUBE_VERSION=${TAG} --platform linux/amd64,linux/arm64 \
		-o type=image,oci-mediatypes=true,name=${OCI-IMAGE}:${TAG} . 
	
.PHONY:build-as-docker
build-as-docker:
	docker buildx build --build-arg KUBE_VERSION=${TAG} --platform linux/amd64,linux/arm64 \
		--tag=${OCI-IMAGE}:${TAG} .

.PHONY: relase
release: build-as-docker
	docker buildx build --platform linux/amd64,linux/arm64 \
		--tag=${IMAGE}:${TAG} -f kubectl.Dockerfile .

.PHONY: push
push: release
	docker push ${OCI-IMAGE}:${TAG}
	docker push ${IMAGE}:${TAG}