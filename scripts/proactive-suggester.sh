#!/bin/bash

# ============================================================================
# PROACTIVE SUGGESTION ENGINE v1.0
# ============================================================================
# Anticipates user needs based on patterns, time, history, and context
# Confidence-ranked suggestions with learning feedback loop
# ============================================================================

CLAUDE_DIR="$HOME/.claude"
MEMORY_DIR="$CLAUDE_DIR/memory"
SUGGESTIONS_LOG="$MEMORY_DIR/suggestions.jsonl"
DASHBOARD="$MEMORY_DIR/dashboard.txt"
KNOWLEDGE_BASE="$MEMORY_DIR/knowledge-base.json"
INTERACTIONS="$MEMORY_DIR/interactions.jsonl"

# Ensure log exists
touch "$SUGGESTIONS_LOG"

# ============================================================================
# SIGNAL ANALYZERS
# ============================================================================

analyze_time_patterns() {
    # Detect what user typically does at this time/day
    local current_hour=$(date +%H)
    local current_day=$(date +%u)  # 1=Monday, 7=Sunday
    local current_time=$(date +%H:%M)

    # Analyze shell history for time patterns
    local history_file="$HOME/.zsh_history"

    if [ -f "$history_file" ]; then
        # Look for commands at similar times (within 2 hour window)
        local time_window_start=$((current_hour - 1))
        local time_window_end=$((current_hour + 1))

        # Extract project patterns from history
        local project_pattern=$(tail -500 "$history_file" | \
            grep -E "cd.*Desktop|cd.*sofia|cd.*quantum|cd.*elo" | \
            head -5 | \
            awk -F'/' '{print $(NF)}' | \
            sort | uniq -c | sort -rn | head -1)

        if [ -n "$project_pattern" ]; then
            echo "time_pattern:$project_pattern:$current_hour"
        fi
    fi
}

analyze_command_sequences() {
    # Detect repeated command patterns
    local history_file="$HOME/.zsh_history"

    if [ -f "$history_file" ]; then
        # Find common command sequences (A followed by B)
        tail -100 "$history_file" | \
            sed 's/.*;//' | \
            awk 'NR>1 {print prev, "→", $0} {prev=$0}' | \
            sort | uniq -c | sort -rn | head -3 | \
            while read count sequence; do
                if [ "$count" -gt 2 ]; then
                    echo "sequence:$sequence:$count"
                fi
            done
    fi
}

analyze_project_health() {
    # Check health of tracked projects
    local projects_dir="$HOME/Desktop"
    local suggestions=""

    # Check for uncommitted changes
    for project_dir in "$projects_dir"/{sofia1,quantum,elo-deu} \
                       "$projects_dir/elvi/sofia-pers" \
                       "$projects_dir/elvi/sofia-pers/local-voice-ai-agent"; do
        if [ -d "$project_dir/.git" ]; then
            cd "$project_dir" 2>/dev/null || continue
            local status=$(git status --short 2>/dev/null)
            if [ -n "$status" ]; then
                local file_count=$(echo "$status" | wc -l | tr -d ' ')
                echo "uncommitted:$(basename "$project_dir"):$file_count"
            fi
        fi
    done

    # Check for missing venvs in Python projects
    for project_dir in "$projects_dir/elvi/sofia-pers"/{,local-voice-ai-agent,sofia-integrated}; do
        if [ -f "$project_dir/requirements.txt" ] && [ ! -d "$project_dir/.venv" ]; then
            echo "missing_venv:$(basename "$project_dir"):high"
        fi
    done
}

analyze_git_intelligence() {
    # Smart git analysis
    local current_dir="$PWD"
    local suggestions=""

    if [ -d ".git" ]; then
        # Check branch status
        local branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
        local behind=$(git rev-list HEAD..origin/"$branch" --count 2>/dev/null)
        local ahead=$(git rev-list origin/"$branch"..HEAD --count 2>/dev/null)

        if [ "$behind" -gt 0 ]; then
            echo "git_behind:$branch:$behind"
        fi

        if [ "$ahead" -gt 0 ]; then
            echo "git_ahead:$branch:$ahead"
        fi

        # Check for stashed changes
        local stash_count=$(git stash list | wc -l | tr -d ' ')
        if [ "$stash_count" -gt 0 ]; then
            echo "git_stashes:$stash_count:review"
        fi
    fi
}

