# Ascension Press dotfiles

All you need to set up a development environment to contriubte to Ascension Press projects.

## Installation

```bash
git clone https://github.com/mathiasbynens/dotfiles.git
cd dotfiles
./bootstrap.sh
```

When setting up a new Mac, you may want to set some sensible OS X defaults:

```bash
./osx.sh
```

Also, there is a very opinionated set of dev apps, setting, etc available by running:

```bash
./brew.sh
```

To update, `cd` into your local `dotfiles` repository and then:

```bash
./bootstrap.sh
```

## Manual Customizations

You'll also need to edit your `.gitconfig` with your GitHub information.
