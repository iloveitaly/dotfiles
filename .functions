function touchp() {
  mkdir -p $(dirname $1) && touch "$1"
}

# All the dig info
function digga() {
  dig +nocmd "$1" any +multiline +noall +answer
}

# git functions
# most pulled from https://github.com/ignu/dotfiles

function gc() {
  git commit -v -a -m "$*"
}

function gd() {
  git difftool $1 -t Kaleidoscope -y
}

# this caused strange terminal input glitches when written as an alias
function gcb() {
  git checkout $(git branch --sort=-committerdate --format="%(refname:short)" | fzf)
}

function gbt() {
  git checkout -b $1 --track origin/$1
}

# make a gif out of the last recorded video
function makegif() {
  # make sure to include trailing slash
  # TODO we should be able to determine the default SS directly automatically
  screenshot_dir=~/Desktop/

  latest_movie=$screenshot_dir`/bin/ls -tp "$screenshot_dir" | grep '.*\.mov' | head -n 1`
  gif_destination=`echo "$latest_movie" | sed 's/.mov/.gif/'`

  # `brew install ffmpeg gifsicle`
  ffmpeg -i "$latest_movie" -r 10 -f gif - | gifsicle > "$gif_destination"

  echo $gif_destination
  open -a "Google Chrome" "$gif_destination"
}
