#!/bin/bash
# Record and replay successful workflows

WORKFLOWS_DIR=~/.claude/memory/workflows
mkdir -p "$WORKFLOWS_DIR"

case "$1" in
    start)
        WORKFLOW_NAME="$2"
        if [ -z "$WORKFLOW_NAME" ]; then
            echo "Usage: workflow-recorder.sh start <name>"
            exit 1
        fi
        
        echo "🎬 Recording workflow: $WORKFLOW_NAME"
        echo "Run your commands. Type 'workflow-recorder.sh stop' when done."
        
        # Start recording history
        export WORKFLOW_RECORDING="$WORKFLOW_NAME"
        export WORKFLOW_START_TIME=$(date +%s)
        ;;
    
    stop)
        if [ -z "$WORKFLOW_RECORDING" ]; then
            echo "No recording in progress"
            exit 1
        fi
        
        END_TIME=$(date +%s)
        DURATION=$((END_TIME - WORKFLOW_START_TIME))
        
        # Extract commands since start
        COMMANDS=$(fc -ln -100 | tail -n +2 | head -n -1)
        
        cat > "$WORKFLOWS_DIR/$WORKFLOW_RECORDING.json" << EOJSON
{
  "name": "$WORKFLOW_RECORDING",
  "recorded": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "duration": $DURATION,
  "commands": [
$(echo "$COMMANDS" | sed 's/^/    "/; s/$/",/')
    ""
  ]
}
EOJSON
        
        echo "✅ Workflow saved: $WORKFLOW_RECORDING ($DURATION seconds)"
        unset WORKFLOW_RECORDING WORKFLOW_START_TIME
        ;;
    
    list)
        echo "📋 Saved Workflows:"
        ls "$WORKFLOWS_DIR"/*.json 2>/dev/null | xargs -n1 basename | sed 's/.json//'
        ;;
    
    replay)
        WORKFLOW_NAME="$2"
        WORKFLOW_FILE="$WORKFLOWS_DIR/$WORKFLOW_NAME.json"
        
        if [ ! -f "$WORKFLOW_FILE" ]; then
            echo "Workflow not found: $WORKFLOW_NAME"
            exit 1
        fi
        
        echo "▶️  Replaying workflow: $WORKFLOW_NAME"
        jq -r '.commands[]' "$WORKFLOW_FILE" | while read cmd; do
            if [ ! -z "$cmd" ]; then
                echo "➤ $cmd"
                eval "$cmd"
            fi
        done
        ;;
    
    *)
        echo "Usage: workflow-recorder.sh {start|stop|list|replay} [name]"
        ;;
esac
