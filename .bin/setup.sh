#!/bin/bash
#
# Sets up environment. Must be run after bootstrap-dotfiles.sh. Can be run multiple times.

set -xueE -o pipefail

if [[ "$(</proc/version)" == *[Mm]icrosoft* ]] 2>/dev/null; then
    readonly WSL=1
else
    readonly WSL=0
fi

# Install a bunch of debian packages.
function install_packages() {
    local packages=(
    ascii
    apt-transport-https
    autoconf
    bc
    bfs
    bsdutils
    bzip2
    build-essential
    ca-certificates
    clang-format
    cmake
    command-not-found
    curl
    dconf-cli
    dos2unix
    g++
    gawk
    git
    # gnome-icon-theme
    gzip
    htop
    # jsonnet
    jq
    lftp
    # libglpk-dev
    # libncurses-dev
    # libxml2-utils
    man
    moreutils
    # openssh-server
    p7zip-full
    p7zip-rar
    perl
    poppler-utils
    python3
    python3-pip
    pigz
    software-properties-common
    tree
    unrar
    unzip
    wget
    x11-utils
    xclip
    xsel
    xz-utils
    yodl
    zip
    zsh
    tmux
    )

    if (( WSL )); then
    packages+=(dbus-x11)
    else
    packages+=(gnome-tweak-tool imagemagick iotop tilix remmina wireguard docker.io)
    fi

    sudo apt-get update
    #sudo bash -c 'DEBIAN_FRONTEND=noninteractive apt-get -o DPkg::options::=--force-confdef -o DPkg::options::=--force-confold upgrade -y'
    sudo apt-get install -y "${packages[@]}"
    sudo apt-get autoremove -y
    sudo apt-get autoclean
}

function install_b2() {
    sudo pip3 install --upgrade b2
}

function install_docker() {
    if (( WSL )); then
        local release
        release="$(lsb_release -cs)"
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
        sudo apt-key fingerprint 0EBFCD88
        sudo add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $release stable"
        sudo apt-get update -y
        sudo apt-get install -y docker-ce
    else
        sudo apt-get install -y docker.io
    fi
    sudo usermod -aG docker "$USER"
    pip3 install --user docker-compose
}

function install_brew() {
    local install
    install="$(mktemp)"
    curl -fsSLo "$install" https://raw.githubusercontent.com/Homebrew/install/master/install.sh
    bash -- "$install" </dev/null
    rm -- "$install"
}

# Install Visual Studio Code.
function install_vscode() {
    (( !WSL )) || return 0
    ! command -v code &>/dev/null || return 0
    local deb
    deb="$(mktemp)"
    curl -fsSL 'https://go.microsoft.com/fwlink/?LinkID=760868' >"$deb"
    sudo dpkg -i "$deb"
    rm -- "$deb"
}

function install_exa() {
    local v="0.9.0"
    ! command -v exa &>/dev/null || [[ "$(exa --version)" != *" v$v" ]] || return 0
    local tmp
    tmp="$(mktemp -d)"
    pushd -- "$tmp"
    curl -fsSLO "https://github.com/ogham/exa/releases/download/v${v}/exa-linux-x86_64-${v}.zip"
    unzip exa-linux-x86_64-${v}.zip
    sudo install -DT ./exa-linux-x86_64 /usr/local/bin/exa
    popd
    rm -rf -- "$tmp"
}

function install_ripgrep() {
    local v="14.1.1"
    ! command -v rg &>/dev/null || [[ "$(rg --version)" != *" $v "* ]] || return 0
    local deb
    deb="$(mktemp)"
    curl -fsSL "https://github.com/BurntSushi/ripgrep/releases/download/${v}/ripgrep_${v}-1_amd64.deb" >"$deb"
    sudo dpkg -i "$deb"
    rm "$deb"
}

function install_jc() {
    local v="1.14.4"
    ! command -v jc &>/dev/null || [[ "$(jc -a | jq -r .version)" != "$v" ]] || return 0
    local deb
    deb="$(mktemp)"
    curl -fsSL "https://jc-packages.s3-us-west-1.amazonaws.com/jc-${v}-1.x86_64.deb" >"$deb"
    sudo dpkg -i "$deb"
    rm "$deb"
}

function install_bat() {
    local v="0.18.0"
    ! command -v bat &>/dev/null || [[ "$(bat --version)" != *" $v" ]] || return 0
    local deb
    deb="$(mktemp)"
    curl -fsSL "https://github.com/sharkdp/bat/releases/download/v${v}/bat_${v}_amd64.deb" > "$deb"
    sudo dpkg -i "$deb"
    rm "$deb"
}

