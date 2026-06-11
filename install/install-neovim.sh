#!/usr/bin/env bash
set -euo pipefail

if command -v nvim &>/dev/null; then
    echo "neovim is already installed."
    exit 0
fi

echo "Installing neovim..."

ARCH=$(uname -m)
case "$ARCH" in
    x86_64) ARCH="x86_64" ;;
    aarch64|arm64) ARCH="arm64" ;;  # neovim names the ARM asset "arm64"
    *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
esac

# Pinned to avoid depending on the rate-limited GitHub API (unauthenticated
# requests are limited to 60/hr per IP, which shared machines blow through).
NVIM_VERSION="0.12.3"
curl -fLo /tmp/nvim.tar.gz "https://github.com/neovim/neovim/releases/download/v${NVIM_VERSION}/nvim-linux-${ARCH}.tar.gz"

mkdir -p ~/.local
tar xzf /tmp/nvim.tar.gz -C /tmp
cp -r /tmp/nvim-linux-${ARCH}/* ~/.local/
rm -rf /tmp/nvim-linux-${ARCH} /tmp/nvim.tar.gz

echo "Done. neovim ${NVIM_VERSION} installed to ~/.local/."
