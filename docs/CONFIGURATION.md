# Configuration Reference

Terminal Identity uses TOML configuration files stored in `~/.config/terminal-id/`.

## File Locations

| File | Purpose |
|------|---------|
| `~/.config/terminal-id/rules.toml` | Directory-to-identity mappings |
| `~/.config/terminal-id/identities.toml` | Custom identity definitions |
| `~/.config/terminal-id/config.toml` | Global settings (optional) |

## rules.toml

Maps directories to identity names.

### Format

```toml
"path" = "identity-name"
```

### Examples

```toml
# Project directories
"~/projects/api-server" = "rocket"
"~/projects/frontend" = "tree"
"~/projects/docs" = "docs"

# Work directories
"~/work" = "work"
"~/work/client-a" = "star"

# Home
"~" = "home"

# Dangerous zones
"/etc" = "warning"
```

### Path Matching

- Paths are expanded (`~` becomes your home directory)
- Matching is prefix-based: `~/projects/api` matches `~/projects/api/src/`
- More specific paths take precedence
- Git repository roots are also checked

### Managing Rules

```bash
# Add a rule
tid rule ~/projects/myapp rocket

# List all rules
tid rules

# Remove a rule
tid rule-remove ~/projects/myapp
```

## identities.toml

Define custom identities in addition to the 24 built-in ones.

### Format

```toml
[identity-name]
emoji = "🎯"
description = "Optional description"
```

### Examples

```toml
# Custom project identities
[myproject]
emoji = "🎯"
description = "My main project"

[client-a]
emoji = "🏢"
description = "Client A work"

# Environment identities
[prod]
emoji = "🔴"
description = "Production - be careful!"

[staging]
emoji = "🟡"
description = "Staging environment"

# Language-specific
[elixir]
emoji = "💧"
description = "Elixir projects"
```

### Notes

- Custom identities appear in `tid list`
- You can override built-in identities by using the same name
- Keep emoji to a single character for best prompt alignment

## config.toml

Global settings (optional, not required for basic use).

### Example

```toml
# Default identity when no rules match
default_identity = ""

# Update terminal title bar (experimental)
update_title = false

# Cache timeout in seconds (0 = indefinite)
cache_timeout = 0
```

## Environment Variables

### TID_IDENTITY

Override identity for current session:

```bash
export TID_IDENTITY=rocket
```

Set via the `tid set` command:

```bash
tid set rocket  # Sets TID_IDENTITY
tid unset       # Removes TID_IDENTITY
```

### XDG Directories

Terminal Identity respects XDG Base Directory specification:

- `XDG_CONFIG_HOME` - Config files (default: `~/.config`)
- `XDG_DATA_HOME` - Data files (default: `~/.local/share`)

## Identity Resolution Order

When determining which identity to display:

1. **TID_IDENTITY** environment variable (highest priority)
2. **Directory rules** matching current working directory
3. **Git root rules** matching the repository root
4. **Hash fallback** - consistent colored circle based on path

## Built-in Identities

These are always available:

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

## Fallback Colors

When no identity matches, a consistent colored circle is assigned based on the directory path hash:

🔵 🟢 🟡 🟠 🔴 🟣 ⚪ 🟤 💠 🔷 🔶 🔸 🔹 🌐 💫 ✨

The same directory will always get the same fallback color.
