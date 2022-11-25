# Mike Bianco's Dotfiles

## What's special here?

* zsh with turbo zinit
* Lots of tidbits for ruby, elixir, and python development
* Asdf for managing all language versions
* Codespace/devcontainer support
* Lots of interesting git shortcuts + tips
* [Aggressively blocks distracting websites](http://mikebian.co/how-to-block-distracting-websites-on-your-laptop/)
* Interesting apps and tools I've found over the years nicely organized

## Installation

```bash
git clone https://github.com/mathiasbynens/dotfiles.git && cd dotfiles && ./bootstrap.sh
```

When setting up a new Mac, you may want to set some sensible OS X defaults:

```bash
./osx.sh
```

Also, there is a very opinionated set of CLI tools:

```bash
./brew.sh
```

And MacOS applications:

```bash
./cask.sh
./mas.sh
```

To update, `cd` into your local `dotfiles` repository and then:

```bash
./bootstrap.sh
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
