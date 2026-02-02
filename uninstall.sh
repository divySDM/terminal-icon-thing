#!/usr/bin/env bash
# Terminal Identity Uninstaller
# Removes tid CLI and shell integration

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Installation paths (must match install.sh)
INSTALL_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/terminal-id"
BIN_DIR="$HOME/.local/bin"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/terminal-id"

echo "Terminal Identity Uninstaller"
echo "============================="
echo ""

# Find all config files that might contain terminal-id or __tid_prompt
find_tid_configs() {
    local configs=(
        "$HOME/.zshrc"
        "$HOME/.zprofile"
        "$HOME/.zshenv"
        "$HOME/.zlogin"
        "$HOME/.bashrc"
        "$HOME/.bash_profile"
        "$HOME/.profile"
    )
    local found=()

    for config in "${configs[@]}"; do
        if [[ -f "$config" ]]; then
            if grep -qi "terminal.id\|__tid_prompt" "$config" 2>/dev/null; then
                found+=("$config")
            fi
        fi
    done

    echo "${found[@]}"
}

# Remove shell integration from all config files that have it
FOUND_CONFIGS=$(find_tid_configs)

if [[ -n "$FOUND_CONFIGS" ]]; then
    for RC_FILE in $FOUND_CONFIGS; do
        echo "Removing terminal-id from $RC_FILE..."

        # Create backup
        cp "$RC_FILE" "$RC_FILE.tid-backup"

        # Remove terminal-id lines (comment, source line, and prompt integration)
        # Using -i for case insensitive and .id to match both "terminal-id" and "Terminal Identity"
        grep -vi "terminal.id\|__tid_prompt" "$RC_FILE.tid-backup" > "$RC_FILE"

        echo -e "${GREEN}Removed from $RC_FILE${NC}"
        echo "  Backup saved to $RC_FILE.tid-backup"
    done
else
    echo "No terminal-id configuration found in any config files."
fi

# Remove tid binary
if [[ -f "$BIN_DIR/tid" ]]; then
    echo ""
    echo "Removing tid CLI..."
    rm -f "$BIN_DIR/tid"
    echo -e "${GREEN}Removed $BIN_DIR/tid${NC}"
else
    echo "tid CLI not found at $BIN_DIR/tid"
fi

# Remove installation directory
if [[ -d "$INSTALL_DIR" ]]; then
    echo ""
    echo "Removing installation directory..."
    rm -rf "$INSTALL_DIR"
    echo -e "${GREEN}Removed $INSTALL_DIR${NC}"
else
    echo "Installation directory not found at $INSTALL_DIR"
fi

# Ask about configuration
if [[ -d "$CONFIG_DIR" ]]; then
    echo ""
    echo "Configuration directory found at $CONFIG_DIR"
    echo "This contains your rules and custom identities."
    echo ""
    read -p "Remove configuration? [y/N] " -n 1 -r
    echo ""

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$CONFIG_DIR"
        echo -e "${GREEN}Removed $CONFIG_DIR${NC}"
    else
        echo "Kept configuration at $CONFIG_DIR"
    fi
fi

echo ""
echo -e "${GREEN}Uninstallation complete!${NC}"
echo ""
echo "Please restart your terminal to apply changes."
