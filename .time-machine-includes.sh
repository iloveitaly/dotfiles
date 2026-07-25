#!/usr/bin/env zsh
# Description: exclude node_modules and other noisy directories from time machine
# Usage: .time-machine-includes.sh [--dry-run]

if [[ $EUID -eq 0 ]]; then
  echo "This script should not be run as root" 1>&2
  exit 1
fi

# TODO make sure home is not the root user

dry_run=0
for arg in "$@"; do
  case $arg in
    --dry-run|-n)
      dry_run=1
      ;;
    -h|--help)
      echo "Usage: ${0:t} [--dry-run]"
      echo "  --dry-run, -n  Print paths that would be excluded without calling tmutil"
      exit 0
      ;;
    *)
      echo "Unknown option: $arg" 1>&2
      echo "Usage: ${0:t} [--dry-run]" 1>&2
      exit 1
      ;;
  esac
done

if (( dry_run )); then
  echo "Dry run: listing paths that would be excluded (no tmutil changes)\n"
fi

# clear out any existing exclusions:
# sudo defaults write /Library/Preferences/com.apple.TimeMachine.plist SkipPaths -array

static_exclusions=(
  # XDG / general tool caches (pip, huggingface, etc.)
  "$HOME/.cache"
  "$HOME/.orbstack"
  "$HOME/.docker"
  "$HOME/.mise"
  "$HOME/.cursor"
  "$HOME/.claude"
  "$HOME/.codex"
  "$HOME/.gemini"
  "$HOME/.grok"
  "$HOME/.dropbox"
  # OrbStack NFS mount: tmutil rejects it (EINVAL). Real data is under
  # .orbstack + Group Containers (globbed below).
  # "$HOME/OrbStack"
  "$HOME/.local/share/mise"
  # Go module / build cache (GOPATH)
  "$HOME/.local/share/go"
  # uv Python package / tool cache
  "$HOME/.local/share/uv"
  "$HOME/.local/share/yarn"
  # zinit zsh plugin manager clones
  "$HOME/.local/share/zinit"
  # Cursor agent runtime + bundled node_modules
  "$HOME/.local/share/cursor-agent"
  "$HOME/.Trash"
  "$HOME/.npm"
  "$HOME/.pnpm"
  "$HOME/.pnpm-state"
  "$HOME/.vscode/extensions"
  "$HOME/.rustup"
  "$HOME/.cargo"
  "$HOME/.yarn"

  # Siri/suggestion context streams (regenerated; not user documents)
  "$HOME/Library/Biome"
  # Elixir Mix build cache
  "$HOME/Library/Caches/mix"
  # Homebrew bottle / download cache
  "$HOME/Library/Caches/Homebrew"
  # Playwright browser binaries
  "$HOME/Library/Caches/ms-playwright"
  # pip wheel / http cache
  "$HOME/Library/Caches/pip"
  # CocoaPods specs / download cache
  "$HOME/Library/Caches/CocoaPods"
  # Xcode DerivedData, simulators, device support
  "$HOME/Library/Developer"
  # Shared Application Support cache bucket
  "$HOME/Library/Application Support/Caches"
  # Apple Container (containers CLI / VM images and runtime data)
  "$HOME/Library/Application Support/com.apple.container"
  "$HOME/Library/Application Support/superwhisper"
  "$HOME/Library/Application Support/Claude"
  "$HOME/Library/Application Support/Cursor"
  "$HOME/Library/Application Support/Dash"
  "$HOME/Library/Application Support/WebCatalog"
  "$HOME/Library/Application Support/Code"
  "$HOME/Library/Application Support/Superhuman"

  # Siri/suggestion context (system-level, if present)
  /Library/Biome
  # Command Line Tools / platform SDKs
  /Library/Developer
)

# Roots already excluded from Time Machine. Used to skip nested discoveries.
excluded_roots=()

