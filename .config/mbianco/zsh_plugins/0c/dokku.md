# Dokku zsh completion

Companion to [`dokku.zsh`](./dokku.zsh). Written so another engineer can understand *why* this exists and what not to “simplify” away.

## Goal

Provide **native zsh** tab completion for the `dokku` CLI (including the official remote client), such that:

1. Completing after `dokku ` offers real **goals** (`apps:create`, `config:set`, …).
2. **Plugin goals** appear automatically when installed on the server (`postgres:…`, `redis:…`, `letsencrypt:…`, etc.).
3. We do **not** depend on bash-completion helpers, polyfills, or a static list of plugins that rots when Dokku adds commands.

Non-goals (for now): completing app names, flag values, or nested argument shapes beyond the flat goal list. That matches the official bash completer’s scope.

## Context: how Dokku is used here

- Local machine typically has the **Homebrew / official remote client** (`dokku` → SSH to a host), not a full Dokku install.
- The client only works when **`DOKKU_HOST` is set** or the current repo has a **git remote named `dokku`**.
- Without that context, `dokku --quiet help --all` does **not** print commands; it prints a setup error that includes an indented line starting with `i.e.` — which naive parsers will treat as a “goal.”

## Approach

### Source of truth

Same pipeline as upstream bash completion:

```text
dokku --quiet help --all | awk '/^    /{ print $1 }'
```

Dokku’s help lists every installed plugin command as a colon-separated token. That is how we get redis/postgres/etc. without hardcoding them.

### Native zsh (not bash-in-zsh)

- Define `_dokku` and register with `compdef` / `_comps[dokku]` (this file lives in **wait`0c`**, after `zicompinit`).
- Offer matches with **`compadd`**, not `_describe`.  
  `_describe` splits on the first `:` (`name:description`), which would break `apps:create`.

### Caching

- Path: `${XDG_CACHE_HOME:-$HOME/.cache}/dokku/completion`  
  (Upstream bash uses `/var/cache/dokku-completion`, which is server-oriented and not writable on a typical Mac client.)
- TTL: **7 days** (refresh on first Tab after expiry). Avoids SSH-ing `help --all` on every keypress.
- Force refresh: `rm ~/.cache/dokku/completion`

### Guarding bad output

Before writing the cache we:

1. Require a successful `help --all` with non-empty stdout.
2. Reject output that looks like the unconfigured-client message (`DOKKU_HOST`, `git remote add dokku`).
3. Keep only tokens matching a strict goal pattern (`apps:create`, `version`, … — **not** `i.e.`).
4. Re-filter when reading cache so an older polluted cache self-heals; wipe and retry once if empty after filter.

## Layout

| Path | Role |
|------|------|
| `.config/mbianco/zsh_plugins/0c/dokku.zsh` | Plugin: define `_dokku`, register completion |
| `.config/mbianco/zsh_plugins/0c/dokku.md` | This document |
| `~/.cache/dokku/completion` | Generated goal list (not in git) |

Loaded via zinit wait`0c` `multisrc` of `0c/*.zsh` (see `~/.zsh_plugins` / repo `.zsh_plugins`). **No `zcompdump` rebuild required** for this plugin — it registers at source time with `compdef`, it is not a `#compdef` fpath file discovered at `compinit`.

## References

| What | Link |
|------|------|
| Official bash completion script | https://github.com/dokku/dokku/blob/master/contrib/bash-completion |
| Packaged install path (server) | `package.mk` copies that file to `/usr/share/bash-completion/completions/dokku` |
| Remote client / `dokku_client.sh` | https://dokku.com/docs/deployment/remote-commands/ |
| Community clients overview | https://dokku.com/docs/community/clients/ |
| Upstream request for zsh completions | https://github.com/dokku/dokku/issues/6023 (open enhancement; no official zsh generator) |
| Community static zsh completers | https://github.com/MenkeTechnologies/zsh-more-completions (`more_src2/_dokku`, `_dokku-cli`) |

