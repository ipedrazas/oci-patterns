# Docker Build - Understanding digests

What is the difference between the following 2 FROM commands:

```
FROM alpine:3.17 as base
```

And

```
FROM alpine:3.17@sha256:c41ab5c992deb4fe7e5da09f67a8804a46bd0592bfdf0b1847dde0e0889d2bff as base
```

That the second one has what we call, `the digest`. What is it and why is important?

For example, if we look at the [Dockerfile](../multi-arch/Dockerfile) from the `multi-arch` example, we can see that the `FROM` contains the digest.

If you do a `docker build` with or without a digest you will see that build times are slightly different. In my machine, the build returns the following:

```
docker buildx build --platform linux/amd64,linux/arm64,linux/386  -o . .
[+] Building 0.0s (15/15) FINISHED
```

Now, let's remove the digest and let's do the build again:

```
docker buildx build --platform linux/amd64,linux/arm64,linux/386  -o . .
[+] Building 1.3s (16/16) FINISHED
```

Why is this? what is happening here? why a build with digest takes 0.0 seconds and without takes 1.3 seconds?

Because when you do not specify a digest, docker is going to go to the registry to fetch the latest digest and use that one. So, those 1.3 extra seconds is my docker going to Docker Hub to check that the alpine image I have in my local registry and the image in the Docker registry is the same.

## What is an Image Digest?

A digest is an id that is automatically created during build time and it's immutable. If you want to make sure that you always pull the same image when doing a `docker pull`, you have to use the digest, otherwise, docker will go to the resgistry to get the latest digest for the tag and use that one.

## Pinning Images

It's called `to pin an image` when you specify the digest. Basically, pinning means making sure that we all pull the same image.

Let's analyse the image `alpine:3.17`. If we do the following command:

```
docker manifest inspect alpine:3.17
```

We're going to get a response like this (this is valid at this point of time):

```
{
   "schemaVersion": 2,
   "mediaType": "application/vnd.docker.distribution.manifest.list.v2+json",
   "manifests": [
      {
         "mediaType": "application/vnd.docker.distribution.manifest.v2+json",
         "size": 528,
         "digest": "sha256:e2e16842c9b54d985bf1ef9242a313f36b856181f188de21313820e177002501",
         "platform": {
            "architecture": "amd64",
            "os": "linux"
         }
      },
      {
         "mediaType": "application/vnd.docker.distribution.manifest.v2+json",
         "size": 528,
         "digest": "sha256:6b68cf2f9f4ace49bf3ecc4c13436ec62afa5e57eef939d178a9a2750c6e5843",
         "platform": {
            "architecture": "arm",
            "os": "linux",
            "variant": "v6"
         }
      },
      {
         "mediaType": "application/vnd.docker.distribution.manifest.v2+json",
         "size": 528,
         "digest": "sha256:68a5b7d32422e42b98bedfe2aef4d0b3445f69f0efe390ba2204427d80179a92",
         "platform": {
            "architecture": "arm",
            "os": "linux",
            "variant": "v7"
         }
      },
      {
         "mediaType": "application/vnd.docker.distribution.manifest.v2+json",
         "size": 528,
         "digest": "sha256:c41ab5c992deb4fe7e5da09f67a8804a46bd0592bfdf0b1847dde0e0889d2bff",
         "platform": {
            "architecture": "arm64",
            "os": "linux",
            "variant": "v8"
         }
      },
      {
         "mediaType": "application/vnd.docker.distribution.manifest.v2+json",
         "size": 528,
         "digest": "sha256:4aa08ef415aecc80814cb42fa41b658480779d80c77ab151812e0d657580f0ae",
         "platform": {
            "architecture": "386",
            "os": "linux"
         }
      },
      {
         "mediaType": "application/vnd.docker.distribution.manifest.v2+json",
         "size": 528,
         "digest": "sha256:95f55647488fbe0195d340089acfa6a094a9ee0aa6540d98dde8f8af5092d40c",
         "platform": {
            "architecture": "ppc64le",
            "os": "linux"
         }
      },
      {
         "mediaType": "application/vnd.docker.distribution.manifest.v2+json",
         "size": 528,
         "digest": "sha256:fe2da55ca9a717feb2da5d65171cee518cc157c5fcfe35c02972d9c4aa48aa1d",
         "platform": {
            "architecture": "s390x",
            "os": "linux"
         }
      }
   ]
}
```

In particular, look at this block:

```
 {
    "mediaType": "application/vnd.docker.distribution.manifest.v2+json",
    "size": 528,
    "digest": "sha256:c41ab5c992deb4fe7e5da09f67a8804a46bd0592bfdf0b1847dde0e0889d2bff",
    "platform": {
    "architecture": "arm64",
    "os": "linux",
    "variant": "v8"
    }
```

As you can see, the digest is the same as the one we used.

**Note:** while I was writing this page, the alpine:3.17 image was updated, this meant that the `FROM` command we were using from the [Dockerfile](../multi-arch/Dockerfile) had a digest that was not returned by the `docker manifest inspect`... I thought it would be better to make sure that they matched, if you're going to try to reproduce this exercise, be aware that the digest will have changed.

Since the `Dockerfile` used a pinned image, we can guarantee that the image I'll use and the image you will use is the same, however, it won't be the latest anymore.
