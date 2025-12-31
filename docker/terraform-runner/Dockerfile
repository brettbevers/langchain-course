# [Choice] Python version (use -bullseye variants on local arm64/Apple Silicon):
# 3, 3.10, 3.9, 3.8, 3.7, 3.6, 3-bullseye, 3.10-bullseye, 3.9-bullseye, 3.8-bullseye,
# 3.7-bullseye, 3.6-bullseye, 3-buster, 3.10-buster, 3.9-buster, 3.8-buster, 3.7-buster, 3.6-buster
ARG VARIANT="3.10-bullseye"
FROM mcr.microsoft.com/vscode/devcontainers/python:0-${VARIANT}

RUN apt-get update -y \
    && apt-get upgrade -y \
    && apt-get install -y \
    unzip \
    curl \
    ca-certificates \
    openssl

# Add the CA cert for First American
ADD cert/cacert.crt /usr/local/share/ca-certificates/cacert.crt
RUN chmod 644 /usr/local/share/ca-certificates/cacert.crt && update-ca-certificates

# Bundle cert after running update-ca-certificates
ENV REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
ENV AWS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
ENV NODE_EXTRA_CA_CERTS=/etc/ssl/certs/ca-certificates.crt
ENV SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt

## Terraform
RUN curl -L https://raw.githubusercontent.com/warrensbox/terraform-switcher/release/install.sh -o install.sh \
    && bash install.sh \
    && rm -f install.sh \
    # Use latest
    && tfswitch -u

## AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf awscliv2.zip aws

## kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    && chmod +x kubectl \
    && mv kubectl /usr/local/bin/

## Helm
RUN curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# AWS credentials (required for Airbyte deployment)
ARG AWS_ACCESS_KEY_ID
ENV AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY
ENV AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
ARG AWS_REGION="us-west-2"
ENV AWS_REGION=$AWS_REGION

# Add the deploy scripts
ADD scripts/tf-init.sh /usr/src/tf-init.sh
RUN chmod +x /usr/src/tf-init.sh
ADD scripts/tf-plan.sh /usr/src/tf-plan.sh
RUN chmod +x /usr/src/tf-plan.sh
ADD scripts/tf-apply.sh /usr/src/tf-apply.sh
RUN chmod +x /usr/src/tf-apply.sh

# Add scripts to PATH
ENV PATH=${PATH}:/usr/src/

# Assumes that a bind mount maps the tf directory to /usr/src/tf.
WORKDIR /usr/src/tf
