#!/bin/sh
set -eu
# This script builds the development container using the current user's name, uid and gid.
# Any arguments are passed through to "docker build", which lets extra build options be given,
# for example:
# ./build-dev-container.sh --build-arg UBUNTU_VERSION="24.04" --progress plain
exec docker build --tag nvm-dev --build-arg "NON_ROOT_USER=$(whoami)" --build-arg "NON_ROOT_UID=$(id -u)" --build-arg "NON_ROOT_GID=$(id -g)" "$@" .
