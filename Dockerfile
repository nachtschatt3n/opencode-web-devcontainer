FROM ubuntu:24.04

# Install system packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    ca-certificates \
    unzip \
    bash \
    && rm -rf /var/lib/apt/lists/*

# Install gh CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    > /etc/apt/sources.list.d/github-cli.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends gh \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN groupadd --gid 1000 opencode \
    && useradd --uid 1000 --gid 1000 --create-home --shell /bin/bash opencode

# Switch to non-root user for all remaining steps
USER opencode
ENV HOME=/home/opencode
WORKDIR /home/opencode

# Install mise
RUN curl https://mise.run | sh

# Activate mise in shell profiles
RUN echo 'eval "$(~/.local/bin/mise activate bash)"' >> ~/.bashrc \
    && echo 'eval "$(~/.local/bin/mise activate bash)"' >> ~/.profile

# Install opencode via mise
RUN ~/.local/bin/mise use -g opencode@latest

EXPOSE 4096

# Copy entrypoint scripts (done as root, then chown)
COPY --chown=opencode:opencode scripts/clone.sh /usr/local/bin/clone.sh
COPY --chown=opencode:opencode scripts/entrypoint.sh /usr/local/bin/entrypoint.sh

USER root
RUN chmod +x /usr/local/bin/clone.sh /usr/local/bin/entrypoint.sh
USER opencode

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
