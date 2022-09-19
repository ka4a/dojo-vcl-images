#!/bin/sh
set -eu

exec dumb-init /usr/bin/code-server "$@"
