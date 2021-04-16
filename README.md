# Mike Bianco's Dotfiles

## What's special here?

* zsh with turbo zinit
* Lots of tidbits for ruby and elixir development
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

## Inspiration From

Clone all of these dotfiles into `dotfiles-inspiration` folder so you can easily `rg` for configuration keywords:

* [Mathias Bynens](https://github.com/mathiasbynens/dotfiles)
(https://github.com/gf3/dotfiles)
* [Tim Pease](https://github.com/TwP/dotfiles)
* [Len Smith](https://github.com/ignu/dotfiles)
* [Richard Maynard](https://github.com/ephur/zshrc)
* [Chris Duerr](https://github.com/chrisduerr/dotfiles)
* [Markus Wein](https://github.com/cypher/dotfiles)
* [Victor Afanasev](https://github.com/vifreefly/dotfiles)
* [Nikita Voloboev](https://github.com/nikitavoloboev/dotfiles)