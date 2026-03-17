# ❯ gtime ast-grep completions > /dev/null
# 0.00user 0.00system 0:00.00elapsed 66%CPU (0avgtext+0avgdata 3968maxresident)k
# 0inputs+0outputs (0major+424minor)pagefaults 0swaps

if (( $+commands[ast-grep] )); then
  # railway completion generation is so fast that we don't need to cache it on the filesystem
  source <(ast-grep completions)
fi