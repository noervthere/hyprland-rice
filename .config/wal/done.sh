#!/usr/bin/env bash

# ── Pywal post-generation hook ──────────────────────────────────────────────
# Runs automatically after `wal` generates a new color scheme.

CACHE="$HOME/.cache/wal"

# Zen Browser
pywalfox update &

# ── Spicetify ───────────────────────────────────────────────────────────────
# color.ini in the Pywal theme is already symlinked to $CACHE/colors-spicetify.ini
# Just re-apply so Spotify picks up the new palette.
spicetify apply &

# ── Vencord (Discord) ───────────────────────────────────────────────────────
# Symlink quickCss.css → generated discord colors so Vencord auto-reloads.
QUICK_CSS="$HOME/.config/Vencord/settings/quickCss.css"
DISCORD_CSS="$CACHE/colors-discord.css"

# Create / refresh the symlink (Vencord watches this file and reloads on change)
ln -sf "$DISCORD_CSS" "$QUICK_CSS"

# ── SwayOSD ───────────────────────────────────────────────────────────────
# SwayOSD colors are now handled by the watcher - disable template to prevent conflict
if [[ -f "$HOME/.config/wal/templates/colors-swayosd.css" ]]; then
    chmod -x "$HOME/.config/wal/templates/colors-swayosd.css" 2>/dev/null || true
fi

wait
