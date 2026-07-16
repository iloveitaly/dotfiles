# Avoid loading the builtin git and docker completions (prefer richer ones
# from other plugins). Same idea for swift.
# https://mikebian.co/git-completions-tooling-on-the-command-line/
#
# Runs in 0b/ so these are gone before the wait'0b' compinit pivot.

if command -v brew &>/dev/null; then
  rm $(brew --prefix)/share/zsh/site-functions/_git 2>/dev/null
  rm $(brew --prefix)/share/zsh/site-functions/_docker 2>/dev/null

  rm $(brew --prefix)/share/zsh/functions/_swift 2>/dev/null
  # TODO does the above also remove? /opt/homebrew/Cellar/zsh/5.9/share/zsh/functions
fi
