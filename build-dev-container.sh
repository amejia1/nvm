#!/bin/sh
set -eu
# This script builds the development container using the current user's name, uid and gid.
exec docker build --tag nvm-dev --build-arg "NON_ROOT_USER=$(whoami)" --build-arg "NON_ROOT_UID=$(id -u)" --build-arg "NON_ROOT_GID=$(id -g)" .
