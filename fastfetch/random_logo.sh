#!/bin/bash
LOGO_DIR="$HOME/.config/fastfetch/images"

# Find all matching files and pick one randomly
find "$LOGO_DIR" -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.gif" -o -iname "*.webp" \) | shuf -n 1   