analyze_error_patterns() {
    # Detect recurring error patterns
    if [ -f "$INTERACTIONS" ]; then
        # Look for failed commands
        local recent_errors=$(tail -50 "$INTERACTIONS" | \
            jq -r 'select(.exit != null and .exit != 0) | .cmd' 2>/dev/null | \
            sort | uniq -c | sort -rn | head -3)

        if [ -n "$recent_errors" ]; then
            echo "$recent_errors" | while read count cmd; do
                if [ "$count" -gt 1 ]; then
                    echo "error_pattern:$cmd:$count"
                fi
            done
        fi

        # Check for venv-related errors
        local venv_errors=$(tail -50 "$INTERACTIONS" | \
            grep -c "ModuleNotFoundError\|pip install" 2>/dev/null || echo 0)
        if [ "$venv_errors" -gt 2 ]; then
            echo "venv_issue:pip_without_venv:$venv_errors"
        fi
    fi
}

analyze_file_modifications() {
    # Check recently modified files
    local project_root="$PWD"

    if [ -d "$project_root" ]; then
        # Find files modified in last 2 hours
        local recent_files=$(find "$project_root" -type f \
            -name "*.py" -o -name "*.js" -o -name "*.go" -o -name "*.rs" 2>/dev/null | \
            while read file; do
                if [ -f "$file" ]; then
                    local mod_time=$(stat -f %m "$file" 2>/dev/null || stat -c %Y "$file" 2>/dev/null)
                    local current_time=$(date +%s)
                    local age=$((current_time - mod_time))
                    if [ "$age" -lt 7200 ]; then  # 2 hours
                        echo "$file:$age"
                    fi
                fi
            done | head -5)

        if [ -n "$recent_files" ]; then
            echo "recent_edits:$recent_files"
        fi
    fi
}

# ============================================================================
# SUGGESTION GENERATOR
# ============================================================================

