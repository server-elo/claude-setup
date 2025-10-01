#!/bin/bash

# PreToolUse Hook - Executes before any tool is used
# Environment Variables Available:
# - TOOL_NAME: Name of the tool being used
# - FILE_PATH: Path to file being modified (for Edit/Write tools)
# - ARGUMENTS: Tool arguments

set -euo pipefail

# Log the tool usage
echo "$(date '+%Y-%m-%d %H:%M:%S') - PreToolUse: ${TOOL_NAME} ${ARGUMENTS:-}" >> ~/.claude/logs/tool-usage.log

# Validation for Edit and Write operations
if [[ "$TOOL_NAME" == "Edit" || "$TOOL_NAME" == "Write" ]]; then
    if [[ -n "${FILE_PATH:-}" ]]; then
        echo "🔍 Preparing to modify: $FILE_PATH"

        # Create backup before modification
        if [[ -f "$FILE_PATH" ]]; then
            BACKUP_DIR="$HOME/.claude/backups/$(date +%Y%m%d)"
            mkdir -p "$BACKUP_DIR"
            cp "$FILE_PATH" "$BACKUP_DIR/$(basename "$FILE_PATH").$(date +%H%M%S).bak"
            echo "✅ Backup created: $BACKUP_DIR/$(basename "$FILE_PATH").$(date +%H%M%S).bak"
        fi

        # Auto-format specific file types before editing
        case "${FILE_PATH##*.}" in
            js|jsx|ts|tsx)
                if command -v prettier >/dev/null 2>&1; then
                    echo "🎨 Auto-formatting JavaScript/TypeScript file..."
                    prettier --write "$FILE_PATH" 2>/dev/null || echo "⚠️ Prettier formatting failed"
                fi
                ;;
            py)
                if command -v black >/dev/null 2>&1; then
                    echo "🎨 Auto-formatting Python file..."
                    black "$FILE_PATH" 2>/dev/null || echo "⚠️ Black formatting failed"
                fi
                ;;
            go)
                if command -v gofmt >/dev/null 2>&1; then
                    echo "🎨 Auto-formatting Go file..."
                    gofmt -w "$FILE_PATH" 2>/dev/null || echo "⚠️ gofmt formatting failed"
                fi
                ;;
        esac
    fi
fi

# Validation for Bash commands
if [[ "$TOOL_NAME" == "Bash" ]]; then
    COMMAND="${ARGUMENTS:-}"
    echo "🔍 Preparing to execute: $COMMAND"

    # Warn about potentially dangerous commands
    if echo "$COMMAND" | grep -qE "(rm -rf|sudo|curl.*\|.*sh|wget.*\|.*sh)"; then
        echo "⚠️ WARNING: Potentially dangerous command detected!"
        echo "Command: $COMMAND"
        # In production, you might want to prompt for confirmation
    fi

    # Check if command modifies important files
    if echo "$COMMAND" | grep -qE "(\.bashrc|\.zshrc|\.profile|\.ssh|/etc/)"; then
        echo "⚠️ WARNING: Command may modify system configuration files!"
    fi
fi

# Performance monitoring
if [[ "$TOOL_NAME" == "Grep" || "$TOOL_NAME" == "Glob" ]]; then
    echo "🔍 Starting search operation: $TOOL_NAME"
    echo "$(date +%s)" > "/tmp/claude_search_start_$$"
fi

# Git status check for file modifications
if [[ "$TOOL_NAME" == "Edit" || "$TOOL_NAME" == "Write" ]] && command -v git >/dev/null 2>&1; then
    if git rev-parse --git-dir > /dev/null 2>&1; then
        echo "📊 Git status before modification:"
        git status --porcelain | head -5
    fi
fi

echo "✅ PreToolUse validation completed for $TOOL_NAME"