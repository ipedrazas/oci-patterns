# Multi Arch

When building multi-arch Docker images is always good to understand how the different arguments work. Thi directory contains a Dockerfile that will generate a set of files depending on the platforms you build it to. If you run the [Makefile](Makefile) by doing `make build` you will see that 3 directories will be created.

This is an example of a build in a Macbook M1 (arm) for a linux/386

```
ARGS in docker build - linux-386
-------------------
TARGETPLATFORM    : linux/386
TARGETOS          : linux
TARGETARCH        : 386
TARGETVARIANT     :

BUILDPLATFORM     : linux/arm64/v8
BUILDOS           : linux
BUILDARCH         : arm64
BUILDVARIANT      : v8
```

The build generates files in our host, in order to do that, we use the `--output` flag in buildx, more info can be fond in the following link:

https://docs.docker.com/engine/reference/commandline/buildx_build/#output
