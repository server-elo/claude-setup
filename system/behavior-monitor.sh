#!/bin/bash
# Claude Behavior Monitor Daemon
# Based on: SentinelAgent (arXiv:2505.24201), Enforcement Agents (arXiv:2504.04070)
# Purpose: Monitor Claude's actual behavior and enforce CLAUDE.md compliance

set -euo pipefail

CLAUDE_HOME="$HOME/.claude"
MONITOR_LOG="$CLAUDE_HOME/logs/behavior-monitor.log"
VIOLATIONS_LOG="$CLAUDE_HOME/logs/violations.log"
COMPLIANCE_REPORT="$CLAUDE_HOME/reports/compliance.json"
PID_FILE="$CLAUDE_HOME/system/monitor.pid"

# Ensure directories exist
mkdir -p "$CLAUDE_HOME/logs" "$CLAUDE_HOME/reports" "$CLAUDE_HOME/system"

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" >> "$MONITOR_LOG"
}

violation() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] VIOLATION: $*" >> "$VIOLATIONS_LOG"
}

# Check if daemon is already running
check_running() {
    if [ -f "$PID_FILE" ]; then
        local pid
        pid=$(cat "$PID_FILE")
        if ps -p "$pid" > /dev/null 2>&1; then
            echo "Daemon already running with PID $pid"
            exit 1
        else
            rm -f "$PID_FILE"
        fi
    fi
}

# Monitor interactions.jsonl for rule compliance
monitor_interactions() {
    local interactions_file="$CLAUDE_HOME/memory/interactions.jsonl"

    if [ ! -f "$interactions_file" ]; then
        log "No interactions file found"
        return
    fi

    # Get last 10 interactions
    local recent_interactions
    recent_interactions=$(tail -10 "$interactions_file" 2>/dev/null || echo "")

    if [ -z "$recent_interactions" ]; then
        return
    fi

    # Check for rule violations

    # Rule 1: Check if TodoWrite was used for complex tasks
    if echo "$recent_interactions" | grep -q '"tool_calls".*"Task"' && \
       ! echo "$recent_interactions" | grep -q '"TodoWrite"'; then
        violation "Complex task detected but TodoWrite not used"
    fi

    # Rule 2: Check if parallel execution was used
    if echo "$recent_interactions" | grep -q '"multiple.*commands"' && \
       echo "$recent_interactions" | grep -q '"sequential"'; then
        violation "Multiple commands run sequentially instead of parallel"
    fi

    # Rule 3: Check if code index was checked before grep
    if echo "$recent_interactions" | grep -q '"Grep"' && \
       ! echo "$recent_interactions" | grep -q '"code-index"'; then
        violation "Grep used without checking code index first"
    fi

    # Rule 4: Check if project memory was loaded
    if echo "$recent_interactions" | grep -q '"new_session"' && \
       ! echo "$recent_interactions" | grep -q '"project.*memory"'; then
        violation "New session started without loading project memory"
    fi
}

# Build execution graph (SentinelAgent-inspired)
build_execution_graph() {
    local interactions_file="$CLAUDE_HOME/memory/interactions.jsonl"

    if [ ! -f "$interactions_file" ]; then
        return
    fi

    # Simple graph: count tool usage patterns
    local graph_data
    graph_data=$(jq -s 'group_by(.tool) | map({tool: .[0].tool, count: length})' "$interactions_file" 2>/dev/null || echo "[]")

    echo "$graph_data" > "$CLAUDE_HOME/reports/execution-graph.json"
    log "Execution graph updated"
}

# Anomaly detection
detect_anomalies() {
    local interactions_file="$CLAUDE_HOME/memory/interactions.jsonl"

    if [ ! -f "$interactions_file" ]; then
        return
    fi

    # Detect unusual patterns
    local recent_count
    recent_count=$(tail -100 "$interactions_file" 2>/dev/null | wc -l)

    # Anomaly: Too many failed commands
    local failed_count
    failed_count=$(tail -100 "$interactions_file" 2>/dev/null | grep -c '"status":"failed"' || echo "0")

    if [ "$failed_count" -gt 10 ]; then
        violation "ANOMALY: High failure rate ($failed_count/100)"
    fi

    # Anomaly: No agent usage in complex tasks
    local complex_tasks
    complex_tasks=$(tail -100 "$interactions_file" 2>/dev/null | grep -c '"complexity":"complex"' || echo "0")
    local agent_usage
    agent_usage=$(tail -100 "$interactions_file" 2>/dev/null | grep -c '"Task"' || echo "0")

    if [ "$complex_tasks" -gt 5 ] && [ "$agent_usage" -eq 0 ]; then
        violation "ANOMALY: Complex tasks without agent usage"
    fi
}

# Generate compliance report
generate_compliance_report() {
    local total_violations
    total_violations=$(wc -l < "$VIOLATIONS_LOG" 2>/dev/null || echo "0")

    local report
    report=$(cat <<EOF
{
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "total_violations": $total_violations,
  "recent_violations": $(tail -10 "$VIOLATIONS_LOG" 2>/dev/null | jq -R -s 'split("\n") | map(select(length > 0))' || echo "[]"),
  "compliance_score": $(echo "scale=2; 100 - ($total_violations * 2)" | bc || echo "100"),
  "status": "$([ "$total_violations" -lt 10 ] && echo "GOOD" || echo "NEEDS_IMPROVEMENT")"
}
EOF
)

    echo "$report" > "$COMPLIANCE_REPORT"
    log "Compliance report generated: $total_violations violations"
}

# Main monitoring loop
monitor_loop() {
    log "Behavior monitor started (PID: $$)"
    echo $$ > "$PID_FILE"

    while true; do
        # Monitor interactions
        monitor_interactions

        # Build execution graph
        build_execution_graph

        # Detect anomalies
        detect_anomalies

        # Generate compliance report
        generate_compliance_report

        # Sleep for 60 seconds
        sleep 60
    done
}

# Signal handlers
cleanup() {
    log "Behavior monitor stopped"
    rm -f "$PID_FILE"
    exit 0
}

trap cleanup SIGTERM SIGINT

# Start daemon
case "${1:-start}" in
    start)
        check_running
        monitor_loop
        ;;
    stop)
        if [ -f "$PID_FILE" ]; then
            kill "$(cat "$PID_FILE")" 2>/dev/null && echo "Daemon stopped" || echo "Failed to stop daemon"
            rm -f "$PID_FILE"
        else
            echo "Daemon not running"
        fi
        ;;
    status)
        if [ -f "$PID_FILE" ] && ps -p "$(cat "$PID_FILE")" > /dev/null 2>&1; then
            echo "Daemon running (PID: $(cat "$PID_FILE"))"
            cat "$COMPLIANCE_REPORT" 2>/dev/null || echo "No compliance report yet"
        else
            echo "Daemon not running"
        fi
        ;;
    *)
        echo "Usage: $0 {start|stop|status}"
        exit 1
        ;;
esac
