
# update git config
setup_git() {
    # Check if git is installed
    if ! command -v git &> /dev/null
    then
        echo "Error: git is not installed."
        echo "Please install git first, then run this function or script again."
        return 1 # Return an error code
    fi

    echo "git is installed."

    git config --global color.status auto
    git config --global color.diff auto
    git config --global color.branch auto
    git config --global color.interactive auto
    git config --global core.quotepath false
    git config --global push.default simple
    git config --global core.autocrlf false
    git config --global core.ignorecase false
    git config --global core.pager delta
    git config --global interactive.diffFilter delta
    git config --global add.interactive.useBuiltin false
    git config --global delta.navigate true
    git config --global delta.light false
    git config --global delta.side-by-side true
    git config --global merge.conflictstyle diff3
    git config --global diff.colorMoved default
}


# Function to set up tmux with TPM and specified plugins
setup_tmux_with_plugins() {
    # Check if tmux is installed
    if ! command -v tmux &> /dev/null
    then
        echo "Error: tmux is not installed."
        echo "Please install tmux first, then run this function or script again."
        echo "For example, on Debian/Ubuntu run: sudo apt update && sudo apt install tmux"
        echo "On macOS run: brew install tmux"
        return 1 # Return an error code
    fi

    echo "Tmux is installed."

    # Define the path for tmux Plugin Manager
    local TPM_DIR="$HOME/.tmux/plugins/tpm" # Use local for variables inside a function

    # Check if TPM is already installed
    if [ -d "$TPM_DIR" ]; then
        echo "Tmux Plugin Manager (TPM) is already installed at $TPM_DIR."
    else
        echo "Installing Tmux Plugin Manager (TPM)..."
        if git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"; then
            echo "TPM installed successfully."
        else
            echo "Error: Could not clone TPM repository. Please check your internet connection and if Git is installed."
            return 1 # Return an error code
        fi
    fi

    # Define the tmux configuration file path
    local TMUX_CONF="$HOME/.tmux.conf" # Use local

    echo "Configuring $TMUX_CONF ..."
    if [ ! -e "$TMUX_CONF" ]; then
        cat << EOF > "$TMUX_CONF"
# Base config
set -g mouse on
set -g history-limit 10000

# List of plugins
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'tmux-plugins/tmux-resurrect'

# Other examples:
# set -g @plugin 'github_username/plugin_name'
# set -g @plugin 'github_username/plugin_name#branch'
# set -g @plugin 'git@github.com:user/plugin'

# Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
run '~/.tmux/plugins/tpm/tpm'
EOF
    else
         echo "tmux config file $TMUX_CONF exists."
    fi
    

    echo "Tmux configuration file ($TMUX_CONF) created/updated."
    echo ""
    echo "Configuration complete!"
    echo ""
    echo "Please follow these steps to complete plugin installation:"
    echo "1. Start tmux (if it's already running, exit and restart it, or reload the configuration:"
    echo "   In tmux, press 'Prefix' (default Ctrl-b), then type ':' and execute 'source-file ~/.tmux.conf')"
    echo "2. In your tmux session, press 'Prefix' + I (uppercase i) to install the plugins."
    echo "   You should see the plugin installation process at the bottom."
    echo ""
    echo "Tip: The 'Prefix' is Ctrl-b (C-b) by default."

    # Attempt to automatically reload the new tmux configuration if a tmux server is running
    if tmux info &> /dev/null; then
        echo "Detected a running tmux server. Attempting to reload configuration..."
        if tmux source-file "$TMUX_CONF"; then
            echo "Tmux configuration reloaded."
            echo "Now, please press 'Prefix' + I (uppercase i) in tmux to install the plugins."
        else
            echo "Could not automatically reload tmux configuration. Please do it manually or restart tmux."
        fi
    else
        echo "Please start tmux to apply the new configuration and install plugins."
    fi

    return 0 # Return success
}

setup_git
setup_tmux_with_plugins