

# vim

configuration files of vim

Usege: Put this repository in where you like, such as ~/.config

## Neovim 安装
```
sudo add-apt-repository ppa:neovim-ppa/unstable && sudo apt update && sudo apt -y install neovim
```

## Install coc.nvim
Coc.nvim is mostly written in TypeScript and runs on Node.js.

### Requirements

* `neovim` >= `0.4.0` or `vim` >= `8.1.1719 ` (run `:version` or `vim --version` to find your Vim version)
* `node` >= `14.14`

Install [Node.js](https://nodejs.org/)
```sh
# 最新版本需要系统更新Glibc，centos7下载老一点的版本
wget https://nodejs.org/download/release/v15.14.0/node-v15.14.0-linux-x64.tar.xz
tar xf node-v15.14.0-linux-x64.tar.xz
cp -r node-v15.14.0-linux-x64  /usr/local/
ln -s /usr/local/node-v15.14.0-linux-x64/bin/node /usr/local/bin
ln -s /usr/local/node-v15.14.0-linux-x64/bin/npm /usr/local/bin

# 使用 nvm 来安装获取 Node.js
# https://github.com/nvm-sh/nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash

# 把这个放到你的 .bashrc (如果你使用 zsh 放到发 .zshrc 中，其他的 shell 类似)
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

nvm install v16
sudo apt install -y npm
sudo npm install --global yarn
```
**Note:** coc.nvim finds `node` by calling `executable('node')` from within vim. Check out
`:h g:coc_node_path` to customize node path.

Install [Yarn](https://yarnpkg.com/) — required when building from source.

```sh
curl --compressed -o- -L https://yarnpkg.com/install.sh | bash
```

**Note**: NixOS users must follow these steps:

1. Install [Node.js](https://nodejs.org/) via `nix-env` or put it in `/etc/nixos/configuration.nix`
2. `sudo nixos-rebuild switch`

### Add coc.nvim to vim's runtimepath

#### Using [vim-plug](https://github.com/junegunn/vim-plug)

Use coc's release branch (recommended):

``` vim
Plug 'neoclide/coc.nvim', {'branch': 'release'}
```

Build from source:

``` vim
Plug 'neoclide/coc.nvim', { 'branch': 'master', 'do': 'yarn install --frozen-lockfile' }
```

Run command `:PlugInstall` in your (neo)vim.

---
## plug.vim 安装
### plug.vim配置
1. 在./config/中git clone nvim配置文件
    ```
    cd ~/.config/ && git clone https://github.com/linweilin/nvim.git
    ```
2. 插件安装
- 启动neovim`$ nvim`
- 安装插件`:PlugInstall`

    #### 配置说明
    - plug.vim 为插件配置器安装文件，位于~/.config/nvim/autoload/下。
    - init.vim 为neovim（及其插件）配置文件，位于~/.config/nvim/init.vim。
    - coc.nvim安装需要较长时间，耐心等待
    - init.vim中的插件列表（可自行增减配置）
        ```
        coc-nvim                    // coc功能
        identline                   // 自动缩进
        nercommenter                // 快速注释
        vim-airline                 // 状态栏
        vim-lsp-cxx-highliht        // 语法高亮
        gruvb                       // 主题和配色
        ```
---
## coc.nvim配置
### coc插件安装
1. 安装marketplace：
    ```
    :CocInstall coc-marketplace
    ```
2. 循环使用`:CocLists`，进入marketplace，再安装剩余的插件。之后每次按 `空格+p`，重复打开上次的窗口，直至安装完毕。
    ```
    coc-python
    coc-lists
    coc-leetcode
    coc-git
    coc-actions
    coc-json
    coc-cmake
    coc-ccls
    ```
3. 如果安装coc-nvim时出错，请先升级nodejs（看下面）

### nodejs安装
1. 到[node js官网](https://nodejs.org/en/download/)下载编译好的二进制文件，解压后得到文件夹node-vxx.xx.x-linux-x64
2. 移动到opt文件夹
    ```
    sudo mv Downloads/node-vxx.xx.x-linux-x64 /opt
    ```
3. 添加环境变量到.bashrc（环境变量用冒号分隔）：
    ```
    echo 'export PATH=$PATH:/opt/node-vxx.xx.x-linux-x64/bin' >> ~/.bashrc
    // 若为zsh，则
    // echo 'export PATH=$PATH:/opt/node-vxx.xx.x-linux-x64/bin' >> ~/.zshrc
    ```
4. 查看版本（至少大于10）：
    ```
    node -v 
    // 若已经安装过node，，且安装的node版本小于10，则需
    // sudo apt remove node nodejs-dev npm
    // 如果node无法通过apt卸载，则可以 sudo mv /usr/bin/node /usr/bin/node_ori
    ```
5. 根据`:checkhealth`中的提示执行：
    ```
    sudo apt install npm
    npm install -g neovim
    ```

### python安装
#### 安装pip3
默认的python 3.5、3.6版本同样可以安装neovim，只是缺少了pip3而已。
```
sudo apt -y install python3-pip
pip3 --version
```
#### 安装pylint和pynvim：
1. `python3 -m pip install pynvim pylint`
    - 如果安装失败，则更换pip的源
        修改 ~/.pip/pip.conf (没有就创建一个)， 重定向 index-url至tuna：
        ```
        mkdir ~/.pip
        nvim ~/.pip/pip.conf
        ```
        添加以下内容
        ```
        [global]
        index-url = https://pypi.tuna.tsinghua.edu.cn/simple
        ```
#### 安装language-server
```
python3 -m pip install 'python-language-server[all]'
```
#### 根据python的版本，修改nvim和coc.nvim的python版本配置
- `$ nvim ~/.config/init.vim`，找到python路径，修改为对应的版本号
- 在nvim中，`:C`（或`:CocConfig`）,找到下列python路径，修改为对应的版本号
```
{
	"python.pythonPath": "/usr/bin/python3.6"
}
```
## ccls安装及使用
### apt install 安装
- 最简单的方式，适用于ubuntu 16.04, 18.04及以上
    
    ```
    sudo apt update && sudo apt install snapd && sudo snap install ccls --classic
    ```
- 或源码编译，适用于不能直接通过snap安装的子系统wsl
    安装ccls的依赖
    ```
    sudo apt install zlib1g-dev libncurses-dev rapidjson-dev
    sudo apt install clang-10 libclang-10-dev
    sudo update-alternatives --install /usr/bin/clang clang /usr/bin/clang-10 100
    sudo update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-10 100
    ```
    cmake 编译
    ```
    cmake -H. -BRelease -GNinja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_PREFIX_PATH=/usr/lib/llvm-10 \
        -DLLVM_INCLUDE_DIR=/usr/lib/llvm-10/include \
        -DLLVM_BUILD_INCLUDE_DIR=/usr/include/llvm-10/
    
    sudo cmake --build Release --target install
    ```
- 或直接使用pre built header的方法

    ```
    wget -c http://releases.llvm.org/8.0.0/clang+llvm-8.0.0-x86_64-linux-gnu-ubuntu-18.04.tar.xz  // 下载的时候有点慢，最好是在gitter下或者是使用sudo apt install 的方法安装clang+llvm
    tar -xzvf clang+llvm-8.0.0-x86_64-linux-gnu-ubuntu-18.04.tar.xz
    mv clang+llvm-8.0.0-x86_64-linux-gnu-ubuntu-18.04.tar.xz clang-8
    sudo mv clang-8 /usr/local/
    cmake -H. -BRelease -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH=/usr/local/clang-8
    ```    
### 配置工程：
- 在cmake时加上
    ```
    cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
    ln -s ~/myproject/compile_commands.json ~/myproject-build/
    ```
- ccls language server（已于coc_settings.json中配置）。
    - 添加到coc-settings.json，去除"languageserver":这一行，加“，”合并在一个花括号中。
    ```
    {
        "ccls": {
            "command": "ccls",
            "filetypes": ["c", "cc", "cpp", "c++", "objc", "objcpp"],
            "rootPatterns": [".ccls", "compile_commands.json", ".nvim/", ".git/", ".hg/"],
            "initializationOptions": {
                "cache": {
                    "directory": "/tmp/ccls"
                }
            }
        },
    }
    ```
### ROS中使用ccls
在catkin_make时，使用以下命令生成compile_commands.json，链接到工程目录下即可。
```
catkin_make --cmake-args -DCMAKE_EXPORT_COMPILE_COMMANDS=YES
```
### 安装coc-ccls后，打开nvim报错解决
报错：`[coc.nvim] Unable to load global extension at /home/username/.config/coc/extensions/node_modules/coc-ccls: main file ./lib/extension.js not found, you may need to build the project.`
```
cd ~/.config/coc/extensions/node_modules/coc-ccls
ln -s node_modules/ws/lib lib
```

---

## 在coc.nvim中使用ripgrep
### 安装ripgrep
```
cd ~/Downloads/ && curl -LO  https://github.com/BurntSushi/ripgrep/releases/download/12.1.1/ripgrep_12.1.1_amd64.deb && sudo dpkg -i ripgrep_12.1.1_amd64.deb
```
### 在nvim中使用
`<leader> m`

### 在Terminal中使用
`rg --help`

## 遗留下来的bug
### 已解决
- 16.04 terminator出现奇怪的字符，vim也表现正常。
    - 使用自带的terminal，而非terminator
    - 使用terminator，但是在~/.bashrc中加入`export VTE_VERSION="100"`
### 未解决
- sudo nvim时报错
    ```
    [coc.nvim] "node" is not executable, checkout https://nodejs.org/en/download/
    ```
    但是nvim时没有。尝试将nodejs的位置从/opt移动普通的文件夹，还是没有用。不知道是否和使用的node是预编译的二进制文件有关，或者自行编译或者通过apt install的方法有改善？
### ccls语法检测
ccls中，检测不到Eigen的语法，却可以编译，因为在编译时会链接到这些库去，而在检索时，却没有包含头文件，因此需要在CMkeLists.txt中加入Eigen头文件的路径。

仍然需要手动创建软连接到project的root目录下，ccls才能解析。
### python 部分库函数无法跳转，自定义的却可以
```
[coc.nvim] Error on load extension from "/home/william/.config/coc/extensions/node_modules/coc-python": item.dispose is not a function
```
有些没有办法跳转，比如opencv的imread，和np的zeros等等。




#### 帮助文档
- Neovim帮助文档
    - 在线：https://neovim.io/doc/
    - 离线：
        ```
        :help nvim-features
        :help quickref
        :help nvim-from-vim
        :help coc-nvim
        ```
- coc.nvim帮助文档：[coc.nvim/coc.cnx at master · neoclide/coc.nvim · GitHub](https://github.com/neoclide/coc.nvim/blob/master/doc/coc.cnx)
- [coc.nvim wiki](https://github.com/neoclide/coc.nvim/wiki)

#### Reference
- [Neovim+Coc.nvim配置 目前个人最舒服终端编辑环境(Python&C++) - zprhhs - 博客园](https://www.cnblogs.com/cniwoq/p/13272746.html)
- [Ubuntu安装NeoVim:一种最简单的方法 - 云+社区 - 腾讯云](https://cloud.tencent.com/developer/article/1559343)
- [安装使用配置 Neovim——配置 - 简书](https://www.jianshu.com/p/c382222e5151)
- [vim插件: nerdcommenter[快速注释]](http://www.wklken.me/posts/2015/06/07/vim-plugin-nerdcommenter.html)
- [Ubuntu 16.04 安装 node](https://www.jianshu.com/p/91cd8c0a26ca)
- [python-更新pip国内源解决pip安装失败的问题](https://www.jianshu.com/p/d31f4d293791)
- [pypi | 镜像站使用帮助 | 北京外国语大学开源软件镜像站 | BFSU Open Source Mirror](https://mirrors.bfsu.edu.cn/help/pypi/)
- [VIM——自动补全插件coc.nvim的安装与使用_bojin4564的博客-CSDN博客](https://blog.csdn.net/bojin4564/article/details/105832148)
- [ubuntu16 ccls neovim coc.nvim ccls langserver安装 - 骏腾 - 博客园](https://www.cnblogs.com/zi-wang/p/12666557.html)
- [Build · MaskRay/ccls Wiki · GitHub](https://github.com/MaskRay/ccls/wiki/Build)
- [ubuntu18.04编译安装clang/llvm_wang.wenchao的博客-CSDN博客](https://blog.csdn.net/wwchao2012/article/details/105888776)
- [coc-ccls not working · Issue #2088 · neoclide/coc.nvim · GitHub](https://github.com/neoclide/coc.nvim/issues/2088)
- [Cannot install llvm-9 or clang-9 on Ubuntu 16.04 - Stack Overflow](https://stackoverflow.com/questions/58242715/cannot-install-llvm-9-or-clang-9-on-ubuntu-16-04)
- [https://clangd.llvm.org/installation.html](https://clangd.llvm.org/installation.html)
- [【每日一库】ripgrep - grep的替代者_Rust语言学习交流-CSDN博客](https://blog.csdn.net/u012067469/article/details/100100824?utm_medium=distribute.pc_relevant.none-task-blog-BlogCommendFromBaidu-1.not_use_machine_learn_pai&depth_1-utm_source=distribute.pc_relevant.none-task-blog-BlogCommendFromBaidu-1.not_use_machine_learn_pai)
- [Unexpected character after update · Issue #5990 · neovim/neovim](https://github.com/neovim/neovim/issues/5990)