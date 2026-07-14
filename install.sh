#!/usr/bin/env bash
set -e

if ! command -v yay >/dev/null 2>&1; then
    echo "❌ yay not installed. Install it first."
    exit 1
fi

echo "🚀 Starting dotfiles installation..."

# -----------------------------
# Variables
# -----------------------------
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

HYPR_SOURCE="$DOTFILES_DIR/hypr"
HYPR_DEST="$HOME/.config/hypr"

KITTY_SOURCE="$DOTFILES_DIR/kitty"
KITTY_DEST="$HOME/.config/kitty"

FASTFETCH_SOURCE="$DOTFILES_DIR/fastfetch"
FASTFETCH_DEST="$HOME/.config/fastfetch"

SDDM_THEME_SOURCE="$DOTFILES_DIR/themes/silent"
SDDM_CONFIG_SOURCE="$DOTFILES_DIR/sddm/default.conf"
SDDM_CONFIG_DEST="/usr/share/sddm/themes/silent/configs"

# -----------------------------
# Ensure ~/.config exists
# -----------------------------
if [ ! -d "$HOME/.config" ]; then
    echo "📁 Creating ~/.config directory..."
    mkdir -p "$HOME/.config"
fi

# -----------------------------
# Backup existing hypr config
# -----------------------------
if [ -d "$HYPR_DEST" ] && ! diff -qr "$HYPR_SOURCE" "$HYPR_DEST" >/dev/null 2>&1; then
    BACKUP_NAME="$HOME/.config/hypr_backup_$(date +%Y%m%d_%H%M%S)"
    echo "💾 Backing up existing hypr config to $BACKUP_NAME"
    mv "$HYPR_DEST" "$BACKUP_NAME"
fi

# -----------------------------
# Install Hypr config
# -----------------------------
if [ -d "$HYPR_SOURCE" ]; then
    echo "⚙️ Installing hypr config..."
    cp -r "$HYPR_SOURCE" "$HYPR_DEST"
    echo "✅ Hypr config installed."
else
    echo "❌ hypr folder not found in dotfiles!"
fi

# -----------------------------
# Backup existing kitty config
# -----------------------------
if [ -d "$KITTY_DEST" ] && ! diff -qr "$KITTY_SOURCE" "$KITTY_DEST" >/dev/null 2>&1; then
    BACKUP_NAME="$HOME/.config/kitty_backup_$(date +%Y%m%d_%H%M%S)"
    echo "💾 Backing up existing kitty config to $BACKUP_NAME"
    mv "$KITTY_DEST" "$BACKUP_NAME"
fi

# -----------------------------
# Install Kitty config
# -----------------------------
if [ -d "$KITTY_SOURCE" ]; then
    echo "⚙️ Installing kitty config..."
    cp -r "$KITTY_SOURCE" "$KITTY_DEST"
    echo "✅ Kitty config installed."
else
    echo "❌ kitty folder not found in dotfiles!"
fi

# -----------------------------
# Backup existing fastfetch config
# ----------------------------- 
if [ -d "$FASTFETCH_DEST" ] && ! diff -qr "$FASTFETCH_SOURCE" "$FASTFETCH_DEST" >/dev/null 2>&1; then
    BACKUP_NAME="$HOME/.config/fastfetch_backup_$(date +%Y%m%d_%H%M%S)"
    echo "💾 Backing up existing fastfetch config to $BACKUP_NAME"
    mv "$FASTFETCH_DEST" "$BACKUP_NAME"
fi

# -----------------------------
# Install fastfetch config
# -----------------------------
if [ -d "$FASTFETCH_SOURCE" ]; then
    echo "⚙️ Installing fastfetch config..."
    cp -r "$FASTFETCH_SOURCE" "$FASTFETCH_DEST"
    echo "✅ Fastfetch config installed."
else
    echo "❌ fastfetch folder not found in dotfiles!"
fi

# -----------------------------
# Backup existing .zshrc
# -----------------------------
if [ -f "$HOME/.zshrc" ] && ! diff -q "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc" >/dev/null 2>&1; then
    BACKUP_NAME="$HOME/.zshrc_backup_$(date +%Y%m%d_%H%M%S)"
    echo "💾 Backing up existing .zshrc to $BACKUP_NAME"
    mv "$HOME/.zshrc" "$BACKUP_NAME"
fi

# -----------------------------
# Install .zshrc
# -----------------------------
if [ -f "$DOTFILES_DIR/.zshrc" ]; then
    echo "⚙️ Installing .zshrc..."
    cp "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
    echo "✅ .zshrc installed."
else
    echo "❌ .zshrc not found in dotfiles!"
fi

# -----------------------------
# Install Plymouth
# -----------------------------
if ! pacman -Q plymouth >/dev/null 2>&1; then
    echo "🚀 Installing Plymouth splash..."
    sudo pacman -S --noconfirm plymouth
fi

echo "📂 Installing PlymouthTheme-Cat..."

# Copy theme from dotfiles
if [ -d "$DOTFILES_DIR/plymouth/PlymouthTheme-Cat" ]; then
    if [ ! -d /usr/share/plymouth/themes/PlymouthTheme-Cat ]; then
        sudo cp -r "$DOTFILES_DIR/plymouth/PlymouthTheme-Cat" /usr/share/plymouth/themes/
        echo "✅ Theme copied."
    fi
else
    echo "❌ PlymouthTheme-Cat not found in dotfiles plymouth!"
fi

echo "🎨 Setting Plymouth theme..."
sudo plymouth-set-default-theme -R PlymouthTheme-Cat

echo "⚙️ Configuring Plymouth boot..."

# Add plymouth hook if not present
if ! grep -q "plymouth" /etc/mkinitcpio.conf; then
    echo "🧩 Adding plymouth hook..."
    sudo sed -i 's/base udev/base udev plymouth/' /etc/mkinitcpio.conf
fi

# Rebuild initramfs
echo "🔄 Rebuilding initramfs..."
sudo mkinitcpio -P
echo "✅ Initramfs configured."

# -----------------------------
# Install SDDM theme
# -----------------------------
echo "💻 Installing SDDM theme..."

yay -S --noconfirm sddm-silent-theme

if [ -d "$SDDM_THEME_SOURCE" ]; then
    sudo cp -r "$SDDM_THEME_SOURCE" /usr/share/sddm/themes/
    echo "✅ SDDM theme installed."
else
    echo "❌ SDDM theme folder not found in dotfiles."
fi

# -----------------------------
# Install custom SDDM config
# -----------------------------
echo "⚙️ Configuring SDDM silent theme..."

if [ -f "$SDDM_CONFIG_SOURCE" ]; then

    if [ -f "$SDDM_CONFIG_DEST/default.conf" ]; then
        echo "💾 Backing up existing SDDM config..."
        BACKUP="$SDDM_CONFIG_DEST/default.conf.bak.$(date +%s)"
        sudo mv "$SDDM_CONFIG_DEST/default.conf" "$BACKUP"
    fi

    echo "📦 Installing custom SDDM config..."
    sudo cp "$SDDM_CONFIG_SOURCE" "$SDDM_CONFIG_DEST/default.conf"

    echo "✅ SDDM config installed."

else
    echo "❌ Custom SDDM default.conf not found in dotfiles."
fi

echo "✨ Installation complete!"
echo "🔄 Reboot recommended to apply Plymouth."