## Alternatives considered

### 1. Source the official bash script under `bashcompinit`

**Pros:** Reuses upstream file; “official.”  
**Cons:** Needs bash-completion helpers (`_get_comp_words_by_ref`, `__ltrim_colon_completions`) that **zsh `bashcompinit` does not provide**; still hardcodes `/var/cache/...`; same unconfigured-client garbage-cache problem. We prototyped polyfills and rejected that as too much bash-in-zsh surface for little gain.

### 2. Vendor MenkeTechnologies `_dokku` / `_dokku-cli`

**Pros:** Pure zsh; no SSH at complete time.  
**Cons:**

- `_dokku` models CLI as `dokku apps create` (space-separated), but real Dokku is `dokku apps:create` — wrong shape.
- `_dokku-cli` uses colon tokens but `#compdef dokku-cli` (not `dokku`), and `_describe` + colons is error-prone (first `:` splits name/description).
- Static lists omit most plugins and go stale.

Rejected as a drop-in; useful only as a “static tree” reference.

### 3. Static hand-maintained plugin list (apps + redis + postgres + …)

**Pros:** Fast; no host required.  
**Cons:** Every Dokku/plugin upgrade becomes a doc churn problem; incomplete by definition. Rejected for our goal of “plugins work automatically.”

### 4. This implementation (dynamic native zsh)

**Pros:** Matches real goal tokens; plugins free; no bash polyfills; fits 0c load slot.  
**Cons:** Needs working client context; first refresh can be slow over SSH; help-output awk is a brittle contract shared with upstream bash.

## Operational notes

```zsh
# After syncing the plugin: new shell is enough (no zcompdump clear).
echo ${_comps[dokku]}   # expect: _dokku

# If Tab still looks wrong:
rm -f ~/.cache/dokku/completion

# Need a host/app context for help --all to return real goals, e.g.:
export DOKKU_HOST=your.server
# or: git remote add dokku dokku@your.server:your-app
```

## Open issues

1. **No second-level completion**  
   We only complete goals. We do not complete app names (`dokku apps:destroy <Tab>`), config keys, domains, etc. Upstream bash does not either; still a UX gap.

2. **Remote client latency**  
   Cache refresh runs `dokku help --all` over SSH when using the remote client. 7-day TTL mitigates; first Tab after wipe can stall the completion UI.

3. **Requires configured client**  
   Outside a dokku-enabled repo / without `DOKKU_HOST`, completion correctly returns nothing. There is no offline fallback list.

4. **Help-output format is a contract**  
   We depend on indented lines from `help --all` and the same awk as upstream. If Dokku changes help formatting, both bash and this plugin break.

5. **Goal pattern may be too strict**  
   `_dokku_goal_pattern` only allows `[a-z0-9_-]` and colons. Unusual plugin names (if any use other characters) would be dropped.

6. **Alias / wrapper edge cases**  
   We register for the command name `dokku`. Unusual wrappers (different binary name, functions that are not aliases) may not attach. `+aliases[dokku]` only ensures we *load* when the name is an alias; registration is still `compdef _dokku dokku`.

7. **No automatic invalidation when plugins are installed**  
   After `plugin:install` on the server, local cache can stay stale for up to 7 days unless manually deleted.

8. **No official upstream zsh story**  
   [dokku#6023](https://github.com/dokku/dokku/issues/6023) is unresolved. Long-term we may want to contribute a generated completer or switch if Dokku ships one.

9. **Stale/polluted caches on disk**  
   Users who hit the `i.e.` bug before the guardrails need one manual `rm` of the cache file (or a successful refresh after upgrade). The loader filters junk and retries once, but a fully empty refresh still leaves no completions until the client is configured.

10. **Testing gap**  
    No automated test; verification is manual Tab in a repo with a live dokku remote. Worth a small script that mocks `help --all` and asserts goal extraction if this becomes load-bearing.
