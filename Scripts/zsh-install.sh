#!/bin/bash
#=============================================================================
# ZSH & STARSHIP INSTALLATION
#=============================================================================

source "$(dirname "${BASH_SOURCE[0]}")/functions.sh"

log "${INFO} Installing Zsh and Starship..."

# Install packages
install_pkg "zsh"
install_pkg "zsh-completions"
install_pkg "zsh-autosuggestions"
install_pkg "zsh-syntax-highlighting"
install_pkg "starship"

# Change default shell to Zsh
if [[ "$SHELL" != "$(which zsh 2>/dev/null)" ]]; then
    log "${INFO} Changing default shell to Zsh..."
    chsh -s "$(which zsh)" 2>/dev/null || true
    log "${OK} Default shell changed to Zsh"
fi

log "${OK} Zsh and Starship installed"
log "${INFO} Config files will be applied by dotfiles step"
