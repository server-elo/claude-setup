#!/bin/bash
# Control script for learning daemon

DAEMON_SCRIPT="$HOME/.claude/scripts/learning-daemon.sh"
DAEMON_PID="$HOME/.claude/daemon.pid"
LOG="$HOME/.claude/logs/learning-daemon.log"

case "$1" in
    start)
        if [ -f "$DAEMON_PID" ] && kill -0 $(cat "$DAEMON_PID") 2>/dev/null; then
            echo "⚠️  Daemon already running (PID: $(cat "$DAEMON_PID"))"
        else
            echo "🚀 Starting learning daemon..."
            nohup "$DAEMON_SCRIPT" > /dev/null 2>&1 &
            sleep 1
            if [ -f "$DAEMON_PID" ]; then
                echo "✅ Daemon started (PID: $(cat "$DAEMON_PID"))"
                echo "📊 Logs: tail -f $LOG"
            else
                echo "❌ Failed to start daemon"
            fi
        fi
        ;;
    stop)
        if [ -f "$DAEMON_PID" ]; then
            PID=$(cat "$DAEMON_PID")
            echo "🛑 Stopping daemon (PID: $PID)..."
            kill $PID 2>/dev/null
            rm -f "$DAEMON_PID"
            echo "✅ Daemon stopped"
        else
            echo "⚠️  Daemon not running"
        fi
        ;;
    status)
        if [ -f "$DAEMON_PID" ] && kill -0 $(cat "$DAEMON_PID") 2>/dev/null; then
            echo "✅ Daemon running (PID: $(cat "$DAEMON_PID"))"
            echo "📊 Latest log entries:"
            tail -10 "$LOG" 2>/dev/null || echo "No logs yet"
        else
            echo "❌ Daemon not running"
            rm -f "$DAEMON_PID"
        fi
        ;;
    restart)
        $0 stop
        sleep 2
        $0 start
        ;;
    logs)
        if [ -f "$LOG" ]; then
            tail -f "$LOG"
        else
            echo "No logs found"
        fi
        ;;
    *)
        echo "Usage: $0 {start|stop|status|restart|logs}"
        exit 1
        ;;
esac