function install_gh() {
    local v="2.12.1"
    ! command -v gh &>/dev/null || [[ "$(gh --version)" != */v"$v" ]] || return 0
    local deb
    deb="$(mktemp)"
    curl -fsSL "https://github.com/cli/cli/releases/download/v${v}/gh_${v}_linux_amd64.deb" > "$deb"
    sudo dpkg -i "$deb"
    rm "$deb"
}

function install_fx() {
    local v="31.0.0"
    ! command -v fx &>/dev/null || [[ "$(fx --version)" != "$v" ]] || return 0
    local tmp
    tmp="$(mktemp -- ~/.bin/fx.XXXXXX)"
    curl -fsSLo "$tmp" "https://github.com/antonmedv/fx/releases/download/${v}/fx_linux_amd64"
    chmod +x -- "$tmp"
    mv -- "$tmp" ~/.bin/fx
}

function install_nuget() {
    (( WSL )) || return 0
    local v="5.8.1"
    ! command -v nuget.exe &>/dev/null || [[ "$(nuget.exe help)" != "NuGet Version: $v."* ]] || return 0
    local tmp
    tmp="$(mktemp -- ~/bin/nuget.exe.XXXXXX)"
    curl -fsSLo "$tmp" "https://dist.nuget.org/win-x86-commandline/v${v}/nuget.exe"
    chmod +x -- "$tmp"
    mv -- "$tmp" ~/bin/nuget.exe
}

function install_bw() {
    local v="1.22.1"
    ! command -v bw &>/dev/null || [[ "$(bw --version)" != "$v" ]] || return 0
    local tmp
    tmp="$(mktemp -d)"
    pushd -- "$tmp"
    curl -fsSLO "https://github.com/bitwarden/cli/releases/download/v${v}/bw-linux-${v}.zip"
    unzip -- "bw-linux-${v}.zip"
    chmod +x bw
    mv bw ~/bin/
    popd
    rm -rf -- "$tmp"
}

function install_websocat() {
    local v="1.12.0"
    [[ ! -x ~/bin/websocat || "$(~/bin/websocat --version)" != "websocat $v" ]] || return 0
    local tmp
    tmp="$(mktemp -- ~/bin/websocat.XXXXXX)"
    curl -fsSLo "$tmp" "https://github.com/vi/websocat/releases/download/v${v}/websocat.x86_64-unknown-linux-musl"
    chmod +x -- "$tmp"
    mv -- "$tmp" ~/bin/websocat
}

function fix_locale() {
    sudo tee /etc/default/locale >/dev/null <<<'LC_ALL="C.UTF-8"'
}

# Avoid clock snafu when dual-booting Windows and Linux.
# See https://www.howtogeek.com/323390/how-to-fix-windows-and-linux-showing-different-times-when-dual-booting/.
function fix_clock() {
    (( !WSL )) || return 0
    timedatectl set-local-rtc 1 --adjust-system-clock
}

# Set the shared memory size limit to 64GB (the default is 32GB).
function fix_shm() {
    (( !WSL )) || return 0
    ! grep -qF '# My custom crap' /etc/fstab || return 0
    sudo mkdir -p /mnt/c /mnt/d
    sudo tee -a /etc/fstab >/dev/null <<<'# My custom crap
tmpfs /dev/shm tmpfs defaults,rw,nosuid,nodev,size=64g 0 0
UUID=F212115212111D63 /mnt/c ntfs-3g nosuid,nodev,uid=0,gid=0,noatime,streams_interface=none,remove_hiberfile,async,lazytime,big_writes 0 0
UUID=2A680BF9680BC315 /mnt/d ntfs-3g nosuid,nodev,uid=0,gid=0,noatime,streams_interface=none,remove_hiberfile,async,lazytime,big_writes 0 0'
}

function win_install_fonts() {
    local dst_dir
    dst_dir="$(cmd.exe /c 'echo %LOCALAPPDATA%\Microsoft\Windows\Fonts' 2>/dev/null | sed 's/\r$//')"
    dst_dir="$(wslpath "$dst_dir")"
    mkdir -p "$dst_dir"
    local src
    for src in "$@"; do
        local file="$(basename "$src")"
        if [[ ! -f "$dst_dir/$file" ]]; then
            cp -f "$src" "$dst_dir/"
        fi
        local win_path
        win_path="$(wslpath -w "$dst_dir/$file")"
        # Install font for the current user. It'll appear in "Font settings".
        reg.exe add                                                 \
            'HKCU\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts' \
            /v "${file%.*} (TrueType)" /t REG_SZ /d "$win_path" /f 2>/dev/null
    done
}

