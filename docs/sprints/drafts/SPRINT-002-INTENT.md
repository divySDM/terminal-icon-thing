# Sprint 002 Intent: Automatic Session Icons

## Seed

Automatically assign a distinct icon to each terminal session. Reserve a subset of icons for special cases (manual rules, production warnings, etc.) and expand the overall icon set for automatic assignment.

## Context

- **Sprint 001 completed**: Basic terminal identity system with 24 named identities, directory rules, and hash-based fallback
- **Current behavior**: Fallback icons are based on directory hash - same directory = same icon, so multiple terminals in same directory look identical
- **Gap**: No way to distinguish multiple terminals working in the same directory
- **Opportunity**: Assign unique icons per terminal session, not per directory

## Recent Sprint Context

**Sprint 001 - Terminal Identity Icons (Completed)**:
- Created `tid` CLI and `terminal-id.sh` shell integration
- 24 named identities (rocket, tree, gear, etc.)
- Directory rules via `rules.toml`
- Hash-based fallback using 16 colored circles
- Works with bash 3.2+ and zsh

## Relevant Codebase Areas

- `src/terminal-id.sh:180-220` - `__tid_prompt()` function and fallback logic
- `src/terminal-id.sh:45` - `_TID_FALLBACKS` - current 16 fallback emojis
- `src/tid:16-41` - `TID_DEFAULTS` - 24 named identities
- Identity resolution order: TID_IDENTITY env -> directory rules -> git root rules -> hash fallback

## Constraints

- Must remain bash 3.2+ compatible (macOS default)
- Must not break existing directory rules or manual `tid set` functionality
- Reserved icons should be clearly separated from auto-assignment pool
- Session identity must persist for the life of the terminal (survive cd)

## Success Criteria

- Each new terminal gets a unique icon automatically (without configuration)
- Opening 5 terminals shows 5 different icons
- Reserved icons (warning, lock, etc.) never auto-assigned
- Expanded icon pool (~50+) for more variety
- `tid current` shows session assignment source

## Open Questions

1. How to generate a unique session ID? (PID, random, TTY?)
2. Should session icons persist across shell restarts in same terminal window?
3. What icons should be reserved vs. available for auto-assignment?
4. Should there be a way to "re-roll" the session icon?
