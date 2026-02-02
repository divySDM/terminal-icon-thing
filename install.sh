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
    *)
        echo -e "${YELLOW}Warning: Unknown shell '$SHELL_NAME'${NC}"
        echo "Please manually add the following to your shell rc file:"
        echo ""
        echo "  source \"$INSTALL_DIR/terminal-id.sh\""
        echo ""
        exit 0
        ;;
esac

# Check if already configured
SOURCE_LINE="source \"$INSTALL_DIR/terminal-id.sh\""
if grep -q "terminal-id.sh" "$RC_FILE" 2>/dev/null; then
    echo "Shell integration already configured in $RC_FILE"
else
    echo ""
    echo "Add shell integration to $RC_FILE?"
    echo "This will add: $SOURCE_LINE"
    echo ""
    read -p "Proceed? [Y/n] " -n 1 -r
    echo ""

    if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
        echo "" >> "$RC_FILE"
        echo "# Terminal Identity - visual terminal differentiation" >> "$RC_FILE"
        echo "$SOURCE_LINE" >> "$RC_FILE"
        echo -e "${GREEN}Added to $RC_FILE${NC}"
    else
        echo "Skipped. Add manually when ready:"
        echo "  echo '$SOURCE_LINE' >> $RC_FILE"
    fi
fi

# Prompt configuration
echo ""
echo "To add the identity icon to your prompt, add this to $RC_FILE:"
echo ""

if [[ "$SHELL_NAME" == "zsh" ]]; then
    echo "  # Add to your PROMPT variable:"
    echo "  PROMPT='\$(__tid_prompt) '\$PROMPT"
    echo ""
    echo "  # Or for right prompt:"
    echo "  RPROMPT='\$(__tid_prompt)'"
else
    echo "  # Add to your PS1 variable:"
    echo "  PS1='\$(__tid_prompt) '\$PS1"
fi

echo ""
echo -e "${GREEN}Installation complete!${NC}"
echo ""
echo "Quick start:"
echo "  1. Restart your terminal or run: source $RC_FILE"
echo "  2. Run: tid list              # See available identities"
echo "  3. Run: tid set rocket        # Set session identity"
echo "  4. Run: tid rule . star       # Set rule for current directory"
echo ""
echo "For more info: tid help"