# Install a decent monospace font.
function install_fonts() {
  (( WSL )) || return 0
  win_install_fonts ~/.local/share/fonts/NerdFonts/*.ttf
}

function add_to_sudoers() {
  # This is to be able to create /etc/sudoers.d/"$username".
  if [[ "$USER" == *'~' || "$USER" == *.* ]]; then
    >&2 echo "$BASH_SOURCE: invalid username: $USER"
    exit 1
  fi

  sudo usermod -aG sudo "$USER"
  sudo tee /etc/sudoers.d/"$USER" <<<"$USER ALL=(ALL) NOPASSWD:ALL" >/dev/null
  sudo chmod 440 /etc/sudoers.d/"$USER"
}

function fix_dbus() {
  (( WSL )) || return 0
  sudo dbus-uuidgen --ensure
}

function patch_ssh() {
  local v='8.9p1-3ubuntu0.10'
  local ssh
  ssh="$(which ssh)"
  grep -qF -- 'Warning: Permanently added' "$ssh" || return 0
  dpkg -s openssh-client | grep -qxF "Version: 1:$v" || return 0
  local deb
  deb="$(mktemp)"
  curl -fsSLo "$deb" \
    "https://github.com/romkatv/ssh/releases/download/v1.0/openssh-client_${v}_amd64.deb"
  sudo dpkg -i "$deb"
  rm -- "$deb"
}

function enable_sshd() {
  sudo tee /etc/ssh/sshd_config >/dev/null <<'END'
ClientAliveInterval 60
AcceptEnv TERM
X11Forwarding no
X11UseLocalhost no
PermitRootLogin no
AllowTcpForwarding no
AllowAgentForwarding no
AllowStreamLocalForwarding no
AuthenticationMethods publickey
PrintLastLog no
PrintMotd no
END
  (( !WSL )) || return 0
  sudo systemctl enable --now ssh
  if [[ ! -e ~/.ssh/authorized_keys ]]; then
    cp ~/.ssh/id_rsa.pub ~/.ssh/authorized_keys
  fi
}


function with_dbus() {
  if [[ -z "${DBUS_SESSION_BUS_ADDRESS+X}" ]]; then
    dbus-launch "$@"
  else
    "$@"
  fi
}

# Set preferences for various applications.
function set_preferences() {
  if (( !WSL )); then
    gsettings set org.gnome.desktop.interface monospace-font-name 'MesloLGS NF 11'
    sudo update-alternatives --set x-terminal-emulator /usr/bin/tilix.wrapper
  fi
  if [[ -z "${DISPLAY+X}" ]]; then
    export DISPLAY=:0
  fi
  if xprop -root &>/dev/null; then
    # Have X server at $DISPLAY.
    with_dbus dconf load '/org/gnome/gedit/preferences/' <<<"$GEDIT_PREFERENCES"
    with_dbus dconf load '/org/gnome/meld/' <<<"$MELD_PREFERENCES"
    if (( !WSL )); then
      with_dbus dconf load '/com/gexperts/Tilix/' <<<"$TILIX_PREFERENCES"
    fi
  fi
}

function disable_motd_news() {
  (( !WSL )) || return 0
  sudo systemctl disable motd-news.timer
}

function install_locale() {
  sudo locale-gen en_US.UTF-8
  sudo update-locale
}

function setup_tmux() {
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

function install_neovim() {
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

function setup_lazyvim() {
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

if [[ "$(id -u)" == 0 ]]; then
  echo "$BASH_SOURCE: please run as non-root" >&2
  exit 1
fi

umask g-w,o-w

add_to_sudoers

install_packages
install_locale
# install_docker
# install_brew
# install_b2
install_vscode
install_ripgrep
# install_jc
install_bat
install_gh
install_exa
install_fx
# install_nuget
# install_bw
# install_websocat
install_fonts

patch_ssh
enable_sshd
disable_motd_news

fix_locale
fix_clock
fix_shm
fix_dbus
setup_tmux
install_neovim
setup_lazyvim
# set_preferences

echo SUCCESS
