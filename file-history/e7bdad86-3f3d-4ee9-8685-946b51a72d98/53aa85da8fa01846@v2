#!/bin/bash
# Claude Code Response Interceptor
# Based on: MI9 (arXiv:2508.03858), AgentSight (arXiv:2508.02736)
# Purpose: Intercept Claude responses and enforce CLAUDE.md patterns

set -euo pipefail

CLAUDE_HOME="$HOME/.claude"
PATTERNS_FILE="$CLAUDE_HOME/system/patterns.json"
LOG_FILE="$CLAUDE_HOME/logs/interception.log"
ENFORCEMENT_LOG="$CLAUDE_HOME/logs/enforcement.log"

# Ensure directories exist
mkdir -p "$CLAUDE_HOME/system" "$CLAUDE_HOME/logs"

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

enforcement_log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" >> "$ENFORCEMENT_LOG"
}

# Pattern Matching Engine (AgentSight-inspired)
check_patterns() {
    local user_message="$1"
    local matched_patterns=()

    # Error/Debug patterns
    if echo "$user_message" | grep -iE '\b(error|bug|broken|crash|fail|not working)\b' >/dev/null 2>&1; then
        matched_patterns+=("DEBUG_MODE")
        log "Pattern matched: DEBUG_MODE"
    fi

    # Search patterns
    if echo "$user_message" | grep -iE '\b(where|find|locate|search)\b' >/dev/null 2>&1; then
        matched_patterns+=("SEMANTIC_SEARCH")
        log "Pattern matched: SEMANTIC_SEARCH"
    fi

    # Performance patterns
    if echo "$user_message" | grep -iE '\b(slow|performance|optimize|faster)\b' >/dev/null 2>&1; then
        matched_patterns+=("PERFORMANCE_MODE")
        log "Pattern matched: PERFORMANCE_MODE"
    fi

    # Complex task patterns
    if echo "$user_message" | grep -iE '\b(implement|build|create|add feature)\b' >/dev/null 2>&1; then
        matched_patterns+=("COMPLEX_TASK")
        log "Pattern matched: COMPLEX_TASK"
    fi

    # Security patterns
    if echo "$user_message" | grep -iE '\b(security|auth|password|vulnerability)\b' >/dev/null 2>&1; then
        matched_patterns+=("SECURITY_MODE")
        log "Pattern matched: SECURITY_MODE"
    fi

    # Ultrathink patterns
    if echo "$user_message" | grep -iE '\b(ultrathink|deep dive|analyze thoroughly)\b' >/dev/null 2>&1; then
        matched_patterns+=("MAX_POWER")
        log "Pattern matched: MAX_POWER"
    fi

    echo "${matched_patterns[@]}"
}

# Enforcement Engine (SentinelAgent-inspired)
enforce_behavior() {
    local patterns="$1"
    local enforcement_actions=()

    for pattern in $patterns; do
        case "$pattern" in
            DEBUG_MODE)
                enforcement_actions+=("Launch debugger agent in parallel")
                enforcement_actions+=("Check knowledge base for similar bugs")
                enforcement_actions+=("Generate 5 hypotheses")
                ;;
            SEMANTIC_SEARCH)
                enforcement_actions+=("Check code index first")
                enforcement_actions+=("Use semantic search not keyword grep")
                ;;
            PERFORMANCE_MODE)
                enforcement_actions+=("Launch performance engineer agent")
                enforcement_actions+=("Profile bottlenecks")
                ;;
            COMPLEX_TASK)
                enforcement_actions+=("Use TodoWrite tool")
                enforcement_actions+=("Dispatch specialist agents")
                ;;
            SECURITY_MODE)
                enforcement_actions+=("Launch security auditor agent")
                ;;
            MAX_POWER)
                enforcement_actions+=("Use full 16K token output")
                enforcement_actions+=("Launch all relevant agents in parallel")
                ;;
        esac
    done

    if [ ${#enforcement_actions[@]} -gt 0 ]; then
        enforcement_log "ENFORCEMENT TRIGGERED:"
        for action in "${enforcement_actions[@]}"; do
            enforcement_log "  → $action"
        done
    fi

    echo "${enforcement_actions[@]}"
}

# Main interception logic
intercept() {
    local user_message="$1"

    log "=== NEW INTERCEPTION ==="
    log "User message: $user_message"

    # Pattern matching
    local matched_patterns
    matched_patterns=$(check_patterns "$user_message")

    if [ -n "$matched_patterns" ]; then
        log "Matched patterns: $matched_patterns"

        # Enforce behaviors
        local actions
        actions=$(enforce_behavior "$matched_patterns")

        if [ -n "$actions" ]; then
            log "Enforcement actions: $actions"

            # Create enforcement directive file
            cat > "$CLAUDE_HOME/system/current_enforcement.txt" <<EOF
ACTIVE ENFORCEMENT:
Patterns detected: $matched_patterns

Required actions:
$(printf '%s\n' "${actions[@]}")

Timestamp: $(date +'%Y-%m-%d %H:%M:%S')
EOF

            echo "ENFORCEMENT_ACTIVE"
        else
            echo "NO_ENFORCEMENT"
        fi
    else
        log "No patterns matched"
        rm -f "$CLAUDE_HOME/system/current_enforcement.txt"
        echo "NO_PATTERNS"
    fi
}

# If called with argument, run interception
if [ $# -gt 0 ]; then
    intercept "$*"
fi
