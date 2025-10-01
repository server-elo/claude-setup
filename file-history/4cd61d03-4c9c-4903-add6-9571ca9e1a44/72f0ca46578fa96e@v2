#!/bin/bash
# Safe JSON Update with File Locking
# Prevents race conditions between multiple daemons

set -euo pipefail

LOCK_DIR="/tmp/claude-locks"
mkdir -p "$LOCK_DIR"

usage() {
    echo "Usage: $0 <json_file> <jq_expression>"
    echo ""
    echo "Example:"
    echo "  $0 ~/.claude/memory/knowledge-base.json '.metrics.total_sessions = 100'"
    exit 1
}

[ $# -lt 2 ] && usage

JSON_FILE="$1"
JQ_EXPR="$2"

# Create lock file based on target JSON file
LOCK_FILE="$LOCK_DIR/$(basename "$JSON_FILE").lock"

# Exclusive lock with timeout (max 5 seconds)
{
    if flock -x -w 5 200; then
        # Lock acquired, perform safe update
        if [ -f "$JSON_FILE" ]; then
            TMP_FILE="$JSON_FILE.tmp.$$"

            # Perform jq operation
            if jq "$JQ_EXPR" "$JSON_FILE" > "$TMP_FILE" 2>/dev/null; then
                # Atomic move
                mv "$TMP_FILE" "$JSON_FILE"
                exit 0
            else
                # jq failed
                rm -f "$TMP_FILE"
                echo "ERROR: jq operation failed: $JQ_EXPR" >&2
                exit 1
            fi
        else
            echo "ERROR: File not found: $JSON_FILE" >&2
            exit 1
        fi
    else
        echo "ERROR: Could not acquire lock on $JSON_FILE (timeout)" >&2
        exit 1
    fi
} 200>"$LOCK_FILE"
