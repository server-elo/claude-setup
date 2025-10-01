#!/bin/bash
# Track what optimizations actually work

METRICS_FILE=~/.claude/memory/self-metrics.json

# Initialize if doesn't exist
if [ ! -f "$METRICS_FILE" ]; then
    cat > "$METRICS_FILE" << 'EOJSON'
{
  "shortcuts": {"created": 0, "used": 0, "last_used": {}},
  "errors_prevented": 0,
  "context_hits": 0,
  "context_misses": 0,
  "optimizations": []
}
EOJSON
fi

case "$1" in
    shortcut-used)
        SHORTCUT_NAME="$2"
        jq ".shortcuts.used += 1 | .shortcuts.last_used[\"$SHORTCUT_NAME\"] = \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"" "$METRICS_FILE" > /tmp/metrics.json
        mv /tmp/metrics.json "$METRICS_FILE"
        ;;
    
    error-prevented)
        jq '.errors_prevented += 1' "$METRICS_FILE" > /tmp/metrics.json
        mv /tmp/metrics.json "$METRICS_FILE"
        ;;
    
    context-hit)
        jq '.context_hits += 1' "$METRICS_FILE" > /tmp/metrics.json
        mv /tmp/metrics.json "$METRICS_FILE"
        ;;
    
    context-miss)
        jq '.context_misses += 1' "$METRICS_FILE" > /tmp/metrics.json
        mv /tmp/metrics.json "$METRICS_FILE"
        ;;
    
    report)
        echo "📊 Self-Improvement Metrics"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━"
        jq -r '
            "Shortcuts:",
            "  Created: \(.shortcuts.created)",
            "  Used: \(.shortcuts.used)",
            "  Usage Rate: \((.shortcuts.used / (.shortcuts.created + 0.001) * 100) | floor)%",
            "",
            "Error Prevention:",
            "  Errors Prevented: \(.errors_prevented)",
            "",
            "Context Prediction:",
            "  Hits: \(.context_hits)",
            "  Misses: \(.context_misses)",
            "  Accuracy: \((.context_hits / (.context_hits + .context_misses + 0.001) * 100) | floor)%"
        ' "$METRICS_FILE"
        ;;
    
    *)
        echo "Usage: self-metrics.sh {shortcut-used|error-prevented|context-hit|context-miss|report}"
        ;;
esac
