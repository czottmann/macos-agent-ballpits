# Claude Code Sandboxed Environment for OrbStack
# Build: docker build --build-arg USERNAME=$(whoami) -t claude-containered .
# Run: docker run --rm -it -v $(pwd):/workspace claude-containered

FROM ubuntu:25.10

# Build argument for username (defaults to czottmann)
ARG USERNAME=czottmann
ARG HOMEDIR=/Users/$USERNAME

# Install system packages
RUN apt-get update
RUN apt-get install -y --no-install-recommends \
    bash \
    build-essential \
    ca-certificates \
    curl \
    fd-find \
    fish \
    forgejo-cli \
    git \
    jq \
    libssl-dev \
    pkg-config \
    ripgrep \
    sd \
    sqlite3 \
    unzip \
  && rm -rf /var/lib/apt/lists/*

# Create user with fish as default shell
RUN useradd -m -s /usr/bin/fish -d $HOMEDIR $USERNAME

# Switch to user for all remaining setup
USER $USERNAME
ENV SHELL=/usr/bin/fish
WORKDIR $HOMEDIR

# Symlink fd
RUN mkdir -p $HOMEDIR/.local/bin
RUN ln -sT /usr/bin/fdfind $HOMEDIR/.local/bin/fd

# Guest git overlay: loaded alongside the shared ~/.gitconfig (mounted at
# runtime). Uses the `store` helper pointed at a file inside a bind-mounted
# directory. Mounting the PARENT directory (not the single file) is deliberate:
# git-credential-store writes atomically via rename, which fails over a
# single-file bind mount with "Device or resource busy". Within a mounted
# directory, the rename stays local to the mount and works normally.
RUN mkdir -p $HOMEDIR/.config/git && \
    printf '%s\n' \
      '[core]' \
      '  editor = vim' \
      '[credential]' \
      '  helper = store --file=/run/claude-containered/git-credentials' \
      > $HOMEDIR/.config/git/config

# Log in to forgejo instance
RUN --mount=type=secret,id=fj_auth_token,mode=0444 \
    fj --host git.zottmann.dev auth add-key czottmann $(cat /run/secrets/fj_auth_token 2>/dev/null)

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
        claude@latest \
        codex@latest \
        deno@latest \
        gh@latest \
        go@latest \
        node@24 \
        pi@latest \
        swiftformat@latest
        # tuist@latest

# Set up npm global directory and ensure Go bin is in PATH
RUN mkdir -p $HOMEDIR/.npm-global && npm config set prefix $HOMEDIR/.npm-global
ENV PATH="$HOMEDIR/.npm-global/bin:$HOMEDIR/go/bin:${PATH}"

RUN go install github.com/hmans/beans@latest

RUN pi install npm:@marckrenn/pi-sub-bar
RUN pi install npm:pi-mcp-adapter # needed for `--mcp-config` support

WORKDIR /workspace
CMD ["claude"]
