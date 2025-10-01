#!/bin/bash

# Stop Hook - Executes when Claude finishes responding
# Environment Variables Available:
# - SESSION_ID: Unique identifier for the session
# - DURATION: Session duration in seconds
# - TOOLS_USED: Comma-separated list of tools used
# - FILES_MODIFIED: Number of files modified in session

set -euo pipefail

# Configuration
LOG_FILE="$HOME/.claude/logs/sessions.log"
STATS_FILE="$HOME/.claude/logs/session-stats.json"

# Ensure logs directory exists
mkdir -p "$(dirname "$LOG_FILE")"

# Session information
SESSION_ID="${SESSION_ID:-unknown}"
DURATION="${DURATION:-0}"
TOOLS_USED="${TOOLS_USED:-none}"
FILES_MODIFIED="${FILES_MODIFIED:-0}"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
DATE=$(date '+%Y-%m-%d')

echo "🏁 Claude Code session ending..."

# Log session summary
cat <<EOF >> "$LOG_FILE"
======================================
Session End: $TIMESTAMP
Session ID: $SESSION_ID
Duration: ${DURATION}s
Tools Used: $TOOLS_USED
Files Modified: $FILES_MODIFIED
======================================

EOF

# Update session statistics
if [[ ! -f "$STATS_FILE" ]]; then
    cat <<EOF > "$STATS_FILE"
{
    "total_sessions": 0,
    "total_duration": 0,
    "total_files_modified": 0,
    "average_session_duration": 0,
    "most_used_tools": {},
    "daily_stats": {},
    "last_updated": "$TIMESTAMP"
}
EOF
fi

