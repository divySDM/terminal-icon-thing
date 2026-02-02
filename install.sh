#!/usr/bin/env bash
# Terminal Identity Installer
# Installs tid CLI and shell integration

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Installation paths
INSTALL_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/terminal-id"
BIN_DIR="$HOME/.local/bin"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/terminal-id"

# Source directory (where this script is)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="$SCRIPT_DIR/src"

echo "Terminal Identity Installer"
echo "==========================="
echo ""

# Check source files exist
if [[ ! -f "$SRC_DIR/terminal-id.sh" ]] || [[ ! -f "$SRC_DIR/tid" ]]; then
    echo -e "${RED}Error: Source files not found in $SRC_DIR${NC}"
    echo "Make sure you're running this from the terminal-id repository root."
    exit 1
fi

# Create directories
echo "Creating directories..."
mkdir -p "$INSTALL_DIR/identities"
mkdir -p "$BIN_DIR"
mkdir -p "$CONFIG_DIR"

# Copy files
echo "Installing files..."
cp "$SRC_DIR/terminal-id.sh" "$INSTALL_DIR/"
cp "$SRC_DIR/tid" "$BIN_DIR/"
chmod +x "$BIN_DIR/tid"

# Copy default identities
if [[ -f "$SRC_DIR/identities/default.toml" ]]; then
    cp "$SRC_DIR/identities/default.toml" "$INSTALL_DIR/identities/"
fi

echo -e "${GREEN}Files installed successfully!${NC}"
echo ""

# Detect shell and find appropriate rc file
SHELL_NAME=$(basename "$SHELL")
RC_FILE=""

# Find zsh config file - check common locations in order of preference
find_zsh_config() {
    local configs=("$HOME/.zshrc" "$HOME/.zprofile" "$HOME/.zshenv" "$HOME/.zlogin")

    # First, check if terminal-id is already installed in any file
    for config in "${configs[@]}"; do
        if [[ -f "$config" ]] && grep -q "terminal-id" "$config" 2>/dev/null; then
            echo "$config"
            return 0
        fi
    done

    # Next, prefer .zshrc if it exists
    if [[ -f "$HOME/.zshrc" ]]; then
        echo "$HOME/.zshrc"
        return 0
    fi

    # Check if .zprofile exists (common on macOS)
    if [[ -f "$HOME/.zprofile" ]]; then
        echo "$HOME/.zprofile"
        return 0
    fi

    # Default to .zshrc (will be created)
    echo "$HOME/.zshrc"
}

# Find bash config file
find_bash_config() {
    local configs=("$HOME/.bashrc" "$HOME/.bash_profile" "$HOME/.profile")

    # First, check if terminal-id is already installed in any file
    for config in "${configs[@]}"; do
        if [[ -f "$config" ]] && grep -q "terminal-id" "$config" 2>/dev/null; then
            echo "$config"
            return 0
        fi
    done

    # Prefer .bashrc for interactive shells
    if [[ -f "$HOME/.bashrc" ]]; then
        echo "$HOME/.bashrc"
        return 0
    fi

    # Check .bash_profile (common on macOS)
    if [[ -f "$HOME/.bash_profile" ]]; then
        echo "$HOME/.bash_profile"
        return 0
    fi

    # Default to .bashrc
    echo "$HOME/.bashrc"
}

case "$SHELL_NAME" in
    zsh)
        RC_FILE=$(find_zsh_config)
        ;;
    bash)
        RC_FILE=$(find_bash_config)
        ;;
    *)
        echo -e "${YELLOW}Warning: Unknown shell '$SHELL_NAME'${NC}"
        echo "Please manually add the following to your shell rc file:"
        echo ""
        echo "  source \"$INSTALL_DIR/terminal-id.sh\""
        echo ""
        exit 0
        ;;
esac

# Add shell integration if not already present
SOURCE_LINE="source \"$INSTALL_DIR/terminal-id.sh\""

if grep -q "terminal-id.sh" "$RC_FILE" 2>/dev/null; then
    echo "Shell integration already configured in $RC_FILE"
else
    echo "Adding shell integration to $RC_FILE..."
    echo "" >> "$RC_FILE"
    echo "# Terminal Identity - visual terminal differentiation" >> "$RC_FILE"
    echo "$SOURCE_LINE" >> "$RC_FILE"
    echo -e "${GREEN}Added source line to $RC_FILE${NC}"
fi

# Add prompt integration if not already present
if grep -q "__tid_prompt" "$RC_FILE" 2>/dev/null; then
    echo "Prompt integration already configured in $RC_FILE"
else
    echo "Adding prompt integration to $RC_FILE..."

    if [[ "$SHELL_NAME" == "zsh" ]]; then
        echo "PROMPT='\$(__tid_prompt) '\"\$PROMPT\"" >> "$RC_FILE"
    else
        echo "PS1='\$(__tid_prompt) '\"\$PS1\"" >> "$RC_FILE"
    fi

    echo -e "${GREEN}Added prompt integration to $RC_FILE${NC}"
fi

echo ""
echo -e "${GREEN}Installation complete!${NC}"
echo ""
echo "Restart your terminal or run: source $RC_FILE"
echo ""
echo "Commands:"
echo "  tid list              See available identities"
echo "  tid set rocket        Set session identity"
echo "  tid reroll            Get a new random session icon"
echo "  tid rule . star       Set rule for current directory"
echo "  tid help              Show all commands"
