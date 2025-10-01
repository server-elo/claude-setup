#!/bin/bash
# Smart Assistant Hook - Makes Claude proactive and intelligent

set -euo pipefail

USER_MESSAGE="${USER_MESSAGE:-}"

# Analyze user intent and auto-trigger appropriate intelligence
if [[ -n "$USER_MESSAGE" ]]; then

    # Auto-trigger deep explanation for "what is" questions
    if echo "$USER_MESSAGE" | grep -qiE "(what is|explain|how does|what does).*\.(js|py|go|rs|java)"; then
        echo "TRIGGER_DEEP_EXPLAIN=true" > /tmp/claude_intelligence
    fi

    # Auto-trigger semantic search for "where is" questions
    if echo "$USER_MESSAGE" | grep -qiE "(where|find|locate|search for)"; then
        echo "TRIGGER_SEMANTIC_SEARCH=true" > /tmp/claude_intelligence
    fi

    # Auto-trigger parallel debug for error messages
    if echo "$USER_MESSAGE" | grep -qiE "(error|bug|broken|not working|fails)"; then
        echo "TRIGGER_PARALLEL_DEBUG=true" > /tmp/claude_intelligence
        echo "🔍 Auto-activating parallel debugging mode..."
    fi

    # Auto-trigger refactor analysis for "improve" requests
    if echo "$USER_MESSAGE" | grep -qiE "(improve|refactor|optimize|better way)"; then
        echo "TRIGGER_REFACTOR_ANALYSIS=true" > /tmp/claude_intelligence
        echo "🔧 Auto-activating refactoring analysis..."
    fi

    # Auto-trigger cascade fix for bug fixes
    if echo "$USER_MESSAGE" | grep -qiE "(fix|repair|solve)"; then
        echo "TRIGGER_CASCADE_FIX=true" > /tmp/claude_intelligence
        echo "🔄 Auto-activating cascade fix mode (will find similar bugs)..."
    fi

    # Auto-trigger documentation for doc requests
    if echo "$USER_MESSAGE" | grep -qiE "(document|documentation|doc|readme)"; then
        echo "TRIGGER_AUTO_DOCUMENT=true" > /tmp/claude_intelligence
    fi
fi

# Context awareness
if [[ -f "/tmp/claude_auto_context" ]]; then
    echo "📊 Full project context loaded automatically"
fi