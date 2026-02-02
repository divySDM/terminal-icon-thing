# Installation Guide

## Automatic Installation

The easiest way to install Terminal Identity:

```bash
git clone <repo-url> terminal-id
cd terminal-id
./install.sh
```

The installer will:
1. Copy files to `~/.local/share/terminal-id/`
2. Add the `tid` command to `~/.local/bin/`
3. Optionally add shell integration to your `.zshrc` or `.bashrc`

## Manual Installation

### 1. Copy Files

```bash
# Create directories
mkdir -p ~/.local/share/terminal-id/identities
mkdir -p ~/.local/bin
mkdir -p ~/.config/terminal-id

# Copy source files
cp src/terminal-id.sh ~/.local/share/terminal-id/
cp src/tid ~/.local/bin/
chmod +x ~/.local/bin/tid

# Copy default identities
cp src/identities/default.toml ~/.local/share/terminal-id/identities/
```

### 2. Add Shell Integration

Add to your `~/.zshrc`:

```bash
# Terminal Identity
source ~/.local/share/terminal-id/terminal-id.sh
```

Or for bash, add to `~/.bashrc`:

```bash
# Terminal Identity
source ~/.local/share/terminal-id/terminal-id.sh
```

### 3. Configure Your Prompt

#### Zsh

Add the identity to the beginning of your prompt:

```bash
PROMPT='$(__tid_prompt) '$PROMPT
```

Or to the right prompt:

```bash
RPROMPT='$(__tid_prompt)'
```

#### Bash

Add to PS1:

```bash
PS1='$(__tid_prompt) '$PS1
```

### 4. Ensure ~/.local/bin is in PATH

If `tid` command isn't found, add to your shell rc:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

## Verifying Installation

```bash
# Check tid is available
tid help

# List identities
tid list

# Test setting an identity
tid set rocket

# Check the prompt function works
__tid_prompt
```

## Updating

To update to the latest version:

```bash
cd terminal-id
git pull
./install.sh
```

The installer will overwrite existing files but preserve your configuration.

## Uninstalling

```bash
# Remove installed files
rm -rf ~/.local/share/terminal-id
rm ~/.local/bin/tid
rm -rf ~/.config/terminal-id  # Optional: removes your config

# Remove from shell rc (edit manually)
# Delete the line: source ~/.local/share/terminal-id/terminal-id.sh
# Delete the prompt modification
```
