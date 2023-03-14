# OCI Patterns and Usage

This repo contains a few examples that illustrate different ways of using docker and OCI to improve your day to day workflow.

Since building `multi-arch` images is not as straight-forwars as it seems, there's a small `Dockerfile` that helps to understand the value of the different variables in the [multi-arch](./multi-arch/) directory.

I've added a little note about image digests in the [understanding digests](./understanding%20digests/) directory. You will find what's a digest (a generated id) and why/when to use them.

In [kubectl as OCI](./kubectl-as-oci/) I've packaged `kubectl` as an OCI image and then used that image as a dependency to create an `Alpine` image that contains kubectl. The code is very simple, we leverage multi-arch builds to keep architectures separated.
