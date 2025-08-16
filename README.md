# Dotfiles for @xuex1x
**Warning:** These are my preferred settings. Use at your own risk!

- Setting up the dotfiles repository as a bare repo with `Git`! No extra tooling, no symlinks, files are tracked on a version control system. 
- The technique consists in storing a Git bare repository in a "side" folder (like `$HOME/.cfg` or `$HOME/.myconfig`) using a specially crafted alias so that commands are run against that repository and not the usual `.git` local folder, which would interfere with any other Git repositories around.
- You can use different branches for different computers, replicate yours configuration easily on new installation.


## Installation

### Using Git and the bootstrap script

Requirements:
- Git
- Curl

Clone and install config tracking in your $HOME by running:
```bash
curl -Lks https://raw.githubusercontent.com/xuex1x/dotfiles/refs/heads/main/.bin/bootstrap-dotfiles.sh | /bin/bash
```

To initilazition more (git, tmux, neovim, lazyvim, zsh/z4h, )
```bash
source ~/.bashrc && bash ~/.bin/init.sh
```

### Onekey deploy bootstrap script

Init config by running:
```bash
GITHUB_USERNAME=xuex1x bash -c \
"$(curl -fsSL https://raw.githubusercontent.com/dotfiles/refs/heads/main/.bin/bootstrap-all.sh)"
```

### Git-free install

To install these dotfiles without Git. To update later on, just run that command again.


```bash
cd; curl -#L https://github.com/xuex1x/dotfiles/tarball/main | tar -xzv --strip-components 1 --exclude={README.md,bootstrap.sh,LICENSE-MIT.txt}
```

You don't need to run Zsh for Humans installer on a new machine. Simply copy/restore these files and Zsh for Humans will bootstrap itself. If you don't have zsh on the machine, you can bootstrap Zsh for Humans from any Bourne-based shell with the following command:
```bash
Z4H_BOOTSTRAPPING=1 . ~/.zshenv
```



### Add custom commands without creating a new fork

If `~/.extra` exists, it will be sourced along with the other files. You can use this to add a few custom commands without the need to fork this entire repository, or to add commands you don’t want to commit to a public repository.

My `~/.extra` looks something like this:

```bash
# Git credentials
# Not in the repository, to prevent people from accidentally committing under my name
GIT_AUTHOR_NAME="xuex1x"
GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
git config --global user.name "$GIT_AUTHOR_NAME"
GIT_AUTHOR_EMAIL="test@xx.com"
GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"
git config --global user.email "$GIT_AUTHOR_EMAIL"
```

