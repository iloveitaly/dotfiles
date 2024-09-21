#!/bin/bash
# Description: installation entrypoint for servers (linux)

cd "$(dirname "$0")/.." || exit 1

rsync --exclude-from="install/standard-exclude.txt" \
  --exclude-from="install/server-exclude.txt" \
  -av . ~

sudo apt install snapd
sudo snap install yq diff-so-fancy
sudo snap install --classic nano

curl https://raw.githubusercontent.com/scopatz/nanorc/master/install.sh | sh
curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash

# this list was generated by chatgpt's ingestion of Brewfile; keep it up to date manually
sudo apt install -y \
  git vim lynx rename wget ngrep iftop lftp httpie ncdu curl gawk jq sqlite3 zsh \
  zsh ripgrep entr prettyping less fd-find tldr zoxide bc delta bat exa tree htop dnsutils moreutils qpdf \
  rsync watch iotop powertop \
  nmap

# maybe limit this list when using arm?
#   cat <<EOF >~/.tool-versions
# direnv 2.34.0
# rust 1.77.0
# EOF

cat <<EOF >~/.extra
alias cat=batcat
alias fd=fdfind

alias dokku="docker exec dokku dokku"
alias dokku-shell="docker exec -it dokku bash -l"

# exa not available yet on ubuntu :/
alias eza=exa

# fzf is really outdated, must install via git $(~/.fzf.zsh)
[ ! -d ~/.fzf ] && git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install --no-key-bindings --no-completion --no-update-rc
[ ! -d ~/.asdf ] && git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.0

# only available after install is complete
source ~/.fzf.zsh
EOF

# delete some zsh_plugins that are macos specific
sed -i '/zicompdef/d' ~/.zsh_plugins
sed -i '/iTerm2-shell/d' ~/.zsh_plugins
sed -i '/zsh-auto-notify/d' ~/.zsh_plugins
sed -i '/fast-syntax-highlighting/d' ~/.zsh_plugins
sed -i '/zsh-autosuggestions/d' ~/.zsh_plugins

sudo chsh -s "$(which zsh)" "$(whoami)"

git config --global --unset commit.gpgsign

# if `python` doesn't exist, let's alias python3 to it if it exists
# if ! command -v python &>/dev/null && command -v python3 &>/dev/null; then
#   sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 1
# fi

# cleaner output since this will be running inside ansible, or something similar
export ZINIT_COLORIZE=false

# run zinit to install all plugins
zsh -lc "source ~/.zshrc && zinit update --parallel"
