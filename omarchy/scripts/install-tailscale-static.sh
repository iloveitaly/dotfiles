#!/usr/bin/env bash
# Install Tailscale from pkgs.tailscale.com static binaries (not the Arch package).
# The Arch package cannot apply `tailscale set --auto-update`.
# https://tailscale.com/docs/install/static · https://pkgs.tailscale.com/stable/
set -euo pipefail

is_static() {
  local bin="${1:-/usr/sbin/tailscale}"
  [[ -x $bin ]] && file -b "$bin" | grep -q 'statically linked'
}

# IgnorePkg is only valid under [options]. Appending after [omarchy] is ignored.
ensure_ignorepkg() {
  local conf=/etc/pacman.conf
  if awk '
    BEGIN { sect = "" }
    /^\[/ { sect = $0 }
    sect == "[options]" && /^[[:space:]]*IgnorePkg[[:space:]]*=.*\btailscale\b/ { found = 1 }
    END { exit found ? 0 : 1 }
  ' "$conf"; then
    return 0
  fi
  sudo sed -i \
    -e '/^# static Tailscale (just install-tailscale); do not reinstall the Arch package$/d' \
    -e '/^[[:space:]]*IgnorePkg[[:space:]]*=[[:space:]]*tailscale[[:space:]]*$/d' \
    "$conf"
  sudo sed -i '/^\[options\]/a # static Tailscale (just install-tailscale); do not reinstall the Arch package\nIgnorePkg = tailscale' "$conf"
}

wait_backend() {
  # first login stays interactive: sudo tailscale up --accept-routes
  local _
  for _ in {1..40}; do
    tailscale status --json 2>/dev/null | grep -q '"BackendState": "Running"' && return 0
    sleep 0.25
  done
}

need_bins=1
if ! pacman -Qq tailscale >/dev/null 2>&1 && is_static /usr/sbin/tailscale && is_static /usr/sbin/tailscaled; then
  need_bins=0
fi

if (( need_bins )); then
  case "$(uname -m)" in
    x86_64) ts_arch=amd64 ;;
    aarch64 | arm64) ts_arch=arm64 ;;
    armv7l | armv6l) ts_arch=arm ;;
    i686 | i386) ts_arch=386 ;;
    riscv64) ts_arch=riscv64 ;;
    *)
      echo "unsupported arch: $(uname -m)" >&2
      exit 1
      ;;
  esac

  work=$(mktemp -d /tmp/tailscale-static.XXXXXX)
  trap 'rm -rf "$work"' EXIT

  # Unversioned tailscale_${arch}.tgz 404s; _latest_ 302s to the current stable tarball.
  url="https://pkgs.tailscale.com/stable/tailscale_latest_${ts_arch}.tgz"
  final_url=$(curl -fsSL -o "$work/tailscale.tgz" -w '%{url_effective}' "$url")
  expected=$(curl -fsSL "${final_url}.sha256" | awk '{print $1}')
  got=$(sha256sum "$work/tailscale.tgz" | awk '{print $1}')
  if [[ -z $expected || $expected != "$got" ]]; then
    echo "tailscale tarball sha256 mismatch (expected ${expected:-empty} got $got)" >&2
    exit 1
  fi

  tar -C "$work" -xf "$work/tailscale.tgz"
  src=$(echo "$work"/tailscale_*_"$ts_arch")
  [[ -x $src/tailscale && -x $src/tailscaled && -f $src/systemd/tailscaled.service ]]

  # /var/lib/tailscale is systemd StateDirectory — not a package file; login survives -Rns.
  if pacman -Qq tailscale >/dev/null 2>&1; then
    sudo pacman -Rns --noconfirm tailscale
  fi

  sudo cp "$src/tailscale" "$src/tailscaled" /usr/sbin/
  sudo cp "$src/systemd/tailscaled.service" /etc/systemd/system/
  sudo cp "$src/systemd/tailscale-online.target" /etc/systemd/system/
  sudo cp "$src/systemd/tailscale-wait-online.service" /etc/systemd/system/
  [[ -f /etc/default/tailscaled ]] || sudo cp "$src/systemd/tailscaled.defaults" /etc/default/tailscaled
fi

ensure_ignorepkg
sudo systemctl daemon-reload
sudo systemctl enable tailscaled.service
# enable --now leaves a pre-swap Arch tailscaled running; restart loads the static binary.
sudo systemctl restart tailscaled.service
wait_backend
sudo tailscale set --auto-update
