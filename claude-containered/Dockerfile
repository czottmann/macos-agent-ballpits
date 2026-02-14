# Claude Code Sandboxed Environment for OrbStack
# Build: docker build --build-arg USERNAME=$(whoami) -t claude-containered .
# Run: docker run --rm -it -v $(pwd):/workspace claude-containered

FROM debian:bookworm-slim

# Build argument for username (defaults to czottmann)
ARG USERNAME=czottmann

# Install required packages (without nodejs - we'll install newer version)
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    curl \
    ca-certificates \
    fish \
    git \
    jq \
    ripgrep \
    fd-find \
    gnupg \
    sqlite3 \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 22 from NodeSource (Debian's v18 is too old for pi-coding-agent)
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install Go from official source (Debian's version is too old for beans)
RUN curl -fsSL https://go.dev/dl/go1.24.13.linux-arm64.tar.gz | tar -xz -C /usr/local
ENV PATH="/usr/local/go/bin:${PATH}"

# Install sd (not in Debian repos, download pre-built binary)
RUN curl -fsSL https://github.com/chmln/sd/releases/download/v1.0.0/sd-v1.0.0-aarch64-unknown-linux-musl.tar.gz \
    | tar -xz -C /usr/local/bin --strip-components=1 sd-v1.0.0-aarch64-unknown-linux-musl/sd

# Create symlink for fd (Debian names it fdfind)
RUN ln -s /usr/bin/fdfind /usr/bin/fd

# Create user with bash as default shell
RUN useradd -m -s /bin/bash $USERNAME

# Install SwiftFormat (pre-built ARM64 binary)
RUN curl -fsSL https://github.com/nicklockwood/SwiftFormat/releases/latest/download/swiftformat_linux_aarch64.zip \
    -o /tmp/swiftformat.zip \
    && unzip -q /tmp/swiftformat.zip -d /tmp \
    && mv /tmp/swiftformat_linux_aarch64 /usr/local/bin/swiftformat \
    && chmod +x /usr/local/bin/swiftformat \
    && rm /tmp/swiftformat.zip

# Install Claude Code, beans, pi-coding-agent, and Deno as the user
USER $USERNAME
WORKDIR /home/$USERNAME
RUN mkdir -p /home/$USERNAME/.npm-global && npm config set prefix /home/$USERNAME/.npm-global
RUN curl -fsSL https://deno.land/install.sh | sh

# Ensure user's local bin, Go bin, npm global bin, and Deno bin are in PATH
ENV PATH="/home/$USERNAME/.local/bin:/home/$USERNAME/go/bin:/home/$USERNAME/.npm-global/bin:/home/$USERNAME/.deno/bin:${PATH}"

RUN curl -fsSL https://claude.ai/install.sh | bash
RUN claude update
RUN npm install -g @mariozechner/pi-coding-agent
RUN go install github.com/hmans/beans@latest

WORKDIR /workspace
CMD ["claude"]
