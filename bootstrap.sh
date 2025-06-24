
git clone --bare https://github.com/auspbro/dotfiles.git $HOME/.dotfiles

function dot() {
   /usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME $@
}

mkdir -p .dotfiles-backup
dot checkout

if [ $? = 0 ]; then
  echo "Checked out dotfiles.";
  else
    echo "Backing up pre-existing config files to .dotfiles-backup.";
    dot checkout 2>&1 | grep -E "\s+\." | awk {'print $1'} | xargs -I{} mv {} .dotfiles-backup/{}
fi;

dot checkout
dot config status.showUntrackedFiles no
