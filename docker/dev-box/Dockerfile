# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.245.2/containers/python-3/.devcontainer/base.Dockerfile

# [Choice] Python version (use -bullseye variants on local arm64/Apple Silicon):
# 3, 3.10, 3.9, 3.8, 3.7, 3.6, 3-bullseye, 3.10-bullseye, 3.9-bullseye, 3.8-bullseye,
# 3.7-bullseye, 3.6-bullseye, 3-buster, 3.10-buster, 3.9-buster, 3.8-buster, 3.7-buster, 3.6-buster
ARG VARIANT="3.12-bullseye"
FROM mcr.microsoft.com/vscode/devcontainers/python:1-${VARIANT} AS base

# Update apt-get packages
RUN apt-get update --fix-missing \
    && export DEBIAN_FRONTEND=noninteractive \
    # && apt-get -y upgrade \
    && apt-get install -y --no-install-recommends \
    ca-certificates \
    gnupg \
    software-properties-common \
    # Install Java
    default-jdk \
    mlocate \
    libgbm-dev \
    build-essential \
    libssl-dev \
    libffi-dev \
    procps \
    curl \
    openssl \
    git \
    git-lfs \
    graphviz

# uv package manager
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# GH CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt update \
    && apt install gh -y

# Create /workspaces and transfer ownership to user: vscode
RUN mkdir -p /workspaces \
    && chown -R vscode:vscode /workspaces

# Create /commandhistory to persist shell history
RUN mkdir -p /commandhistory \
    && chown -R vscode:vscode /commandhistory

# Allow vscode to install to /usr/local
RUN chown -R vscode:vscode /usr/local/

# Switch user or everything owned by root
USER vscode

# Add pyenv / virtualenv
RUN git clone https://github.com/pyenv/pyenv.git /home/vscode/.pyenv \
    && git clone https://github.com/pyenv/pyenv-virtualenv.git /home/vscode/.pyenv/plugins/pyenv-virtualenv \
    # ~/.zshrc
    && echo "" >> /home/vscode/.zshrc \
    && echo '# Pyenv' >> /home/vscode/.zshrc \
    && echo 'export PYENV_ROOT="/home/vscode/.pyenv"' >> /home/vscode/.zshrc \
    && echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> /home/vscode/.zshrc \
    && echo 'eval "$(pyenv init --path)"' >> /home/vscode/.zshrc \
    && echo 'eval "$(pyenv init -)"' >> /home/vscode/.zshrc \
    && echo 'eval "$(pyenv virtualenv-init -)"' >> /home/vscode/.zshrc

# Persist shell history
RUN echo "" >> /home/vscode/.zshrc \
    && echo "export HISTFILE=/commandhistory/.zsh_history" >> /home/vscode/.zshrc

##########################
## Base Environment     ##
##########################

FROM base as langchain-course

WORKDIR /workspaces/langchain-course
SHELL ["/bin/zsh", "-c"]

## Terraform
# Note: Installing while `USER root` caused access issues
RUN curl -L https://raw.githubusercontent.com/warrensbox/terraform-switcher/release/install.sh -o install.sh \
    && bash install.sh \
    && rm -f install.sh \
    # Use latest
    && tfswitch -u

## AWS CLI (architecture-aware)
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "aarch64" ]; then \
        curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"; \
    else \
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"; \
    fi && \
    unzip awscliv2.zip && \
    sudo ./aws/install && \
    rm -rf awscliv2.zip aws

## kubectl (architecture-aware)
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "aarch64" ]; then KUBECTL_ARCH="arm64"; else KUBECTL_ARCH="amd64"; fi && \
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/${KUBECTL_ARCH}/kubectl" && \
    chmod +x kubectl && \
    sudo mv kubectl /usr/local/bin/

## Helm
RUN curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

## Azure CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

## Claude Code
RUN curl -fsSL https://claude.ai/install.sh | bash

# ##########################
# ## data-ingestion       ##
# ##########################

# FROM base as data-ingestion

# WORKDIR /workspaces/langchain-course/services/data_ingestion
# SHELL ["/bin/zsh", "-c"]

# # Install dependencies
# COPY services/data_ingestion/requirements-dev.txt .
# RUN pip3 install --no-cache-dir -r requirements-dev.txt

