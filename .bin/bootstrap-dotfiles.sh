#!/bin/bash
# set -xueEo pipefail
#
# Clone the dotfiles repository as a bare repo.
# A bare repository stores the git history but doesn't have a working tree,
# which is perfect for managing dotfiles in the home directory.
git clone --bare https://github.com/xuex1x/dotfiles.git $HOME/.dotfiles

# Define an alias function for git operations on the dotfiles repo.
# This avoids polluting the global git command and makes commands cleaner.
function dot() {
  /usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME "$@"
}

# Create a backup directory for any existing dotfiles that would conflict.
mkdir -p .dotfiles-backup
echo "Looking for pre-existing dotfiles to back up..."
has_backed_up=false
# Assumes the default branch is 'main'. Change to 'master' if needed.
dot ls-tree -r main --name-only | while read -r file; do
  if [ -e "$HOME/$file" ]; then
    if ! $has_backed_up; then
      echo "Found conflicting files. Moving them to .dotfiles-backup/"
      has_backed_up=true
    fi
    echo "  -> Backing up $file"
    # Ensure the parent directory exists in the backup folder to support nested files
    mkdir -p ".dotfiles-backup/$(dirname "$file")"
    mv "$HOME/$file" ".dotfiles-backup/$file"
  fi
done

# Now that all conflicting files have been moved, we can safely perform the checkout.
echo "Checking out dotfiles from the bare repository..."
dot checkout

# Final check to ensure the checkout was successful.
if [ $? = 0 ]; then
  echo "Checked out dotfiles successfully.";
else
  # If checkout still fails here, there's a more serious problem.
  echo "Failed to checkout dotfiles. Please check for issues."
  exit 1
fi

# Configure git to not show untracked files in `git status`.
dot config status.showUntrackedFiles no
echo "Setup complete! Dotfiles now managed by dot."
