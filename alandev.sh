#!/bin/bash -i
LOCATION="${LOCATION:=$(pwd)}"
HTTP_PROXY="ip_addr:port"

ACTIVE_CONTAINER_ID=$(docker ps -aqf "name=alanenv")
NOCACHE=""

if [ "$1" == "rebuild" ] ; then
    NOCACHE="--no-cache"
fi

# DOCKER_BUILDKIT=0 docker build --build-arg http_proxy=$HTTP_PROXY $NOCACHE --platform linux/amd64 -t alanenv - <<EOF
DOCKER_BUILDKIT=0 docker build $NOCACHE --platform linux/amd64 -t alanenv - <<EOF
FROM ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV http_proxy=$HTTP_PROXY 
ENV https_proxy=$HTTP_PROXY

# Configure apt-get proxy
RUN if [ -n "${http_proxy}" ] ; then \
     echo "Acquire::http::Proxy ${http_proxy}"; >> /etc/apt/apt.conf && \
     echo "Acquire::https::Proxy ${http_proxy}"; >> /etc/apt/apt.conf ; \
    fi


# 更换阿里云源
# RUN sed -i "s/security.ubuntu.com/mirrors.aliyun.com/" /etc/apt/sources.list && \
    sed -i "s/archive.ubuntu.com/mirrors.aliyun.com/" /etc/apt/sources.list && \
    sed -i "s/security.ubuntu.com/mirrors.aliyun.com/" /etc/apt/sources.list && \
    apt-get clean && \
    apt-get update


RUN apt-get install -y \
    curl \
    cmake \
    g++ \
    gcc \
    git \
    libncurses5-dev \
    docker.io \
    docker-compose \
    libssl-dev \
    xsltproc \
    fop \
    libxml2-utils \
    wget

# Configure wget proxy 
RUN  echo "http_proxy=${http_proxy}" >> /etc/wgetrc && \
     echo "https_proxy=${http_proxy}" >> /etc/wgetrc && \
     echo "use_proxy=yes" >> /etc/wgetrc ; \

# RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash -

RUN apt-get update

RUN apt-get install -y \
    cmake \
    curl \
    docker-compose \
    docker.io \
    efm-langserver \
    zsh \
    fzf \
    bat \
    g++ \
    gcc \
    git \
    vim \
    libncurses5-dev \
    ripgrep \
    tmux \
    unzip \
    python3 \
    python3-pip

# SHELL ["/bin/zsh", "-lc"]

RUN wget https://github.com/tree-sitter/tree-sitter/releases/download/v0.20.7/tree-sitter-linux-x64.gz
RUN gunzip tree-sitter-linux-x64.gz
RUN mv tree-sitter-linux-x64 /usr/bin/tree-sitter
RUN chmod +x /usr/bin/tree-sitter

# Install nvm & node
ENV NVM_DIR /root/.nvm
ENV NODE_VERSION v19
RUN mkdir -p $NVM_DIR && \
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash \
        && export NVM_DIR="$HOME/.nvm" \
        && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm \
        && [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion 

        # && nvm install ${NODE_VERSION} \
        # && nvm use ${NODE_VERSION} \
        # && nvm alias ${NODE_VERSION} 

# Install oh-my-zsh
RUN git clone https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh && \
    cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc && \
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting && \
    git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search && \
    sed -i 's/^plugins=(/plugins=(git tmux history-substring-search zsh-autosuggestions zsh-syntax-highlighting z /' ~/.zshrc && \
    chsh -s /bin/zsh

RUN echo '' >> ~/.zshrc \
    && echo 'export NVM_DIR="/root/.nvm"' >> ~/.zshrc \
    && echo '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm' >> ~/.zshrc
    && echo "bindkey ',' autosuggest-accept" >>/.zshrc
    && echo "bindkey '^P' history-substring-search-up" >>/.zshrc
    && echo "bindkey '^N' history-substring-search-down" >>/.zshrc


# Install neovim
RUN wget https://github.com/neovim/neovim/releases/download/stable/nvim.appimage
RUN chmod u+x nvim.appimage \
    && ./nvim.appimage --appimage-extract \
    && cp ./squashfs-root/usr/bin/nvim /usr/bin

# RUN git clone --depth=1 https://github.com/savq/paq-nvim.git /root/.local/share/nvim/site/pack/paqs/start/paq-nvim --branch v1.1.0
# RUN git clone --depth=1 https://github.com/hauxir/dotfiles.git /root/dotfiles
RUN git clone --depth=1 https://github.com/auspbro/dotfiles.git /root/.dotfiles


RUN git config --global --add safe.directory '*'
# RUN npm install -g typescript-language-server typescript
# RUN npm install -g vscode-json-languageserver
# RUN npm install -g bash-language-server
# RUN npm install -g eslint_d


RUN git clone --depth=1 https://github.com/asdf-vm/asdf.git /root/.asdf --branch v0.8.1
RUN echo -e '\n. /root/.asdf/asdf.sh' >> /root/.profile
RUN echo -e '\n. /root/.asdf/completions/asdf.bash' >> /root/.bashrc
RUN echo 'source ~/.config/.env' >> /root/.profile


RUN echo "N"
ENV KERL_BUILD_DOCS=yes

RUN pip install pyright
RUN pip install shell-gpt
WORKDIR /root/alan

CMD ["tmux", "-u", "new-session"]
EOF


mkdir -p $HOME/.local/share/zsh/
touch $HOME/.local/share/zsh/zsh_history
touch $HOME/.config/.env

if [ -n "$NOCACHE" ]
then
    docker kill $ACTIVE_CONTAINER_ID
    docker rm $ACTIVE_CONTAINER_ID
    ACTIVE_CONTAINER_ID=""
fi

if [ -z "$ACTIVE_CONTAINER_ID" ]
then
  ACTIVE_CONTAINER_ID=$(
    docker run \
    --platform linux/amd64 \
    -v "$HOME/.local/share/zsh/zsh_history:/root/.local/share/zsh/zsh_history" \
    -v "$HOME/.ssh":/root/.ssh \
    -v "$HOME/.config/github-copilot":/root/.config/github-copilot/ \
    -v "$HOME/.config/.env":/root/.config/.env \
    -v "$LOCATION:/root/work/" \
    -v /var/run/docker.sock:/var/run/docker.sock \
    --network host \
    --name alanenv \
    -d \
    -it \
    alanenv
  )
fi

docker start $ACTIVE_CONTAINER_ID
docker attach $ACTIVE_CONTAINER_ID
