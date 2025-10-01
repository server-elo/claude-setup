#!/bin/bash
# Learn cause-effect relationships

CAUSAL_DB=~/.claude/memory/causal-patterns.json

# Initialize if doesn't exist
if [ ! -f "$CAUSAL_DB" ]; then
    echo '{"patterns": []}' > "$CAUSAL_DB"
fi

case "$1" in
    learn)
        ACTION="$2"
        EFFECT="$3"
        
        # Add pattern
        jq --arg action "$ACTION" --arg effect "$EFFECT" \
           '.patterns += [{
              "action": $action,
              "effect": $effect,
              "confidence": 0.7,
              "occurrences": 1,
              "timestamp": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"
            }]' "$CAUSAL_DB" > /tmp/causal.json
        mv /tmp/causal.json "$CAUSAL_DB"
        
        echo "📚 Learned: $ACTION → $EFFECT"
        ;;
    
    predict)
        ACTION="$2"
        
        # Find matching patterns
        MATCHES=$(jq --arg action "$ACTION" \
                    '.patterns[] | select(.action | contains($action))' \
                    "$CAUSAL_DB")
        
        if [ ! -z "$MATCHES" ]; then
            echo "🔮 Predicted effects of: $ACTION"
            echo "$MATCHES" | jq -r '"  → \(.effect) (confidence: \(.confidence * 100)%)"'
        else
            echo "No predictions available for: $ACTION"
        fi
        ;;
    
    prevent)
        # Check if current context likely to cause errors
        if [ -z "$VIRTUAL_ENV" ]; then
            PATTERN=$(jq '.patterns[] | select(.action | contains("pip install")) | select(.effect | contains("error"))' "$CAUSAL_DB" 2>/dev/null)
            if [ ! -z "$PATTERN" ]; then
                echo "⚠️  Warning: Running pip without venv often causes errors"
                echo "   Suggestion: Activate venv first"
                return 1
            fi
        fi
        ;;
    
    *)
        echo "Usage: causal-learner.sh {learn|predict|prevent} <action> [effect]"
        ;;
esac
