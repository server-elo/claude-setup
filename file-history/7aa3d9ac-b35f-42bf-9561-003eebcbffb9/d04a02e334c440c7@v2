#!/bin/bash
# Auto-Context Hook - Runs automatically when Claude enters a new directory

set -euo pipefail

CURRENT_DIR=$(pwd)
CONTEXT_CACHE="$HOME/.claude/memory/context-cache.json"

# Check if this is a new project directory
if [[ -f "package.json" ]] || [[ -f "requirements.txt" ]] || [[ -f "go.mod" ]] || [[ -f "Cargo.toml" ]] || [[ -f "pom.xml" ]]; then

    # Check if we already analyzed this project
    if ! grep -q "$CURRENT_DIR" "$CONTEXT_CACHE" 2>/dev/null; then
        echo "🧠 New project detected! Auto-analyzing..."
        echo "📂 Location: $CURRENT_DIR"

        # Trigger deep context understanding
        echo "TRIGGER_AUTO_CONTEXT=true" > /tmp/claude_auto_context
        echo "PROJECT_PATH=$CURRENT_DIR" >> /tmp/claude_auto_context

        # Cache this project
        mkdir -p "$(dirname "$CONTEXT_CACHE")"
        echo "{\"project\": \"$CURRENT_DIR\", \"analyzed\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"}" >> "$CONTEXT_CACHE"
    fi
fi

# Check for common issues that should trigger auto-analysis
if [[ -f "package.json" ]] && ! [[ -d "node_modules" ]]; then
    echo "⚠️  No node_modules found - suggesting 'npm install'"
fi

if [[ -f ".env.example" ]] && ! [[ -f ".env" ]]; then
    echo "⚠️  Missing .env file - found .env.example"
fi