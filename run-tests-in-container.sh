#!/bin/sh
set -eu
# This script is here to as a way to run all tests while inside of the development container.
# It can be ran by running the following.
# ./run-dev-container.sh "/home/$(whoami)/.nvm/run-tests-in-container.sh"
# If the container was not built with the "build-dev-container.sh" script or was ran without any build arguments, the `docker run`
# command can be used directly as follows.
# docker run --rm --name nvm-dev -it nvm-dev "/home/nvm/.nvm/run-tests-in-container.sh"
#
# Temporary log files (like the output of a run) should be written to "${HOME}/workspace/scratch_space", not to "/tmp":
# mount that directory into the container at the same location when logs need to be written, for example:
# mkdir -p "$HOME/workspace/scratch_space"
# docker run --rm --name nvm-dev \
#   --volume "$HOME/workspace/scratch_space":"/home/$(whoami)/workspace/scratch_space" \
#   nvm-dev "/home/$(whoami)/.nvm/run-tests-in-container.sh" \
#   > "$HOME/workspace/scratch_space/nvm-test-run.log" 2>&1
# Delete such log files once they are no longer needed, so they do not fill the disk.
#
# The six real test suites ("fast", "slow", "sourcing", "installation_node", "installation_iojs", and "install_script",
# in that order) are run in bash, mirroring how the CI runs them. The "test/fixtures" and "test/mocks" directories
# are not test suites and are not ran (for example, "test/mocks/pkg_info_fail" exits 1 by design).
#
# Each test suite is given a timeout (SUITE_TIMEOUT, 600 seconds by default, as in the CI): the tests download a lot of
# files, and an occasional download can hang, in which case the whole suite (including the hung download) is stopped and
# the suite is retried (up to 3 attempts), as in the CI.
#
# The container uses tini as its init process, so the exit code of this script (and of any command it runs, including via "exec")
# is propagated to the "docker run" command.
#
# The "nvm_stdout_is_terminal" test writes to /dev/tty, which requires a controlling terminal; the CI runs the suites
# under one (the runner's pty). When this script is run without a controlling terminal (for example, "docker run"
# without "-t"), re-exec it under "script" (util-linux), which allocates a pty; "-e" makes "script" propagate the
# exit code of the re-executed script.
if [ ! -t 1 ] && command -v script >/dev/null 2>&1; then
  exec script -q -e -c "$0"
fi
cd "$(dirname "$0")"

# Mirror the CI test environment: NVM_DIR is set (tests' "setup_dir" scripts run under "sh", where nvm.sh's
# NVM_DIR auto-detection, which relies on "BASH_SOURCE", does not work), the other NVM_* variables and BASH_ENV
# are unset (tests must run in clean shells, and a BASH_ENV that loads nvm, like the one set in the development
# container, both pollutes tests that inspect the shell's functions and variables and makes the tests' fake
# "node" wrapper scripts re-enter nvm through their shebangs, forking endlessly), and nvm is then loaded and a
# node version is used, so that tests that run node directly (like the "test-npmlink" tests) have node on the
# PATH, as they do in the CI environment.
NVM_DIR="$PWD"
export NVM_DIR
for v in $(set | awk -F'=' '$1 ~ "^NVM_" && $1 != "NVM_DIR" { print $1 }'); do
  unset "$v"
done
unset BASH_ENV
# "set +e" so that a failing "nvm use" (for example, if the default version is not installed) does not abort the script.
set +e
. ./nvm.sh
set -e
nvm use --silent node >/dev/null 2>&1 || true
[ -x "./node_modules/.bin/urchin" ] || { printf 'ERROR: "node_modules/.bin/urchin" not found; run "npm install" first.\n' >&2; exit 1; }
export PATH="$PWD/node_modules/.bin:$PATH"

SUITE_TIMEOUT="${SUITE_TIMEOUT:-600}"
# "install_script" runs last: some of its tests run "install.sh" against the packaged repository, which updates it
# to the latest release with git (detaching HEAD and deleting the branches), so any suite ran after it would test
# that release instead of the packaged working copy (in the CI, every suite gets a fresh checkout, so the order
# does not matter there).
for suite in fast slow sourcing installation_node installation_iojs install_script; do
  echo "Running test suite: $suite"
  attempt=0
  while true; do
    attempt=$(( attempt + 1 ))
    exit_code=0
    # "timeout" runs the suite in its own process group, so on timeout the whole tree (the tests and, for example,
    # a hung download) is stopped ("-k" escalates to SIGKILL); it exits with 124, or 137 if the SIGKILL was needed.
    timeout -k 30 "$SUITE_TIMEOUT" ./node_modules/.bin/urchin -f -s bash "test/$suite" || exit_code=$?
    if [ "$exit_code" -eq 0 ]; then
      break
    fi
    if [ "$attempt" -ge 3 ] || { [ "$exit_code" -ne 124 ] && [ "$exit_code" -ne 137 ]; }; then
      exit "$exit_code"
    fi
    echo "Suite \"$suite\" attempt $attempt timed out; retrying..."
  done
done
