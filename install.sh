#!/usr/bin/env bash
set -euo pipefail

RICE="$(cd "$(dirname "$0")" && pwd)"
CFG="$HOME/.config"
BIN="$HOME/.local/bin"

backup() {
  [ -e "$2" ] && [ ! -L "$2" ] && mv "$2" "${2}.bak.$(date +%s)"
}
cpd() { backup "$1" "$2"; mkdir -p "$(dirname "$2")"; cp -r "$1" "$2"; echo "  ok $2"; }
cpf() { backup "$1" "$2"; mkdir -p "$(dirname "$2")"; cp "$1" "$2"; echo "  ok $2"; }

echo "-> configs"
cpd "$RICE/.config/hypr"       "$CFG/hypr"
cpd "$RICE/.config/waybar"     "$CFG/waybar"
cpd "$RICE/.config/quickshell" "$CFG/quickshell"
cpd "$RICE/.config/rofi"       "$CFG/rofi"
cpd "$RICE/.config/kitty"      "$CFG/kitty"
cpd "$RICE/.config/wal"        "$CFG/wal"
cpd "$RICE/.config/swayosd"    "$CFG/swayosd"
cpd "$RICE/.config/fastfetch"  "$CFG/fastfetch"
cpd "$RICE/.config/fish"       "$CFG/fish"
cpd "$RICE/.config/spicetify/Themes/Pywal" "$CFG/spicetify/Themes/Pywal"
cpf "$RICE/.config/gtk-3.0/settings.ini"   "$CFG/gtk-3.0/settings.ini"
cpf "$RICE/.config/gtk-4.0/settings.ini"   "$CFG/gtk-4.0/settings.ini"

echo "-> scripts"
mkdir -p "$BIN"
cp "$RICE/.local/bin/"* "$BIN/"
chmod +x "$BIN/erdfetch" "$BIN/mic-toggle" "$BIN/mon-off" "$BIN/mon-on" \
         "$BIN/start-quickshell.sh" "$BIN/swayosd-colors-watch" "$BIN/swayosd-wrapper"
chmod +x "$CFG/wal/done.sh" "$CFG/hypr/scripts/"*.sh "$CFG/quickshell/update-menu-style.sh"

echo "-> wallpapers"
mkdir -p "$HOME/wallpapers"
cp -n "$RICE/wallpapers/"* "$HOME/wallpapers/" 2>/dev/null || true

echo "-> pywal colors"
WALL=""
[ -f "$HOME/wallpapers/Lain.jpg" ] && WALL="$HOME/wallpapers/Lain.jpg"
[ -z "$WALL" ] && WALL=$(find "$HOME/wallpapers" -maxdepth 1 \( -name "*.jpg" -o -name "*.png" \) | head -1)
[ -n "$WALL" ] && wal -i "$WALL" -q && echo "  ok: $WALL" || echo "  run wal -i <wallpaper> manually"

echo ""
echo "done! next steps:"
echo "  fish -c 'fisher update'"
echo "  pywalfox install"
echo "  spicetify config current_theme Pywal && spicetify apply"
echo "  killall waybar; waybar &"
echo "  ~/.local/bin/start-quickshell.sh"