# Update statistics (using jq if available, otherwise basic approach)
if command -v jq >/dev/null 2>&1; then
    echo "📊 Updating session statistics..."

    # Read current stats
    CURRENT_STATS=$(cat "$STATS_FILE")

    # Calculate new stats
    NEW_STATS=$(echo "$CURRENT_STATS" | jq \
        --arg date "$DATE" \
        --arg duration "$DURATION" \
        --arg files "$FILES_MODIFIED" \
        --arg tools "$TOOLS_USED" \
        --arg timestamp "$TIMESTAMP" \
        '
        .total_sessions += 1 |
        .total_duration += ($duration | tonumber) |
        .total_files_modified += ($files | tonumber) |
        .average_session_duration = (.total_duration / .total_sessions) |
        .last_updated = $timestamp |

        # Update daily stats
        .daily_stats[$date] = (.daily_stats[$date] // {
            "sessions": 0,
            "duration": 0,
            "files_modified": 0
        }) |
        .daily_stats[$date].sessions += 1 |
        .daily_stats[$date].duration += ($duration | tonumber) |
        .daily_stats[$date].files_modified += ($files | tonumber) |

        # Update tool usage stats
        ($tools | split(",") | map(select(length > 0))) as $tool_list |
        reduce $tool_list[] as $tool (.; .most_used_tools[$tool] = (.most_used_tools[$tool] // 0) + 1)
        ')

    echo "$NEW_STATS" > "$STATS_FILE"
    echo "✅ Statistics updated"
else
    echo "📊 jq not available, skipping detailed statistics update"
fi

# Session cleanup
echo "🧹 Performing session cleanup..."

# Clean up temporary files
find /tmp -name "claude_*" -mtime +1 -delete 2>/dev/null || true

# Rotate logs if they're getting too large
for log in "$HOME/.claude/logs"/*.log; do
    if [[ -f "$log" ]] && [[ $(wc -l < "$log" 2>/dev/null || echo 0) -gt 10000 ]]; then
        echo "📜 Rotating large log file: $(basename "$log")"
        tail -5000 "$log" > "${log}.tmp" && mv "${log}.tmp" "$log"
    fi
done

# Clean up old backup files (older than 7 days)
find "$HOME/.claude/backups" -type f -mtime +7 -delete 2>/dev/null || true

# Generate session report
echo "📋 Generating session report..."

REPORT_FILE="$HOME/.claude/logs/last-session-report.txt"
cat <<EOF > "$REPORT_FILE"
Claude Code Session Report
==========================
Date: $TIMESTAMP
Session ID: $SESSION_ID
Duration: ${DURATION} seconds ($(printf "%.1f" $(echo "scale=1; $DURATION / 60" | bc 2>/dev/null || echo "0")) minutes)
Tools Used: $TOOLS_USED
Files Modified: $FILES_MODIFIED

Session Productivity:
- Files per minute: $(echo "scale=2; $FILES_MODIFIED / ($DURATION / 60)" | bc 2>/dev/null || echo "0")
- Average tool usage: $(echo "$TOOLS_USED" | tr ',' '\n' | wc -l | tr -d ' ')

Quick Stats:
EOF

# Add recent statistics if jq is available
if command -v jq >/dev/null 2>&1 && [[ -f "$STATS_FILE" ]]; then
    echo "- Total sessions today: $(jq -r ".daily_stats[\"$DATE\"].sessions // 0" "$STATS_FILE")" >> "$REPORT_FILE"
    echo "- Total duration today: $(jq -r ".daily_stats[\"$DATE\"].duration // 0" "$STATS_FILE")s" >> "$REPORT_FILE"
    echo "- Files modified today: $(jq -r ".daily_stats[\"$DATE\"].files_modified // 0" "$STATS_FILE")" >> "$REPORT_FILE"
    echo "- Average session length: $(jq -r ".average_session_duration | floor" "$STATS_FILE")s" >> "$REPORT_FILE"

    # Most used tool
    MOST_USED_TOOL=$(jq -r '.most_used_tools | to_entries | max_by(.value) | .key' "$STATS_FILE" 2>/dev/null || echo "none")
    echo "- Most used tool: $MOST_USED_TOOL" >> "$REPORT_FILE"
fi

echo "" >> "$REPORT_FILE"
echo "Report generated: $TIMESTAMP" >> "$REPORT_FILE"

# Git status summary if in git repository
if command -v git >/dev/null 2>&1 && git rev-parse --git-dir > /dev/null 2>&1; then
    echo "📊 Git repository status:"

    STAGED_FILES=$(git diff --cached --name-only | wc -l | tr -d ' ')
    MODIFIED_FILES=$(git diff --name-only | wc -l | tr -d ' ')
    UNTRACKED_FILES=$(git ls-files --others --exclude-standard | wc -l | tr -d ' ')

    echo "- Staged files: $STAGED_FILES"
    echo "- Modified files: $MODIFIED_FILES"
    echo "- Untracked files: $UNTRACKED_FILES"

    if [[ $STAGED_FILES -gt 0 ]]; then
        echo "💡 Suggestion: Consider committing your staged changes"
        echo "   Run: git commit -m 'Your commit message'"
    fi

    # Add to session report
    cat <<EOF >> "$REPORT_FILE"

Git Status:
- Staged files: $STAGED_FILES
- Modified files: $MODIFIED_FILES
- Untracked files: $UNTRACKED_FILES
EOF
fi

# Performance suggestions based on session data
if [[ $DURATION -gt 300 ]]; then  # 5+ minutes
    echo ""
    echo "💡 Performance suggestions for long sessions:"
    echo "   - Consider using subagents for complex tasks"
    echo "   - Break large tasks into smaller chunks"
    echo "   - Use custom slash commands for repeated workflows"
fi

if [[ $FILES_MODIFIED -gt 10 ]]; then
    echo ""
    echo "💡 Productivity note:"
    echo "   - High file modification count detected"
    echo "   - Consider reviewing changes before committing"
    echo "   - Use /review-code for quality assurance"
fi

# Display session summary
echo ""
echo "📊 Session Summary:"
echo "   Duration: ${DURATION}s"
echo "   Files Modified: $FILES_MODIFIED"
echo "   Tools Used: $(echo "$TOOLS_USED" | tr ',' ' ')"
echo ""
echo "📋 Session report saved to: $REPORT_FILE"

# Final message
echo "✅ Claude Code session cleanup completed"
echo "🎯 Ready for next session!"