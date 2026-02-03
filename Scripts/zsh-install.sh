#!/bin/bash
#=============================================================================
# ZSH & STARSHIP INSTALLATION
#=============================================================================

source "$(dirname "${BASH_SOURCE[0]}")/functions.sh"

log "${INFO} Installing Zsh and Starship..."

# Install Zsh
install_pkg "zsh"
install_pkg "zsh-completions"
install_pkg "zsh-autosuggestions"
install_pkg "zsh-syntax-highlighting"
install_pkg "starship"

# Create Zsh configuration
cat > "$HOME/.zshrc" << 'EOF'
# s4d Hyprland - Zsh Configuration

# History configuration
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups

# Basic options
setopt autocd
setopt interactive_comments
setopt magicequalsubst
setopt notify
setopt numericglobsort

# Completion
autoload -Uz compinit
compinit -d ~/.cache/zcompdump
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Key bindings
bindkey -e
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[3~' delete-char
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

# Aliases
alias ls='ls --color=auto'
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'
alias grep='grep --color=auto'
alias ..='cd ..'
alias ...='cd ../..'
alias cls='clear'
alias cat='cat -v'
alias df='df -h'
alias du='du -h'
alias free='free -h'

# Hyprland specific aliases
alias hypr-reload='hyprctl reload'
alias hypr-kill='hyprctl kill'
alias hypr-logs='cat ~/.local/share/hyprland/hyprland.log'

# Environment variables
export EDITOR=vim
export VISUAL=vim
export TERMINAL=kitty
export BROWSER=firefox

# Wayland environment
export XDG_CURRENT_DESKTOP=Hyprland
export XDG_SESSION_TYPE=wayland
export XDG_SESSION_DESKTOP=Hyprland
export QT_QPA_PLATFORM=wayland
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
export GDK_BACKEND=wayland,x11
export MOZ_ENABLE_WAYLAND=1

# Plugins
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh 2>/dev/null
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null

# FZF integration
if command -v fzf &>/dev/null; then
    source /usr/share/fzf/key-bindings.zsh 2>/dev/null
    source /usr/share/fzf/completion.zsh 2>/dev/null
fi

# Initialize Starship prompt
eval "$(starship init zsh)"
EOF

# Create Starship configuration
mkdir -p "$HOME/.config"

cat > "$HOME/.config/starship.toml" << 'EOF'
# Starship Configuration - s4d Hyprland

format = """
[╭─](bold blue)$username$hostname$directory$git_branch$git_status$cmd_duration
[╰─](bold blue)$character"""

[username]
style_user = "bold green"
style_root = "bold red"
format = "[$user]($style)"
show_always = true

[hostname]
ssh_only = false
format = "[@$hostname](bold yellow) "

[directory]
style = "bold cyan"
truncation_length = 3
truncate_to_repo = true
format = "[$path]($style)[$read_only]($read_only_style) "

[git_branch]
style = "bold purple"
format = "[$symbol$branch]($style) "

[git_status]
style = "bold red"
format = "[$all_status$ahead_behind]($style)"
conflicted = "⚡"
ahead = "⇡${count}"
behind = "⇣${count}"
diverged = "⇕⇡${ahead_count}⇣${behind_count}"
untracked = "?"
stashed = "📦"
modified = "!"
staged = "+"
renamed = "»"
deleted = "✘"

[cmd_duration]
min_time = 2000
format = "took [$duration](bold yellow) "

[character]
success_symbol = "[❯](bold green)"
error_symbol = "[❯](bold red)"
EOF

# Change default shell to Zsh
if [[ "$SHELL" != "$(which zsh)" ]]; then
    log "${INFO} Changing default shell to Zsh..."
    chsh -s "$(which zsh)"
    log "${OK} Default shell changed to Zsh"
fi

log "${OK} Zsh and Starship installed and configured"
log "${INFO} Restart your terminal or run 'source ~/.zshrc' to apply changes"
