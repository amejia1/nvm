#!/bin/sh
set -eu
# This script runs the full test suite inside the development container. "npm run test" picks the
# test shell from its parent process, so the suite runs in this script's shell (dash). Build the
# image first (./build-dev-container.sh), then run the script from the host with:
# ./run-dev-container.sh "/home/$(whoami)/.nvm/run-tests-in-container.sh"
# If the image was not built with the "build-dev-container.sh" script, or it was built with arguments
# that change the user or the working directory, the `docker run` command can be used directly
# (adjusting the script path as needed):
# docker run --rm --name nvm-dev nvm-dev "/home/nvm/.nvm/run-tests-in-container.sh"
# The container's init process is "tini", so the script's exit code is propagated to the host.
npm run test
