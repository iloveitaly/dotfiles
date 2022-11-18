    echo '# Set PATH, MANPATH, etc., for Homebrew.' >> /home/ubuntu/.profile
    echo 'eval "$(/home/ubuntu/.linuxbrew/bin/brew shellenv)"' >> /home/ubuntu/.profile
    eval "$(/home/ubuntu/.linuxbrew/bin/brew shellenv)"

# for homebrew to actually work
sudo apt-get install build-essential procps curl file git gobjc++ glibc-source

echo "Syncing dotfiles..."
rsync --exclude ".git/" \
      --exclude "osx.sh" \
      --exclude={'brew.sh','Brewfile'} \
      --exclude={'duti','distracting_websites.txt'} \
      --exclude "cask.sh" --exclude "mas.sh" \
      --exclude ipython_config.py \
      --exclude={'vscode-extensions.txt','vscode-keybindings.json','vscode-settings.json'} \
      --exclude "backup.sh" \
      --exclude={'bootstrap.sh','codespace.sh','README.md','ssh_config'} \
      -av . ~

brew bundle