# Kubectl as OCI

Have you ever created a Docker image that contains a set of tools you need to debug | test | work? me too. The thing is that crafting those Dockeriles are a pain. First you need to find where to download the binary from, then, you need to write the curl | wget command that will fetched it, and last but not least, you have to give the right permissions... It's painful.

Let's take a look at a different approach. First, we are going to create an OCI image with just those binaries. The URL to fetch the latest stable kubectl is `https://dl.k8s.io/release/${KUBE_VERSION}/bin/${TARGETOS}/${TARGETARCH}/kubectl`, as you can see, it depends on the version, the OS (linux, darwin, windows...) and the Architecture (amd64, arm64...).

The [Dockerfile](./Dockerfile) we're going to use is the following:

```bash
# syntax = docker/dockerfile:1.4
FROM alpine:latest@sha256:c41ab5c992deb4fe7e5da09f67a8804a46bd0592bfdf0b1847dde0e0889d2bff as builder

ARG KUBE_VERSION
ARG TARGETARCH
ARG TARGETOS

ENV KUBE_VERSION="${KUBE_VERSION}"

RUN <<EOF
    wget -q https://dl.k8s.io/release/${KUBE_VERSION}/bin/${TARGETOS}/${TARGETARCH}/kubectl -O /kubectl
EOF

FROM scratch

COPY --from=builder /kubectl /
```

We use a `build-arg` to pass the `KUBE_VERSION`, this is because we will fetch it by doing a curl to https://dl.k8s.io/release/stable.txt.

Last, but not least, we need to build the image as an OCI image, to do that, we need to pass the `--output` flag, in the shorthand version `-o` and in that output, we're going to specify the image type as OCI: `-o type=image,oci-mediatypes=true,name=IMAGE:TAG`

The whole command is as follows:

```
docker buildx build --build-arg KUBE_VERSION=${TAG} \
  --platform linux/amd64,linux/arm64 \
  -o type=image,oci-mediatypes=true,name=${OCI-IMAGE}:${TAG} .
```

Once this build is completed, we need to use this OCI image as a dependency for our final [Docker Image](./kubectl.Dockerfile):

```Dockerfile
COPY --chown=1000:1000 --chmod=0755 --from=ipedrazas/kubectl-oci:v1.26.2 /kubectl /usr/local/bin/kubectl
```

Note that we use the usual `COPY` command but we use the OCI image in the `--from` flag. Usually in multi-stage docker builds, we refer to a previous stage (image), but we can reference any image.

Also, it's interesting to note that we `chown` and `chmod` the binary during the `COPY` command. No need for polluting our Dockerfile with extra `RUN` instructions to set ownership and permissions.

## Inspecting Images

```bash
docker manifest inspect ipedrazas/kubectl-oci:v1.26.2
```

returns

```json
{
  "schemaVersion": 2,
  "mediaType": "application/vnd.oci.image.index.v1+json",
  "manifests": [
    {
      "mediaType": "application/vnd.oci.image.manifest.v1+json",
      "size": 506,
      "digest": "sha256:4b32d70743997ad4f6d40cef2c00325b4d656cac34d7a981f4f83f8969df6aa8",
      "platform": {
        "architecture": "amd64",
        "os": "linux"
      }
    },
    {
      "mediaType": "application/vnd.oci.image.manifest.v1+json",
      "size": 506,
      "digest": "sha256:1fac47a174aeedb43172641706f80cf8268d7b7d2290cb38fd59333db88c034b",
      "platform": {
        "architecture": "arm64",
        "os": "linux"
      }
    }
  ]
}
```

**IF** you build that [Dockerfile](Dockerfile) using the usual build command:

```
docker buildx build --build-arg KUBE_VERSION=${TAG} --platform linux/amd64,linux/arm64 \
		--tag=${OCI-IMAGE}:${TAG} .
```

The result is slightly different:

```json
{
  "schemaVersion": 2,
  "mediaType": "application/vnd.docker.distribution.manifest.list.v2+json",
  "manifests": [
    {
      "mediaType": "application/vnd.docker.distribution.manifest.v2+json",
      "size": 528,
      "digest": "sha256:1f106cf632e16c2138bd1a0d82e4698e7001b04f8d8c7b3b528899ff81d72680",
      "platform": {
        "architecture": "amd64",
        "os": "linux"
      }
    },
    {
      "mediaType": "application/vnd.docker.distribution.manifest.v2+json",
      "size": 528,
      "digest": "sha256:603a4a686becec38120eaaca993eab2e99277408eeb223ce21ee88de42eba024",
      "platform": {
        "architecture": "arm64",
        "os": "linux"
      }
    }
  ]
}
```

Do you see the difference? in the second line you can see that the media type is different:

` "mediaType": "application/vnd.oci.image.index.v1+json",`

vs

`"mediaType": "application/vnd.docker.distribution.manifest.list.v2+json",`

And then, each manifest media type is different as well:

` "mediaType": "application/vnd.oci.image.manifest.v1+json",`

vs

` "mediaType": "application/vnd.docker.distribution.manifest.v2+json",`
