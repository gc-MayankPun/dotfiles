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

set GRUB_SOURCE "$DOTFILES_DIR/etc/default/grub"
set SDDM_THEME_SOURCE "$DOTFILES_DIR/themes/silent"
set SDDM_CONFIG_SOURCE "$DOTFILES_DIR/sddm/default.conf"
set SDDM_CONFIG_DEST "/usr/share/sddm/themes/silent/configs"

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
# Install Hypr config
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
    echo "🎨 Installing Wallpapers..."

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

# -----------------------------
# Install Plymouth
# -----------------------------
echo "🚀 Installing Plymouth splash..."

sudo pacman -S --noconfirm plymouth
yay -S --noconfirm plymouth-theme-circle-hud-git

echo "🎨 Setting Plymouth theme..."
sudo plymouth-set-default-theme -R circle-hud

# -----------------------------
# Install GRUB config
# -----------------------------
if test -f $GRUB_SOURCE
    echo "⚙️ Installing GRUB config..."
    sudo cp $GRUB_SOURCE /etc/default/grub
    echo "🔧 Regenerating GRUB config..."
    sudo grub-mkconfig -o /boot/grub/grub.cfg
    echo "✅ GRUB configured."
else
    echo "❌ GRUB config not found in dotfiles."
end

# -----------------------------
# Install SDDM theme
# -----------------------------
echo "💻 Installing SDDM theme..."

yay -S --noconfirm sddm-silent-theme

if test -d $SDDM_THEME_SOURCE
    sudo cp -r $SDDM_THEME_SOURCE /usr/share/sddm/themes/
    echo "✅ SDDM theme installed."
else
    echo "❌ SDDM theme folder not found in dotfiles."
end

# -----------------------------
# Install custom SDDM config
# -----------------------------
echo "⚙️ Configuring SDDM silent theme..."

if test -f $SDDM_CONFIG_SOURCE

    if test -f "$SDDM_CONFIG_DEST/default.conf"
        echo "💾 Backing up existing SDDM config..."
        sudo mv "$SDDM_CONFIG_DEST/default.conf" "$SDDM_CONFIG_DEST/default.conf.bak"
    end

    echo "📦 Installing custom SDDM config..."
    sudo cp $SDDM_CONFIG_SOURCE "$SDDM_CONFIG_DEST/default.conf"

    echo "✅ SDDM config installed."

else
    echo "❌ Custom SDDM default.conf not found in dotfiles."
end

echo "✨ Installation complete!"
echo "🔄 Reboot recommended to apply GRUB and Plymouth."
