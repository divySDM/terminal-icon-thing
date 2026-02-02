# Sprint 001: Terminal Identity Icons

## Overview

When working with multiple terminal windows, it's easy to lose track of which terminal is which, especially when they all look identical. This sprint creates a system for visually distinguishing terminal windows through iconography and color coding.

The solution will integrate into the shell prompt (zsh/bash) to display a unique visual identifier in the terminal. This approach is portable across terminal emulators, requires no special terminal support, and persists naturally with shell configuration.

The visual identity will consist of: an icon (Unicode/emoji or Nerd Font), a color scheme, and optionally a name. Identities can be assigned automatically based on the working directory, manually configured, or randomly assigned per session.

## Use Cases

1. **Multi-project development**: Developer has 5 terminals open for different projects. Each displays a unique icon (rocket for the API server, tree for frontend, gear for infra, etc.) making it easy to locate the right terminal.

2. **Server/local distinction**: Production SSH sessions show a red warning icon, staging shows yellow, local shows green. This prevents accidental commands in production.

3. **Named sessions**: User creates named terminal sessions ("build", "logs", "edit") with custom icons that persist across restarts.

4. **Directory-based identity**: Terminals automatically adopt the identity configured for their working directory (or git repository root).

## Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                          User's Terminal                            │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ PROMPT                                                       │   │
│  │                                                             │   │
│  │  [icon] [name] ~/projects/api-server                        │   │
│  │  └─ identity badge (emoji/nerd font + color)                │   │
│  │                                                             │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                         Configuration Flow                          │
│                                                                     │
│  ~/.config/terminal-id/                                             │
│  ├── config.toml          # Global settings                         │
│  ├── identities.toml      # Named identity definitions              │
│  └── rules.toml           # Auto-assignment rules                   │
│                                                                     │
│  Shell Integration:                                                 │
│  ~/.zshrc / ~/.bashrc                                              │
│    └── source terminal-id.sh                                       │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                         Identity Resolution                         │
│                                                                     │
│  1. Check if TID_IDENTITY env var is set (manual override)         │
│  2. Check rules.toml for directory/git-root match                  │
│  3. Fall back to session-based hash for consistent random ID       │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

## Implementation Plan

### Phase 1: Core Shell Integration (~40%)

**Files:**
- `src/terminal-id.sh` - Main shell integration script (zsh/bash compatible)
- `src/tid` - CLI tool for configuration (shell script)

**Tasks:**
- [ ] Create shell function that outputs identity badge for prompt
- [ ] Implement identity resolution logic (env var -> rules -> hash)
- [ ] Build prompt integration snippets for zsh and bash
- [ ] Create installation script that modifies shell rc files

### Phase 2: Configuration System (~30%)

**Files:**
- `src/tid-config` - Configuration management commands
- `examples/config.toml` - Example global config
- `examples/identities.toml` - Example identity definitions
- `examples/rules.toml` - Example auto-assignment rules

**Tasks:**
- [ ] Define TOML schema for configuration files
- [ ] Implement config file loading and parsing
- [ ] Create `tid set` command to manually set session identity
- [ ] Create `tid rule add` command to add directory rules
- [ ] Create `tid list` command to show available identities

### Phase 3: Identity Library (~20%)

**Files:**
- `src/identities/default.toml` - Built-in identity set

**Tasks:**
- [ ] Curate default set of ~20 identities with icons and colors
- [ ] Include categories: development, servers, tools, status
- [ ] Ensure icons work with both Unicode emoji and Nerd Fonts
- [ ] Add color schemes using ANSI 256 colors for compatibility

### Phase 4: Documentation & Polish (~10%)

**Files:**
- `README.md` - Project documentation
- `docs/INSTALL.md` - Installation guide
- `docs/CONFIGURATION.md` - Configuration reference

**Tasks:**
- [ ] Write installation instructions for zsh and bash
- [ ] Document all configuration options
- [ ] Add examples for common use cases
- [ ] Create demo GIF/screenshots

## Files Summary

| File | Action | Purpose |
|------|--------|---------|
| `src/terminal-id.sh` | Create | Main shell integration (prompt function, identity resolution) |
| `src/tid` | Create | CLI entry point for configuration commands |
| `src/tid-config` | Create | Configuration management helper functions |
| `src/identities/default.toml` | Create | Built-in identity definitions |
| `examples/config.toml` | Create | Example global configuration |
| `examples/identities.toml` | Create | Example custom identities |
| `examples/rules.toml` | Create | Example directory rules |
| `README.md` | Create | Project documentation |
| `docs/INSTALL.md` | Create | Installation guide |
| `docs/CONFIGURATION.md` | Create | Configuration reference |
| `install.sh` | Create | One-line installer script |

## Definition of Done

- [ ] Running `tid set rocket` displays rocket icon in prompt
- [ ] Identity persists within a terminal session
- [ ] `tid list` shows all available identities with previews
- [ ] Directory rules automatically assign identities
- [ ] Works in both zsh and bash
- [ ] README includes installation and basic usage
- [ ] At least 15 default identities defined

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Unicode/emoji rendering varies by terminal | High | Medium | Provide Nerd Font fallback option |
| Prompt slowdown from identity resolution | Medium | High | Cache identity per session, avoid file I/O on every prompt |
| Complex zsh/bash compatibility | Medium | Medium | Test on both shells, use POSIX-compatible constructs where possible |
| TOML parsing in shell is slow | Medium | Low | Use simple key=value parsing or optional Python helper |

## Security Considerations

- Configuration files should only be readable by owner (chmod 600)
- No execution of external code from config files
- Directory rules use exact match or glob patterns, no arbitrary code

## Dependencies

- None (this is the first sprint)
- Optional: Nerd Fonts for extended icon support
- Optional: Python 3 for advanced TOML parsing

## Open Questions

1. Should we support terminal title bar changes in addition to prompt? (Requires escape codes that vary by terminal)
2. How should SSH sessions be handled? Should identity carry over or reset?
3. Should we integrate with tmux/screen session names?
