#!/bin/bash
# Predict command outcome before execution

COMMAND="$1"

echo "🔮 Execution Prediction"
echo "Command: $COMMAND"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Analyze command
CONFIDENCE=85
RISKS=()

# Check venv for Python commands
if [[ "$COMMAND" =~ ^(pip|python) ]]; then
    if [ -z "$VIRTUAL_ENV" ]; then
        CONFIDENCE=30
        RISKS+=("No venv active - 70% chance of wrong environment")
    fi
fi

# Check git state for git commands
if [[ "$COMMAND" =~ ^git ]]; then
    if [ -d .git ]; then
        UNCOMMITTED=$(git status --short 2>/dev/null | wc -l)
        if [ "$UNCOMMITTED" -gt 0 ]; then
            RISKS+=("$UNCOMMITTED uncommitted changes")
        fi
    fi
fi

# Check dependencies
if [[ "$COMMAND" =~ npm|node ]]; then
    if [ ! -d node_modules ]; then
        CONFIDENCE=20
        RISKS+=("node_modules missing - run npm install first")
    fi
fi

echo ""
echo "Confidence: $CONFIDENCE%"
if [ ${#RISKS[@]} -gt 0 ]; then
    echo "⚠️  Risks:"
    for risk in "${RISKS[@]}"; do
        echo "  • $risk"
    done
fi

if [ $CONFIDENCE -lt 50 ]; then
    echo ""
    echo "❌ LOW CONFIDENCE - Review before executing"
    exit 1
else
    echo ""
    echo "✅ Likely to succeed"
    exit 0
fi
