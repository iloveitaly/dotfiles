# Omarchy (this machine) — agent notes

Arch / Hyprland customizations live here. Apply with `just sync` / `just install` from this directory. Do not edit `~/.local/share/omarchy/` (upstream; reading is fine).

Never commit Tailscale or network host IPs. Discover them at runtime (`tailscale ip`, `ip addr`); document interfaces (`enp5s0`, `tailscale0`) and MagicDNS, not addresses. See the root `AGENTS.md`.

User `dev` is SSH-only (`just configure-dev`): zsh, locked password, `docker` group, keys from `omarchy/.ssh/authorized_keys`. No linger, no VNC, no `wheel`, no home overlay in this tree.

## Justfile over tiny scripts

Prefer **Just recipes** (new or expanded) over one-off shell scripts under `scripts/`.

- Install steps, package lists, webapp setup, and multi-command flows belong in `Justfile` (`install-pkgs`, `configure`, `sync`, or a focused recipe that `install` / `sync` can call).
- Do **not** add a small `scripts/*.sh` that only wraps a few CLI lines — put those lines in the recipe.
- Keep a script only when it is a real helper with non-trivial logic reused outside Just (e.g. `ensure-keyd-application-mapper.sh`).

### Inline short helpers

Do **not** add a separate Just recipe (or script) for a helper that is fewer than **5 lines of zsh**. Inline those lines into the caller (`sync`, `configure`, `install-pkgs`, …).

- Count only body lines that run commands (not blank lines or comments).
- Duplicating a few lines in two recipes is fine; a one-off `configure-foo` recipe is not.
- Extract a named recipe only when the body is ≥ 5 command lines, or it is called from many places and would otherwise drift.

Recipe style: `@just _banner_echo "…"` as the first line of each recipe so long runs are easy to follow; one colored success line at the end (`{{GREEN}}ok{{NORMAL}}  …`). Each recipe line is a new shell — keep dependent commands on one line.
