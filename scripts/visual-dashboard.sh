#!/bin/bash
# Generate HTML visual dashboard

HTML_FILE=~/.claude/dashboard.html

generate_html() {
cat > "$HTML_FILE" << 'EOHTML'
<!DOCTYPE html>
<html>
<head>
    <title>Claude Max Power V3 Dashboard</title>
    <meta http-equiv="refresh" content="10">
    <style>
        body { font-family: monospace; background: #0a0a0a; color: #00ff00; padding: 20px; }
        .container { max-width: 1200px; margin: 0 auto; }
        .header { font-size: 24px; margin-bottom: 20px; border-bottom: 2px solid #00ff00; }
        .section { margin: 20px 0; padding: 15px; border: 1px solid #333; }
        .metric { display: inline-block; margin: 10px 20px; }
        .alert { color: #ff6600; font-weight: bold; }
        .good { color: #00ff00; }
        .warning { color: #ffcc00; }
        .timeline { margin: 20px 0; }
        .event { padding: 5px; margin: 5px 0; background: #1a1a1a; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            🎯 CLAUDE MAX POWER V3 DASHBOARD
            <br><small>Last Updated: TIMESTAMP</small>
        </div>
        
        <div class="section">
            <h2>📊 System Status</h2>
            <div class="metric good">✅ Autonomous Daemon: ACTIVE</div>
            <div class="metric good">✅ Learning Daemon: ACTIVE</div>
            <div class="metric">📚 Code Index: 19MB / 158K symbols</div>
            <div class="metric">📂 Projects: 12 tracked</div>
        </div>
        
        <div class="section">
            <h2>⚡ Real-Time Activity</h2>
            <div class="timeline">
EVENTS
            </div>
        </div>
        
        <div class="section">
            <h2>🚨 Alerts & Suggestions</h2>
ALERTS
        </div>
        
        <div class="section">
            <h2>📈 Intelligence Metrics</h2>
            <div class="metric">Sessions: SESSIONS</div>
            <div class="metric">Patterns: PATTERNS</div>
            <div class="metric">Context Hits: HITS%</div>
        </div>
    </div>
</body>
</html>
EOHTML

    # Replace placeholders
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    SESSIONS=$(jq -r '.metrics.total_sessions' ~/.claude/memory/knowledge-base.json 2>/dev/null || echo "0")
    PATTERNS=$(jq -r '.metrics.patterns_detected' ~/.claude/memory/knowledge-base.json 2>/dev/null || echo "0")
    
    # Get recent events
    EVENTS=$(tail -10 ~/.claude/logs/autonomous-daemon.log 2>/dev/null | sed 's/^/<div class="event">/' | sed 's/$/<\/div>/' | tr '\n' ' ')
    
    # Get alerts
    ALERTS=$(tail -5 ~/.claude/memory/suggestions.log 2>/dev/null | sed 's/^/<div class="alert">⚠️ /' | sed 's/$/<\/div>/' | tr '\n' ' ')
    
    sed -i.bak \
        -e "s/TIMESTAMP/$TIMESTAMP/" \
        -e "s/SESSIONS/$SESSIONS/" \
        -e "s/PATTERNS/$PATTERNS/" \
        -e "s|EVENTS|$EVENTS|" \
        -e "s|ALERTS|$ALERTS|" \
        "$HTML_FILE"
    
    echo "✅ Dashboard generated: $HTML_FILE"
    echo "   Open: open $HTML_FILE"
}

# Generate and optionally open
generate_html

if [ "$1" = "open" ]; then
    open "$HTML_FILE"
fi
