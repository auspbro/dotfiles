# Dotfiles for 0x2f
**Warning:** If you want to give these dotfiles a try, you should first fork this repository, review the code, and remove things you don’t want or need. Don’t blindly use my settings unless you know what that entails. Use at your own risk!

## Requirements

- Git
- Curl

## Installation

### Using Curl launch the bootstrap script
Install config tracking in your $HOME by running:
```bash
sh -c "$(curl -fsSL  https://raw.githubusercontent.com/auspbro/dotfiles/refs/heads/main/bootstrap.sh)"
```
This requires the public key of the machine where the setup is being installed
to be registered as authorized on Bitbucket.

### Setup Git and Tmux configuration
Init git and tmux config by running:
```bash
sh init.sh
```

### Add custom commands without creating a new fork

If `~/.extra` exists, it will be sourced along with the other files. You can use this to add a few custom commands without the need to fork this entire repository, or to add commands you don’t want to commit to a public repository.

My `~/.extra` looks something like this:

```bash
# Git credentials
# Not in the repository, to prevent people from accidentally committing under my name
GIT_AUTHOR_NAME="0x2f"
GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
git config --global user.name "$GIT_AUTHOR_NAME"
GIT_AUTHOR_EMAIL="auspbro@gamil.com"
GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"
git config --global user.email "$GIT_AUTHOR_EMAIL"
```

You could also use `~/.extra` to override settings, functions and aliases from my dotfiles repository. It’s probably better to [fork this repository](https://github.com/mathiasbynens/dotfiles/fork) instead, though.

## Starting from scratch

If you haven't been tracking your configurations in a Git repository before, you can start using this technique easily with these lines:

```bash
git init --bare $HOME/.dotfiles
alias dot='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
dot config --local status.showUntrackedFiles no
echo "alias dot='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'" >> $HOME/.bashrc
```

- The first line creates a folder `~/.dotfiles` which is a [Git bare repository](http://www.saintsjd.com/2011/01/what-is-a-bare-git-repository/) that will track our files.
- Then we create an alias `dot` which we will use instead of the regular `git` when we want to interact with our configuration repository.  
- We set a flag - local to the repository - to hide files we are not explicitly tracking yet. This is so that when you type `dot status` and other commands later, files you are not interested in tracking will not show up as `untracked`.
- Also you can add the alias definition by hand to your `.bashrc` or use the the fourth line provided for convenience.

I packaged the above lines into a [snippet](https://bitbucket.org/snippets/nicolapaolucci/ergX9) up on Bitbucket and linked it from a short-url. So that you can set things up with:

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/auspbro/dotfiles/refs/heads/main/bootstrap.sh)"
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

## Installing your dotfiles onto a new system (or migrate to this setup)  

If you already store your configuration/dotfiles in a [Git repository](https://www.atlassian.com/git), on a new system you can migrate to this setup with the following steps:

- Prior to the installation make sure you have committed the alias to your `.bashrc` or `.zsh`:  

```bash
alias dot='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
```

- And that your source repository ignores the folder where you'll clone it, so that you don't create weird recursion problems:  

```bash
echo ".dotfiles" >> .gitignore
```

- Now clone your dotfiles into a [bare](http://www.saintsjd.com/2011/01/what-is-a-bare-git-repository/) repository in a "_dot_" folder of your `$HOME`:

```bash
git clone --bare <git-repo-url> $HOME/.dotfiles
```

- Define the alias in the current shell scope:

```bash
alias dot='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
```

- Checkout the actual content from the bare repository to your `$HOME`:

```undefined
dot checkout
```

- The step above might fail with a message like:  

```js
error: The following untracked working tree files would be overwritten by checkout:
    .bashrc
    .gitignore
Please move or remove them before you can switch branches.
Aborting
```

This is because your `$HOME` folder might already have some stock configuration files which would be overwritten by Git. The solution is simple: back up the files if you care about them, remove them if you don't care. I provide you with a possible rough shortcut to move all the offending files automatically to a backup folder:  

```bash
mkdir -p .dotfiles-backup && \
dot checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | \
xargs -I{} mv {} .dotfiles-backup/{}
```

- Re-run the check out if you had problems:

```undefined
dot checkout
```

- Set the flag `showUntrackedFiles` to `no` on this specific (local) repository:

```bash
dot config --local status.showUntrackedFiles no
```

- You're done, from now on you can now type `dot` commands to add and update your dotfiles:

```bash
dot status
dot add .vimrc
dot commit -m "Add vimrc"
dot add .bashrc
dot commit -m "Add bashrc"
dot push
```

Again as a shortcut not to have to remember all these steps on any new machine you want to setup, you can create a simple script, [store it as Bitbucket snippet](https://bitbucket.org/snippets/nicolapaolucci/7rE9K) like I did, [create a short url](http://bit.do/) for it and call it like this:  

```bash
curl -Lks http://bit.do/cfg-install | /bin/bash
```

For completeness this is what I ended up with (tested on many freshly minted [Alpine Linux](http://www.alpinelinux.org/) containers to test it out):

```bash

git clone --bare https://github.com/auspbro/dotfiles.git $HOME/.dotfiles

function dot() {
   /usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME $@
}

mkdir -p .dotfiles-backup
dot checkout

if [ $? = 0 ]; then
  echo "Checked out dot.";
  else
    echo "Backing up pre-existing config files to .dotfiles-backup.";
    dot checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} mv {} .dotfiles-backup/{}
fi;

dot checkout
dot config status.showUntrackedFiles no
```

