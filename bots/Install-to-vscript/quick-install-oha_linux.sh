#!/bin/bash

set -euo pipefail

function error_exit {
    echo "============"
    echo "$1"
    echo "Common troubleshooting:"
    echo "1. Make sure to execute this script in the folder: 'SteamLibrary/steamapps/workshop/content/570/3246316298/Install-to-vscript' (or equivalent path in your Steam library)."
    echo "2. If you don't know where the Steam library folder is, right-click Dota 2 in Steam Library, select Properties > Installed Files > Browse. It will open the folder: 'steamapps/common/dota 2 beta'. From there, navigate back to 'steamapps' and then to 'workshop/content/570/3246316298/Install-to-vscript'."
    echo "3. If you encounter permission issues, ensure the Steam library folders are owned by your user (e.g., run 'chown -R $USER:$USER /path/to/SteamLibrary' if needed, replacing /path/to/SteamLibrary with your actual path). The chown command recursively changes ownership of files and directories to the specified user and group (here, your current user and group)."
    echo "============"
    echo "Install failed!!!"
    echo "============"
    exit 1
}

# Get the current timestamp (format: YYYYMMDD_HHMMSS)
TIMESTAMP=$(date +%Y%m%d_%H%M%S) || error_exit "Failed to generate timestamp."

# Get the script's directory
SCRIPT_DIR=$(pwd) || error_exit "Failed to determine current directory."

# Workshop item directory (parent of this script's directory)
WORKSHOP_ITEM_DIR="$SCRIPT_DIR/.."
if [ ! -d "$WORKSHOP_ITEM_DIR" ]; then
    error_exit "Workshop item directory not found: $WORKSHOP_ITEM_DIR. Ensure the script is run from the correct location."
fi

# Check for required source Customize folder
if [ ! -d "$WORKSHOP_ITEM_DIR/Customize" ]; then
    error_exit "Source Customize folder not found in $WORKSHOP_ITEM_DIR."
fi

# Dota 2 directory (assuming standard Steam library structure)
DOTA_DIR="$SCRIPT_DIR/../../../../../common/dota 2 beta"
if [ ! -d "$DOTA_DIR" ]; then
    error_exit "Dota 2 installation directory not found: $DOTA_DIR. Verify your Steam library path and script location."
fi

# vscripts directory
VSCRIPTS_DIR="$DOTA_DIR/game/dota/scripts/vscripts"
if [ ! -d "$VSCRIPTS_DIR" ]; then
    error_exit "Dota 2 vscripts directory not found: $VSCRIPTS_DIR. Ensure Dota 2 is installed correctly."
fi

# Target directories
BOTS_DIR="$VSCRIPTS_DIR/bots"
CUSTOMIZE_TARGET="$VSCRIPTS_DIR/game/Customize"
CUSTOMIZE_PARENT="$VSCRIPTS_DIR/game"
if [ ! -d "$CUSTOMIZE_PARENT" ]; then
    mkdir -p "$CUSTOMIZE_PARENT" || error_exit "Failed to create parent directory for Customize: $CUSTOMIZE_PARENT."
fi

# Check if the bots folder already exists
if [ -d "$BOTS_DIR" ] || [ -L "$BOTS_DIR" ]; then
    echo "bots folder or symlink already exists, renaming to bots_old_$TIMESTAMP..."
    mv "$BOTS_DIR" "$VSCRIPTS_DIR/bots_old_$TIMESTAMP" || error_exit "Failed to rename existing bots directory."
fi

echo "Creating symbolic link..."
ln -s "$WORKSHOP_ITEM_DIR" "$BOTS_DIR" || error_exit "Failed to create symbolic link for bots."

# Check if the Customize folder already exists
if [ -d "$CUSTOMIZE_TARGET" ] || [ -L "$CUSTOMIZE_TARGET" ]; then
    echo "Customize folder already exists, renaming to Customize_old_$TIMESTAMP..."
    mv "$CUSTOMIZE_TARGET" "$VSCRIPTS_DIR/game/Customize_old_$TIMESTAMP" || error_exit "Failed to rename existing Customize directory."
fi

echo "Copying Customize folder..."
cp -r "$WORKSHOP_ITEM_DIR/Customize/" "$CUSTOMIZE_TARGET" || error_exit "Failed to copy Customize folder."

echo "============"
echo "Install Succeeded!!!"
echo "============"
