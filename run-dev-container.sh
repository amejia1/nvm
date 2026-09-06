#!/bin/sh
set -eu
# This script will run the development container mounting the "nvm" top-level directory into the directory
# inside of the container at "${HOME}/nvm". Files can then be copied from that directory into the "${HOME}/.nvm" directory.
# The working directory is left as being the "${HOME}/.nvm" directory since the test suite is best ran from that directory.
#
# Arguments before a "--" separator are passed through to "docker run", which lets extra run options be given
# (for example, additional "--volume" arguments); arguments after the "--" separator (or all of the arguments,
# when there is no "--") are the command that is ran inside of the container:
# ./run-dev-container.sh "/home/andres/.nvm/run-tests-in-container.sh"
# ./run-dev-container.sh --volume "/host/path":"/home/andres/path" -- "/home/andres/.nvm/run-tests-in-container.sh"
# Note that the "docker run" arguments are word-split on whitespace, so they must not contain spaces.
have_separator=0
for arg in "$@"; do
  if [ "$arg" = "--" ]; then
    have_separator=1
    break
  fi
done
docker_run_args=
if [ "$have_separator" -eq 1 ]; then
  while [ $# -gt 0 ]; do
    case "$1" in
      --) shift
          break
          ;;
      *)  docker_run_args="${docker_run_args:+$docker_run_args }$1"
          shift
          ;;
    esac
  done
fi
# shellcheck disable=SC2086  # word-splitting of "docker_run_args" is intentional
exec docker run --rm --name nvm-dev -it --volume "$(pwd):/home/$(whoami)/nvm:rw" ${docker_run_args} nvm-dev "$@"