You could also use `~/.extra` to override settings, functions and aliases from my dotfiles repository. It’s probably better to [fork this repository](https://github.com/mathiasbynens/dotfiles/fork) instead, though.

## Starting from Scratch

If you haven't been tracking your configurations in a Git repository before, you can start using this technique easily with these lines:

```bash
git init --bare $HOME/.dotfiles
alias dot='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
dot config --local status.showUntrackedFiles no
echo "alias dot='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'" >> $HOME/.bashrc
```

- The first line creates a folder `~/.dotfiles` which is a [Git bare repository](http://www.sjd.com/2011/01/what-is-a-bare-git-repository/) that will track our files.
- Then we create an alias `dot` which we will use instead of the regular `git` when we want to interact with our configuration repository.  
- We set a flag - local to the repository - to hide files we are not explicitly tracking yet. This is so that when you type `dot status` and other commands later, files you are not interested in tracking will not show up as `untracked`.
- Also you can add the alias definition by hand to your `.bashrc` or use the the fourth line provided for convenience.

I packaged the above lines into a [snippet](https://bitbucket.org/snippets/nicolapaolucci/ergX9) up on Bitbucket and linked it from a short-url. So that you can set things up with:

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/xuex1x/dotfiles/refs/heads/main/bootstrap.sh)"
```

After you've executed the setup any file within the `$HOME` folder can be versioned with normal commands, replacing `git` with your newly created `dot` alias, like:

```bash
dot status
dot add .vimrc
dot commit -m "Add vimrc"
dot add .bashrc
dot commit -m "Add bashrc"
dot remote add origin <remote-url>
dot push -u origin main
```

## Deploy from Scratch

Assuming your primary workstation is a Windows PC, you may follow the instructions to deploy your dotfiles on WSL from scratch. 

### Github Setup

This needs to be done once per user.

#### Set up dotfiles-public repo.

- Go to https://github.com/romkatv/dotfiles-public and click *Fork*.
- Replace "romkatv" and "roman.perepelitsa@gmail.com" in `.gitconfig` of the newly created fork with your own data. You can do it thrugh the GitHub web UI.

#### Set up dotfiles-private repo.

- Go to https://github.com/new and create an empty `dotfiles-private` repo. Make it private.

#### Set up ssh keys.

- Generate a pair of ssh keys -- `rsa_id` and `rsa_id.pub` -- and add `rsa_id.pub` to github.com. See https://help.github.com/en/articles/connecting-to-github-with-ssh for details. Use a strong passphrase.
- Backup `rsa_id` in a secure persistent storage system. For example, in your password manager.

### Windows Setup

#### Windows Preparation

This needs to be done once per Windows installation. You don't need to repeat these steps when reinstalling Ubuntu.

- Download these four ttf files:
  - [MesloLGS NF Regular.ttf](
      https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf)
  - [MesloLGS NF Bold.ttf](
      https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf)
  - [MesloLGS NF Italic.ttf](
      https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf)
  - [MesloLGS NF Bold Italic.ttf](
      https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf)
- Double-click on each file and click "Install". This will make `MesloLGS NF` font available to all
   applications on your system.
- Open *PowerShell* as *Administrator* and run:
```powershell
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
```
- Reboot if prompted.
- Install chocolatey from https://chocolatey.org/install.
- Open *PowerShell* as *Administrator* and run:
```powershell
choco.exe install -y microsoft-windows-terminal vcxsrv

## Or use winget in Windows 11 (24h2)
winget install vcxsrv
```
- Run *Start > XLaunch*.
  - Click *Next*.
  - Click *Next*.
  - Uncheck *Primary Selection*. Click *Next*.
  - Click *Save Configuration* and save `config.xlaunch` in your `Startup` folder at `%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup`.
  - Click *Finish*.

Optional: if disk `D:` does not exist, make it an alias for `C:`. If you don't know why you might want this, then you don't need it.

- Open *PowerShell* as *Administrator* and run:
```powershell
if (!(Test-Path -Path "D:\")) {
  New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\DOS Devices" -Name "D:" -PropertyType String -Value \DosDevices\C:\ -Force
}
```
- Reboot.

#### WSL Removal

Follow these steps to remove your Linux distro with all files (applications, settings, home directory, etc.). You can recreate it by following [WSL Installation](#wsl-installation) guide below.

- Find out the name of your default distro by running the following command from *PowerShell*:
```powershell
wsl -l -v
```
- Delete a distro:
```powershell
wsl --terminate $DISTRO
wsl --unregister $DISTRO
```

#### WSL Installation

These steps allow you to recreate the whole WSL environment. Before proceeding, delete the current distro if you have it. See [WSL Removal](#wsl-removal).

- Download `id_rsa` into the Windows `Downloads` folder. It's OK if it's downloaded as `id_rsa.txt`.
- Run these commands from *PowerShell*:
  ```powershell
  wsl --set-default-version 1
  wsl --install -d Ubuntu-22.04
  ```
- When prompted, create a new user.
- Type this (change the value of `GITHUB_USERNAME` if it's not the same as your WSL username):
```bash
GITHUB_USERNAME=$USER bash -c \
  "$(curl -fsSL 'https://raw.githubusercontent.com/xuex1x/dotfiles-public/refs/heads/main/bin/bootstrap-machine.sh')"
```
- Say `Yes` when prompted to terminate WSL.
- Run *Start > Windows Terminal*.
  - Press <kbd>Ctrl+Shift+,</kbd>.
  - Replace the content of `settings.json` with [this](https://raw.githubusercontent.com/romkatv/dotfiles-public/master/dotfiles/microsoft-terminal-settings.json). Change "romkatv" to your WSL username.

#### Optional: Windows Defender Exclusion

- Run *Start > Windows Security*.
  - Click *Virus & threat protection*.
  - Click *Manage settings* under *Virus & threat protection settings*.
  - Click *Add or remove exclusions* under *Exclusions*.
  - Click *Add an exclusion > Folder*.
  - Select `%USERPROFILE%\AppData\Local\Packages\CanonicalGroupLimited.Ubuntu22.04LTS_79rhkp1fndgsc`.

### Maintenance

Run this command occasionally.

```zsh
sync-dotfiles && bash ~/bin/setup-machine.sh && z4h update #maintenance
```

Pro tip: Copy-paste this whole command including the comment. Next time when you decide to run maintenance tasks, press `Ctrl+R` and type `#maintenance`. This is how you can "tag" commands and easily find them later. You can apply more than one "tag". Technically, everything after `#` is a comment.
