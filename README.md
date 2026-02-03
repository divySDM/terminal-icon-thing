# Terminal Identity

Visually distinguish between terminal windows using emoji icons in your prompt.

```
🚀 ~/projects/api-server $
🌳 ~/projects/frontend $
⚙️ ~/infra $
```

## Quick Start

```bash
# Clone and install
git clone https://github.com/divySDM/terminal-icon-thing.git
cd terminal-icon-thing
./install.sh

# Restart your terminal - icons appear automatically!
```

The installer automatically configures your shell prompt.

## Features

- **Directory-based icons**: Each directory gets a consistent icon from a pool of ~170 distinct emojis
- **Same directory = same icon**: All terminals in the same directory show the same icon
- **Per-directory rules**: Configure specific icons for directories and projects
- **Manual override**: Set any identity for the current session
- **24 named identities**: rocket, tree, gear, star, and more
- **Custom identities**: Define your own icons
- **Works with zsh and bash**: Portable shell integration (bash 3.2+ compatible)
- **Fast**: Caches identity per directory, no slowdown

## How It Works

Icons are determined by hashing the directory path. This means:
- The same directory always shows the same icon
- Different directories get different icons (from a pool of 168 visually distinct emojis)
- No tracking or state required - purely computed from the path

## Usage

### List Available Identities

```bash
tid list
```

### Set Session Identity

```bash
tid set rocket
```

This sets `TID_IDENTITY=rocket` for the current session, overriding the directory-based icon.

### Clear Session Identity

```bash
tid unset
```

### Add Directory Rule

```bash
tid rule ~/projects/myapp rocket
```

Now whenever you `cd` into `~/projects/myapp` (or any subdirectory), you'll see the rocket emoji.

### View Current Identity

```bash
tid current
```

### List Rules

```bash
tid rules
```

### Remove a Rule

```bash
tid rule-remove ~/projects/myapp
```

## Configuration

Configuration files are stored in `~/.config/terminal-id/`:

- `rules.toml` - Directory-to-identity mappings
- `identities.toml` - Custom identity definitions

### Custom Identities

Create `~/.config/terminal-id/identities.toml`:

```toml
[myproject]
emoji = "🎯"
description = "My main project"

[prod]
emoji = "🔴"
description = "Production - be careful!"
```

### Directory Rules

Create `~/.config/terminal-id/rules.toml`:

```toml
"~/projects/api" = "rocket"
"~/projects/frontend" = "tree"
"~/work" = "work"
"~" = "home"
```

## Identity Resolution

Identity is resolved in this order:

1. **Environment variable**: `TID_IDENTITY` (set by `tid set`)
2. **Directory rules**: Exact or prefix match from `rules.toml`
3. **Git root rules**: Rules matching the git repository root
4. **Directory hash**: Consistent icon based on directory path

### Reserved Icons

Some icons are reserved for explicit rules only and never used for directory hashing:
- ⚠️ warning - Production or danger zones
- 🔒 lock - Security or authentication
- ✅ success - Completed or stable projects
- 🐛 bug - Debugging or bug fixes

This ensures these icons always signal intentional meaning when they appear.

## Built-in Identities

| Name | Emoji | Description |
|------|-------|-------------|
| rocket | 🚀 | Launch, deploy, or API projects |
| tree | 🌳 | Frontend, UI, or growth projects |
| gear | ⚙️ | Infrastructure, config, or tooling |
| bolt | ⚡ | Fast, performance, or scripts |
| star | ⭐ | Important or favorite projects |
| heart | ❤️ | Personal or passion projects |
| fire | 🔥 | Hot, active, or urgent work |
| cloud | ☁️ | Cloud, AWS, or remote systems |
| database | 🗄️ | Database or data projects |
| lock | 🔒 | Security or authentication |
| bug | 🐛 | Debugging or bug fixes |
| test | 🧪 | Testing or experiments |
| docs | 📚 | Documentation projects |
| home | 🏠 | Home directory or personal |
| work | 💼 | Work or professional projects |
| warning | ⚠️ | Production or danger zones |
| success | ✅ | Completed or stable projects |
| robot | 🤖 | AI, automation, or bots |
| gem | 💎 | Ruby or precious projects |
| python | 🐍 | Python projects |
| node | 📦 | Node.js or package projects |
| rust | 🦀 | Rust projects |
| go | 🐹 | Go/Golang projects |
| docker | 🐳 | Docker or container projects |

## Uninstall

```bash
./uninstall.sh
```

This removes the shell integration and installed files.

## Requirements

- Bash 3.2+ or Zsh (macOS compatible)
- Terminal with Unicode emoji support (most modern terminals)

## License

MIT
