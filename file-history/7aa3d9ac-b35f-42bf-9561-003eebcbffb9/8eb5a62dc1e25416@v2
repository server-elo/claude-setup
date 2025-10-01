#!/bin/bash
# Analyze user patterns to help Claude learn

set -euo pipefail

MEMORY_DIR="$HOME/.claude/memory"
mkdir -p "$MEMORY_DIR"

echo "📊 Analyzing usage patterns..."

# Analyze shell history
if [[ -f "$HOME/.zsh_history" ]]; then
    echo "🔍 Shell command patterns..."

    # Most used commands
    cat ~/.zsh_history | cut -d';' -f2- | awk '{print $1}' | sort | uniq -c | sort -rn | head -20 > "$MEMORY_DIR/top-commands.txt"

    # Command sequences (workflows)
    cat ~/.zsh_history | cut -d';' -f2- | awk '{print $1}' > /tmp/cmd_sequence
    paste - - < /tmp/cmd_sequence | sort | uniq -c | sort -rn | head -20 > "$MEMORY_DIR/command-sequences.txt"
fi

# Analyze git usage patterns
echo "🔍 Git workflow patterns..."
if command -v git >/dev/null; then
    # Find all git repos
    find "$HOME/Desktop" "$HOME/Documents" -name ".git" -type d 2>/dev/null | while read -r gitdir; do
        repo=$(dirname "$gitdir")
        cd "$repo"

        # Commit frequency
        git log --oneline --since="30 days ago" 2>/dev/null | wc -l

        # Most changed files
        git log --since="30 days ago" --name-only --pretty=format: 2>/dev/null | sort | uniq -c | sort -rn | head -10

    done > "$MEMORY_DIR/git-patterns.txt"
fi

# Analyze Claude usage
if [[ -f "$HOME/.claude/history.jsonl" ]]; then
    echo "🔍 Claude usage patterns..."

    # Count interactions by type
    cat "$HOME/.claude/history.jsonl" | jq -r '.type' 2>/dev/null | sort | uniq -c > "$MEMORY_DIR/interaction-types.txt" || true

    # Extract common user phrases
    cat "$HOME/.claude/history.jsonl" | jq -r '.messages[]?.content' 2>/dev/null | head -100 > "$MEMORY_DIR/recent-requests.txt" || true
fi

# Analyze project structure preferences
echo "🔍 Project structure patterns..."
find "$HOME/Desktop" "$HOME/Documents" -name "package.json" -o -name "requirements.txt" -o -name "go.mod" 2>/dev/null | while read -r manifest; do
    dirname $(dirname "$manifest")
done | sort | uniq > "$MEMORY_DIR/active-projects.txt"

echo "✅ Pattern analysis complete!"
echo "📍 Results: $MEMORY_DIR"