# ╔══════════════════════════════════════════════════════╗
# ║  s4d Zsh Configuration                              ║
# ╚══════════════════════════════════════════════════════╝

# ── History ──
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY

# ── Options ──
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt CORRECT
setopt INTERACTIVE_COMMENTS
setopt NO_BEEP

# ── Completion ──
autoload -Uz compinit
compinit -d ~/.cache/zsh/zcompdump
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # Case insensitive
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' rehash true
zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.cache/zsh/compcache

# ── Key Bindings ──
bindkey -e  # Emacs-style
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[3~' delete-char
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

# ── Aliases ──
# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Listing (use eza if available)
if command -v eza &>/dev/null; then
    alias ls='eza --icons --group-directories-first'
    alias ll='eza -la --icons --group-directories-first'
    alias lt='eza --tree --icons --level=2'
    alias la='eza -a --icons --group-directories-first'
else
    alias ls='ls --color=auto'
    alias ll='ls -lah --color=auto'
    alias la='ls -A --color=auto'
fi

# Safety
alias rm='rm -I --preserve-root'
alias mv='mv -iv'
alias cp='cp -iv'
alias ln='ln -iv'

# System
alias grep='grep --color=auto'
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias ip='ip -color=auto'
alias dmesg='dmesg --color=auto'

# Pacman / AUR
alias pac='sudo pacman'
alias pacs='sudo pacman -S'
alias pacr='sudo pacman -Rns'
alias pacss='pacman -Ss'
alias pacq='pacman -Q'
alias pacu='sudo pacman -Syu'
alias yays='yay -S'
alias yayu='yay -Syu'
alias cleanup='sudo pacman -Rns $(pacman -Qdtq) 2>/dev/null; yay -Sc --noconfirm 2>/dev/null'

# Hyprland
alias hypr='cd ~/.config/hypr'
alias hc='$EDITOR ~/.config/hypr/hyprland.conf'
alias hr='hyprctl reload'
alias hw='hyprctl clients'
alias hm='hyprctl monitors'

# s4d Theme
alias s4d-theme='~/.config/hypr/scripts/s4d-theme.sh'
alias s4d-wall='~/.config/hypr/scripts/wallpaper.sh'

# Git
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph --decorate -20'
alias gd='git diff'
alias gco='git checkout'

# Quick tools
alias cat='bat --style=plain --paging=never 2>/dev/null || cat'
alias ff='fastfetch'
alias nv='nvim'
alias k='kitty'
alias cls='clear'

# ── Functions ──
# Create and cd into directory
mkcd() { mkdir -p "$@" && cd "$_"; }

# Extract any archive
extract() {
    if [[ -f "$1" ]]; then
        case "$1" in
            *.tar.bz2) tar xjf "$1" ;;
            *.tar.gz)  tar xzf "$1" ;;
            *.tar.xz)  tar xJf "$1" ;;
            *.bz2)     bunzip2 "$1" ;;
            *.gz)      gunzip "$1" ;;
            *.tar)     tar xf "$1" ;;
            *.tbz2)    tar xjf "$1" ;;
            *.tgz)     tar xzf "$1" ;;
            *.zip)     unzip "$1" ;;
            *.7z)      7z x "$1" ;;
            *.rar)     unrar x "$1" ;;
            *)         echo "'$1' cannot be extracted" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# ── Plugins (load if available) ──
# zsh-autosuggestions
[[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && \
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# zsh-syntax-highlighting (must be last)
[[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && \
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ── Prompt ──
# Use starship if available, otherwise simple prompt
if command -v starship &>/dev/null; then
    export STARSHIP_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/starship/starship.toml"
    eval "$(starship init zsh)"
else
    autoload -Uz vcs_info
    precmd() { vcs_info }
    zstyle ':vcs_info:git:*' formats '%F{magenta}(%b)%f '
    setopt PROMPT_SUBST
    PROMPT='%F{blue}%~%f ${vcs_info_msg_0_}%F{green}❯%f '
fi

# ── Fastfetch on first terminal ──
if [[ -z "$S4D_FETCHED" ]] && command -v fastfetch &>/dev/null; then
    fastfetch
    export S4D_FETCHED=1
fi
