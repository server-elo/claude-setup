#!/bin/bash

# Notification Hook - Executes when Claude sends notifications
# Environment Variables Available:
# - MESSAGE: The notification message
# - LEVEL: Notification level (info, warning, error)
# - CONTEXT: Additional context information

set -euo pipefail

# Configuration
SLACK_WEBHOOK_URL="${SLACK_WEBHOOK_URL:-}"  # Set in environment
DISCORD_WEBHOOK_URL="${DISCORD_WEBHOOK_URL:-}"  # Set in environment
LOG_FILE="$HOME/.claude/logs/notifications.log"

# Ensure logs directory exists
mkdir -p "$(dirname "$LOG_FILE")"

# Log the notification
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
echo "$TIMESTAMP - LEVEL: ${LEVEL:-info} - MESSAGE: ${MESSAGE:-}" >> "$LOG_FILE"

# Determine notification urgency and emoji
case "${LEVEL:-info}" in
    error|critical)
        EMOJI="🚨"
        URGENCY="high"
        ;;
    warning)
        EMOJI="⚠️"
        URGENCY="medium"
        ;;
    success)
        EMOJI="✅"
        URGENCY="low"
        ;;
    *)
        EMOJI="ℹ️"
        URGENCY="low"
        ;;
esac

# Format the message
FORMATTED_MESSAGE="$EMOJI Claude Code Notification: ${MESSAGE:-}"
if [[ -n "${CONTEXT:-}" ]]; then
    FORMATTED_MESSAGE="$FORMATTED_MESSAGE\nContext: ${CONTEXT}"
fi

# Display desktop notification (macOS)
if command -v osascript >/dev/null 2>&1; then
    osascript -e "display notification \"${MESSAGE:-}\" with title \"Claude Code\" sound name \"default\"" 2>/dev/null || true
fi

# Display desktop notification (Linux)
if command -v notify-send >/dev/null 2>&1; then
    notify-send "Claude Code" "${MESSAGE:-}" 2>/dev/null || true
fi

# Send Slack notification for important messages
if [[ -n "$SLACK_WEBHOOK_URL" ]] && [[ "$URGENCY" != "low" || "${LEVEL:-}" == "error" ]]; then
    echo "📡 Sending Slack notification..."

    SLACK_PAYLOAD=$(cat <<EOF
{
    "text": "$FORMATTED_MESSAGE",
    "channel": "#claude-code",
    "username": "Claude Code Bot",
    "icon_emoji": "$EMOJI",
    "attachments": [
        {
            "color": "$([[ "$LEVEL" == "error" ]] && echo "danger" || [[ "$LEVEL" == "warning" ]] && echo "warning" || echo "good")",
            "fields": [
                {
                    "title": "Timestamp",
                    "value": "$TIMESTAMP",
                    "short": true
                },
                {
                    "title": "Level",
                    "value": "${LEVEL:-info}",
                    "short": true
                }
            ]
        }
    ]
}
EOF
    )

    if curl -X POST -H 'Content-type: application/json' \
        --data "$SLACK_PAYLOAD" \
        "$SLACK_WEBHOOK_URL" >/dev/null 2>&1; then
        echo "✅ Slack notification sent"
    else
        echo "⚠️ Failed to send Slack notification"
    fi
fi

# Send Discord notification for critical errors
if [[ -n "$DISCORD_WEBHOOK_URL" ]] && [[ "${LEVEL:-}" == "error" ]]; then
    echo "📡 Sending Discord notification..."

    DISCORD_PAYLOAD=$(cat <<EOF
{
    "content": "$FORMATTED_MESSAGE",
    "embeds": [
        {
            "title": "Claude Code Error",
            "description": "${MESSAGE:-}",
            "color": 15158332,
            "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%S.000Z)",
            "fields": [
                {
                    "name": "Context",
                    "value": "${CONTEXT:-No additional context}",
                    "inline": false
                }
            ]
        }
    ]
}
EOF
    )

    if curl -X POST -H 'Content-type: application/json' \
        --data "$DISCORD_PAYLOAD" \
        "$DISCORD_WEBHOOK_URL" >/dev/null 2>&1; then
        echo "✅ Discord notification sent"
    else
        echo "⚠️ Failed to send Discord notification"
    fi
fi

# Email notification for critical errors (if configured)
if [[ "${LEVEL:-}" == "error" ]] && command -v mail >/dev/null 2>&1; then
    EMAIL_RECIPIENT="${CLAUDE_EMAIL_RECIPIENT:-}"
    if [[ -n "$EMAIL_RECIPIENT" ]]; then
        echo "📧 Sending email notification..."

        cat <<EOF | mail -s "Claude Code Error Alert" "$EMAIL_RECIPIENT"
Claude Code Error Notification

Message: ${MESSAGE:-}
Level: ${LEVEL:-}
Timestamp: $TIMESTAMP
Context: ${CONTEXT:-No additional context}

This is an automated notification from Claude Code.
EOF
        echo "✅ Email notification sent to $EMAIL_RECIPIENT"
    fi
fi

# Log to system log (macOS/Linux)
if command -v logger >/dev/null 2>&1; then
    logger -t "claude-code" "${LEVEL:-info}: ${MESSAGE:-}"
fi

# Create aggregated notification summary
SUMMARY_FILE="$HOME/.claude/logs/notification-summary.log"
if [[ ! -f "$SUMMARY_FILE" ]] || [[ $(find "$SUMMARY_FILE" -mtime +1 2>/dev/null) ]]; then
    # Create new summary or reset daily
    echo "# Claude Code Notification Summary - $(date '+%Y-%m-%d')" > "$SUMMARY_FILE"
    echo "Errors: 0" >> "$SUMMARY_FILE"
    echo "Warnings: 0" >> "$SUMMARY_FILE"
    echo "Info: 0" >> "$SUMMARY_FILE"
fi

# Update summary counts
case "${LEVEL:-info}" in
    error|critical)
        sed -i.bak 's/Errors: \([0-9]*\)/Errors: \1/' "$SUMMARY_FILE" 2>/dev/null || true
        CURRENT_ERRORS=$(grep "Errors:" "$SUMMARY_FILE" | grep -o '[0-9]*' || echo "0")
        NEW_ERRORS=$((CURRENT_ERRORS + 1))
        sed -i.bak "s/Errors: [0-9]*/Errors: $NEW_ERRORS/" "$SUMMARY_FILE" 2>/dev/null || true
        ;;
    warning)
        CURRENT_WARNINGS=$(grep "Warnings:" "$SUMMARY_FILE" | grep -o '[0-9]*' || echo "0")
        NEW_WARNINGS=$((CURRENT_WARNINGS + 1))
        sed -i.bak "s/Warnings: [0-9]*/Warnings: $NEW_WARNINGS/" "$SUMMARY_FILE" 2>/dev/null || true
        ;;
    *)
        CURRENT_INFO=$(grep "Info:" "$SUMMARY_FILE" | grep -o '[0-9]*' || echo "0")
        NEW_INFO=$((CURRENT_INFO + 1))
        sed -i.bak "s/Info: [0-9]*/Info: $NEW_INFO/" "$SUMMARY_FILE" 2>/dev/null || true
        ;;
esac

# Clean up backup files
rm -f "$SUMMARY_FILE.bak" 2>/dev/null || true

echo "✅ Notification processing completed"