# `set-environment -g PATH` is intentionally set to a very minimalist path
# this plugin ensures that the PATH for the tmux server is kept in sync with the latest
# dotfiles config. This allows tools like fzf to be used by tmux plugins.

if [[ -n "$TMUX" && "$PWD" == "$HOME" ]]; then
    tmux set-environment -g PATH "$PATH" 2>/dev/null || true
fi