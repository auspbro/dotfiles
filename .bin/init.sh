#!/bin/bash

# Rigorous error handling: exit on error, exit on unset variables,
# and propagate pipeline failures.
set -euo pipefail

# --- Helper Functions and Color Definitions ---
info() {
    echo -e "\033[32m[INFO]\033[0m $1"
}

warn() {
    echo -e "\033[33m[WARN]\033[0m $1"
}

error() {
    echo -e "\033[31m[ERROR]\033[0m $1" >&2 # Print errors to stderr
    exit 1
}

# --- Global Dotfiles Alias Function ---
# Define this globally so all functions can use it.
# This function assumes the bare repo is at $HOME/.dotfiles
dot() {
    /usr/bin/git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME" "$@"
}

# --- Setup Functions ---

setup_git_config() {
    info "Configuring global git settings..."
    if ! command -v git &> /dev/null; then
        error "git is not installed. Please install it first."
    fi

    # Set git configurations
    git config --global user.email "test@test.com"
    git config --global user.name "test"
    git config --global color.ui auto
    git config --global core.quotepath false
    git config --global push.default simple
    git config --global core.autocrlf false
    git config --global core.ignorecase false
    # Optional: delta configuration
    if command -v delta &> /dev/null; then
        info "Configuring git to use 'delta' as the pager."
        git config --global core.pager delta
        git config --global interactive.diffFilter delta
        git config --global delta.navigate true
        git config --global delta.light false
        git config --global delta.side-by-side true
        git config --global merge.conflictstyle diff3
        git config --global diff.colorMoved default
    else
        warn "'delta' is not found. Skipping delta-specific git configuration."
    fi

    info "Global git config setup is complete."
}

setup_tmux() {
    info "Setting up tmux..."
    if ! command -v tmux &> /dev/null; then
        warn "tmux is not installed. Please install it first, e.g., 'sudo apt install tmux' or 'brew install tmux'."
        return 0 # Not a fatal error, just skip
    fi

    local TPM_DIR="$HOME/.tmux/plugins/tpm"
    if [ -d "$TPM_DIR" ]; then
        info "Tmux Plugin Manager (TPM) is already installed."
    else
        info "Installing Tmux Plugin Manager (TPM)..."
        if ! git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"; then
            error "Failed to clone TPM repository."
        fi
    fi
    
    # This check is now smarter. It ensures the TPM initialization line is present.
    local TMUX_CONF="$HOME/.tmux.conf"
    local TPM_RUN_LINE="run '~/.tmux/plugins/tpm/tpm'"
    if [ -f "$TMUX_CONF" ] && grep -q "$TPM_RUN_LINE" "$TMUX_CONF"; then
        info "tmux config ($TMUX_CONF) already seems to be configured for TPM."
    else
        warn "$TMUX_CONF is missing or not configured for TPM. Appending default TPM config."
        # Appending ensures we don't overwrite a user's existing partial config.
        cat << EOF >> "$TMUX_CONF"

# --- Added by setup script ---
# List of plugins
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'tmux-plugins/tmux-resurrect'

# Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
$TPM_RUN_LINE
EOF
    fi

    info "Tmux setup complete. Start tmux and press 'Prefix + I' to install plugins."
}

install_zsh() {
    info "Checking for Zsh..."
    if command -v zsh &> /dev/null; then
        info "Zsh is already installed: $(zsh --version)"
        return 0
    fi

    warn "Zsh not found, attempting installation..."
    if command -v apt-get &> /dev/null; then
        sudo apt-get update && sudo apt-get install -y zsh
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y zsh
    elif command -v yum &> /dev/null; then
        sudo yum install -y zsh
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm zsh
    elif command -v zypper &> /dev/null; then
        sudo zypper install -y zsh
    elif command -v brew &> /dev/null; then
        brew install zsh
    else
        error "Could not determine package manager. Please install Zsh manually."
    fi

    if ! command -v zsh &> /dev/null; then
        error "Zsh installation failed. Please check the output."
    fi
    info "Zsh installed successfully!"
}

setup_zsh4humans() {
    info "Setting up zsh4humans..."
    local Z4H_DIR="$HOME/.cache/zsh4humans"

    if [ -d "$Z4H_DIR" ]; then
        info "zsh4humans appears to be already installed. Skipping installation."
    else
        info "Installing zsh4humans..."
        if ! zsh -c "$(curl -fsSL https://raw.githubusercontent.com/romkatv/zsh4humans/v5/install)"; then
            error "zsh4humans installation script failed."
        fi
        info "zsh4humans core files installed."

        info "Restoring '.zshrc' and '.p10k.zsh' from your dotfiles repository..."
        if ! dot checkout -f -- .zshrc .p10k.zsh; then
            error "Failed to restore config from bare repository. Ensure .zshrc and .p10k.zsh are tracked."
        fi
        info "Successfully restored your custom Zsh configuration."
    fi

    if [ "$(basename "$SHELL")" != "zsh" ]; then
        warn "Your default shell is not Zsh. Attempting to change it."
        local ZSH_PATH
        ZSH_PATH=$(which zsh)
        if [ -z "$ZSH_PATH" ]; then
            error "Could not find the zsh executable path."
        fi

        # Robust check for chsh
        if ! grep -Fxq "$ZSH_PATH" /etc/shells; then
            warn "Zsh path '$ZSH_PATH' not found in /etc/shells. Adding it with sudo."
            if ! echo "$ZSH_PATH" | sudo tee -a /etc/shells; then
                error "Failed to add Zsh to /etc/shells. Please do it manually."
            fi
        fi

        if command -v chsh &>/dev/null; then
            info "Changing default shell to Zsh. This may require your password."
            if chsh -s "$ZSH_PATH"; then
                info "Default shell changed to Zsh. Please log out and log back in for it to take effect."
            else
                warn "Could not automatically change the default shell. Please run 'chsh -s $ZSH_PATH' manually."
            fi
        else
            warn "'chsh' command not found. Please change your default shell to Zsh manually."
        fi
    fi
    info "zsh4humans setup is complete."
}


# --- Main Execution Logic ---
main() {
    info "Starting the development environment setup..."
    
    # Step 1: Git must be installed. The rest depends on it.
    if ! command -v git &>/dev/null; then
        error "Git is not installed. It's a fundamental requirement. Please install it and run again."
    fi
    
    # Step 3: Configure global git settings.
    setup_git_config
    
    # Step 4: Install Zsh if not present.
    install_zsh

    # Step 5: Setup zsh4humans and link our dotfiles.
    setup_zsh4humans
    
    # Step 6: Setup tmux.
    setup_tmux

    echo -e "\n\033[32m✅ All setup tasks completed successfully!\033[0m"
}

# Run the main function if the script is not being sourced.
# This check is robust and works for direct execution, and `curl | bash`.
if ! (return 0 2>/dev/null); then
    main
fi
