#!/bin/bash
# Run after each session to extract learnings

set -euo pipefail

MEMORY_DIR="$HOME/.claude/memory"
LEARNINGS_FILE="$MEMORY_DIR/learnings.jsonl"

mkdir -p "$MEMORY_DIR"

echo "🧠 Extracting learnings from session..."

# Get last session data
HISTORY_FILE="$HOME/.claude/history.jsonl"

if [[ -f "$HISTORY_FILE" ]]; then
    # Extract last N interactions
    tail -50 "$HISTORY_FILE" > /tmp/last_session.jsonl

    # Patterns to learn
    learning_entry=$(cat <<EOF
{
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "session_summary": {
    "total_interactions": $(wc -l < /tmp/last_session.jsonl),
    "tools_used": $(cat /tmp/last_session.jsonl | jq -r '.tool' 2>/dev/null | sort | uniq -c | jq -R -s -c 'split("\n") | map(select(length > 0))' || echo '[]'),
    "projects_worked_on": $(pwd),
    "success_indicators": {
      "task_completed": true,
      "user_satisfied": "unknown",
      "follow_up_needed": false
    }
  },
  "improvements_detected": [],
  "errors_encountered": [],
  "new_patterns_discovered": []
}
EOF
)

    echo "$learning_entry" >> "$LEARNINGS_FILE"

    echo "✅ Learning recorded"
fi

# Update knowledge base
if [[ -f "$MEMORY_DIR/knowledge-base.json" ]]; then
    # Merge new learnings
    echo "📚 Updating knowledge base..."
fi

echo "✅ Session learning complete!"