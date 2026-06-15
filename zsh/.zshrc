bindkey -e
autoload -U colors && colors
PS1="%{$fg[green]%}%n@%m%{$reset_color%}:%{$fg[blue]%}%~%{$reset_color%} $ "

if [[ "$(uname)" == "Darwin" ]]; then
	MAC=1
else
	LINUX=1
fi


# Recency-sorted directory picker: top-level non-hidden dirs in $HOME plus the
# immediate subdirs of ~/ws, newest-first; cd into the pick
recent-files() {
    local dir
    dir=$({ fd --type d --max-depth 1 --exclude node_modules --exclude Library . "$HOME";
            fd --type d --max-depth 1 --exclude node_modules . "$HOME/ws"; } 2>/dev/null \
        | perl -e 'my %seen; print map { $_->[1] } sort { $b->[0] <=> $a->[0] } grep { !$seen{$_->[1]}++ } map { my $f=$_; chomp $f; [ (stat $f)[9], "$f\n" ] } <>' \
        | fzf --height 40% --reverse --preview 'ls -la {}') || return
    if [[ -n $dir ]]; then
        BUFFER="cd ${(q)dir}"
        zle accept-line
    else
        zle reset-prompt
    fi
}
mkcd() {
  mkdir -p "$1" && cd "$1"
}
tcc() {
	local panes=$(tmux display-message -p '#{window_panes}')
	[[ $panes -gt 1 ]] && echo "more than 1 pane" && return 0
	tmux split-window -h -p 30
	tmux select-pane -t 0
	tmux split-window -v -p 20
	tmux send-keys -t 0 'nvim .' Enter
	tmux send-keys -t 2 'claude' Enter
	tmux select-pane -t 0
}
re-tcc() {
	local panes=$(tmux display-message -p '#{window_panes}')
	[[ $panes -ne 3 ]] && echo "need exactly 3 panes" && return 1
	tmux resize-pane -t 2 -x 30%
	tmux resize-pane -t 1 -y 20%
}

zle -N recent-files
bindkey '^f' recent-files

# C-s: pick an ssh target with fzf and connect (names the tmux window if inside tmux)
ssh-picker() {
    local host
    host=$(grep -E "^Host " ~/.ssh/config | awk '$2 != "*" {print $2}' \
        | fzf --height 40% --reverse --prompt="ssh> ") || return
    if [[ -n $host ]]; then
        BUFFER="ssh-connect.sh ${(q)host}"
        zle accept-line
    else
        zle reset-prompt
    fi
}
zle -N ssh-picker
bindkey '^s' ssh-picker
stty -ixon  # free C-s from terminal flow control

HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"

export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.local/scripts:$PATH"

export GG_WS="$HOME/ws/"
export GG_AP="$HOME/ws/ari-pilot"
export GG_DO="$HOME/Downloads"

export EDITOR="nvim"
export MANPAGER="nvim +Man!"
export HISTIGNORE='exit:cd:ls:bg:fg:history:f:fd:vim'

alias src="source ~/.zshrc"
alias venv="source .venv/bin/activate"
alias c="claude"
alias cr="claude --resume"
alias vim="nvim"
alias vi="nvim"
alias im="nvim"
alias ta="tmux attach -d"
alias scp="scp -r"
alias rsync="rsync -avz"
alias cd-w="cd ${GG_WS}"
alias cd-a="cd ${GG_AP}"
alias cd-d="cd ${GG_DO}"
alias chx="chmod +x"
alias ls="ls --color=auto"
alias ll="ls -alF"
alias la="ls -A"
alias l="ls -CF"
alias ga="git add -u"
alias gaa="git add -A"
alias gc="git commit -m"
alias gs="git status"

autoload -U compinit && compinit
autoload edit-command-line
zmodload zsh/complist
zle -N edit-command-line
bindkey '^Xe' edit-command-line

[[ -s /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
[[ -s /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh

[[ -s /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
[[ -s /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

source <(fzf --zsh)


# >>> ari-pilot dora run guard >>>
__ari_pilot_confirm_dora_run() {
    [[ $- == *i* ]] || return 0
    printf '\n[ari-pilot] Prefer starting flows from the dashboard.\n' >&2
    printf '[ari-pilot] WARNING: existing Dora nodes will be killed before this command runs.\n' >&2
    local answer
    printf 'Continue? [y/N] ' >&2
    read -r answer
    [[ "$answer" == [yY] || "$answer" == [yY][eE][sS] ]]
}

if [[ $- == *i* ]]; then
    dora() {
        if [[ "$1" == "run" ]]; then
            __ari_pilot_confirm_dora_run || return 130
        fi
        command dora "$@"
    }

    uv() {
        if [[ "$1" == "run" && "$2" == "dora" && "$3" == "run" ]]; then
            __ari_pilot_confirm_dora_run || return 130
        fi
        command uv "$@"
    }
fi
# <<< ari-pilot dora run guard <<<
