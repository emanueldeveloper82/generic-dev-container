# Imagem base oficial — Ubuntu com ferramentas comuns para dev containers
FROM mcr.microsoft.com/devcontainers/base:ubuntu

# Pacotes extras úteis em qualquer stack (ajuste conforme necessidade)
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
        curl \
        jq \
        unzip \
        ca-certificates \
        shellcheck \
    && curl -fsSL "https://github.com/hadolint/hadolint/releases/download/v2.12.0/hadolint-Linux-x86_64" \
        -o /usr/local/bin/hadolint \
    && chmod +x /usr/local/bin/hadolint \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/*
