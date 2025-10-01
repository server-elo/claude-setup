#!/bin/bash
# Real-time system dashboard

clear
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎯 CLAUDE MAX POWER DASHBOARD - $(date '+%Y-%m-%d %H:%M:%S')"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# System Status
echo "📊 SYSTEM STATUS"
if pgrep -f "learning-daemon.sh" > /dev/null; then
    echo "  ✅ Learning Daemon: ACTIVE ($(pgrep -f learning-daemon.sh | wc -l | tr -d ' ') processes)"
else
    echo "  ❌ Learning Daemon: STOPPED"
fi

CODE_SIZE=$(du -sh ~/.claude/memory/code-index 2>/dev/null | awk '{print $1}')
SYMBOL_COUNT=$(wc -l ~/.claude/memory/code-index/symbols.txt 2>/dev/null | awk '{print $1}')
echo "  📚 Code Index: $CODE_SIZE, $SYMBOL_COUNT symbols"

PROJ_COUNT=$(ls ~/.claude/memory/projects/*.json 2>/dev/null | wc -l | tr -d ' ')
echo "  📂 Projects Tracked: $PROJ_COUNT"

LAST_LEARN=$(jq -r '.last_learning_cycle' ~/.claude/memory/knowledge-base.json 2>/dev/null)
echo "  🧠 Last Learn: $LAST_LEARN"
echo ""

# Quick Project Health
echo "⚡ PROJECT HEALTH"
for proj in quantum RedTeam GuardrailProxy whisper; do
    if [ -d ~/Desktop/$proj ]; then
        HAS_VENV=""
        if [ -d ~/Desktop/$proj/venv ] || [ -d ~/Desktop/$proj/.venv ]; then
            HAS_VENV="✅"
        else
            HAS_VENV="⚠️ "
        fi
        
        FILE_COUNT=$(find ~/Desktop/$proj -type f 2>/dev/null | wc -l | tr -d ' ')
        echo "  $HAS_VENV $proj: $FILE_COUNT files"
    fi
done
echo ""

# Metrics
echo "📈 INTELLIGENCE METRICS"
SESSIONS=$(jq -r '.metrics.total_sessions' ~/.claude/memory/knowledge-base.json 2>/dev/null)
PATTERNS=$(jq -r '.metrics.patterns_detected' ~/.claude/memory/knowledge-base.json 2>/dev/null)
SHORTCUTS=$(jq -r '.metrics.shortcuts_created' ~/.claude/memory/knowledge-base.json 2>/dev/null)
echo "  Sessions: $SESSIONS | Patterns: $PATTERNS | Shortcuts: $SHORTCUTS"

INTERACTIONS=$(wc -l ~/.claude/memory/interactions.jsonl 2>/dev/null | awk '{print $1}')
echo "  Interactions Logged: $INTERACTIONS"
echo ""

# Alerts
echo "🚨 ALERTS & SUGGESTIONS"
if [ ! -d ~/Desktop/quantum/venv ] && [ ! -d ~/Desktop/quantum/.venv ]; then
    echo "  ⚠️  quantum: Missing venv - Run: cd ~/Desktop/quantum && python3 -m venv venv"
fi

TODO_COUNT=$(rg "TODO|FIXME" ~/Desktop/quantum ~/Desktop/RedTeam ~/Desktop/GuardrailProxy --type py -c 2>/dev/null | awk -F: '{sum+=$2} END {print sum}')
if [ ! -z "$TODO_COUNT" ] && [ "$TODO_COUNT" -gt 0 ]; then
    echo "  📝 Found $TODO_COUNT TODOs/FIXMEs across projects"
fi

ERROR_COUNT=$(wc -l ~/.claude/memory/error-patterns.txt 2>/dev/null | awk '{print $1}')
if [ "$ERROR_COUNT" -gt 0 ]; then
    echo "  🔍 $ERROR_COUNT error patterns captured for learning"
fi
echo ""

# Quick commands
echo "💡 QUICK COMMANDS"
echo "  dashboard  - Show this dashboard"
echo "  health <project>  - Deep health check"
echo "  status    - Full system status"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
