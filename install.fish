#!/usr/bin/env fish

# Source folder (Wallpapers in current directory)
set SOURCE_DIR "Wallpapers"

# Destination folder
set DEST_DIR "$HOME/Pictures/Wallpapers"

# Check if Wallpapers folder exists
if test -d $SOURCE_DIR
    echo "Found Wallpapers folder."

    # Create destination directory if it doesn't exist
    if not test -d "$HOME/Pictures"
        echo "Creating ~/Pictures directory..."
        mkdir -p "$HOME/Pictures"
    end

    if not test -d $DEST_DIR
        echo "Creating ~/Pictures/Wallpapers directory..."
        mkdir -p $DEST_DIR
    end

    # Move all contents inside Wallpapers to destination
    echo "Moving wallpapers..."
    mv $SOURCE_DIR/* $DEST_DIR/

    echo "Removing empty source directory..."
    rmdir $SOURCE_DIR

    echo "Wallpapers moved successfully!"
else
    echo "Wallpapers folder not found in current directory."
end

