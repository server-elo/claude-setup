#!/bin/bash
# Stop all MAX POWER V3 daemons

echo "🛑 Stopping all daemons..."

# Kill all instances
pkill -f "learning-daemon.sh" 2>/dev/null && echo "✅ Learning daemon stopped" || echo "⚠️  Learning daemon not running"
pkill -f "v3-autonomous-daemon.sh" 2>/dev/null && echo "✅ Autonomous daemon stopped" || echo "⚠️  Autonomous daemon not running"

# Clean up PID files
rm -f ~/.claude/daemon.pid ~/.claude/autonomous.pid 2>/dev/null

sleep 1

# Verify stopped
if pgrep -f "daemon.sh" > /dev/null; then
    echo "⚠️  Some daemon processes still running:"
    ps aux | grep -E "daemon.sh" | grep -v grep
else
    echo "✅ All daemons stopped successfully"
fi
