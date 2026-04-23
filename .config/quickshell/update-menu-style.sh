#!/usr/bin/env bash

# This script generates a Qt StyleSheet to match the current Pywal/Cyberpunk theme for QMenu system tray popups.
# It uses the colors from pywal's colors.json cache.

WAL_CACHE="$HOME/.cache/wal/colors.json"
OUT_FILE="$HOME/.cache/wal/colors-qt.qss"

if [ ! -f "$WAL_CACHE" ]; then
    echo "Warning: Pywal cache not found at $WAL_CACHE"
    exit 0
fi

# Extract colors using jq
BG=$(jq -r '.special.background' "$WAL_CACHE")
FG=$(jq -r '.special.foreground' "$WAL_CACHE")
COLOR_ACCENT=$(jq -r '.colors.color5' "$WAL_CACHE") # Using color5 (blue/accent) for selections
COLOR_SEC=$(jq -r '.colors.color1' "$WAL_CACHE") # Using color1 (pink/red) for borders
COLOR_INACTIVE=$(jq -r '.colors.color8' "$WAL_CACHE") # Color8 for separators/disabled

cat <<EOF > "$OUT_FILE"
QMenu {
    background-color: ${BG}e6; /* slight transparency */
    color: ${FG};
    border: 1px solid ${COLOR_ACCENT};
    border-radius: 8px;
    padding: 6px 0px;
    font-family: "JetBrainsMono Nerd Font", monospace;
    font-size: 11px;
    font-weight: bold;
}

QMenu::item {
    background-color: transparent;
    padding: 6px 24px 6px 24px;
    margin: 0px 4px;
    border-radius: 4px;
    color: ${FG};
}

QMenu::item:selected {
    background-color: ${COLOR_ACCENT}40; /* 25% opacity accent glow */
    color: ${COLOR_ACCENT};
    border-left: 2px solid ${COLOR_ACCENT};
}

QMenu::item:disabled {
    color: ${COLOR_INACTIVE};
}

QMenu::separator {
    height: 1px;
    background-color: ${COLOR_ACCENT}40;
    margin: 4px 12px;
}

QMenu::indicator {
    width: 13px;
    height: 13px;
}
EOF

echo "Generated Qt QMenu stylesheet at $OUT_FILE"

# Apply Spicetify Theme dynamically in background
if command -v spicetify >/dev/null; then
    nohup spicetify apply -n -q >/dev/null 2>&1 &
fi
