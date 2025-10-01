# Real-time learning hooks for zsh
# Source this in ~/.zshrc: source ~/.claude/scripts/shell-hooks.sh

# Hook: After every command
precmd() {
  local EXIT_CODE=$?
  local LAST_CMD=$(fc -ln -1)
  
  # Log to interactions if non-trivial command
  if [[ ! "$LAST_CMD" =~ ^(ls|cd|pwd|echo)$ ]]; then
    echo "{\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\"cmd\":\"$LAST_CMD\",\"exit\":$EXIT_CODE,\"pwd\":\"$PWD\"}" >> ~/.claude/memory/interactions.jsonl 2>/dev/null
  fi
  
  # Track errors
  if [ $EXIT_CODE -ne 0 ]; then
    echo "[$(date)] FAILED: $LAST_CMD (exit $EXIT_CODE)" >> ~/.claude/memory/error-patterns.txt
  fi
}

# Hook: Before cd
chpwd() {
  local NEW_DIR=$(basename "$PWD")
  
  # Check if project memory exists
  if [ -f ~/.claude/memory/projects/${NEW_DIR}.json ]; then
    echo "💡 Known project: $NEW_DIR"
    jq -r '.entry_point // .type // "unknown"' ~/.claude/memory/projects/${NEW_DIR}.json 2>/dev/null
  fi
}

# Smart aliases
alias find='fd'
alias grep='rg'

echo "✅ Claude learning hooks loaded"
