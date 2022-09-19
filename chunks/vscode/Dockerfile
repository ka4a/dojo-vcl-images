ARG base
FROM ${base}

ARG VSCODE_VERSION

RUN touch /vscode

RUN apt-get update \
 && apt-get install -y \
    curl \
    dumb-init \
    zsh \
    htop \
    locales \
    man \
    nano \
    git \
    git-lfs \
    procps \
    openssh-client \
    vim.tiny \
    lsb-release \
  && git lfs install \
  && rm -rf /var/lib/apt/lists/*

# https://wiki.debian.org/Locale#Manually
RUN sed -i "s/# en_US.UTF-8/en_US.UTF-8/" /etc/locale.gen \
  && locale-gen
ENV LANG=en_US.UTF-8

RUN adduser --gecos '' --disabled-password coder

RUN ARCH="$(dpkg --print-architecture)" && \
    curl -fsSL "https://github.com/boxboat/fixuid/releases/download/v0.5/fixuid-0.5-linux-$ARCH.tar.gz" | tar -C /usr/local/bin -xzf - && \
    chown root:root /usr/local/bin/fixuid && \
    chmod 4755 /usr/local/bin/fixuid && \
    mkdir -p /etc/fixuid && \
    printf "user: coder\ngroup: coder\n" > /etc/fixuid/config.yml

RUN ARCH="$(dpkg --print-architecture)" && \
    curl -fsSL "https://github.com/coder/code-server/releases/download/v${VSCODE_VERSION}/code-server_${VSCODE_VERSION}_$ARCH.deb" -o /tmp/cs.deb && \
    dpkg -i /tmp/cs.deb && \
    rm /tmp/cs.deb

COPY entrypoint.sh /usr/bin/entrypoint.sh

RUN mkdir /home/workspaces

EXPOSE 8080
# This way, if someone sets $DOCKER_USER, docker-exec will still work as
# the uid will remain the same. note: only relevant if -u isn't passed to
# docker-run.
USER 1000
ENV USER=coder
WORKDIR /home/coder

ENTRYPOINT ["/usr/bin/entrypoint.sh", "--bind-addr", "0.0.0.0:8080", "."]
