sudo pacman -S keyd
sudo systemctl enable --now keyd

sudo tee /etc/keyd/default.conf >/dev/null <<'EOF'
[ids]
*

[main]
leftalt = leftmeta
leftmeta = leftalt
compose = leftalt
EOF

sudo keyd reload
