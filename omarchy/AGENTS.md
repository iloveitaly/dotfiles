# Omarchy (this machine) — agent notes

Arch / Hyprland customizations live here. Apply with `just sync` / `just install` from this directory. Do not edit `~/.local/share/omarchy/` (upstream; reading is fine).

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

Recipe style: quiet body, one colored success line at the end (`{{GREEN}}ok{{NORMAL}}  …`). No step-by-step chatter. Each recipe line is a new shell — keep dependent commands on one line.
