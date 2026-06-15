#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

run() {
    echo "=== $1 ==="
    bash "$SCRIPT_DIR/$1"
    echo
}

# APT packages
run install-stow.sh
run install-btop.sh
run install-fd.sh
run install-fzf.sh
run install-ripgrep.sh
run install-tmux.sh
run install-wget.sh
run install-timewarrior.sh
run install-zsh-autosuggestions.sh
run install-zsh-syntax-highlighting.sh

# GitHub CLI (apt repo)
run install-gh.sh

# GitHub releases
run install-lazygit.sh
run install-sk.sh
run install-hostess.sh

# Neovim
run install-neovim.sh

# Rust ecosystem
run install-rustup.sh

# Python ecosystem
run install-uv.sh

# Node ecosystem (order matters)
run install-node.sh
run install-tree-sitter-cli.sh
run install-pyright.sh

# Desktop apps (Linux only)
run install-solaar.sh

echo "=== All done! ==="
