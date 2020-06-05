# TODO https://github.com/jeromedalbert/dotfiles/blob/3e91c7bf8b44b4d989eaab49cc4ca412f7ecbb73/.zshrc

eval $(brew shellenv)

eval "$(fasd --init auto)"

# load in rbenv
if [[ ! -z `which rbenv` ]]; then
	. "$(rbenv init -)"
fi

# TODO feels like there's a better way to load up asdf into the shell
if [[ ! -z `which asdf` ]]; then
  . `brew --prefix asdf`/asdf.sh
fi

# Load ~/.exports, ~/.aliases, ~/.functions and ~/.extra
# ~/.extra can be used for settings you don’t want to commit
for file in exports aliases functions extra; do
  file="$HOME/.$file"
  [ -e "$file" ] && source "$file"
done