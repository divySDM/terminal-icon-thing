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

# Detect shell
SHELL_NAME=$(basename "$SHELL")
RC_FILE=""

case "$SHELL_NAME" in
    zsh)
        RC_FILE="$HOME/.zshrc"
        ;;
    bash)
        RC_FILE="$HOME/.bashrc"
        ;;
esac

# Remove shell integration from rc file
if [[ -n "$RC_FILE" ]] && [[ -f "$RC_FILE" ]]; then
    if grep -q "terminal-id" "$RC_FILE" 2>/dev/null; then
        echo "Removing shell integration from $RC_FILE..."

        # Create backup
        cp "$RC_FILE" "$RC_FILE.tid-backup"

        # Remove terminal-id lines (comment and source line)
        grep -v "terminal-id" "$RC_FILE.tid-backup" > "$RC_FILE"

        echo -e "${GREEN}Removed from $RC_FILE${NC}"
        echo "  Backup saved to $RC_FILE.tid-backup"
    else
        echo "No shell integration found in $RC_FILE"
    fi
else
    echo -e "${YELLOW}Warning: Could not detect shell rc file${NC}"
    echo "Please manually remove any terminal-id lines from your shell config."
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
echo "Please restart your terminal or run:"
echo "  source $RC_FILE"
echo ""
echo "Note: You may want to remove any __tid_prompt references from your PROMPT/PS1."