generate_suggestions() {
    local suggestions=()
    local now=$(date +%s)

    # Collect all signals
    local time_signals=$(analyze_time_patterns)
    local sequence_signals=$(analyze_command_sequences)
    local health_signals=$(analyze_project_health)
    local git_signals=$(analyze_git_intelligence)
    local error_signals=$(analyze_error_patterns)
    local file_signals=$(analyze_file_modifications)

    # Process time patterns
    if echo "$time_signals" | grep -q "time_pattern"; then
        local project=$(echo "$time_signals" | grep "time_pattern" | cut -d: -f2 | awk '{print $1}')
        local hour=$(echo "$time_signals" | grep "time_pattern" | cut -d: -f3)
        suggestions+=("{\"type\":\"time_pattern\",\"message\":\"You often work on $project at this time\",\"action\":\"cd ~/Desktop/*/$project\",\"confidence\":75,\"priority\":\"medium\"}")
    fi

    # Process uncommitted changes
    while IFS=: read -r type project count; do
        if [ "$type" = "uncommitted" ] && [ -n "$project" ] && [ -n "$count" ]; then
            # Clean count value
            count=$(echo "$count" | tr -d ' ')
            local conf=80
            [ "$count" -gt 10 ] 2>/dev/null && conf=90
            suggestions+=("{\"type\":\"git_uncommitted\",\"message\":\"$project has $count uncommitted changes\",\"action\":\"cd ~/Desktop/*/$project && git status\",\"confidence\":$conf,\"priority\":\"high\"}")
        fi
    done < <(echo "$health_signals")

    # Process missing venvs
    if echo "$health_signals" | grep -q "missing_venv"; then
        local project=$(echo "$health_signals" | grep "missing_venv" | cut -d: -f2)
        suggestions+=("{\"type\":\"missing_venv\",\"message\":\"Python project $project missing virtual environment\",\"action\":\"cd ~/Desktop/*/$project && python3 -m venv .venv\",\"confidence\":85,\"priority\":\"medium\"}")
    fi

    # Process git behind/ahead
    if echo "$git_signals" | grep -q "git_behind"; then
        local branch=$(echo "$git_signals" | grep "git_behind" | cut -d: -f2)
        local count=$(echo "$git_signals" | grep "git_behind" | cut -d: -f3)
        suggestions+=("{\"type\":\"git_behind\",\"message\":\"Branch $branch is $count commits behind origin\",\"action\":\"git pull\",\"confidence\":90,\"priority\":\"high\"}")
    fi

    if echo "$git_signals" | grep -q "git_ahead"; then
        local branch=$(echo "$git_signals" | grep "git_ahead" | cut -d: -f2)
        local count=$(echo "$git_signals" | grep "git_ahead" | cut -d: -f3)
        suggestions+=("{\"type\":\"git_ahead\",\"message\":\"Branch $branch has $count unpushed commits\",\"action\":\"git push\",\"confidence\":85,\"priority\":\"medium\"}")
    fi

    # Process error patterns
    if echo "$error_signals" | grep -q "venv_issue"; then
        local count=$(echo "$error_signals" | grep "venv_issue" | cut -d: -f3)
        suggestions+=("{\"type\":\"venv_warning\",\"message\":\"Detected $count pip installs without venv - activate venv first\",\"action\":\"source .venv/bin/activate\",\"confidence\":88,\"priority\":\"high\"}")
    fi

    # Process command sequences
    if echo "$sequence_signals" | grep -q "→"; then
        local sequence=$(echo "$sequence_signals" | head -1 | grep "sequence" | cut -d: -f2-)
        if [ -n "$sequence" ]; then
            suggestions+=("{\"type\":\"command_sequence\",\"message\":\"Common pattern detected: $sequence\",\"action\":\"Create alias for this sequence?\",\"confidence\":70,\"priority\":\"low\"}")
        fi
    fi

    # Recent file edits → suggest testing
    if [ -n "$file_signals" ] && echo "$file_signals" | grep -q "recent_edits"; then
        local file_count=$(echo "$file_signals" | grep "recent_edits" | cut -d: -f2 | wc -l)
        if [ "$file_count" -gt 0 ]; then
            suggestions+=("{\"type\":\"test_suggestion\",\"message\":\"$file_count files modified recently - run tests?\",\"action\":\"pytest OR npm test\",\"confidence\":72,\"priority\":\"medium\"}")
        fi
    fi

    # Sofia project specific patterns
    if echo "$PWD" | grep -q "sofia"; then
        # Check if console script exists
        if [ -f "./start_sofia.sh" ] || [ -f "./run_console.sh" ]; then
            local last_run=$(tail -20 "$HOME/.zsh_history" | grep -c "start_sofia\|run_console" || echo 0)
            if [ "$last_run" -gt 3 ]; then
                suggestions+=("{\"type\":\"sofia_pattern\",\"message\":\"Frequent console runs detected - create alias?\",\"action\":\"alias sofia-console='cd ~/Desktop/elvi/sofia-pers && ./start_sofia.sh'\",\"confidence\":82,\"priority\":\"low\"}")
            fi
        fi
    fi

    # Print all suggestions as JSON array
    if [ ${#suggestions[@]} -gt 0 ]; then
        echo "["
        for i in "${!suggestions[@]}"; do
            echo "  ${suggestions[$i]}"
            if [ $i -lt $((${#suggestions[@]} - 1)) ]; then
                echo ","
            fi
        done
        echo "]"
    else
        echo "[]"
    fi
}

# ============================================================================
# RANKING ENGINE
# ============================================================================

rank_suggestions() {
    local suggestions="$1"

    # Parse suggestions and calculate final confidence scores
    echo "$suggestions" | jq -c '.[]' | while read -r suggestion; do
        local type=$(echo "$suggestion" | jq -r '.type')
        local confidence=$(echo "$suggestion" | jq -r '.confidence')
        local priority=$(echo "$suggestion" | jq -r '.priority')

        # Adjust confidence based on historical acceptance
        if [ -f "$SUGGESTIONS_LOG" ]; then
            local acceptance_rate=$(grep "\"type\":\"$type\"" "$SUGGESTIONS_LOG" | \
                jq -s '[.[] | select(.accepted == true)] | length' 2>/dev/null || echo 0)
            local total_shown=$(grep "\"type\":\"$type\"" "$SUGGESTIONS_LOG" | wc -l | tr -d ' ')

            if [ "$total_shown" -gt 0 ]; then
                local rate=$((acceptance_rate * 100 / total_shown))
                # Adjust confidence by acceptance rate
                confidence=$((confidence + rate / 10))
                [ "$confidence" -gt 100 ] && confidence=100
            fi
        fi

        # Priority boost
        case "$priority" in
            high) confidence=$((confidence + 5)) ;;
            low) confidence=$((confidence - 5)) ;;
        esac

        # Recency boost (recent patterns are more relevant)
        local hour=$(date +%H)
        if [ "$hour" -ge 9 ] && [ "$hour" -le 18 ]; then
            confidence=$((confidence + 3))  # Work hours boost
        fi

        # Output adjusted suggestion
        echo "$suggestion" | jq --arg conf "$confidence" '.confidence = ($conf | tonumber)'
    done | jq -s 'sort_by(-.confidence)'
}

# ============================================================================
# PROACTIVE BEHAVIORS (AUTO-EXECUTE)
# ============================================================================

execute_proactive_actions() {
    local current_dir="$PWD"

    # 1. Auto-activate venv before pip
    if echo "$current_dir" | grep -qE "sofia|quantum|elo"; then
        if [ -f "$current_dir/.venv/bin/activate" ]; then
            # Check if venv is activated
            if [ -z "$VIRTUAL_ENV" ]; then
                echo "proactive_action:venv_activate:$current_dir/.venv"
            fi
        fi
    fi

    # 2. Pre-load context by time
    local hour=$(date +%H)
    if [ "$hour" -ge 9 ] && [ "$hour" -le 12 ]; then
        # Morning: suggest daily standup/review
        echo "proactive_action:morning_review:git status && git log -3"
    fi

    # 3. Warn before common errors
    local last_cmd=$(tail -1 "$HOME/.zsh_history" | sed 's/.*;//')
    if echo "$last_cmd" | grep -q "pip install" && [ -z "$VIRTUAL_ENV" ]; then
        echo "proactive_warning:pip_without_venv:Activate venv first"
    fi

    # 4. Suggest commits before project switch
    if [ -d ".git" ]; then
        local uncommitted=$(git status --short | wc -l | tr -d ' ')
        if [ "$uncommitted" -gt 0 ]; then
            local pwd_hash=$(echo "$PWD" | md5sum | cut -d' ' -f1 2>/dev/null || echo "$PWD" | md5)
            local last_dir=$(cat "$MEMORY_DIR/.last_dir" 2>/dev/null || echo "")

            if [ "$pwd_hash" != "$last_dir" ] && [ -n "$last_dir" ]; then
                echo "proactive_suggestion:commit_before_switch:$uncommitted files uncommitted"
            fi

            echo "$pwd_hash" > "$MEMORY_DIR/.last_dir"
        fi
    fi
}

# ============================================================================
# LEARNING & FEEDBACK
# ============================================================================

log_suggestion() {
    local suggestion="$1"
    local shown="$2"  # true/false
    local accepted="$3"  # true/false/null (if not yet acted upon)
    local timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    local log_entry=$(echo "$suggestion" | jq \
        --arg ts "$timestamp" \
        --arg shown "$shown" \
        --arg accepted "$accepted" \
        '. + {timestamp: $ts, shown: ($shown | test("true")), accepted: (if $accepted == "null" then null else ($accepted | test("true")) end)}')

    echo "$log_entry" >> "$SUGGESTIONS_LOG"
}

# ============================================================================
# DASHBOARD INTEGRATION
# ============================================================================

update_dashboard() {
    local suggestions="$1"

    # Get top 3 suggestions
    local top_suggestions=$(echo "$suggestions" | jq -r '.[] | select(.confidence > 70) | "  [\(.confidence)%] \(.message)"' | head -3)

    if [ -n "$top_suggestions" ]; then
        # Update dashboard with suggestions
        local temp_dashboard=$(mktemp)

        if [ -f "$DASHBOARD" ]; then
            # Remove old suggestions section
            sed '/^## 🔮 PROACTIVE SUGGESTIONS/,/^## [^P]/{ /^## [^P]/!d; }' "$DASHBOARD" > "$temp_dashboard"

            # Insert new suggestions
            echo "" >> "$temp_dashboard"
            echo "## 🔮 PROACTIVE SUGGESTIONS (Top 3)" >> "$temp_dashboard"
            echo "$top_suggestions" >> "$temp_dashboard"
            echo "" >> "$temp_dashboard"

            mv "$temp_dashboard" "$DASHBOARD"
        fi
    fi
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

main() {
    local mode="${1:-analyze}"

    case "$mode" in
        analyze)
            # Full analysis and suggestion generation
            local suggestions=$(generate_suggestions)
            local ranked=$(rank_suggestions "$suggestions")

            # Filter: only show >70% confidence
            local filtered=$(echo "$ranked" | jq '[.[] | select(.confidence > 70)]')

            # Log suggestions
            echo "$filtered" | jq -c '.[]' | while read -r suggestion; do
                log_suggestion "$suggestion" "true" "null"
            done

            # Update dashboard
            update_dashboard "$filtered"

            # Output suggestions
            if [ "$(echo "$filtered" | jq '. | length')" -gt 0 ]; then
                echo "$filtered" | jq -r '.[] | "[\(.confidence)%] \(.message)\n   → \(.action)\n"' | head -9
            else
                echo "No high-confidence suggestions at this time."
            fi
            ;;

        proactive)
            # Execute proactive actions
            execute_proactive_actions
            ;;

        feedback)
            # Record feedback (suggestion accepted/rejected)
            local suggestion_type="$2"
            local accepted="$3"  # true/false

            if [ -n "$suggestion_type" ] && [ -n "$accepted" ]; then
                # Find most recent suggestion of this type and update
                local last_suggestion=$(grep "\"type\":\"$suggestion_type\"" "$SUGGESTIONS_LOG" | tail -1)
                if [ -n "$last_suggestion" ]; then
                    local updated=$(echo "$last_suggestion" | jq --arg acc "$accepted" '.accepted = ($acc | test("true"))')
                    echo "$updated" >> "$SUGGESTIONS_LOG"
                    echo "Feedback recorded: $suggestion_type → $accepted"
                fi
            fi
            ;;

        stats)
            # Show statistics
            if [ -f "$SUGGESTIONS_LOG" ]; then
                echo "=== SUGGESTION STATISTICS ==="
                echo ""
                echo "Total suggestions shown: $(wc -l < "$SUGGESTIONS_LOG")"
                echo ""
                echo "By type:"
                jq -r '.type' "$SUGGESTIONS_LOG" | sort | uniq -c | sort -rn
                echo ""
                echo "Acceptance rate by type:"
                jq -r 'select(.accepted != null) | "\(.type):\(.accepted)"' "$SUGGESTIONS_LOG" | \
                    awk -F: '{arr[$1" "$2]++} END {for (key in arr) print key, arr[key]}' | \
                    sort
            else
                echo "No statistics available yet."
            fi
            ;;

        *)
            echo "Usage: $0 {analyze|proactive|feedback|stats}"
            echo ""
            echo "  analyze    - Generate and rank suggestions"
            echo "  proactive  - Execute proactive behaviors"
            echo "  feedback   - Record user feedback (type accepted/rejected)"
            echo "  stats      - Show suggestion statistics"
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
