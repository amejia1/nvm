# nvm Coding Agent Instructions

This document provides guidance for AI coding agents when working with the Node Version Manager (nvm) codebase.

## Overview

nvm is a version manager for Node.js, implemented as a POSIX-compliant function that works across multiple shells (sh, dash, bash, ksh, zsh). The codebase is primarily written in shell script and emphasizes portability and compatibility.

### Core Architecture

- **Main script**: `nvm.sh` - Contains all core functionality and the main `nvm()` function
- **Installation script**: `install.sh` - Handles downloading and installing nvm itself
- **Execution wrapper**: `nvm-exec` - Allows running commands with specific Node.js versions
- **Bash completion**: `bash_completion` - Provides tab completion for bash users
- **Tests**: Comprehensive test suite in `test/` directory using the [urchin](https://www.npmjs.com/package/urchin) test framework

## Key Files and Their Purposes

### `nvm.sh`
The core functionality file containing:
- Main `nvm()` function (starts around line 3000)
- All internal helper functions (prefixed with `nvm_`)
- Command implementations for install, use, ls, etc.
- Shell compatibility logic
- POSIX compliance utilities

### `install.sh`
Handles nvm installation via curl/wget/git:
- Downloads nvm from GitHub
- Sets up directory structure
- Configures shell integration
- Supports both git clone and script download methods

### `nvm-exec`
Simple wrapper script that:
- Sources nvm.sh with `--no-use` flag
- Switches to specified Node version via `NODE_VERSION` env var or `.nvmrc`
- Executes the provided command with that Node version

## Top-Level nvm Commands and Internal Functions

### Core Commands

#### `nvm install [version]`
- **Internal functions**: `nvm_install_binary()`, `nvm_install_source()`, `nvm_download_artifact()`
- Downloads and installs specified Node.js version
- Automatically `nvm use`s that version after installation
- Supports LTS versions, version ranges, and built-in aliases (like `node`, `stable`) and user-defined aliases
- Can install from binary or compile from source
- When compiling from source, accepts additional arguments that are passed to the compilation task

#### `nvm use [version]`
- **Internal functions**: `nvm_resolve_alias()`, `nvm_version_path()`, `nvm_change_path()`
- Switches current shell to use specified Node.js version
- Updates PATH environment variable
- Supports `.nvmrc` file integration

#### `nvm ls [pattern]`
- **Internal functions**: `nvm_ls()`, `nvm_tree_contains_path()`
- Lists installed Node.js versions
- Supports pattern matching and filtering
- Shows current version and aliases

#### `nvm ls-remote [pattern]`
- **Internal functions**: `nvm_ls_remote()`, `nvm_download()`, `nvm_ls_remote_index_tab()`
- Lists available Node.js versions from nodejs.org and iojs.org, or the env-var-configured mirrors
- Supports LTS filtering and pattern matching
- Downloads version index on-demand

#### `nvm alias [name] [version]`
- **Internal functions**: `nvm_alias()`, `nvm_alias_path()`
- Creates text files containing the mapped version, named as the alias name
- Special aliases: `default`, `node`, `iojs`, `stable`, `unstable` (note: `stable` and `unstable` are deprecated, from node's pre-v1 release plan)
- Stored in `$NVM_DIR/alias/` directory

#### `nvm current`
- **Internal functions**: `nvm_ls_current()`
- Shows currently active Node.js version
- Returns "system" if using system Node.js

#### `nvm which [version]`
- **Internal functions**: `nvm_version_path()`, `nvm_resolve_alias()`
- Shows path to specified Node.js version
- Resolves aliases and version strings

### Utility Commands

#### `nvm cache clear|dir`
- Cache management for downloaded binaries and source code
- Clears or shows cache directory path

#### `nvm debug`
- Diagnostic information for troubleshooting
- Shows environment, tool versions, and paths

#### `nvm deactivate`
- Removes nvm modifications from current shell
- Restores original PATH

#### `nvm unload`
- Completely removes nvm from shell environment
- Unsets all nvm functions and variables

### Internal Function Categories

#### Version Resolution
- `nvm_resolve_alias()` - Resolves aliases to version numbers
- `nvm_version()` - Finds best matching local version
- `nvm_remote_version()` - Finds best matching remote version
- `nvm_normalize_version()` - Standardizes version strings
- `nvm_version_greater()` - Compares version numbers
- `nvm_version_greater_than_or_equal_to()` - Version comparison with equality
- `nvm_get_latest()` - Gets latest version from a list

#### Installation Helpers
- `nvm_install_binary()` - Downloads and installs precompiled binaries
- `nvm_install_source()` - Compiles Node.js from source
- `nvm_download_artifact()` - Downloads tarballs or binaries
- `nvm_compute_checksum()` - Verifies download integrity
- `nvm_checksum()` - Checksum verification wrapper
- `nvm_get_mirror()` - Gets appropriate download mirror
- `nvm_get_arch()` - Determines system architecture

#### Path Management
- `nvm_change_path()` - Updates PATH for version switching
- `nvm_strip_path()` - Removes nvm paths from PATH
- `nvm_version_path()` - Gets installation path for version
- `nvm_version_dir()` - Gets version directory name
- `nvm_prepend_path()` - Safely prepends to PATH

#### Shell Detection and Compatibility
- `nvm_is_zsh()` - Shell detection for zsh
- `nvm_is_iojs_version()` - Checks if version is io.js
- `nvm_get_os()` - Operating system detection
- `nvm_supports_source_options()` - Checks if shell supports source options

#### Network and Remote Operations
- `nvm_download()` - Generic download function
- `nvm_ls_remote()` - Lists remote versions
- `nvm_ls_remote_iojs()` - Lists remote io.js versions
- `nvm_ls_remote_index_tab()` - Parses remote version index

#### Utility Functions
- `nvm_echo()`, `nvm_err()` - Output functions
- `nvm_has()` - Checks if command exists
- `nvm_sanitize_path()` - Cleans sensitive data from paths
- `nvm_die_on_prefix()` - Validates npm prefix settings
- `nvm_ensure_default_set()` - Ensures default alias is set
- `nvm_auto()` - Automatic version switching from .nvmrc

#### Alias Management
- `nvm_alias()` - Creates or lists aliases
- `nvm_alias_path()` - Gets path to alias file
- `nvm_unalias()` - Removes aliases
- `nvm_resolve_local_alias()` - Resolves local aliases

#### Listing and Display
- `nvm_ls()` - Lists local versions
- `nvm_ls_current()` - Shows current version
- `nvm_tree_contains_path()` - Checks if path is in nvm tree
- `nvm_format_version()` - Formats version display

## Running Tests

### Test Framework
nvm uses the [urchin](https://www.npmjs.com/package/urchin) test framework for shell script testing.

### Test Structure
```
test/
├── fast/           # Quick unit tests
├── slow/           # Integration tests
├── sourcing/       # Shell sourcing tests
├── install_script/ # Installation script tests
├── installation_node/ # Node installation tests
├── installation_iojs/ # io.js installation tests
└── common.sh       # Shared test utilities
```

### Running Tests

#### Install Dependencies
```bash
npm install  # Installs urchin, semver, and replace tools
```

#### Run All Tests
```bash
npm test               # Runs tests in the current shell only (sh, bash, dash, zsh)
make test              # Runs tests in default shells (sh, bash, dash, zsh)
make test-sh           # Runs tests only in sh
make test-bash         # Runs tests only in bash
make test-dash         # Runs tests only in dash
make test-zsh          # Runs tests only in zsh
make SHELLS=ksh test   # Runs tests only in ksh (experimental, see issue #574)
```

#### Run Specific Test Suites
```bash
npm run test/fast                # Runs fast tests in the current shell
npm run test/slow                # Runs slow tests in the current shell
npm run test/sourcing            # Runs sourcing tests in the current shell
npm run test/install_script      # Runs install script tests in the current shell
npm run test/installation        # Runs installation tests (node + iojs) in the current shell
npm run test/installation/node   # Runs Node installation tests in the current shell
npm run test/installation/iojs   # Runs io.js installation tests in the current shell
make TEST_SUITE=fast test        # Only fast tests
make TEST_SUITE=slow test        # Only slow tests
make SHELLS=bash test            # Only bash shell
```

#### Individual Test Execution
```bash
./test/fast/Unit\ tests/nvm_get_arch     # Run single test (WARNING: This will exit/terminate your current shell session)
./node_modules/.bin/urchin test/fast/                        # Run fast test suite
./node_modules/.bin/urchin 'test/fast/Unit tests/nvm_get_arch'  # Run single test safely without shell termination
./node_modules/.bin/urchin test/slow/                        # Run slow test suite
./node_modules/.bin/urchin test/sourcing/                    # Run sourcing test suite
./node_modules/.bin/urchin test/install_script/              # Run install script test suite
./node_modules/.bin/urchin test/installation_node/           # Run Node installation test suite
./node_modules/.bin/urchin test/installation_iojs/           # Run io.js installation test suite
```

#### Linting and Docs Checks
```bash
npm run eclint               # Checks EditorConfig compliance
npm run doctoc:check         # Verifies README table of contents
npm run dockerfile_lint      # Lints the Dockerfile
npm run test:check-exec      # Checks test files have executable permission
npm run test:check-nonexec   # Checks non-test files don't have executable permission
npm run markdown-link-check  # Validates markdown links (requires markdown-link-check)
```

### Test Writing Guidelines
- Tests should work across all supported shells (sh, bash, dash, zsh, ksh)
- Define and use a `die()` function for test failures
- Clean up after tests in cleanup functions
- Mock external dependencies when needed
- Place mocks in `test/mocks/` directory
- Mock files should only be updated by the existing `update_test_mocks.sh` script, and any new mocks must be added to this script

## Docker Development Container

A development container image (`nvm-dev`) packages the current `nvm` working copy into an Ubuntu-based environment prepared with the tools needed to develop and test `nvm`. It is the recommended environment for running the test suite: it provides a clean shell environment with all supported shells (bash, zsh, dash, ksh) and a working pty, and all test suites pass when run in it. `tini` is the container's init process (PID 1), so signals are forwarded to the running command, orphaned processes are reaped, and scripts can use `exec`.

### Building the container

Run from the root of the `nvm` repository:

```bash
./build-dev-container.sh
```

Any arguments given to the script are passed through to `docker build`, so extra build options can be given (for example, additional `--build-arg` or `--progress` flags):

```bash
./build-dev-container.sh --build-arg UBUNTU_VERSION="24.04" --progress plain
```

This builds the `nvm-dev` image with the current user's username, uid, and gid as the non-root user inside the container. Building with the host user's identity is important: it allows the host's `nvm` source directory to be mounted into the container and for files to be copied to and from it with matching ownership. The build takes several minutes and the image is not suitable for production usage.

Note that the build copies the current working copy (including its `.git` directory) into the image and then points the git `origin` remote at the upstream `https://github.com/nvm-sh/nvm` repository (as the CI's checkout does): if the working copy's origin were left as an ssh fork, the tests that run `install.sh` (the `install_script` suite) would hang waiting for an ssh authentication or host-key prompt. The `test/fixtures/nvmrc` git submodule is also checked out at build time, pinned to the upstream `nvm-sh/nvmrc` repository.

To build a container with the default `nvm` username, uid, and gid (1001) instead, run:

```bash
docker build --tag nvm-dev .
```

### Running the container

Run from the root of the `nvm` repository:

```bash
./run-dev-container.sh
```

This starts an interactive container that mounts the host's `nvm` top-level directory into `${HOME}/nvm` inside the container and leaves the working directory at `${HOME}/.nvm`, where the packaged copy of the repository (including its `node_modules` and node installation) lives. To test changes made on the host, copy the changed files from `${HOME}/nvm` into `${HOME}/.nvm` inside the container, then run the tests from `${HOME}/.nvm`.

Extra `docker run` arguments (for example, additional `--volume` flags) can be passed before a `--` separator; arguments after the `--` separator become the container command (and without a `--` separator, all arguments are the container command). The `docker run` arguments are word-split on whitespace, so do not use arguments that contain spaces:

```bash
./run-dev-container.sh --volume "/host/path":"/home/andres/path" -- "/home/andres/.nvm/run-tests-in-container.sh"
```

The equivalent direct command is:

```bash
docker run --rm --name nvm-dev -it --volume "$(pwd):/home/$(whoami)/nvm:rw" nvm-dev
```

The `--rm` flag removes the container on exit and the `--name nvm-dev` flag means only one such container can run at a time.

### Running the test suite

Run one test suite inside the container (from `${HOME}/.nvm`):

```bash
npm run test/fast
```

Run all six test suites ("fast", "slow", "sourcing", "installation_node", "installation_iojs", and "install_script" — in that order, with "install_script" last because some of its tests update the packaged repository with git) with the `run-tests-in-container.sh` script shipped in the repository; see the comments in that script for example commands:

```bash
./run-dev-container.sh "/home/$(whoami)/.nvm/run-tests-in-container.sh"
```

The tests must run in clean shells with `NVM_DIR` set and the other `NVM_*` variables and `BASH_ENV` unset, mirroring the CI environment: the tests' `setup_dir` scripts run under `sh`, where nvm.sh's `NVM_DIR` auto-detection does not work (it relies on `BASH_SOURCE`), and the container sets `BASH_ENV` to load nvm into every bash shell, which both pollutes tests that inspect the shell's functions and variables and makes the tests' fake `node` wrapper scripts re-enter nvm through their `#!/bin/bash` shebangs, forking endlessly. Both `run-tests-in-container.sh` and the `make` test targets (used by `npm run test/*`) set up this environment: do not remove the `NVM_DIR` setup from `run-tests-in-container.sh` or the `BASH_ENV` unset from the `Makefile`. `test/fixtures` and `test/mocks` are not test suites ("test/mocks/pkg_info_fail" exits 1 by design), which is why `run-tests-in-container.sh` runs an explicit list of suites instead of the default.

The tests download a lot of files, and an occasional download can hang: `run-tests-in-container.sh` therefore gives each suite a timeout (600 seconds by default, as in the CI; override with the `SUITE_TIMEOUT` environment variable) and, if a suite times out, stops the whole suite (including the hung download, by killing the suite's process group) and retries the suite, up to 3 attempts.

When capturing the output of a container run to a log file, write the log to a dedicated directory under `${HOME}/.cache` (like `${HOME}/.cache/ai_agent_scratch_space`), not to `/tmp`, and mount that directory into the container at the same location so that logs can also be written from inside the container:

```bash
mkdir -p "${HOME}/.cache/ai_agent_scratch_space"
container_user="$(docker image inspect --format '{{.Config.User}}' nvm-dev)"
docker run --rm --name nvm-dev \
  --volume "${HOME}/.cache/ai_agent_scratch_space":"/home/${container_user}/.cache/ai_agent_scratch_space" \
  nvm-dev "/home/${container_user}/.nvm/run-tests-in-container.sh" \
  > "${HOME}/.cache/ai_agent_scratch_space/nvm-test-run.log" 2>&1
```

Delete such log files once they are no longer needed, so they do not fill the disk.

Some tests build old node and io.js versions from source, which requires a python 2 (and, for io.js, a gcc ≤ 5) toolchain. The CI provides that toolchain, but a modern system (including this container) typically does not, so those tests detect the missing toolchain and skip (exit 0) instead of failing; the binary-install tests and the "fake source" tests cover nvm's source-install pipeline on every toolchain.

Note that running the test suite typically removes the node installation, so if you need to rerun the tests, exit the container and then run the container again.

### Running commands non-interactively

Commands can be run in a non-interactive way by first writing them into a separate shell script file and then executing it inside the container. The image's entrypoint is `tini` and its default command (`CMD`) is an interactive bash, so a mounted script can be run through an interactive bash (which loads nvm and puts node/npm on the PATH). Example, from the host:

```bash
printf '#!/bin/sh\nnpm run test/fast\n' >/tmp/test.sh
container_user="$(docker image inspect --format '{{.Config.User}}' nvm-dev)"
docker run --rm --name nvm-dev -it --volume "/tmp/test.sh:/home/${container_user}/.nvm/test.sh" nvm-dev /bin/bash -i "/home/${container_user}/.nvm/test.sh"
```

A script can also be executed directly as a container command; it then runs in the shell of its shebang line. A `#!/bin/bash` script loads nvm through `BASH_ENV`, but a `#!/bin/sh` (dash) script does not (dash ignores `BASH_ENV`), so such scripts must either source nvm themselves or run commands that do not need node. Note that the `npm run test/*` scripts detect the shell to test in from their parent process, so a script that runs `npm run test/*` should be run through the interactive bash above, or should run the tests explicitly (like `run-tests-in-container.sh` does), so that the intended test shell is used:

```bash
docker run --rm --name nvm-dev -it nvm-dev "/home/${container_user}/.nvm/run-tests-in-container.sh"
```

## Shell Environment Setup

### Supported Shells
- **bash** - Full feature support
- **zsh** - Full feature support
- **dash** - Basic POSIX support
- **sh** - Basic POSIX support
- **ksh** - Limited support (experimental)

### Installing Shell Environments

#### Ubuntu/Debian
```bash
sudo apt-get update
sudo apt-get install bash zsh dash ksh
# sh is typically provided by dash or bash and is available by default
```

#### macOS
```bash
# bash and zsh are available by default, bash is not the default shell for new user accounts
# Install other shells via Homebrew
brew install dash ksh
# For actual POSIX sh (not bash), install mksh which provides a true POSIX sh
brew install mksh
```

#### Manual Shell Testing
```bash
# Test in specific shell
bash -c "source nvm.sh && nvm --version"
zsh -c "source nvm.sh && nvm --version"
dash -c ". nvm.sh && nvm --version"
sh -c ". nvm.sh && nvm --version"          # On macOS: mksh -c ". nvm.sh && nvm --version"
ksh -c ". nvm.sh && nvm --version"
```

### Shell-Specific Considerations
- **zsh**: Requires basically any non-default zsh option to be temporarily unset to restore POSIX compliance
- **dash**: Limited feature set, avoid bash-specific syntax
- **ksh**: Some features may not work, primarily for compatibility testing

## CI Environment Details

### GitHub Actions Workflows

#### `.github/workflows/tests.yml`
- Runs test suite across multiple shells and test suites
- Uses `script` command for proper TTY simulation
- Matrix strategy covers shell × test suite combinations
- Excludes install_script tests from non-bash shells

#### `.github/workflows/shellcheck.yml`
- Lints all shell scripts using shellcheck
- Tests against multiple shell targets (bash, sh, dash, ksh)
  - Note: zsh is not included due to [shellcheck limitations](https://github.com/koalaman/shellcheck/issues/809)
- Uses Homebrew to install latest shellcheck version

#### `.github/workflows/lint.yml`
- Runs additional linting and formatting checks
- Validates documentation and code style

### Travis CI (Legacy)
- Configured in `.travis.yml`
- Tests on multiple Ubuntu versions
- Installs shell environments via apt packages

### CI Test Execution
```bash
# Simulate CI environment locally
unset TRAVIS_BUILD_DIR  # Disable Travis-specific logic
unset GITHUB_ACTIONS    # Disable GitHub Actions logic
make test
```

## Setting Up shellcheck Locally

### Installation

#### macOS (Homebrew)
```bash
brew install shellcheck
```

#### Ubuntu/Debian
```bash
sudo apt-get install shellcheck
```

#### From Source
```bash
# Download from https://github.com/koalaman/shellcheck/releases
wget https://github.com/koalaman/shellcheck/releases/download/latest/shellcheck-latest.linux.x86_64.tar.xz
tar -xf shellcheck-latest.linux.x86_64.tar.xz
sudo cp shellcheck-latest/shellcheck /usr/local/bin/
```

### Usage

#### Lint Main Files
```bash
shellcheck -s bash nvm.sh
shellcheck -s bash install.sh
shellcheck -s bash nvm-exec
shellcheck -s bash bash_completion
```

#### Lint Across Shell Types
```bash
shellcheck -s sh nvm.sh      # POSIX sh
shellcheck -s bash nvm.sh    # Bash extensions
shellcheck -s dash nvm.sh    # Dash compatibility
shellcheck -s ksh nvm.sh     # Ksh compatibility
```

#### Common shellcheck Directives in nvm
- `# shellcheck disable=SC2039` - Allow bash extensions in POSIX mode
- `# shellcheck disable=SC2016` - Allow literal `$` in single quotes
- `# shellcheck disable=SC2001` - Allow sed usage instead of parameter expansion
- `# shellcheck disable=SC3043` - Allow `local` keyword (bash extension)

### Fixing shellcheck Issues
1. **Quoting**: Always quote variables: `"${VAR}"` instead of `$VAR`
2. **POSIX compliance**: Avoid bash-specific features in portable sections
3. **Array usage**: Use `set --` for positional parameters instead of arrays, which are not supported in POSIX
4. **Local variables**: Declared with `local FOO` and then initialized on the next line (the latter is for ksh support)

## Development Best Practices

### Code Style
- Use 2-space indentation
- Follow POSIX shell guidelines for portability
- Prefix internal functions with `nvm_`
- Use `nvm_echo` instead of `echo` for output
- Use `nvm_err` for error messages

### Compatibility
- Test changes across all supported shells
- Avoid bash-specific features in core functionality
- Use `nvm_is_zsh` to check when zsh-specific behavior is needed
- Mock external dependencies in tests

### Performance
- Cache expensive operations (like remote version lists)
- Use local variables to avoid scope pollution
- Minimize subprocess calls where possible
- Implement lazy loading for optional features

### Debugging
- Use `nvm debug` command for environment information
- Enable verbose output with `set -x` during development
- Test with `NVM_DEBUG=1` environment variable
- Check `$NVM_DIR/.cache` for cached data issues

## Common Gotchas

1. **PATH modification**: nvm modifies PATH extensively; be careful with restoration
2. **Shell sourcing**: nvm must be sourced, not executed as a script
3. **Version resolution**: Aliases, partial versions, and special keywords interact complexly
4. **Platform differences**: Handle differences between Linux, macOS, and other Unix systems
5. **Network dependencies**: Many operations require internet access for version lists
6. **Concurrent access**: Multiple shells can conflict when installing versions simultaneously

## Windows Support

nvm works on Windows via several compatibility layers:

### WSL2 (Windows Subsystem for Linux)
- Full nvm functionality available
- **Important**: Ensure you're using WSL2, not WSL1 - see [Microsoft's WSL2 installation guide](https://docs.microsoft.com/en-us/windows/wsl/install) for up-to-date instructions
- Install Ubuntu or other Linux distribution from Microsoft Store
- Follow Linux installation instructions within WSL2

### Cygwin
- POSIX-compatible environment for Windows
- Download Cygwin from [cygwin.com](https://www.cygwin.com/install.html) and run the installer
- During installation, include these packages: bash, curl, git, tar, and wget
- May require additional PATH configuration

### Git Bash (MSYS2)
- Comes with Git for Windows
- Limited functionality compared to full Linux environment
- Some features may not work due to path translation issues, including:
  - Binary extraction paths may be incorrectly translated
  - Symlink creation may fail
  - Some shell-specific features may behave differently
  - File permissions handling differs from Unix systems

### Setup Instructions for Windows

#### WSL2 (recommended)
1. Install WSL2 using the official Microsoft guide: https://docs.microsoft.com/en-us/windows/wsl/install
2. Install Ubuntu or preferred Linux distribution from Microsoft Store
3. Follow standard Linux installation within WSL2

#### Git Bash
1. Install Git for Windows (includes Git Bash) from https://git-scm.com/download/win
2. Open Git Bash terminal
3. Run nvm installation script

#### Cygwin
1. Download and install Cygwin from https://www.cygwin.com/install.html
2. Include bash, curl, git, tar, and wget packages during installation
3. Run nvm installation in Cygwin terminal

This guide should help AI coding agents understand the nvm codebase structure, testing procedures, and development environment setup requirements.
