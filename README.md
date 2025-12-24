# Mike Bianco's Dotfiles

## What's special here?

* zsh with turbo zinit
* [Advanced tmux configuration](https://mikebian.co/tag/tmux/)
* Lots of tidbits for ruby, elixir, and python development
* Mise for managing all language versions
* [Codespace/devcontainer support](https://mikebian.co/my-experience-with-github-codespaces/)
* Lots of interesting git shortcuts + tips
* Custom macOS keybinding & karabiner config
* [Hyper Focus config](https://github.com/iloveitaly/hyper-focus) to [Aggressively blocks distracting websites](http://mikebian.co/how-to-block-distracting-websites-on-your-laptop/)
* Interesting apps and tools I've found over the years nicely organized
* macOS and linux installation support, so you can have the same dotfiles setup on your server.

## Installation

```bash
git clone https://github.com/iloveitaly/dotfiles.git && cd dotfiles && ./bootstrap.sh
```

When setting up a new Mac, you may want to set some sensible OS X defaults:

```bash
./osx.sh
```

To run everything else (brew install, keybindings, zsh setup, etc):

```bash
./bootstrap.sh
```

## Development

For easy development, you can automatically run the `rsync` command in `bootstrap.sh` each time a file changes:

```shell
fd --hidden --max-depth 4 -t f --exclude=.git | entr rsync --exclude-from=install/standard-exclude.txt -av . ~
```

## Clone Interesting Dotfiles Locally

Clone all of these dotfiles into `dotfiles-inspiration` folder so you can easily `rg` for configuration keywords:

```shell
interesting_repos=(
  https://github.com/mathiasbynens/dotfiles
  https://github.com/TwP/dotfiles
  https://github.com/ignu/dotfiles
  https://github.com/chrisduerr/dotfiles
  https://github.com/cypher/dotfiles
  https://github.com/vifreefly/dotfiles
  https://github.com/nikitavoloboev/dotfiles
  https://github.com/jeromedalbert/dotfiles
  https://github.com/gf3/dotfiles
  https://github.com/matijs/homedir
  https://github.com/janmoesen/tilde
  https://github.com/ephur/zshrc
  https://github.com/ptarjan/dotfiles
  https://github.com/nixme/dotfiles
  https://github.com/dbalatero/dotfiles
  https://github.com/yujinyuz/dotfiles
  https://github.com/schickling/dotfiles
  https://github.com/jessfraz/dotfiles
  https://github.com/jschaf/dotfiles
  https://github.com/lunchbag/dotfiles
  https://github.com/peterhajas/dotfiles
  https://github.com/evanpurkhiser/dots-personal
  https://github.com/phillbaker/dotfiles
  https://github.com/brucebentley/dotfiles
  https://github.com/mislav/dotfiles
  https://github.com/romkatv/dotfiles-public
  https://github.com/pnodet/zsh-config
  https://github.com/nateberkopec/dotfiles
  https://github.com/melchoy/dotfiles
  https://github.com/jmduke/dotfiles
)

cd ~/Projects/dotfiles-inspiration

for repo in $interesting_repos; do
  repo_username=$(echo $repo | cut -d '/' -f 4)
  target_directory="$PWD/$repo_username"

  if [ ! -d "$target_directory" ]; then
    git clone $repo "$target_directory"
  else
    (cd "$target_directory" && git pull)
  fi
done
```
