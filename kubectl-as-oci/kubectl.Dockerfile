# syntax = docker/dockerfile:1.4
FROM alpine:3.17@sha256:c41ab5c992deb4fe7e5da09f67a8804a46bd0592bfdf0b1847dde0e0889d2bff as builder

ENV HOME="/home/appuser"
WORKDIR ${HOME}

RUN <<EOF
addgroup -g 1000 apps
adduser -u 1000 -G apps -h ${HOME} -D appuser
EOF

COPY --chown=1000:1000 --chmod=0755 --from=ipedrazas/kubectl-oci:v1.26.2 /kubectl /usr/local/bin/kubectl

USER appuser

