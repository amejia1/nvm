# Dockerized nvm development environment
#
# This Dockerfile is for building nvm development environment only,
# not for any distribution/production usage.
#
# Please note that it'll use about 1.2 GB disk space and about 15 minutes to
# build this image, it depends on your hardware.

ARG UBUNTU_VERSION="26.04"
FROM ubuntu:${UBUNTU_VERSION} AS build
ARG UBUNTU_APT_SITE="ubuntu.cs.utah.edu"
ARG NON_ROOT_USER="nvm"
ARG NON_ROOT_UID="1001"
ARG NON_ROOT_GID="1001"
LABEL maintainer="Peter Dave Hello <hsu@peterdavehello.org>"
LABEL name="nvm-dev-env"
LABEL version="latest"

# Set the SHELL to bash with pipefail option
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Prevent dialog during apt install
ENV DEBIAN_FRONTEND="noninteractive"

# Pick a Ubuntu apt mirror site for better speed
# ref: https://launchpad.net/ubuntu/+archivemirrors
ENV UBUNTU_APT_SITE="${UBUNTU_APT_SITE}"

# Replace origin apt package site with the mirror site
RUN sed -E -i "s/([a-z]+.)?archive.ubuntu.com/$UBUNTU_APT_SITE/g" /etc/apt/sources.list
RUN sed -i "s/security.ubuntu.com/$UBUNTU_APT_SITE/g" /etc/apt/sources.list

# Install apt packages
RUN apt update         && \
    apt upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"  && \
    apt install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"     \
        coreutils             \
        util-linux            \
        bsdutils              \
        file                  \
        openssl               \
        libssl-dev            \
        locales               \
        ca-certificates       \
        ssh                   \
        wget                  \
        patch                 \
        sudo                  \
        htop                  \
        dstat                 \
        vim                   \
        tmux                  \
        curl                  \
        git                   \
        jq                    \
        zsh                   \
        ksh                   \
        gcc                   \
        g++                   \
        xz-utils              \
        build-essential       \
        bash-completion       \
        shellcheck            && \
    apt-get clean

RUN shellcheck -V

# Set locale
RUN locale-gen en_US.UTF-8

# Print tool versions
RUN bash --version | head -n 1
RUN zsh --version
RUN ksh --version || true
RUN dpkg -s dash | grep ^Version | awk '{print $2}'
RUN git --version
RUN curl --version
RUN wget --version

# Add the non-root group and user
RUN if getent passwd "${NON_ROOT_UID}" >/dev/null 2>&1; then userdel --remove "$(id -nu ${NON_ROOT_UID})"; fi
RUN if getent group "${NON_ROOT_GID}" >/dev/null 2>&1; then groupdel "$(getent group | awk -F: '$3 == ${NON_ROOT_GID} {print $1}')"; fi
RUN groupadd -g "${NON_ROOT_GID}" "${NON_ROOT_USER}"
RUN useradd --create-home --shell /bin/bash --uid "${NON_ROOT_UID}" --gid "${NON_ROOT_GID}" "${NON_ROOT_USER}"

# Copy and set permission for nvm directory
COPY . /home/${NON_ROOT_USER}/.nvm/
RUN chown ${NON_ROOT_USER}:${NON_ROOT_USER} -R "/home/${NON_ROOT_USER}/.nvm"

# Set sudoer for "nvm"
RUN echo "${NON_ROOT_USER} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Switch to user "nvm" from now
USER "${NON_ROOT_USER}"

# Create a script file sourced by both interactive and non-interactive bash shells
ENV BASH_ENV="/home/${NON_ROOT_USER}/.bash_env"
RUN touch "$BASH_ENV"
RUN echo '. "$BASH_ENV"' >> "$HOME/.bashrc"

# nvm
RUN echo 'export NVM_DIR="$HOME/.nvm"'                                       >> "$BASH_ENV"
RUN echo '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm' >> "$BASH_ENV"
RUN echo '[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion" # This loads nvm bash_completion' >> "$BASH_ENV"

# nodejs and tools
RUN nvm install node
RUN npm install -g doctoc urchin eclint dockerfile_lint replace semver
RUN npm install --prefix "$HOME/.nvm/"

# Create a new layer to squash down the "build" stage layers to a single layer.
FROM scratch
COPY --from=build / /
ARG NON_ROOT_USER="nvm"

# Set ENV directives here that need to be set for final image build.
ENV BASH_ENV="/home/${NON_ROOT_USER}/.bash_env"

# Set the user again here since it gets reset when going to new stages.
USER "${NON_ROOT_USER}"

# Set WORKDIR to nvm directory. This needs to be here so it is set for the final image build.
WORKDIR "/home/${NON_ROOT_USER}/.nvm"

# The entrypoint also needs to be set in final build stage.
ENTRYPOINT ["/bin/bash", "-i"]
