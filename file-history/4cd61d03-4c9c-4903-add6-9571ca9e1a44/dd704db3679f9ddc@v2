#!/bin/bash
# Check status of all MAX POWER V3 daemons

echo "📊 MAX POWER V3 Daemon Status"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Learning Daemon
if pgrep -f "learning-daemon.sh" > /dev/null; then
    PID=$(pgrep -f "learning-daemon.sh" | head -1)
    UPTIME=$(ps -p $PID -o etime= 2>/dev/null | xargs)
    echo "✅ Learning Daemon: RUNNING"
    echo "   PID: $PID"
    echo "   Uptime: $UPTIME"
    echo "   Log: ~/.claude/logs/learning-daemon.log"

    # Show last cycle
    LAST_CYCLE=$(grep "Learning cycle complete" ~/.claude/logs/learning-daemon.log 2>/dev/null | tail -1)
    if [ -n "$LAST_CYCLE" ]; then
        echo "   Last cycle: $LAST_CYCLE"
    fi
else
    echo "❌ Learning Daemon: STOPPED"
fi

echo ""

# Autonomous Daemon
if pgrep -f "v3-autonomous-daemon.sh" > /dev/null; then
    PID=$(pgrep -f "v3-autonomous-daemon.sh" | head -1)
    UPTIME=$(ps -p $PID -o etime= 2>/dev/null | xargs)
    echo "✅ Autonomous Daemon: RUNNING"
    echo "   PID: $PID"
    echo "   Uptime: $UPTIME"
    echo "   Log: ~/.claude/logs/autonomous-daemon.log"

    # Show last activity
    LAST_ACTIVITY=$(tail -1 ~/.claude/logs/autonomous-daemon.log 2>/dev/null)
    if [ -n "$LAST_ACTIVITY" ]; then
        echo "   Last: $LAST_ACTIVITY"
    fi
else
    echo "❌ Autonomous Daemon: STOPPED"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# System health
echo ""
echo "🏥 System Health:"

# Code index
if [ -f ~/.claude/memory/code-index/metadata.json ]; then
    FILES=$(jq -r '.total_files' ~/.claude/memory/code-index/metadata.json 2>/dev/null)
    SYMBOLS=$(jq -r '.total_symbols' ~/.claude/memory/code-index/metadata.json 2>/dev/null)
    echo "   Code Index: ✅ $FILES files, $SYMBOLS symbols"
else
    echo "   Code Index: ❌ Not built"
fi

# Knowledge base
if [ -f ~/.claude/memory/knowledge-base.json ]; then
    SESSIONS=$(jq -r '.metrics.total_sessions' ~/.claude/memory/knowledge-base.json 2>/dev/null)
    PATTERNS=$(jq -r '.metrics.patterns_detected' ~/.claude/memory/knowledge-base.json 2>/dev/null)
    echo "   Knowledge: ✅ $SESSIONS sessions, $PATTERNS patterns"
else
    echo "   Knowledge: ❌ Not initialized"
fi

# GitHub intelligence
if [ -f ~/.claude/memory/github-intelligence.json ]; then
    REPOS=$(jq -r '.metrics.total_repos // 0' ~/.claude/memory/github-intelligence.json 2>/dev/null)
    echo "   GitHub: ✅ Tracking $REPOS repos"
else
    echo "   GitHub: ⚠️  Not scanned yet"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Commands:"
echo "  Start:  ~/.claude/scripts/auto-start-daemons.sh"
echo "  Stop:   ~/.claude/scripts/stop-all-daemons.sh"
echo "  Status: ~/.claude/scripts/daemon-status.sh"
