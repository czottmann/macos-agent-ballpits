# Claude Code Sandboxed Environment for OrbStack
# Build: docker build -t cc-sandbox .
# Run: docker run --rm -it -v $(pwd):/workspace cc-sandbox

FROM alpine:latest

# Add edge/community repo for sd
RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories

# Install required packages
RUN apk add --no-cache \
    bash \
    curl \
    ca-certificates \
    git \
    nodejs \
    npm \
    ripgrep \
    fd \
    sd \
    shadow \
    go

# Create claude user with bash as default shell
RUN useradd -m -s /bin/bash claude

# Install Claude Code and beans as the claude user
USER claude
WORKDIR /home/claude
RUN curl -fsSL https://claude.ai/install.sh | bash
RUN go install github.com/hmans/beans@latest

# Ensure claude's local bin and Go bin are in PATH
ENV PATH="/home/claude/.local/bin:/home/claude/go/bin:${PATH}"

WORKDIR /workspace
CMD ["claude"]
