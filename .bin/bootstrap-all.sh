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

setup_dotfiles_repo() {
    info "Setting up the dotfiles bare repository..."
    if [ -d "$HOME/.dotfiles" ]; then
        info "Dotfiles repository already exists at $HOME/.dotfiles. Skipping clone."
    else
        # Replace with your actual repository URL
        if ! git clone --bare https://github.com/xuex1x/dotfiles.git "$HOME/.dotfiles"; then
            error "Failed to clone the dotfiles repository."
        fi
    fi

    # Create a backup directory
    mkdir -p "$HOME/.dotfiles-backup"

    info "Backing up any pre-existing dotfiles that would conflict..."
    local has_backed_up=false
    # Use `dot ls-tree` to get a list of all files in the repo
    dot ls-tree -r main --name-only | while read -r file; do
        if [ -e "$HOME/$file" ] || [ -L "$HOME/$file" ]; then # Check for files or symlinks
            if ! $has_backed_up; then
                warn "Found conflicting files. Moving them to .dotfiles-backup/"
                has_backed_up=true
            fi
            info "  -> Backing up $file"
            # Ensure parent directory exists in backup location
            mkdir -p "$HOME/.dotfiles-backup/$(dirname "$file")"
            mv "$HOME/$file" "$HOME/.dotfiles-backup/$file"
        fi
    done

    info "Checking out dotfiles..."
    if ! dot checkout; then
        error "Failed to checkout dotfiles. Check the output above for conflicts."
    fi

    # Configure the repo to not show untracked files
    dot config status.showUntrackedFiles no
    info "Setup complete! Dotfiles are now managed by dot."
}

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


install_neovim() {
    info "Checking and installing Neovim..."

    if command -v nvim &> /dev/null; then
        # ... (version check logic remains the same) ...
        local version_str=$(nvim --version | head -n 1 | cut -d ' ' -f 2)
        if [[ "$(printf '%s\n' "v0.9.0" "${version_str}" | sort -V | head -n 1)" == "v0.9.0" ]]; then
             info "Neovim is already installed and meets the version requirement: $version_str"
             return 0
        fi
    fi

    warn "Neovim not found. Attempting to install the latest stable version..."
    if [[ "$(uname)" == "Darwin" ]]; then
        # ... (macOS logic remains the same) ...
        if ! command -v brew &> /dev/null; then error "Homebrew not found..."; fi
        info "Using Homebrew to install Neovim on macOS..."
        if ! brew install neovim; then error "Failed to install Neovim via Homebrew."; fi

    elif [[ "$(uname)" == "Linux" ]]; then
        # --- Linux Installation with a robust PATH handling ---
        local NVIM_INSTALL_DIR="$HOME/.local/bin"
        local NVIM_APPIMAGE_PATH="$NVIM_INSTALL_DIR/nvim"
        mkdir -p "$NVIM_INSTALL_DIR"

        info "Downloading the latest Neovim AppImage to $NVIM_APPIMAGE_PATH..."
        if ! curl -fLo "$NVIM_APPIMAGE_PATH" "https://github.com/neovim/neovim/releases/download/stable/nvim-linux-x86_64.appimage"; then
            error "Failed to download Neovim AppImage.Please check your network or the URL."
        fi
        chmod u+x "$NVIM_APPIMAGE_PATH"

        # --- ELEGANT SOLUTION STARTS HERE ---
        
        # 1. IMMEDIATE FIX: Update PATH for the CURRENT script execution.
        # This ensures the verification step below will pass.
        if [[ ":$PATH:" != *":$NVIM_INSTALL_DIR:"* ]]; then
            info "Adding '$NVIM_INSTALL_DIR' to PATH for the current session."
            export PATH="$NVIM_INSTALL_DIR:$PATH"
        fi

        # 2. PERSISTENT FIX: Add the PATH update to the user's shell config file.
        local shell_config_file=""
        local current_shell=$(basename "$SHELL")

        if [ "$current_shell" = "zsh" ]; then
            shell_config_file="$HOME/.zshrc"
        elif [ "$current_shell" = "bash" ]; then
            shell_config_file="$HOME/.bashrc"
        fi

        if [ -n "$shell_config_file" ] && [ -f "$shell_config_file" ]; then
            # Add to config file only if the line doesn't already exist
            local path_export_line="export PATH=\"\$HOME/.local/bin:\$PATH\""
            if ! grep -qF "$path_export_line" "$shell_config_file"; then
                info "Adding PATH update to $shell_config_file for future sessions..."
                echo -e "\n# Add ~/.local/bin to PATH for locally installed tools\n$path_export_line" >> "$shell_config_file"
            else
                info "PATH configuration already exists in $shell_config_file."
            fi
        else
            # Fallback warning if shell config is not found
            warn "Could not automatically update your shell config. Please manually add '$NVIM_INSTALL_DIR' to your PATH."
        fi
        # --- ELEGANT SOLUTION ENDS HERE ---

    else
        error "Unsupported OS: $(uname). Please install Neovim manually."
    fi

    # Verify installation - this will now succeed thanks to the immediate PATH export
    if ! command -v nvim &> /dev/null; then
        error "Neovim installation failed. The 'nvim' command is still not available."
    fi

    info "Neovim installed successfully: $(nvim --version | head -n 1)"
    return 0
}


