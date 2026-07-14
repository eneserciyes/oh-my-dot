#!/usr/bin/env bash
# Symlinks the dotfiles into $HOME and sets up local git identity.
# Run from the repo: ./make_symlinks.sh   (or: source make_symlinks.sh to reload now)
# NOTE: loop lists are spelled out literally (not $var expansions) so the script
# also works sourced from zsh, which doesn't word-split unquoted variables.

# Resolve this script's directory in both Zsh and Bash
if [ -n "$ZSH_VERSION" ]; then
    DOTFILES="$(cd "$(dirname "${(%):-%N}")" && pwd)"
    SYMLINK_BASENAME="zshrc"
else
    DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
    SYMLINK_BASENAME="bashrc"
fi

DOTFILES_BKP=~/dotfiles.bkp

mkdir -p "$DOTFILES_BKP"

# Move a real (non-symlink) file/dir out of the way without clobbering or
# nesting into an earlier backup of the same name.
backup() {  # backup <path>
    local bkp="$DOTFILES_BKP/$(basename "$1")"
    [ -e "$bkp" ] && bkp="$bkp.$(date +%Y%m%d%H%M%S).$$"
    mv "$1" "$bkp"
}

# Back up real files (not our own symlinks), then link
echo "Linking dotfiles into $HOME (backups in $DOTFILES_BKP)"
for file in aliases vimrc screenrc gitconfig; do
    [ -e ~/."$file" ] && [ ! -L ~/."$file" ] && backup ~/."$file"
    ln -sf "$DOTFILES/$file" ~/."$file"
    echo "  ~/.$file -> $DOTFILES/$file"
done

# Both shells share the same rc file
for rc in bashrc zshrc; do
    [ -e ~/."$rc" ] && [ ! -L ~/."$rc" ] && backup ~/."$rc"
    ln -sf "$DOTFILES/bashrc" ~/."$rc"
    echo "  ~/.$rc -> $DOTFILES/bashrc"
done

# XDG config directories -> ~/.config/<name>
XDG_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
mkdir -p "$XDG_CONFIG"
echo "Linking config dirs into $XDG_CONFIG"
for dir in nvim yazi zellij ghostty; do
    target="$XDG_CONFIG/$dir"
    # Back up a real (non-symlink) existing dir, then link. -n stops ln from
    # nesting the link inside an existing symlinked dir on re-run.
    [ -e "$target" ] && [ ! -L "$target" ] && backup "$target"
    ln -sfn "$DOTFILES/config/$dir" "$target"
    echo "  $target -> $DOTFILES/config/$dir"
done

# Executable scripts -> ~/.local/bin/<name> (without the .sh extension)
LOCAL_BIN="$HOME/.local/bin"
mkdir -p "$LOCAL_BIN"
echo "Linking scripts into $LOCAL_BIN"
for script in ssh-connect tmux-session-dispensary open-github; do
    target="$LOCAL_BIN/$script"
    [ -e "$target" ] && [ ! -L "$target" ] && backup "$target"
    ln -sf "$DOTFILES/scripts/$script.sh" "$target"
    echo "  $target -> $DOTFILES/scripts/$script.sh"
done

# Install the CLI tools the nvim/zellij/yazi configs use (idempotent;
# best-effort). Skip entirely with SKIP_DEPS=1. See install_deps.sh.
if [ "${SKIP_DEPS:-0}" != "1" ] && [ -x "$DOTFILES/install_deps.sh" ]; then
    if [ -t 0 ]; then
        printf "\nInstall/upgrade developer tools now (nvim, zellij, yazi, fzf, ripgrep, ruff, ty, glow)? [Y/n]: "
        read -r ans
    else
        ans="y"  # non-interactive: assume yes
    fi
    case "${ans:-y}" in
        [Nn]*) echo "Skipping tool install (run ./install_deps.sh anytime)." ;;
        *)     "$DOTFILES/install_deps.sh" ;;
    esac
fi

source ~/."$SYMLINK_BASENAME"

# Don't leak helpers/temp vars into the live shell when sourced.
unset -f backup 2>/dev/null
unset name email ans whost wname wemail gv file rc dir target script \
     GITLOCAL SYMLINK_BASENAME DOTFILES_BKP LOCAL_BIN 2>/dev/null
