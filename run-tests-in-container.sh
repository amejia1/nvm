#!/bin/sh
set -eu
# This script is here to as a way to run all tests while inside of the container. It can be ran by running the following.
# ./run-dev-container.sh "/home/$(whoami)/.nvm/run-tests-in-container.sh"
# If the container was not built with the "build-dev-container.sh" script or was run without any build arguments, the `docker run`
# command can be used directly as follows.
# docker run --rm --name nvm-dev -it nvm-dev "/home/nvm/.nvm/run-tests-in-container.sh"
# Note that when running this scripts or scripts like it inside of the development container, the "exec" directive should not be used since
# due to the way the container is built, using "exec" is not expected to work.
npm run test