setup_lazyvim() {
    info "Setting up LazyVim..."

    # --- Dependency Check ---
    if ! command -v nvim &> /dev/null; then
        error "Neovim is not installed. Please run the Neovim installer first."
    fi
    if ! command -v git &> /dev/null; then
        error "Git is not installed. It is required to install LazyVim."
    fi
    info "Dependencies met (Neovim and Git are installed)."

    # --- Backup and Install Logic ---
    local NVIM_CONFIG_DIR="$HOME/.config/nvim"

    # If the config dir exists, decide what to do
    if [ -d "$NVIM_CONFIG_DIR" ]; then
        # If it's already a LazyVim setup, we are done.
        if [ -f "$NVIM_CONFIG_DIR/lazy-lock.json" ]; then
            info "LazyVim configuration already exists at $NVIM_CONFIG_DIR. No action needed."
            return 0
        fi
        
        # If it's some other config, back it up.
        local backup_dir="${NVIM_CONFIG_DIR}.bak.$(date +%Y%m%d-%H%M%S)"
        warn "Existing Neovim configuration found at $NVIM_CONFIG_DIR."
        info "Backing it up to $backup_dir"
        if ! mv "$NVIM_CONFIG_DIR" "$backup_dir"; then
            error "Failed to back up existing Neovim configuration."
        fi
    fi

    # Clone the LazyVim starter template
    info "Cloning the LazyVim starter template..."
    if ! git clone https://github.com/LazyVim/starter "$NVIM_CONFIG_DIR"; then
        error "Failed to clone LazyVim starter repository."
    fi
    # Remove the .git directory so the user can initialize their own git repo for their config
    rm -rf "$NVIM_CONFIG_DIR/.git"
    info "LazyVim starter template installed successfully."
    
    # Optional but highly recommended: back up existing data/state directories
    # to provide a completely fresh start for LazyVim.
    for dir_to_backup in "$HOME/.local/share/nvim" "$HOME/.local/state/nvim" "$HOME/.cache/nvim"; do
        if [ -d "$dir_to_backup" ]; then
             local backup_data_dir="${dir_to_backup}.bak.$(date +%Y%m%d-%H%M%S)"
             info "Backing up existing Neovim data directory '$dir_to_backup' to '$backup_data_dir'"
             mv "$dir_to_backup" "$backup_data_dir"
        fi
    done

    echo ""
    info "--- LazyVim Setup Complete ---"
    info "Next time you run 'nvim', LazyVim will bootstrap and install all plugins."
    return 0
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
        if ! sh -c "$(curl -fsSL https://raw.githubusercontent.com/romkatv/zsh4humans/v5/install)"; then
            error "zsh4humans installation script failed."
        fi
        info "zsh4humans core files installed."

        info "Restoring '.zshrc' and '.p10k.zsh' from your dotfiles repository..."
        if ! dot checkout -f -- .zshrc .p10k.zsh; then
            error "Failed to restore config from bare repository. Ensure .zshrc and .p10k.zsh are tracked."
        fi
        info "Successfully restored your custom Zsh configuration."
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
    
    # Step 2: Setup dotfiles repository first, as other steps may depend on it.
    setup_dotfiles_repo

    # Step 3: Configure global git settings.
    # setup_git_config

    # Step 4: Setup tmux.
    setup_tmux

    # Step 5: Install neovim.
    install_neovim

    # Step 6: Setup lazyvim.
    setup_lazyvim
    
    # Step 7: Install Zsh if not present.
    install_zsh

    # Step 8: Setup zsh4humans and link our dotfiles.
    setup_zsh4humans

    echo -e "\n\033[32m✅ All setup tasks completed successfully!\033[0m"
}

# Run the main function if the script is not being sourced.
# This check is robust and works for direct execution, and `curl | bash`.
if ! (return 0 2>/dev/null); then
    main
fi
