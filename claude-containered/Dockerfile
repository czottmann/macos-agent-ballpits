# Claude Code Sandboxed Environment for OrbStack
# Build: docker build --build-arg USERNAME=$(whoami) -t claude-containered .
# Run: docker run --rm -it -v $(pwd):/workspace claude-containered

FROM ubuntu:24.04

# Build argument for username (defaults to czottmann)
ARG USERNAME=czottmann
ARG HOMEDIR=/Users/$USERNAME

# Install system packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    curl \
    ca-certificates \
    fish \
    git \
    jq \
    ripgrep \
    sqlite3 \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Create user with fish as default shell
RUN useradd -m -s /usr/bin/fish -d $HOMEDIR $USERNAME

# Switch to user for all remaining setup
USER $USERNAME
ENV SHELL=/usr/bin/fish
WORKDIR $HOMEDIR

# CACHEBUST for fresh installs of frequently-updated tools
ARG CACHEBUST
RUN echo "Keepin' it fresh ($CACHEBUST)"

# Install mise
ENV MISE_YES=1
RUN curl https://mise.run | sh
ENV PATH="$HOMEDIR/.local/bin:$HOMEDIR/.local/share/mise/shims:${PATH}"

# Install stable tools via mise
RUN --mount=type=secret,id=mise_github_token,mode=0444 \
    MISE_GITHUB_TOKEN=$(cat /run/secrets/mise_github_token 2>/dev/null) \
    mise use --global \
        node@24 \
        go@latest \
        gh@latest \
        deno@latest \
        fd@latest \
        sd@latest \
        swiftformat@latest \
        pi@latest \
        tuist@latest \
        claude@latest \
        codex@latest

# Set up npm global directory and ensure Go bin is in PATH
RUN mkdir -p $HOMEDIR/.npm-global && npm config set prefix $HOMEDIR/.npm-global
ENV PATH="$HOMEDIR/.npm-global/bin:$HOMEDIR/go/bin:${PATH}"

# Install frequently-updated tools via mise
RUN go install github.com/hmans/beans@latest

WORKDIR /workspace
CMD ["claude"]