# Returns 0 if $1 is equal to, or nested under, any path in excluded_roots.
# Note: never use a local named `path` — in zsh it is tied to PATH and breaks
# command lookup (e.g. "command not found: sudo").
is_under_excluded() {
  local candidate="${1%/}"
  local root
  for root in $excluded_roots; do
    root="${root%/}"
    if [[ "$candidate" == "$root" || "$candidate" == "$root"/* ]]; then
      return 0
    fi
  done
  return 1
}

# Add a fixed-path Time Machine exclusion unless a parent is already excluded.
exclude_path() {
  local candidate="${1%/}"

  if is_under_excluded "$candidate"; then
    echo "Skipping '$candidate' (parent already excluded)"
    return 0
  fi

  if [[ ! -d $candidate ]]; then
    echo "Invalid path: $candidate"
    return 1
  fi

  if (( dry_run )); then
    echo "Would exclude '$candidate'"
  else
    echo "Excluding '$candidate' from time machine..."
    if ! sudo tmutil addexclusion -p "$candidate"; then
      echo "Failed to exclude '$candidate' (tmutil error; not tracking as excluded)" 1>&2
      return 1
    fi
  fi
  excluded_roots+=("$candidate")
}

# Exclude discovered paths from stdin. Lexicographic order puts parents before
# nested children (a path is a strict prefix of any path under it).
# Call via process substitution (`< <(...)`), not a pipe, so excluded_roots
# updates stay in this shell (zsh runs pipeline stages in subshells).
exclude_discovered() {
  local -a found
  local candidate line

  found=()
  while IFS= read -r line; do
    [[ -n $line ]] || continue
    found+=("${line%/}")
  done

  (( ${#found} == 0 )) && return 0

  for candidate in ${(o)found}; do
    exclude_path "$candidate"
  done
}

# https://apple.stackexchange.com/questions/384455/how-to-ignore-all-the-node-modules-folders-from-time-machine

# Replace $HOME with an empty string, since fdfind does *not* treat --exclude as an absolute path
# https://github.com/sharkdp/fd/issues/1577
expanded_exclusions=("${(@)static_exclusions/#$HOME\//}")

# Prefix each exclusion pattern with --exclude= for use in fdfind
prefixed_exclusions=("${(@)expanded_exclusions/#/--exclude=}")

# exclude the above folders
for exclusion in $static_exclusions; do
  exclude_path "$exclusion"
done

# Group Containers whose team-id prefix varies (e.g. HUAQ24HBR6.dev.orbstack).
group_container_globs=(
  "*.dev.orbstack"                 # OrbStack Linux VM disk / container data
  "*.groups.com.apple.podcasts"    # Podcasts downloads / library
  "group.com.apple.SiriTTS"        # Siri TTS voice assets
)
echo "\nExcluding selected group containers from time machine..."
for glob in $group_container_globs; do
  for group_container in "$HOME/Library/Group Containers"/${~glob}(N/); do
    exclude_path "$group_container"
    # Keep fd from walking this tree during later discovery
    prefixed_exclusions+=("--exclude=${group_container:t}")
  done
done

# Exclude package roots / build caches before node_modules so anything under a
# discovered .venv or target (etc.) is already in excluded_roots and skipped.
#
# Path-segment anchors (e.g. /target$) avoid false positives like obj.target or
# symlink_target that matched a bare target$ suffix.
echo "\nExcluding package management and build cache directories from time machine..."
exclude_discovered < <(
  fd -uuu --color never --type d --absolute-path --full-path \
    '(/\.venv|/\.pnpm|/vendor/bundle|/target|/\.elixir_ls|/_build)$' \
    $prefixed_exclusions \
    $HOME
)

echo "\nExcluding node_modules from time machine..."
# Skip .venv/target during search. Drop nested node_modules under other
# node_modules up front; exclude_discovered skips anything under an already-
# excluded parent (including .venv / target from above).
exclude_discovered < <(
  fd -uuu --type d --absolute-path --full-path '/node_modules$' \
    --exclude=.venv \
    --exclude=target \
    $prefixed_exclusions \
    $HOME | rg --max-columns=0 --pcre2 '^(?!.*\/node_modules\/.*\/node_modules\/).*\/node_modules\/?$' --no-filename --no-column --no-line-number --color never
)

if (( dry_run )); then
  echo "\nDry run complete (${#excluded_roots} path(s) would be excluded)"
else
  echo "Time machine excludes are done"
fi
