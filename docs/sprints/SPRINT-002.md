# Sprint 002: Automatic Session Icons

## Overview

Currently, terminal identity falls back to directory-based hashing when no rules match. This means multiple terminals in the same directory display the same icon, making them indistinguishable.

This sprint changes the fallback behavior to assign a unique icon per terminal session. Each new terminal window/tab automatically gets a distinct icon from an expanded pool (~70 icons), allowing users to visually distinguish terminals even when working in the same directory. A small set of status icons (warning, lock, success, bug) are reserved for explicit rules only, while all other icons (including the original named identities like rocket, tree, gear) are available for auto-assignment.

The session identity is determined once when the shell starts and persists for the entire session, regardless of directory changes. Subshells inherit the parent's session icon.

## Use Cases

1. **Multiple terminals, same project**: Developer has 3 terminals open in `~/projects/api` - one running the server, one for git, one for editing. Each terminal has a unique icon (🚀, 🌺, 🎭) making it easy to identify which is which.

2. **Reserved icons for danger zones**: Status icons like warning ⚠️, lock 🔒, success ✅, and bug 🐛 are never auto-assigned. They only appear when explicitly configured via rules, so they always signal intentional meaning.

3. **Fresh terminal, fresh icon**: User opens a new terminal tab - it immediately shows a unique icon without any configuration.

4. **Subshell inheritance**: Running a script or opening a subshell keeps the same icon as the parent terminal for visual consistency.

5. **Re-roll option**: User doesn't like their auto-assigned icon? `tid reroll` picks a new random one for the session.

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
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                       Icon Categories                               │
│                                                                     │
│  RESERVED (status icons only, never auto-assigned):                │
│    warning ⚠️, lock 🔒, success ✅, bug 🐛                          │
│                                                                     │
│  AUTO-ASSIGN POOL (~70 icons):                                      │
│    - All other named identities (rocket, tree, gear, etc.)         │
│    - New expanded set:                                              │
│      🌸 🌺 🌻 🌷 🌹 🍀 🌵 🎋 🎍 🍄 (nature)                        │
│      🦋 🐝 🐞 🦊 🦁 🐯 🦄 🐙 🦑 🦐 (creatures)                     │
│      🎪 🎭 🎨 🎯 🎲 🎳 🎸 🎺 🎻 🥁 (entertainment)                 │
│      🚂 ⛵ 🚁 🎠 🎡 🎢 ⛱️ 🏖️ 🏔️ 🗻 (travel)                        │
│      💎 🔮 🎀 🎁 🏆 🎖️ 🧩 🪁 🎈 🎏 (objects)                       │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                    Session Icon Assignment                          │
│                                                                     │
│  On shell start:                                                   │
│  1. Check if TID_SESSION_ICON already set (inherited from parent)  │
│  2. If not, generate session ID: $$ (PID) + $RANDOM + timestamp    │
│  3. Hash session ID to pick from auto-assign pool                  │
│  4. Export TID_SESSION_ICON for subshells to inherit               │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

## Implementation Plan

### Phase 1: Expanded Icon Pool (~25%)

**Files:**
- `src/terminal-id.sh` - Add expanded auto-assign pool
- `src/tid` - Update list display

**Tasks:**
- [ ] Define `_TID_AUTO_POOL` with ~70 unique emojis (named + new)
- [ ] Define `_TID_RESERVED` with status icons (warning, lock, success, bug)
- [ ] Update `tid list` to indicate which icons are reserved

### Phase 2: Session Icon Assignment (~40%)

**Files:**
- `src/terminal-id.sh` - Session ID generation and assignment logic

**Tasks:**
- [ ] Check for existing `TID_SESSION_ICON` env var (subshell inheritance)
- [ ] Generate unique session ID from PID + RANDOM + timestamp
- [ ] Hash session ID to index into auto-assign pool
- [ ] Export `TID_SESSION_ICON` for child processes
- [ ] Update `__tid_prompt()` to use `TID_SESSION_ICON` as final fallback
- [ ] Remove old directory-hash fallback

### Phase 3: CLI Updates (~25%)

**Files:**
- `src/tid` - Add `reroll` command, update `current` and `list`

**Tasks:**
- [ ] Add `tid reroll` command to re-assign session icon
- [ ] Update `tid current` to show "session (auto-assigned)" source
- [ ] Update `tid list` to show reserved vs auto-assign
- [ ] Update help text with new commands

### Phase 4: Documentation (~10%)

**Files:**
- `README.md` - Update with session icon behavior
- `docs/CONFIGURATION.md` - Document reserved icons

**Tasks:**
- [ ] Document automatic session assignment in README
- [ ] Document reserved vs auto-assign concept
- [ ] Update examples

## Files Summary

| File | Action | Purpose |
|------|--------|---------|
| `src/terminal-id.sh` | Modify | Session ID generation, expanded pool, inheritance |
| `src/tid` | Modify | Add `reroll`, update `list` and `current` |
| `README.md` | Modify | Document session icons |
| `docs/CONFIGURATION.md` | Modify | Document reserved icons |

## Definition of Done

- [ ] Opening 5 new terminals shows 5 different icons (without configuration)
- [ ] Reserved icons (warning, lock, success, bug) never appear via auto-assignment
- [ ] `tid reroll` assigns a new random session icon
- [ ] `tid current` shows "session (auto-assigned)" when applicable
- [ ] `tid list` indicates reserved icons
- [ ] Session icon persists when changing directories
- [ ] Subshells inherit parent's session icon
- [ ] At least 60 icons in auto-assign pool
- [ ] Works in both zsh and bash

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| PID reuse causes icon collision | Low | Low | Add RANDOM and timestamp to session ID |
| Too many similar-looking emojis | Medium | Medium | Curate pool for visual distinctiveness |
| Performance from larger pool | Low | Low | Single string lookup, no impact |

## Security Considerations

- Session ID uses PID + random, not cryptographically sensitive
- No file I/O for session assignment (env var only)
- Reserved icons ensure explicit rules maintain their meaning

## Dependencies

- Sprint 001 (completed)

## Notes from Planning

**Confirmed design decisions:**
- Expand pool, no strict reserved concept - only status icons (warning, lock, success, bug) are reserved
- Named identities (rocket, tree, etc.) available for auto-assignment
- Subshells inherit parent's session icon
- Session icon persists across directory changes within same terminal
