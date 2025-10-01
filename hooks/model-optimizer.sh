#!/bin/bash

# Model Optimizer Hook - Intelligent model switching based on task complexity
# This hook analyzes task complexity and switches models for optimal performance

set -euo pipefail

# Configuration
LOG_FILE="$HOME/.claude/logs/model-optimization.log"
COMPLEXITY_FILE="/tmp/claude_task_complexity_$$"

# Model definitions
OPUS_MODEL="claude-opus-4-1-20250805"
SONNET_MODEL="claude-sonnet-4-20250514"
HAIKU_MODEL="claude-3-5-haiku-20241022"

# Ensure logs directory exists
mkdir -p "$(dirname "$LOG_FILE")"

# Function to analyze task complexity
analyze_task_complexity() {
    local task="$1"
    local complexity_score=0

    # Architecture and design keywords (high complexity)
    if echo "$task" | grep -qiE "(architect|design|system|infrastructure|scalability|performance|security audit|migration)"; then
        complexity_score=$((complexity_score + 30))
    fi

    # Multi-agent orchestration (high complexity)
    if echo "$task" | grep -qiE "(orchestrate|parallel|multi-agent|workflow|pipeline|coordinate)"; then
        complexity_score=$((complexity_score + 25))
    fi

    # Code review and analysis (medium-high complexity)
    if echo "$task" | grep -qiE "(review|analyze|debug|optimize|refactor|test)"; then
        complexity_score=$((complexity_score + 20))
    fi

    # Documentation and simple tasks (low complexity)
    if echo "$task" | grep -qiE "(document|comment|format|simple|quick|fix)"; then
        complexity_score=$((complexity_score + 10))
    fi

    # File operations and basic tasks (very low complexity)
    if echo "$task" | grep -qiE "(read|write|edit|list|find|grep|ls|cat)"; then
        complexity_score=$((complexity_score + 5))
    fi

    # Large file operations (increase complexity)
    if echo "$task" | grep -qiE "(large|big|huge|massive|entire|all|complete)"; then
        complexity_score=$((complexity_score + 15))
    fi

    # Multiple files/directories (increase complexity)
    local file_count=$(echo "$task" | grep -o "/" | wc -l | tr -d ' ')
    complexity_score=$((complexity_score + file_count * 3))

    echo "$complexity_score"
}

# Function to recommend model based on complexity
recommend_model() {
    local complexity="$1"

    if [[ $complexity -ge 50 ]]; then
        echo "$OPUS_MODEL"
    elif [[ $complexity -ge 20 ]]; then
        echo "$SONNET_MODEL"
    else
        echo "$HAIKU_MODEL"
    fi
}

# Function to get current model
get_current_model() {
    # Try to get from environment variable or default to Sonnet
    echo "${ANTHROPIC_MODEL:-$SONNET_MODEL}"
}

# Function to switch model if needed
switch_model_if_needed() {
    local recommended_model="$1"
    local current_model="$2"

    if [[ "$recommended_model" != "$current_model" ]]; then
        echo "🔄 Switching model for optimal performance:"
        echo "   From: $current_model"
        echo "   To: $recommended_model"

        # Note: Actual model switching would happen through Claude Code's /model command
        # This hook provides the recommendation
        echo "💡 Recommendation: Use /model command to switch to optimal model"

        # Log the recommendation
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Model recommendation: $recommended_model (complexity: $3)" >> "$LOG_FILE"

        return 0
    fi

    return 1
}

# Main execution based on hook trigger
case "${HOOK_TYPE:-pre}" in
    "pre")
        # Pre-execution: Analyze task and recommend model
        TASK_DESCRIPTION="${ARGUMENTS:-unknown}"

        echo "🧠 Analyzing task complexity..."
        COMPLEXITY=$(analyze_task_complexity "$TASK_DESCRIPTION")
        RECOMMENDED_MODEL=$(recommend_model "$COMPLEXITY")
        CURRENT_MODEL=$(get_current_model)

        echo "$COMPLEXITY" > "$COMPLEXITY_FILE"

        echo "📊 Task Complexity Analysis:"
        echo "   Task: $TASK_DESCRIPTION"
        echo "   Complexity Score: $COMPLEXITY/100"
        echo "   Current Model: $CURRENT_MODEL"
        echo "   Recommended Model: $RECOMMENDED_MODEL"

        if switch_model_if_needed "$RECOMMENDED_MODEL" "$CURRENT_MODEL" "$COMPLEXITY"; then
            echo ""
            echo "⚡ Performance Optimization Tip:"
            case "$RECOMMENDED_MODEL" in
                *"opus"*)
                    echo "   Using Opus for complex reasoning and architecture tasks"
                    ;;
                *"sonnet"*)
                    echo "   Using Sonnet for balanced performance and coding tasks"
                    ;;
                *"haiku"*)
                    echo "   Using Haiku for quick responses and simple operations"
                    ;;
            esac
        else
            echo "✅ Current model is optimal for this task"
        fi
        ;;

    "post")
        # Post-execution: Log performance metrics
        if [[ -f "$COMPLEXITY_FILE" ]]; then
            COMPLEXITY=$(cat "$COMPLEXITY_FILE")
            DURATION="${DURATION:-0}"

            echo "📈 Task Completion Metrics:"
            echo "   Complexity: $COMPLEXITY"
            echo "   Duration: ${DURATION}s"
            echo "   Model Used: $(get_current_model)"

            # Calculate efficiency score
            EFFICIENCY=0
            if [[ $DURATION -gt 0 ]]; then
                EFFICIENCY=$(echo "scale=2; 100 / ($DURATION * $COMPLEXITY / 100)" | bc 2>/dev/null || echo "0")
            fi

            echo "   Efficiency Score: $EFFICIENCY"

            # Log detailed metrics
            echo "$(date '+%Y-%m-%d %H:%M:%S') - Completed task (complexity: $COMPLEXITY, duration: ${DURATION}s, efficiency: $EFFICIENCY)" >> "$LOG_FILE"

            # Clean up
            rm -f "$COMPLEXITY_FILE"

            # Recommendations for future optimization
            if [[ $DURATION -gt 30 ]] && [[ $COMPLEXITY -lt 30 ]]; then
                echo ""
                echo "💡 Optimization Suggestion: Consider using Haiku model for faster simple tasks"
            elif [[ $DURATION -gt 60 ]] && [[ $COMPLEXITY -gt 70 ]]; then
                echo ""
                echo "💡 Optimization Suggestion: Consider breaking complex tasks into smaller subtasks"
            fi
        fi
        ;;
esac

# Model performance tracking
track_model_performance() {
    local model="$1"
    local complexity="$2"
    local duration="$3"

    PERF_FILE="$HOME/.claude/logs/model-performance.json"

    # Initialize performance file if it doesn't exist
    if [[ ! -f "$PERF_FILE" ]]; then
        echo '{"opus": {"total_tasks": 0, "avg_complexity": 0, "avg_duration": 0}, "sonnet": {"total_tasks": 0, "avg_complexity": 0, "avg_duration": 0}, "haiku": {"total_tasks": 0, "avg_complexity": 0, "avg_duration": 0}}' > "$PERF_FILE"
    fi

    # Update performance metrics (simplified version)
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Model: $model, Complexity: $complexity, Duration: $duration" >> "${PERF_FILE}.log"
}

echo "✅ Model optimization analysis completed"