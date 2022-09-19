FROM ubuntu:latest

ENV BUILDKIT_VERSION=0.10.0
ENV BUILDKIT_FILENAME=buildkit-v${BUILDKIT_VERSION}.linux-amd64.tar.gz

ENV YQ_VERSION=v4.2.0
ENV YQ_BINARY=yq_linux_amd64

RUN apt-get update && apt-get install -y curl wget
RUN wget https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/${YQ_BINARY}.tar.gz -O - |\
    tar xz && mv ${YQ_BINARY} /usr/bin/yq

RUN curl -sSL https://github.com/moby/buildkit/releases/download/v${BUILDKIT_VERSION}/${BUILDKIT_FILENAME} | tar -xvz -C /usr \
    && curl -sSL https://github.com/gitpod-io/dazzle/releases/download/v0.1.10/dazzle_0.1.10_Linux_x86_64.tar.gz | tar -xvz -C /usr/bin
