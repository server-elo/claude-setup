#!/bin/bash
# Auto-start all MAX POWER V3 daemons
# Run this once and they'll stay running in background

set -e

LEARNING_DAEMON="$HOME/.claude/scripts/learning-daemon.sh"
AUTONOMOUS_DAEMON="$HOME/.claude/scripts/v3-autonomous-daemon.sh"
LOG_DIR="$HOME/.claude/logs"

mkdir -p "$LOG_DIR"

echo "🚀 Starting MAX POWER V3 Daemons..."

# 1. Learning Daemon (30-minute cycles)
if pgrep -f "learning-daemon.sh" > /dev/null; then
    echo "⚠️  Learning daemon already running"
else
    nohup "$LEARNING_DAEMON" >> "$LOG_DIR/learning-daemon.log" 2>&1 &
    sleep 1
    if pgrep -f "learning-daemon.sh" > /dev/null; then
        PID=$(pgrep -f "learning-daemon.sh")
        echo "✅ Learning daemon started (PID: $PID)"
    else
        echo "❌ Learning daemon failed to start"
    fi
fi

# 2. Autonomous Daemon (60-second cycles)
if pgrep -f "v3-autonomous-daemon.sh" > /dev/null; then
    echo "⚠️  Autonomous daemon already running"
else
    nohup "$AUTONOMOUS_DAEMON" start >> "$LOG_DIR/autonomous-daemon.log" 2>&1 &
    sleep 1
    if pgrep -f "v3-autonomous-daemon.sh" > /dev/null; then
        PID=$(pgrep -f "v3-autonomous-daemon.sh")
        echo "✅ Autonomous daemon started (PID: $PID)"
    else
        echo "❌ Autonomous daemon failed to start"
    fi
fi

echo ""
echo "📊 Daemon Status:"
ps aux | grep -E "(learning-daemon|autonomous-daemon)" | grep -v grep | awk '{print "   PID", $2, "-", $11, $12}'

echo ""
echo "📝 Monitor logs:"
echo "   Learning:    tail -f $LOG_DIR/learning-daemon.log"
echo "   Autonomous:  tail -f $LOG_DIR/autonomous-daemon.log"

echo ""
echo "🛑 Stop all daemons:"
echo "   pkill -f learning-daemon && pkill -f autonomous-daemon"
