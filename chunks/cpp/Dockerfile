ARG base
FROM ${base}

RUN rm -rf /var/lib/apt/lists/* && apt-get clean
RUN apt-get update

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
    build-essential \
    clang-format \
    cmake \
    libncurses-dev

WORKDIR /app
