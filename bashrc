# Check if running Zsh or Bash
if [ -n "$ZSH_VERSION" ]; then
    SHELL_TYPE="zsh"
elif [ -n "$BASH_VERSION" ]; then
    SHELL_TYPE="bash"
else
    SHELL_TYPE="unknown"
fi

# Prepend a dir to PATH only if it exists and isn't already there
path_prepend() {
    case ":$PATH:" in
        *":$1:"*) ;;
        *) [ -d "$1" ] && PATH="$1:$PATH" ;;
    esac
}
path_prepend "$HOME/bin"
path_prepend "$HOME/.local/bin"
export PATH

# uv's env file (adds its bin dir; only if installed on this machine)
[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"

# Default editor: prefer neovim, fall back to vim (works on every box).
if command -v nvim >/dev/null 2>&1; then
    export EDITOR=nvim
    export VISUAL=nvim
else
    export EDITOR=vim
    export VISUAL=vim
fi

# Fix less issue in Docker
export LESS="-R"

# -------------------------------
# Interactive shells only below:
# -------------------------------
case $- in *i*) ;; *) return ;; esac

# Set a cross-shell PS1 prompt
if [ "$SHELL_TYPE" = "bash" ]; then
    PS1="\[\e[32m\]\u:\w\[\e[m\]\$ "
elif [ "$SHELL_TYPE" = "zsh" ]; then
    PS1="%F{green}%n:%~%f$ "
fi

# Source alias file if it exists
if [ -f "$HOME/.aliases" ]; then
    source "$HOME/.aliases"
fi

# History settings (persisted and de-duplicated in both shells)
HISTSIZE=10000
if [ "$SHELL_TYPE" = "bash" ]; then
    HISTFILESIZE=20000
    HISTCONTROL=ignoreboth      # ignore duplicate and space-prefixed commands
    shopt -s histappend         # append to history instead of overwriting
elif [ "$SHELL_TYPE" = "zsh" ]; then
    HISTFILE="$HOME/.zsh_history"
    SAVEHIST=20000
    setopt SHARE_HISTORY HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE
fi

# Completion
if [ "$SHELL_TYPE" = "bash" ]; then
    [ -f /etc/bash_completion ] && . /etc/bash_completion
elif [ "$SHELL_TYPE" = "zsh" ]; then
    autoload -U compinit && compinit -C   # -C skips the slow security check
fi

# yazi: terminal file manager. Use `y` (not plain `yazi`) so that on quit your
# shell cd's to the directory you ended up in — the wrapper Yazi documents.
if command -v yazi >/dev/null 2>&1; then
    y() {
        local tmp cwd
        tmp="$(mktemp -t yazi-cwd.XXXXXX)"
        yazi "$@" --cwd-file="$tmp"
        cwd="$(cat -- "$tmp")"
        [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && cd -- "$cwd"
        rm -f -- "$tmp"
    }
fi

# uv shell completion (only if installed on this machine)
if command -v uv >/dev/null 2>&1 && [ "$SHELL_TYPE" != "unknown" ]; then
    eval "$(uv generate-shell-completion "$SHELL_TYPE")"
fi

# zoxide: smarter directory jumping. Learns dirs as you cd; jump with a
# fragment (`z dotf`), pick interactively with `zi`. Plain cd is untouched.
if command -v zoxide >/dev/null 2>&1 && [ "$SHELL_TYPE" != "unknown" ]; then
    eval "$(zoxide init "$SHELL_TYPE")"
fi

# fzf keybindings + completion: Ctrl-R fuzzy history, Ctrl-T fuzzy file insert,
# Alt-C fuzzy cd. Needs fzf >= 0.48 for --bash/--zsh (install_deps.sh installs
# a current release where the distro's is older); an old fzf just no-ops here.
if command -v fzf >/dev/null 2>&1 && [ "$SHELL_TYPE" != "unknown" ]; then
    eval "$(fzf --"$SHELL_TYPE" 2>/dev/null)"
fi

# Machine-local overrides: secrets, work tools, per-host aliases.
# Lives only in $HOME, never tracked here. Sourced last so it can override.
# (if-form, not `&&`: keeps this file's exit status 0 when no override exists)
if [ -f "$HOME/.bashrc.local" ]; then
    source "$HOME/.bashrc.local"
fi
