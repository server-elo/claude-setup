#!/bin/bash
# Predictive context pre-loading

TRANSITION_MATRIX=~/.claude/memory/transition-matrix.json

# Build transition matrix from history
build_matrix() {
    log "🧮 Building project transition matrix..."
    
    # Extract folder transitions from history
    tail -1000 ~/.zsh_history | \
        grep "cd " | \
        sed 's/.*cd //' | \
        awk 'NR>1{print prev" -> "$0} {prev=$0}' | \
        sort | uniq -c | sort -rn > /tmp/transitions.txt
    
    # Convert to JSON
    echo '{"transitions": []}' > "$TRANSITION_MATRIX"
}

# Predict next likely directory
predict_next() {
    CURRENT=$(basename "$PWD")
    
    # Look up in transition matrix
    NEXT=$(grep "$CURRENT" /tmp/transitions.txt 2>/dev/null | head -1 | awk '{print $NF}')
    
    if [ ! -z "$NEXT" ]; then
        echo "$NEXT"
    fi
}

# Pre-load context for project
preload() {
    PROJECT="$1"
    
    if [ -d "$PROJECT" ]; then
        echo "⚡ Pre-loading: $PROJECT"
        
        # Check project memory
        PROJ_NAME=$(basename "$PROJECT")
        if [ -f ~/.claude/memory/projects/${PROJ_NAME}.json ]; then
            # Cache into RAM
            cat ~/.claude/memory/projects/${PROJ_NAME}.json > /dev/null
        fi
        
        # Pre-load recent files
        find "$PROJECT" -type f -name "*.py" -o -name "*.js" -mtime -1 2>/dev/null | \
            head -10 | xargs cat > /dev/null 2>&1
        
        echo "✅ Pre-loaded: $PROJ_NAME"
    fi
}

case "$1" in
    build)
        build_matrix
        ;;
    predict)
        predict_next
        ;;
    preload)
        preload "$2"
        ;;
    *)
        echo "Usage: $0 {build|predict|preload <path>}"
        ;;
esac
