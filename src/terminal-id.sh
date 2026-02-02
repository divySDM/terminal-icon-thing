#!/bin/bash
# Terminal Identity - Visual terminal differentiation through emoji icons
# Source this file in your .zshrc or .bashrc
# Compatible with bash 3.2+ and zsh

# Configuration paths
TID_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/terminal-id"
TID_DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/terminal-id"
TID_RULES_FILE="$TID_CONFIG_DIR/rules.toml"
TID_IDENTITIES_FILE="$TID_CONFIG_DIR/identities.toml"

# Cache for performance (avoid re-reading files on every prompt)
_TID_CACHE_DIR=""
_TID_CACHE_IDENTITY=""

# Default identities - name|emoji pairs
_TID_DEFAULTS="
bolt|⚡
bug|🐛
cloud|☁️
database|🗄️
docker|🐳
docs|📚
fire|🔥
gear|⚙️
gem|💎
go|🐹
heart|❤️
home|🏠
lock|🔒
node|📦
python|🐍
robot|🤖
rocket|🚀
rust|🦀
star|⭐
success|✅
test|🧪
tree|🌳
warning|⚠️
work|💼
"

# Fallback emojis for hash-based assignment
_TID_FALLBACKS="🔵 🟢 🟡 🟠 🔴 🟣 ⚪ 🟤 💠 🔷 🔶 🔸 🔹 🌐 💫 ✨"

# Get emoji for an identity name
__tid_get_emoji() {
    local name="$1"
    local emoji

    # Check default identities
    emoji=$(echo "$_TID_DEFAULTS" | while IFS='|' read -r n e; do
        if [ "$n" = "$name" ]; then
            echo "$e"
            break
        fi
    done)

    if [ -n "$emoji" ]; then
        echo "$emoji"
        return 0
    fi

    # Check custom identities file
    if [ -f "$TID_IDENTITIES_FILE" ]; then
        local in_section=0
        while IFS= read -r line; do
            case "$line" in
                \["$name"\])
                    in_section=1
                    ;;
                \[*\])
                    in_section=0
                    ;;
                emoji\ =\ \"*\"|emoji=\"*\")
                    if [ "$in_section" = "1" ]; then
                        emoji="${line#*\"}"
                        emoji="${emoji%\"*}"
                        echo "$emoji"
                        return 0
                    fi
                    ;;
            esac
        done < "$TID_IDENTITIES_FILE"
    fi

    return 1
}

# Get identity from directory rules
__tid_get_rule_identity() {
    local dir="$1"

    if [ ! -f "$TID_RULES_FILE" ]; then
        return 1
    fi

    while IFS= read -r line; do
        # Skip comments and empty lines
        case "$line" in
            \#*|"") continue ;;
        esac

        # Parse "path" = "identity"
        case "$line" in
            \"*\"\ =\ \"*\"|\"*\"=\"*\")
                local rule_path="${line#\"}"
                rule_path="${rule_path%%\"*}"
                local rule_identity="${line##*= \"}"
                rule_identity="${rule_identity%\"*}"

                # Expand ~
                case "$rule_path" in
                    \~*) rule_path="$HOME${rule_path#\~}" ;;
                esac

                # Check for exact match or prefix match
                case "$dir" in
                    "$rule_path"|"$rule_path"/*)
                        echo "$rule_identity"
                        return 0
                        ;;
                esac
                ;;
        esac
    done < "$TID_RULES_FILE"

    return 1
}

# Get git root directory
__tid_get_git_root() {
    git rev-parse --show-toplevel 2>/dev/null
}

# Hash a string to get a consistent index (portable version using cksum)
__tid_hash_to_index() {
    local str="$1"
    local max="$2"
    local hash

    hash=$(echo "$str" | cksum | cut -d' ' -f1)
    echo $((hash % max))
}

# Resolve identity for current context
__tid_resolve_identity() {
    local dir="${PWD}"

    # 1. Check TID_IDENTITY env var (manual override)
    if [ -n "$TID_IDENTITY" ]; then
        echo "$TID_IDENTITY"
        return 0
    fi

    # 2. Check directory rules
    local rule_identity
    rule_identity=$(__tid_get_rule_identity "$dir")
    if [ -n "$rule_identity" ]; then
        echo "$rule_identity"
        return 0
    fi

    # 3. Check git root rules
    local git_root
    git_root=$(__tid_get_git_root)
    if [ -n "$git_root" ] && [ "$git_root" != "$dir" ]; then
        rule_identity=$(__tid_get_rule_identity "$git_root")
        if [ -n "$rule_identity" ]; then
            echo "$rule_identity"
            return 0
        fi
    fi

    # 4. No match - return empty (will use fallback)
    return 1
}

# Get the prompt emoji for current context
__tid_prompt() {
    local dir="${PWD}"

    # Use cache if directory hasn't changed
    if [ "$dir" = "$_TID_CACHE_DIR" ] && [ -n "$_TID_CACHE_IDENTITY" ]; then
        echo "$_TID_CACHE_IDENTITY"
        return
    fi

    local identity emoji

    # Try to resolve named identity
    identity=$(__tid_resolve_identity)

    if [ -n "$identity" ]; then
        emoji=$(__tid_get_emoji "$identity")
        if [ -n "$emoji" ]; then
            _TID_CACHE_DIR="$dir"
            _TID_CACHE_IDENTITY="$emoji"
            echo "$emoji"
            return
        fi
    fi

    # Fallback: hash-based consistent random emoji
    local hash_source="${dir}"
    local git_root
    git_root=$(__tid_get_git_root)
    if [ -n "$git_root" ]; then
        hash_source="$git_root"
    fi

    local idx
    idx=$(__tid_hash_to_index "$hash_source" 16)
    emoji=$(echo "$_TID_FALLBACKS" | cut -d' ' -f$((idx + 1)))

    _TID_CACHE_DIR="$dir"
    _TID_CACHE_IDENTITY="$emoji"
    echo "$emoji"
}

# Clear the identity cache (call after cd or tid set)
__tid_clear_cache() {
    _TID_CACHE_DIR=""
    _TID_CACHE_IDENTITY=""
}

# Hook into cd to clear cache
if [ -n "$ZSH_VERSION" ]; then
    # Zsh: use chpwd hook
    autoload -Uz add-zsh-hook 2>/dev/null || true
    if type add-zsh-hook &>/dev/null; then
        add-zsh-hook chpwd __tid_clear_cache
    fi
elif [ -n "$BASH_VERSION" ]; then
    # Bash: wrap cd using PROMPT_COMMAND to check for directory change
    _TID_LAST_PWD="$PWD"
    __tid_check_dir_change() {
        if [ "$PWD" != "$_TID_LAST_PWD" ]; then
            __tid_clear_cache
            _TID_LAST_PWD="$PWD"
        fi
    }

    # Add to PROMPT_COMMAND if not already there
    case "$PROMPT_COMMAND" in
        *__tid_check_dir_change*) ;;
        *)
            if [ -n "$PROMPT_COMMAND" ]; then
                PROMPT_COMMAND="__tid_check_dir_change; $PROMPT_COMMAND"
            else
                PROMPT_COMMAND="__tid_check_dir_change"
            fi
            ;;
    esac
fi

# Prompt integration helpers
tid_zsh_prompt() {
    # Returns string suitable for PROMPT variable
    echo '$(__tid_prompt) '
}

tid_bash_prompt() {
    # Returns string suitable for PS1 variable
    echo '$(__tid_prompt) '
}
