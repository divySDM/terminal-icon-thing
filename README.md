# Terminal Identity

Visually distinguish between terminal windows using emoji icons in your prompt.

```
🚀 ~/projects/api-server $
🌳 ~/projects/frontend $
⚙️ ~/infra $
```

## Quick Start

```bash
# 1. Clone and install
git clone <repo-url> terminal-id
cd terminal-id
./install.sh

# 2. Add to your prompt (in ~/.zshrc or ~/.bashrc)
PROMPT='$(__tid_prompt) '$PROMPT    # zsh
PS1='$(__tid_prompt) '$PS1          # bash

# 3. Restart terminal and try it out
tid list                            # See available identities
tid set rocket                      # Set session identity
tid rule ~/projects/myapp star      # Set directory rule
```

## Features

- **Automatic session icons**: Each terminal automatically gets a unique icon from a pool of ~80 emojis
- **Per-directory rules**: Configure specific icons for directories and projects
- **Manual override**: Set any identity for the current session
- **24 named identities**: rocket, tree, gear, star, and more
- **Custom identities**: Define your own icons
- **Works with zsh and bash**: Portable shell integration (bash 3.2+ compatible)
- **Fast**: Caches identity per directory, no slowdown

## Usage

### List Available Identities

```bash
tid list
```

Output:
```
Available identities:

  bolt         ⚡  Fast, performance, or scripts
  bug          🐛  Debugging or bug fixes
  cloud        ☁️   Cloud, AWS, or remote systems
  docker       🐳  Docker or container projects
  docs         📚  Documentation projects
  ...
```

### Set Session Identity

```bash
tid set rocket
```

This sets `TID_IDENTITY=rocket` for the current session.

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
- `config.toml` - Global settings

See the `examples/` directory for sample configurations.

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
4. **Session icon**: Unique icon auto-assigned when terminal starts (from pool of ~80 emojis)

### Session Icons

Each terminal automatically gets a unique icon when it starts. This makes it easy to distinguish between multiple terminals working in the same directory.

```bash
# Terminal 1: 🚀 ~/projects/api $
# Terminal 2: 🌺 ~/projects/api $
# Terminal 3: 🎭 ~/projects/api $
```

- Session icons persist for the life of the terminal (unchanged by `cd`)
- Subshells inherit the parent's session icon
- Use `tid reroll` to get a new random session icon
- Use `tid current` to see your current icon and its source

### Reserved Icons

Some icons are reserved for explicit rules only and never auto-assigned:
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

### Re-rolling Session Icon

Don't like your auto-assigned icon? Get a new one:

```bash
tid reroll
# New session icon: 🎪
# Run this command to apply:
#   export TID_SESSION_ICON='🎪'
```

## Requirements

- Bash 3.2+ or Zsh (macOS compatible)
- Terminal with Unicode emoji support (most modern terminals)

## Troubleshooting

### Emoji not showing

- Ensure your terminal supports Unicode emoji
- Try a different terminal (iTerm2, Terminal.app, VS Code terminal all work)
- Check your font supports emoji

### Identity not changing on cd

- Run `tid current` to see what identity is being resolved
- Check that your rule path is correct with `tid rules`
- Make sure you've restarted your shell after installation

### Prompt is slow

- The identity is cached per directory, so it should only resolve once
- If still slow, check that `TID_CONFIG_DIR` files aren't very large

## License

MIT
