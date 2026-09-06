#!/bin/sh
set -eu
# This script will run the development container mounting the "nvm" top-level directory into the directory
# inside of the container at "${HOME}/nvm". Files can then be copied from that directory into the "${HOME}/.nvm" directory.
# The working directory is left as being the "${HOME}/.nvm" directory since the test suite is best ran from that directory.
exec docker run --rm --name nvm-dev -it --volume "$(pwd):/home/$(whoami)/nvm:rw" nvm-dev "$@"
