#!/usr/bin/env fish

echo "🚀 Starting dotfiles installation..."

# -----------------------------
# Variables
# -----------------------------
set DOTFILES_DIR (dirname (status -f))
set HYPR_SOURCE "$DOTFILES_DIR/hypr"
set HYPR_DEST "$HOME/.config/hypr"
set WALL_SOURCE "$DOTFILES_DIR/Wallpapers"
set WALL_DEST "$HOME/Pictures/Wallpapers"

# -----------------------------
# Ensure ~/.config exists
# -----------------------------
if not test -d "$HOME/.config"
    echo "📁 Creating ~/.config directory..."
    mkdir -p "$HOME/.config"
end

# -----------------------------
# Backup existing hypr config
# -----------------------------
if test -d $HYPR_DEST
    set BACKUP_NAME "$HOME/.config/hypr_backup_"(date +%Y%m%d_%H%M%S)
    echo "💾 Backing up existing hypr config to $BACKUP_NAME"
    mv $HYPR_DEST $BACKUP_NAME
end

# -----------------------------
# Copy new hypr config
# -----------------------------
if test -d $HYPR_SOURCE
    echo "⚙️ Installing hypr config..."
    cp -r $HYPR_SOURCE $HYPR_DEST
    echo "✅ Hypr config installed."
else
    echo "❌ hypr folder not found in dotfiles!"
end

# -----------------------------
# Ensure ~/Pictures exists
# -----------------------------
if not test -d "$HOME/Pictures"
    echo "🖼️ Creating ~/Pictures directory..."
    mkdir -p "$HOME/Pictures"
end

# -----------------------------
# Move Wallpapers
# -----------------------------
if test -d $WALL_SOURCE
    echo "🎨 Moving Wallpapers..."

    if test -d $WALL_DEST
        echo "📂 Wallpapers folder already exists. Merging..."
        cp -r $WALL_SOURCE/* $WALL_DEST/
    else
        mv $WALL_SOURCE "$HOME/Pictures/"
    end

    echo "✅ Wallpapers installed."
else
    echo "❌ Wallpapers folder not found in dotfiles."
end

echo "✨ Done! Restart Hyprland to apply changes."