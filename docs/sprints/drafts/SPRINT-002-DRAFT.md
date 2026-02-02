# Sprint 002: Automatic Session Icons

## Overview

Currently, terminal identity falls back to directory-based hashing when no rules match. This means multiple terminals in the same directory display the same icon, making them indistinguishable.

This sprint changes the fallback behavior to assign a unique icon per terminal session. Each new terminal window/tab automatically gets a distinct icon from an expanded pool, allowing users to visually distinguish terminals even when working in the same directory. Reserved icons (like warning, lock, success) remain available only for explicit rules and manual assignment.

The session identity is determined once when the shell starts and persists for the entire session, regardless of directory changes. This gives each terminal a stable visual identity while still respecting explicit rules and manual overrides.

## Use Cases

1. **Multiple terminals, same project**: Developer has 3 terminals open in `~/projects/api` - one running the server, one for git, one for editing. Each terminal has a unique icon (🌺, 🎪, 🎭) making it easy to identify which is which.

2. **Reserved icons for danger zones**: The warning ⚠️ and lock 🔒 icons are never auto-assigned. They only appear when explicitly configured via rules (e.g., for production servers), so they always signal intentional caution.

3. **Fresh terminal, fresh icon**: User opens a new terminal tab - it immediately shows a unique icon without any configuration. No two terminals show the same auto-assigned icon (unless the pool is exhausted).

4. **Re-roll option**: User doesn't like their auto-assigned icon? `tid reroll` picks a new random one for the session.

## Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                   Identity Resolution (Updated)                      │
│                                                                     │
│  Priority order:                                                    │
│  1. TID_IDENTITY env var (manual override)                         │
│  2. Directory rules (rules.toml)                                    │
│  3. Git repository root rules                                       │
│  4. TID_SESSION_ICON env var (auto-assigned at shell start)   NEW  │
│                                                                     │
│  Fallback removed - session icon always assigned on shell start     │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                       Icon Categories                               │
│                                                                     │
│  RESERVED (24 named, manual/rule only):                            │
│    rocket, tree, gear, warning, lock, success, bug, fire...        │
│                                                                     │
│  AUTO-ASSIGN POOL (50+ icons):                                      │
│    🌸 🌺 🌻 🌷 🌹 🍀 🌵 🎋 🎍 🍄                                   │
│    🦋 🐝 🐞 🦊 🦁 🐯 🦄 🐙 🦑 🦐                                   │
│    🎪 🎭 🎨 🎯 🎲 🎳 🎸 🎺 🎻 🥁                                   │
│    🚂 🚀 ⛵ 🚁 🎠 🎡 🎢 ⛱️ 🏖️ 🏔️                                    │
│    💎 🔮 🎀 🎁 🏆 🎖️ 🏅 🎗️ 🧩 🪁                                   │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                    Session ID Generation                            │
│                                                                     │
│  On shell start:                                                   │
│  1. Check if TID_SESSION_ICON already set (inherited subshell)     │
│  2. If not, generate session ID from: $$ (PID) + $RANDOM + time    │
│  3. Hash session ID to pick from auto-assign pool                  │
│  4. Set TID_SESSION_ICON env var                                   │
│                                                                     │
│  Result: Each terminal process tree gets a unique icon             │
└─────────────────────────────────────────────────────────────────────┘
```

## Implementation Plan

### Phase 1: Expanded Icon Pool (~30%)

**Files:**
- `src/terminal-id.sh` - Add auto-assign pool, separate from named identities
- `src/tid` - Update `tid list` to show both categories

**Tasks:**
- [ ] Define `_TID_AUTO_POOL` with 50+ unique emojis
- [ ] Mark existing named identities as "reserved" (documentation)
- [ ] Update `tid list` to show "Reserved" and "Auto-assign pool" sections

### Phase 2: Session Icon Assignment (~40%)

**Files:**
- `src/terminal-id.sh` - Session ID generation and assignment

**Tasks:**
- [ ] Generate unique session ID on shell start (PID + random + time)
- [ ] Hash session ID to index into auto-assign pool
- [ ] Set `TID_SESSION_ICON` env var if not already set
- [ ] Update `__tid_prompt()` to use session icon as final fallback
- [ ] Ensure session icon persists across directory changes

### Phase 3: CLI Updates (~20%)

**Files:**
- `src/tid` - Add `reroll` command, update `current`

**Tasks:**
- [ ] Add `tid reroll` command to re-assign session icon
- [ ] Update `tid current` to show session icon source
- [ ] Update help text

### Phase 4: Documentation (~10%)

**Files:**
- `README.md` - Update with session icon behavior
- `docs/CONFIGURATION.md` - Document reserved vs auto-assign

**Tasks:**
- [ ] Document automatic session assignment
- [ ] Document reserved icons concept
- [ ] Add examples for multi-terminal workflows

## Files Summary

| File | Action | Purpose |
|------|--------|---------|
| `src/terminal-id.sh` | Modify | Add auto-assign pool, session ID generation, update resolution |
| `src/tid` | Modify | Add `reroll` command, update `list` and `current` |
| `README.md` | Modify | Document session icons |
| `docs/CONFIGURATION.md` | Modify | Document reserved vs auto-assign pools |

## Definition of Done

- [ ] Opening 5 new terminals shows 5 different icons (without configuration)
- [ ] Reserved icons (warning, lock, success, etc.) never appear via auto-assignment
- [ ] `tid reroll` assigns a new random session icon
- [ ] `tid current` shows "session (auto-assigned)" as source when applicable
- [ ] `tid list` shows Reserved and Auto-assign sections
- [ ] Session icon persists when changing directories
- [ ] Subshells inherit parent's session icon
- [ ] At least 50 icons in auto-assign pool
- [ ] Works in both zsh and bash

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| PID reuse causes icon collision | Low | Low | Add timestamp/random to session ID hash |
| Too many similar-looking emojis | Medium | Medium | Curate pool carefully, test visual distinctiveness |
| Subshell icon inheritance issues | Medium | Medium | Check TID_SESSION_ICON before assigning |
| Performance impact from larger pool | Low | Low | Pool is just a string, no lookup needed |

## Security Considerations

- Session ID uses PID + random, not cryptographically sensitive
- No file I/O for session assignment (env var only)
- Existing rule-based security (warning for prod) unchanged

## Dependencies

- Sprint 001 (completed)
- No external dependencies

## Open Questions

1. Should we track "used" session icons to guarantee uniqueness? (Probably overkill)
2. Should the auto-assign pool be configurable? (Future sprint)
