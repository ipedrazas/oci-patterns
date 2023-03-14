# syntax = docker/dockerfile:1.4
FROM alpine:3.17@sha256:c41ab5c992deb4fe7e5da09f67a8804a46bd0592bfdf0b1847dde0e0889d2bff as builder

ARG KUBE_VERSION
ARG TARGETARCH
ARG TARGETOS

ENV KUBE_VERSION="${KUBE_VERSION}"

RUN <<EOF 
    wget -q https://dl.k8s.io/release/${KUBE_VERSION}/bin/${TARGETOS}/${TARGETARCH}/kubectl -O /kubectl 
EOF

FROM scratch

COPY --from=builder /kubectl /
