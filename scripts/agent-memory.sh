#!/bin/bash
# Persistent agent memory system

MEMORY_DIR=~/.claude/memory/agents
mkdir -p "$MEMORY_DIR"

case "$1" in
    remember)
        AGENT="$2"
        KEY="$3"
        VALUE="$4"
        
        AGENT_FILE="$MEMORY_DIR/$AGENT.json"
        if [ ! -f "$AGENT_FILE" ]; then
            echo '{"memories": {}, "expertise": []}' > "$AGENT_FILE"
        fi
        
        jq --arg key "$KEY" --arg value "$VALUE" \
           '.memories[$key] = $value' \
           "$AGENT_FILE" > /tmp/agent.json
        mv /tmp/agent.json "$AGENT_FILE"
        
        echo "🧠 $AGENT remembered: $KEY"
        ;;
    
    recall)
        AGENT="$2"
        KEY="$3"
        
        AGENT_FILE="$MEMORY_DIR/$AGENT.json"
        if [ -f "$AGENT_FILE" ]; then
            jq -r --arg key "$KEY" '.memories[$key] // "unknown"' "$AGENT_FILE"
        fi
        ;;
    
    expertise)
        AGENT="$2"
        SKILL="$3"
        
        AGENT_FILE="$MEMORY_DIR/$AGENT.json"
        if [ ! -f "$AGENT_FILE" ]; then
            echo '{"memories": {}, "expertise": []}' > "$AGENT_FILE"
        fi
        
        jq --arg skill "$SKILL" \
           'if (.expertise | contains([$skill])) then . else .expertise += [$skill] end' \
           "$AGENT_FILE" > /tmp/agent.json
        mv /tmp/agent.json "$AGENT_FILE"
        
        echo "🎓 $AGENT gained expertise: $SKILL"
        ;;
    
    profile)
        AGENT="$2"
        AGENT_FILE="$MEMORY_DIR/$AGENT.json"
        
        if [ -f "$AGENT_FILE" ]; then
            echo "👤 Agent Profile: $AGENT"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "Expertise:"
            jq -r '.expertise[]' "$AGENT_FILE" | sed 's/^/  • /'
            echo ""
            echo "Memories:"
            jq -r '.memories | to_entries[] | "  \(.key): \(.value)"' "$AGENT_FILE"
        else
            echo "No profile found for: $AGENT"
        fi
        ;;
    
    *)
        echo "Usage: agent-memory.sh {remember|recall|expertise|profile} <agent> [key] [value]"
        ;;
esac
