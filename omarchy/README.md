# Omarchy (this machine)

Arch Linux desktop setup for Omarchy / Hyprland. Configs in this folder are **excluded from dotfiles rsync** (`install/standard-exclude.txt`); apply with `just sync` / `just install`.

## Hardware

Documented in more detail on the blog:

**[Building a High-Performance Local Server](https://mikebian.co/building-a-high-performance-local-server/)**

| Component | Spec |
|-----------|------|
| **Motherboard** | MSI MAG B550 Tomahawk (AM4 / B550), 4× DIMM (up to 128 GB DDR4), 2× M.2 |
| **CPU** | AMD Ryzen 7 5800X — 8 cores / 16 threads, 3.8 GHz base, 105 W |
| **Memory** | Originally 32 GB DDR4; currently ~**92 GB** usable RAM |
| **Storage** | 2 TB NVMe SSD |
| **GPU** | MSI GeForce GT 710 |
| **PSU** | MSI MAG A750GL 750 W |
| **Case** | be quiet! Pure Base 500DX / 500-series |

## CalDigit / Thunderbolt docks

**CalDigit TS3+ does not work with this MSI MAG B550 Tomahawk.**

Findings on this host:

- No Thunderbolt / USB4 controller in `lspci` (USB XHCI only)
- No `/sys/class/typec`, empty `/sys/bus/thunderbolt/devices/`
- `bolt` / `boltd` is installed and runs, but `boltctl list` stays empty when the dock is plugged in
- No CalDigit device enumerates over USB either when the TS3+ is connected

The TS3+ expects **Thunderbolt 3**. This B550 board has no TB host, so authorization via `boltctl` never applies — there is nothing to authorize. CalDigit’s docking utility is **macOS-only** and is not relevant here.

If a future machine has real TB/USB4:

```bash
boltctl                  # list devices
boltctl enroll <uuid>    # authorize + remember for future boots
```

Some docks also need firmware updates (`fwupd`) and PCIe resource kernel parameters; that is host-specific and not applicable until TB hardware is present.

## Layout

```text
omarchy/
├── Justfile                         # install / sync / configure
├── etc/keyd/default.conf            # → /etc/keyd/default.conf
├── .cursor/argv.json                # → ~/.cursor/argv.json (password-store for Hyprland)
├── .linux                           # → ~/.linux (zsh: EDITOR=nvim, pbcopy/open shims; not .extra)
├── .config/keyd/app.conf            # → ~/.config/keyd/app.conf
├── .config/ghostty/config.local     # → ~/.config/ghostty/config.local (tmux path, etc.)
├── .tmux.conf.local                 # → ~/.tmux.conf.local (zsh + PATH; overrides Homebrew)
└── .config/hypr/                    # → ~/.config/hypr/ (sourced from hyprland.conf)
    ├── bindings-hyper.conf
    ├── bindings-1password.conf
    ├── bindings-clipboard.conf
    ├── bindings-close.conf           # Cmd+Q closes window (macOS-style; was Super+W)
    ├── bindings-tabs.conf            # Cmd+T new tab in Chromium/Ghostty
    ├── bindings-unbind.conf          # pure stock unbinds (background, Spotify, webapps, Ghostty chords)
    ├── bindings-window-resizing.conf # Super+Ctrl+Alt+arrows → column width (scrolling layout)
    ├── bindings-vicinae.conf         # Ctrl+Space → Vicinae (Raycast-style; Super+Space = Walker)
    ├── bindings-switcher.conf        # Hyper+W windows, Cmd+Tab running apps
    └── scripts/
        ├── cmd-new-tab.sh       # Cmd+T new tab helper
        ├── switch-window.sh     # fuzzy open-window switcher
        └── switch-app.sh        # fuzzy running-app switcher
```

### Neovim

Neovim is **not** under `omarchy/`. The shared LazyVim tree lives at **`.config/nvim`** in the main dotfiles repo (Omarchy LazyVim seed + personal plugins such as `tpope/vim-rsi`). Main `just sync` / bootstrap rsync deploys it. The binary is **`aqua:neovim/neovim`** via mise (`.config/mise/config.toml`); with mise activated it shadows the Arch `/usr/bin/nvim`.

`lua/plugins/theme.lua` is a host-only symlink to the active Omarchy theme’s `neovim.lua`. It is omitted from the repo; `just sync` here recreates it. Prefer not running `omarchy-nvim-refresh` after adopting this tree — that reseeds from the package and drops custom plugins until the next dotfiles sync.

Shared Ghostty config (`.config/ghostty/config`) ends with `config-file = ?config.local` so this host can override macOS defaults (e.g. `command = /usr/bin/tmux` instead of Homebrew).

Shared `.tmux.conf` pins `default-shell` and `PATH` to Homebrew; it ends with `source-file -q ~/.tmux.conf.local`. Omarchy’s `.tmux.conf.local` sets `default-shell` to `/usr/bin/zsh` and a Linux `PATH` (no Homebrew).

### Cursor keyring (Hyprland)

`just sync` copies `omarchy/.cursor/argv.json` → `~/.cursor/argv.json` (`password-store: gnome-libsecret`). **Fully quit and reopen Cursor** after syncing — reload window is not enough.

## Microsoft Ergonomic Keyboard (this host)

Device (USB): **Microsoft Ergonomic Keyboard** `045e:082c` (keyd id `045e:082c:27d47cb9`).

Printed layout left of the spacebar is the usual PC cluster (from the spacebar outward to the left):

```text
  …  Ctrl  |  Win  |  Alt  |  space  |  …
```

`etc/keyd/default.conf` rewrites that so Hyprland/apps see a Mac-like modifier row. **`sudo keyd monitor`** on the **keyd virtual keyboard** shows **post-remap** codes (what the system receives), not the raw scancodes.

### Verified with `keyd monitor` (tap each key alone)

Pressed in order from the spacebar leftward, then Ctrl:

| Order | Physical key (from space left) | After keyd (virtual keyboard) | Role on this machine |
|------:|--------------------------------|-------------------------------|----------------------|
| (a) | **Alt** (immediately left of space) | `leftmeta` | **Cmd / Super** for Hyprland (Mac ⌘) |
| (b) | **Win** (next left) | `leftalt` | **Option / Alt** |
| (c) | (also emitted `leftalt` in the capture — same Alt role; confirm if a second Win/Compose key or a double tap) | `leftalt` | **Option / Alt** |
| (d) | **Ctrl** (outer) | `leftcontrol` | **Control** (unchanged) |

Capture excerpt (virtual keyboard, post-remap):

```text
leftmeta down/up      ← (a) physical Alt  → Cmd/Super
leftalt down/up       ← (b) physical Win  → Alt/Option
leftalt down/up       ← (c)
leftcontrol down/up   ← (d) physical Ctrl → Ctrl
```

keyd rules that produce this (`etc/keyd/default.conf`):

```ini
leftalt  = layer(cmd)    # physical Alt → Cmd layer (Meta / Super)
leftmeta = layer(alt)    # physical Win → Alt
compose  = layer(alt)    # compose/menu → Alt if present
```

### Practical consequences

- For **Super+…** Hyprland binds, hold the key **next to space** (physical **Alt** → `leftmeta` / Cmd), **not** the Windows logo key.
- The Windows logo key is **Option/Alt** after remap.
- **1Password Quick Access (macOS-style):** **Cmd+Shift+Space** = Super+Shift+Space → `1password --quick-access` (`bindings-1password.conf`). Stock Omarchy used that chord for **toggle Waybar**; that bind is unbound here.
- **Caps Lock** → Hyper (`Ctrl+Alt+Shift+Super`) for window focus / workspace numbers (see `bindings-hyper.conf`, `bindings-workspaces.conf`).
- **Hyper+W** → fuzzy list of **open windows** (`bindings-switcher.conf` / `switch-window.sh`).
- **Hyper+D** → toggle Voxtype dictation (`bindings-hyper.conf`; stock also has Super+Ctrl+X and F9 push-to-talk).
- **Cmd+Tab** (Super+Tab) → fuzzy list of **running applications** (macOS-style; one entry per app; `switch-app.sh`). Stock Super+Tab was next workspace (unbound). **Super+Space** still launches any installed app via Walker.
- **Hyper+F** → fullscreen (stock was Super+F). **Cmd+F** is **Ctrl+F** (search) via keyd — so Super+F never reached Hyprland and looked “broken,” including on scrolling.


Re-check anytime:

```bash
sudo keyd monitor
# Tap modifiers alone; watch "keyd virtual keyboard" lines
```

## Key input layering

Stack: **hardware → keyd → Hyprland → app**. Do not collapse everything into Hyprland; the hybrid split is intentional (macOS-ish editing + Omarchy Super binds + arrows that do not mean two things).

```text
Keyboard
  → keyd          rewrite keycodes / layers (device-level)
  → Hyprland      WM actions, or sendshortcut into focused window
  → Application   what finally receives keys
```

| Put it in… | When | Examples here |
|------------|------|----------------|
| **keyd** (`etc/keyd/default.conf`) | Physical key identity; Mac text chords that should arrive as *different* keycodes so Hyprland never sees Super for that press | Alt→Cmd layer; Win/Compose→Alt; Caps→Hyper; Cmd+A/Z/F→Ctrl+letter; Cmd+arrows→Home/End; Alt+Backspace→Ctrl+Backspace; Alt+Delete→Ctrl+Delete |
| **Hyprland bind** | Window-manager actions | Cmd+Q close (`bindings-close.conf`); Hyper+arrows focus + Hyper+D Voxtype + Hyper+F fullscreen (`bindings-hyper.conf`); Hyper+W / Cmd+Tab switchers (`bindings-switcher.conf`); 1Password (`bindings-1password.conf`) |
| **Hyprland `sendshortcut` / wtype** | Super must stay Super for the bind, but the app needs a Linux chord | Cmd+C/V/X clipboard (stock Omarchy); Cmd+Shift+C history (`bindings-clipboard.conf`); browser Cmd+T/W/1–9 via `scripts/cmd-*-tab.sh` (`bindings-tabs.conf`, `binddn`) |
| **App config** (Ghostty `config.local`, keyd `app.conf`) | App-native Super chords, or true per-app remaps | Ghostty `super+t/w/1..9` + splits; Chromium optional keyd mapper path |

### Chromium / browser tab chords (Cmd)

**Reliable path (no keyd mapper):** Hyprland `binddn` (non-consuming) + scripts (`bindings-tabs.conf`, sourced **after** `bindings-workspaces.conf`). Super also reaches the focused app:

| Cmd | Browser | Ghostty |
|-----|---------|---------|
| Cmd+T | `cmd-new-tab.sh` → `wtype` Ctrl+T | native `super+t=new_tab` |
| Cmd+W | `cmd-close-tab.sh` → `wtype` Ctrl+W | native `super+w=close_tab:this` |
| Cmd+1…9 | `cmd-select-tab.sh N` → `wtype` Ctrl+N | native `super+N=goto_tab` |

**Optional keyd path** (mapper + `keyd` group) in `app.conf` when the mapper runs:

| Cmd | Linux chord |
|-----|-------------|
| Cmd+[ / ] | history back / forward (Alt+Left / Alt+Right) |
| Cmd+Shift+[ / ] | prev / next tab |
| Cmd+Option+Left/Right | prev / next tab |

Window close remains **Cmd+Q**. Workspace switch is **Hyper+1…0**.


### Why not move more keyd → Hyprland?

- **Cmd+arrows → Home/End must stay in keyd.** Stock Omarchy uses Super+arrows for window focus. keyd rewrites those chords to Home/End before Hyprland; window focus lives on **Hyper+arrows** instead. Putting line-nav in Hyprland would fight tiling binds.
- **Letter text chords (A/Z/F) stay in keyd.** Moving them to `sendshortcut` would split “Mac text editing” across two files without buying Super+Shift variants. Prefer Hyprland only when Super+Shift+same-key needs a WM action (the C/V/X lesson: keyd rewrites broke clipboard history). **S is not remapped** — files are edited on the CLI; Cmd+S stays Super+S so it does not collide with Ctrl+S.
- **Layout / Hyper stay in keyd.** Hyprland consumes Hyper chords; it should not redefine which physical key is Super/Alt/Hyper.

### Cmd layer mental model

`[cmd:M]` defaults to **Meta**. Only listed keys rewrite (e.g. `a = C-a`). Everything else still emits Super so Omarchy binds keep working (Return, Q, K, …).

Intentionally **not** remapped in keyd: **C/V/X** (clipboard, Hyprland), **Q** (close window), **T**, **W**, **S** (no GUI save; keep Cmd+S ≠ Ctrl+S for CLI editors), etc.

```bash
cd omarchy
just install    # packages + sync + git/1Password SSH-sign configure
just sync       # keyd + Hyprland + ghostty local, reload
just configure  # Arch git/1Password SSH-sign paths, editor, gpgsign
```
