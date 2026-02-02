# Sprint 001: Terminal Identity Icons

## Overview

When working with multiple terminal windows, it's easy to lose track of which terminal is which, especially when they all look identical. This sprint creates a system for visually distinguishing terminal windows through Unicode emoji icons integrated directly into the shell prompt.

The solution will integrate into the shell prompt (zsh/bash) to display a unique visual identifier. This approach is portable across terminal emulators, requires no special terminal support, and persists naturally with shell configuration. The primary assignment mechanism will be per-directory, so terminals working in the same project automatically display the same identity.

The visual identity will consist of: a Unicode emoji icon, an optional color accent, and optionally a name. Identities are assigned automatically based on the working directory (or git repository root), with the ability to manually override.

## Use Cases

1. **Multi-project development**: Developer has 5 terminals open for different projects. Each displays a unique emoji based on the directory (rocket for the API server, tree for frontend, gear for infra) making it easy to locate the right terminal at a glance.

2. **Server/local distinction**: Production SSH sessions show a red warning icon, staging shows yellow, local shows green. This prevents accidental commands in the wrong environment.

3. **Directory-based identity**: Terminals automatically adopt the identity configured for their working directory or git repository root. Moving to a different project automatically changes the icon.

4. **Manual override**: User can manually set a session identity with `tid set rocket` for special cases that don't match directory rules.

## Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                          User's Terminal                            │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ PROMPT                                                       │   │
│  │                                                             │   │
│  │  🚀 ~/projects/api-server $                                 │   │
│  │  └─ identity emoji (auto-assigned from directory rule)      │   │
│  │                                                             │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                         Configuration Files                         │
│                                                                     │
│  ~/.config/terminal-id/                                             │
│  ├── config.toml          # Global settings                         │
│  ├── identities.toml      # Named identity definitions              │
│  └── rules.toml           # Directory -> identity mappings          │
│                                                                     │
│  Shell Integration:                                                 │
│  ~/.zshrc / ~/.bashrc                                              │
│    └── source ~/.local/share/terminal-id/terminal-id.sh           │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                         Identity Resolution                         │
│                                                                     │
│  Order of precedence:                                              │
│  1. TID_IDENTITY env var (manual override for session)             │
│  2. Directory rules in rules.toml (exact or glob match)            │
│  3. Git repository root rules                                       │
│  4. Hash-based fallback (consistent random icon per directory)     │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

## Implementation Plan

### Phase 1: Core Shell Integration (~40%)

**Files:**
- `src/terminal-id.sh` - Main shell integration script (zsh/bash compatible)
- `src/tid` - CLI tool for configuration (shell script)

**Tasks:**
- [ ] Create shell function `__tid_prompt` that outputs emoji for current context
- [ ] Implement identity resolution logic (env var -> rules -> git root -> hash)
- [ ] Build prompt integration for zsh (PROMPT variable)
- [ ] Build prompt integration for bash (PS1 variable)
- [ ] Create installation script that adds source line to shell rc files

### Phase 2: Configuration System (~30%)

**Files:**
- `src/tid-config` - Configuration management helper functions
- `examples/config.toml` - Example global config
- `examples/identities.toml` - Example identity definitions
- `examples/rules.toml` - Example directory rules

**Tasks:**
- [ ] Define simple TOML schema for configuration
- [ ] Implement config file loading (shell-based parsing)
- [ ] Create `tid set <identity>` command to set session identity
- [ ] Create `tid rule <path> <identity>` command to add directory rules
- [ ] Create `tid list` command to show available identities with preview
- [ ] Create `tid current` command to show active identity

### Phase 3: Identity Library (~20%)

**Files:**
- `src/identities/default.toml` - Built-in identity set with Unicode emoji

**Tasks:**
- [ ] Curate default set of ~20 identities using Unicode emoji
- [ ] Categories: projects (rocket, tree, gear), status (warning, success), general (star, heart, bolt)
- [ ] Each identity has: name, emoji, optional description
- [ ] Test emoji rendering on common terminals (iTerm2, Terminal.app, VS Code)

### Phase 4: Documentation & Polish (~10%)

**Files:**
- `README.md` - Project documentation with quick start
- `docs/INSTALL.md` - Detailed installation guide
- `docs/CONFIGURATION.md` - Configuration reference

**Tasks:**
- [ ] Write quick start (3 commands to get running)
- [ ] Write installation instructions for zsh and bash
- [ ] Document all configuration options
- [ ] Add examples for common use cases
- [ ] Include troubleshooting section

## Files Summary

| File | Action | Purpose |
|------|--------|---------|
| `src/terminal-id.sh` | Create | Main shell integration (prompt function, identity resolution) |
| `src/tid` | Create | CLI entry point for all commands |
| `src/tid-config` | Create | Configuration management functions |
| `src/identities/default.toml` | Create | Built-in emoji identity definitions |
| `examples/config.toml` | Create | Example global configuration |
| `examples/identities.toml` | Create | Example custom identities |
| `examples/rules.toml` | Create | Example directory rules |
| `README.md` | Create | Project documentation with quick start |
| `docs/INSTALL.md` | Create | Detailed installation guide |
| `docs/CONFIGURATION.md` | Create | Configuration reference |
| `install.sh` | Create | One-line installer script |

## Definition of Done

- [ ] Running `tid set rocket` displays rocket emoji in prompt
- [ ] `cd`-ing between directories with different rules changes the icon automatically
- [ ] `tid list` shows all available identities with emoji preview
- [ ] `tid rule ~/projects/myapp rocket` creates a persistent directory rule
- [ ] Works in both zsh and bash
- [ ] README includes 3-command quick start
- [ ] At least 15 default emoji identities defined
- [ ] Identity persists within a terminal session when manually set

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Emoji rendering varies by terminal/font | Medium | Medium | Test on common terminals, document requirements, provide fallback option |
| Prompt slowdown from directory rule checking | Medium | High | Cache identity per directory, avoid re-parsing config on every prompt |
| Complex zsh/bash compatibility | Medium | Medium | Test on both shells, use POSIX-compatible constructs |
| Config file parsing in pure shell is limited | Low | Low | Keep TOML schema simple, line-based parsing |

## Security Considerations

- Configuration files use standard XDG paths with user ownership
- No execution of external code from config files
- Directory rules use glob patterns, not arbitrary code
- Installer only modifies shell rc files with explicit user confirmation

## Dependencies

- None (first sprint)
- Requires: Terminal with Unicode emoji support (most modern terminals)
- Requires: zsh or bash

## Notes from Planning

**Confirmed design decisions:**
- Shell prompt integration (not title bar or overlay)
- Per-directory automatic assignment as the default mechanism
- Unicode emoji as the icon format (no Nerd Fonts required)
