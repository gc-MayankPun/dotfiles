#!/usr/bin/env fish
set -e

if not type -q yay
    echo "❌ yay not installed. Install it first."
    exit 1
end

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
if test -d $HYPR_DEST; and not diff -qr $HYPR_SOURCE $HYPR_DEST >/dev/null 2>&1
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
        cp -r $WALL_SOURCE $WALL_DEST
    end

    echo "✅ Wallpapers installed."
else
    echo "❌ Wallpapers folder not found in dotfiles."
end

# -----------------------------
# Install GRUB config
# -----------------------------
if test -f $GRUB_SOURCE
    echo "⚙️ Installing GRUB config..."
    sudo cp $GRUB_SOURCE /etc/default/grub
    echo "✅ GRUB configured."
else
    echo "❌ GRUB config not found in dotfiles."
end

# # -----------------------------
# # Install Plymouth
# # -----------------------------
if not pacman -Q plymouth >/dev/null 2>&1
    echo "🚀 Installing Plymouth splash..."
    sudo pacman -S --noconfirm plymouth
end

echo "📂 Installing PlymouthTheme-Cat..."

# Copy theme from dotfiles
if test -d "$DOTFILES_DIR/plymouth/PlymouthTheme-Cat"
    if not test -d /usr/share/plymouth/themes/PlymouthTheme-Cat
        sudo cp -r $DOTFILES_DIR/plymouth/PlymouthTheme-Cat /usr/share/plymouth/themes/
        echo "✅ Theme copied."
    end
else
    echo "❌ PlymouthTheme-Cat not found in dotfiles plymouth!"
end

echo "🎨 Setting Plymouth theme..."
sudo plymouth-set-default-theme -R PlymouthTheme-Cat

echo "⚙️ Configuring Plymouth boot..."

# Add plymouth hook if not present
if not grep -q "plymouth" /etc/mkinitcpio.conf
    echo "🧩 Adding plymouth hook..."
    sudo sed -i 's/base udev/base udev plymouth/' /etc/mkinitcpio.conf
end

# Add splash to GRUB
if not grep -q "quiet splash" /etc/default/grub
    echo "🎛️ Updating GRUB kernel params..."
    sudo sed -i 's/quiet/quiet splash/' /etc/default/grub
end

# Rebuild initramfs & grub
echo "🔄 Rebuilding initramfs and GRUB..."
sudo mkinitcpio -P
sudo grub-mkconfig -o /boot/grub/grub.cfg
echo "✅ GRUB and initramfs configured."

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
        set BACKUP "$SDDM_CONFIG_DEST/default.conf.bak."(date +%s)
        sudo mv "$SDDM_CONFIG_DEST/default.conf" $BACKUP
    end

    echo "📦 Installing custom SDDM config..."
    sudo cp $SDDM_CONFIG_SOURCE "$SDDM_CONFIG_DEST/default.conf"

    echo "✅ SDDM config installed."

else
    echo "❌ Custom SDDM default.conf not found in dotfiles."
end

echo "✨ Installation complete!"
echo "🔄 Reboot recommended to apply GRUB and Plymouth."
