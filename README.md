
## 📦 Reinstall Instructions

To restore this setup on a new system:

```bash
git clone https://github.com/<your-username>/dotfiles.git
cd dotfiles

# Copy configs
cp -r .config/* ~/.config/
cp .bashrc ~/

# Install packages
sudo pacman -S --needed - < pkglist.txt

# Done!
