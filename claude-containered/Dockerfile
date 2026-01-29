# Claude Code Sandboxed Environment for OrbStack
# Build: docker build -t cc-sandbox .
# Run: docker run --rm -it -v $(pwd):/workspace cc-sandbox

FROM debian:bookworm-slim

# Install required packages (without nodejs - we'll install newer version)
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    curl \
    ca-certificates \
    git \
    jq \
    ripgrep \
    fd-find \
    gnupg \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 22 from NodeSource (Debian's v18 is too old for pi-coding-agent)
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install Go from official source (Debian's version is too old for beans)
RUN curl -fsSL https://go.dev/dl/go1.24.2.linux-arm64.tar.gz | tar -xz -C /usr/local
ENV PATH="/usr/local/go/bin:${PATH}"

# Install sd (not in Debian repos, download pre-built binary)
RUN curl -fsSL https://github.com/chmln/sd/releases/download/v1.0.0/sd-v1.0.0-aarch64-unknown-linux-musl.tar.gz \
    | tar -xz -C /usr/local/bin --strip-components=1 sd-v1.0.0-aarch64-unknown-linux-musl/sd

# Create symlink for fd (Debian names it fdfind)
RUN ln -s /usr/bin/fdfind /usr/bin/fd

# Create claude user with bash as default shell
RUN useradd -m -s /bin/bash claude

# Install SwiftFormat (pre-built ARM64 binary)
RUN curl -fsSL https://github.com/nicklockwood/SwiftFormat/releases/latest/download/swiftformat_linux_aarch64.zip \
    -o /tmp/swiftformat.zip \
    && unzip -q /tmp/swiftformat.zip -d /tmp \
    && mv /tmp/swiftformat_linux_aarch64 /usr/local/bin/swiftformat \
    && chmod +x /usr/local/bin/swiftformat \
    && rm /tmp/swiftformat.zip

# Install Claude Code, beans, pi-coding-agent, and Deno as the claude user
USER claude
WORKDIR /home/claude
RUN curl -fsSL https://claude.ai/install.sh | bash
RUN go install github.com/hmans/beans@latest
RUN mkdir -p /home/claude/.npm-global && npm config set prefix /home/claude/.npm-global
RUN npm install -g @mariozechner/pi-coding-agent

# Install Deno
RUN curl -fsSL https://deno.land/install.sh | sh

# Ensure claude's local bin, Go bin, npm global bin, and Deno bin are in PATH
ENV PATH="/home/claude/.local/bin:/home/claude/go/bin:/home/claude/.npm-global/bin:/home/claude/.deno/bin:${PATH}"

WORKDIR /workspace
CMD ["claude"]
