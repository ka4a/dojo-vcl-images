ARG base
FROM ${base}

ARG PYTHON_VERSION_PIP
ARG PYTHON_VERSION

RUN rm -rf /var/lib/apt/lists/* && apt-get clean
RUN apt-get update

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
    python${PYTHON_VERSION} \
    python${PYTHON_VERSION}-dev \
    python${PYTHON_VERSION_PIP}-pip

RUN ln -s $(which python${PYTHON_VERSION}) /usr/bin/python

WORKDIR /app
RUN mkdir -p /.local \
    && chown -R 1000:1000 /.local
USER 1000
COPY requirements.txt requirements.txt
RUN python -m pip install -r requirements.txt --no-cache-dir --user
ENV PYTHONPATH "${PYTHONPATH}:/.local/lib/python${PYTHON_VERSION}/site-packages"
