#!/bin/bash
# MCP GitHub Intelligence Tracker
# Discovers, monitors, and analyzes GitHub repositories for MAX POWER V3
# Uses MCP GitHub tools for deep repository intelligence

INTELLIGENCE_FILE=~/.claude/memory/github-intelligence.json
LOG=~/.claude/logs/github-tracker.log
CACHE_DIR=~/.claude/cache/github
CACHE_TTL=300  # 5 minutes cache for expensive operations

mkdir -p "$CACHE_DIR"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG"
}

# Initialize intelligence state
init_intelligence() {
    if [ ! -f "$INTELLIGENCE_FILE" ]; then
        cat > "$INTELLIGENCE_FILE" << 'EOJSON'
{
  "last_updated": "",
  "repositories": {},
  "suggestions": [],
  "alerts": [],
  "metrics": {
    "total_repos": 0,
    "uncommitted_files": 0,
    "unpushed_commits": 0,
    "open_prs": 0,
    "open_issues": 0
  }
}
EOJSON
    fi
}

# Check if cache is valid
is_cache_valid() {
    local cache_file="$1"
    if [ ! -f "$cache_file" ]; then
        return 1
    fi

    local cache_age=$(($(date +%s) - $(stat -f %m "$cache_file" 2>/dev/null || echo 0)))
    [ "$cache_age" -lt "$CACHE_TTL" ]
}

# Discover local git repositories in ~/Desktop
discover_local_repos() {
    log "Discovering local git repositories..."

    local repos=()
    for dir in ~/Desktop/*; do
        if [ -d "$dir/.git" ]; then
            local repo_name=$(basename "$dir")
            repos+=("$repo_name:$dir")
        fi
    done

    echo "${repos[@]}"
}

# Extract GitHub remote URL from local repo
get_github_remote() {
    local repo_path="$1"
    cd "$repo_path" 2>/dev/null || return 1

    # Get remote URL
    local remote_url=$(git remote get-url origin 2>/dev/null)

    if [[ "$remote_url" =~ github\.com[:/]([^/]+)/([^/.]+) ]]; then
        local owner="${BASH_REMATCH[1]}"
        local repo="${BASH_REMATCH[2]}"
        echo "$owner/$repo"
        return 0
    fi

    return 1
}

# Check local git status (fast, no MCP needed)
check_local_status() {
    local repo_path="$1"
    local repo_name="$2"

    cd "$repo_path" 2>/dev/null || return 1

    local status_json="{}"

    # Uncommitted changes
    local uncommitted=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
    status_json=$(echo "$status_json" | jq ".uncommitted_files = $uncommitted")

    # Get changed files list
    if [ "$uncommitted" -gt 0 ]; then
        local changed_files=$(git status --porcelain | head -10 | sed 's/^...//g' | jq -R . | jq -s .)
        status_json=$(echo "$status_json" | jq ".changed_files = $changed_files")
    fi

    # Unpushed commits
    local current_branch=$(git branch --show-current 2>/dev/null)
    local unpushed=0
    if [ ! -z "$current_branch" ]; then
        unpushed=$(git log origin/$current_branch..$current_branch 2>/dev/null | grep -c '^commit' || echo 0)
    fi
    status_json=$(echo "$status_json" | jq ".unpushed_commits = $unpushed")
    status_json=$(echo "$status_json" | jq ".current_branch = \"$current_branch\"")

    # Last commit info
    local last_commit=$(git log -1 --pretty=format:'%h|%s|%ar' 2>/dev/null)
    if [ ! -z "$last_commit" ]; then
        IFS='|' read -r hash message time <<< "$last_commit"
        status_json=$(echo "$status_json" | jq ".last_commit = {\"hash\": \"$hash\", \"message\": \"$message\", \"time\": \"$time\"}")
    fi

    echo "$status_json"
}

# Check for stale branches (not updated in 30+ days)
check_stale_branches() {
    local repo_path="$1"
    cd "$repo_path" 2>/dev/null || return 1

    local stale_branches=()
    local thirty_days_ago=$(date -v-30d +%s 2>/dev/null || date -d '30 days ago' +%s 2>/dev/null)

    while IFS= read -r branch; do
        branch=$(echo "$branch" | sed 's/^[* ]*//')
        local last_commit_date=$(git log -1 --format=%ct "$branch" 2>/dev/null)

        if [ ! -z "$last_commit_date" ] && [ "$last_commit_date" -lt "$thirty_days_ago" ]; then
            stale_branches+=("$branch")
        fi
    done < <(git branch -a | grep -v HEAD)

    if [ ${#stale_branches[@]} -gt 0 ]; then
        printf '%s\n' "${stale_branches[@]}" | jq -R . | jq -s .
    else
        echo "[]"
    fi
}

# Generate actionable suggestions
generate_suggestions() {
    local repo_name="$1"
    local repo_path="$2"
    local status="$3"

    local suggestions=()

    # Parse status
    local uncommitted=$(echo "$status" | jq -r '.uncommitted_files // 0')
    local unpushed=$(echo "$status" | jq -r '.unpushed_commits // 0')
    local branch=$(echo "$status" | jq -r '.current_branch // "unknown"')

    # Uncommitted files suggestion
    if [ "$uncommitted" -gt 0 ]; then
        if [ "$uncommitted" -ge 10 ]; then
            suggestions+=("{\"priority\": \"high\", \"repo\": \"$repo_name\", \"type\": \"commit\", \"message\": \"$uncommitted uncommitted files - suggest: review and commit in smaller chunks\"}")
        elif [ "$uncommitted" -ge 5 ]; then
            suggestions+=("{\"priority\": \"medium\", \"repo\": \"$repo_name\", \"type\": \"commit\", \"message\": \"$uncommitted uncommitted files - suggest: commit and push\"}")
        else
            suggestions+=("{\"priority\": \"low\", \"repo\": \"$repo_name\", \"type\": \"commit\", \"message\": \"$uncommitted uncommitted files\"}")
        fi
    fi

    # Unpushed commits suggestion
    if [ "$unpushed" -gt 0 ]; then
        suggestions+=("{\"priority\": \"medium\", \"repo\": \"$repo_name\", \"type\": \"push\", \"message\": \"$unpushed unpushed commits on $branch - suggest: git push\"}")
    fi

    # Check if on main/master without upstream
    if [[ "$branch" =~ ^(main|master)$ ]]; then
        if ! git rev-parse --abbrev-ref @{u} &>/dev/null; then
            suggestions+=("{\"priority\": \"low\", \"repo\": \"$repo_name\", \"type\": \"branch\", \"message\": \"No upstream tracking for $branch - suggest: set remote tracking\"}")
        fi
    fi

    # Output suggestions as JSON array
    if [ ${#suggestions[@]} -gt 0 ]; then
        printf '%s\n' "${suggestions[@]}" | jq -s .
    else
        echo "[]"
    fi
}

# Scan all tracked projects
scan_all_projects() {
    log "Starting GitHub intelligence scan..."
    init_intelligence

    local all_suggestions=()
    local all_alerts=()
    local total_uncommitted=0
    local total_unpushed=0
    local total_repos=0

    # Discover local repos
    local repos_data=$(discover_local_repos)

    # Build repositories object
    local repos_object="{}"

    for repo_info in $repos_data; do
        IFS=':' read -r repo_name repo_path <<< "$repo_info"

        log "Scanning $repo_name..."
        total_repos=$((total_repos + 1))

        # Get GitHub remote (if exists)
        local github_remote=$(get_github_remote "$repo_path")

        # Check local status
        local status=$(check_local_status "$repo_path" "$repo_name")

        # Check stale branches
        local stale_branches=$(check_stale_branches "$repo_path")

        # Generate suggestions
        local suggestions=$(generate_suggestions "$repo_name" "$repo_path" "$status")

        # Accumulate metrics
        local uncommitted=$(echo "$status" | jq -r '.uncommitted_files // 0')
        local unpushed=$(echo "$status" | jq -r '.unpushed_commits // 0')
        total_uncommitted=$((total_uncommitted + uncommitted))
        total_unpushed=$((total_unpushed + unpushed))

        # Build repo entry
        local repo_entry=$(jq -n \
            --arg path "$repo_path" \
            --arg remote "$github_remote" \
            --argjson status "$status" \
            --argjson stale "$stale_branches" \
            --argjson sugg "$suggestions" \
            '{
                path: $path,
                github_remote: $remote,
                status: $status,
                stale_branches: $stale,
                suggestions: $sugg,
                last_scanned: "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"
            }')

        repos_object=$(echo "$repos_object" | jq --arg name "$repo_name" --argjson entry "$repo_entry" '.[$name] = $entry')

        # Collect all suggestions
        if [ "$(echo "$suggestions" | jq 'length')" -gt 0 ]; then
            all_suggestions+=($(echo "$suggestions" | jq -c '.[]'))
        fi
    done

    # Build final intelligence object
    local intelligence=$(jq -n \
        --argjson repos "$repos_object" \
        --argjson sugg "$(printf '%s\n' "${all_suggestions[@]}" | jq -s . 2>/dev/null || echo '[]')" \
        --arg total "$total_repos" \
        --arg uncommitted "$total_uncommitted" \
        --arg unpushed "$total_unpushed" \
        '{
            last_updated: "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'",
            repositories: $repos,
            suggestions: $sugg,
            alerts: [],
            metrics: {
                total_repos: ($total | tonumber),
                uncommitted_files: ($uncommitted | tonumber),
                unpushed_commits: ($unpushed | tonumber),
                open_prs: 0,
                open_issues: 0
            }
        }')

    # Write to intelligence file
    echo "$intelligence" | jq . > "$INTELLIGENCE_FILE"

    log "Scan complete: $total_repos repos, $total_uncommitted uncommitted, $total_unpushed unpushed"
}

# Display actionable summary
show_summary() {
    if [ ! -f "$INTELLIGENCE_FILE" ]; then
        echo "No intelligence data. Run: $0 scan"
        return
    fi

    local data=$(cat "$INTELLIGENCE_FILE")

    echo "============================================"
    echo "GitHub Intelligence Summary"
    echo "============================================"
    echo ""

    # Metrics
    echo "Metrics:"
    echo "$data" | jq -r '.metrics | to_entries | .[] | "  \(.key): \(.value)"'
    echo ""

    # High priority suggestions
    local high_priority=$(echo "$data" | jq -r '.suggestions[] | select(.priority == "high")')
    if [ ! -z "$high_priority" ]; then
        echo "HIGH PRIORITY ACTIONS:"
        echo "$data" | jq -r '.suggestions[] | select(.priority == "high") | "  \(.repo): \(.message)"'
        echo ""
    fi

    # Medium priority suggestions
    local medium_priority=$(echo "$data" | jq -r '.suggestions[] | select(.priority == "medium")')
    if [ ! -z "$medium_priority" ]; then
        echo "SUGGESTED ACTIONS:"
        echo "$data" | jq -r '.suggestions[] | select(.priority == "medium") | "  \(.repo): \(.message)"'
        echo ""
    fi

    # Repository details
    echo "Repository Status:"
    echo "$data" | jq -r '.repositories | to_entries[] |
        "  \(.key):\n    Branch: \(.value.status.current_branch // "unknown")\n    Uncommitted: \(.value.status.uncommitted_files // 0)\n    Unpushed: \(.value.status.unpushed_commits // 0)"'
}

# Quick check mode (fast, for daemon)
quick_check() {
    local has_issues=0

    for dir in ~/Desktop/quantum ~/Desktop/RedTeam ~/Desktop/GuardrailProxy ~/Desktop/elvi/sofia-pers; do
        if [ -d "$dir/.git" ]; then
            cd "$dir"
            local repo_name=$(basename "$dir")

            # Check for uncommitted
            local uncommitted=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
            if [ "$uncommitted" -gt 5 ]; then
                log "[QUICK] $repo_name: $uncommitted uncommitted files"
                has_issues=1
            fi

            # Check for unpushed
            local branch=$(git branch --show-current 2>/dev/null)
            if [ ! -z "$branch" ]; then
                local unpushed=$(git log origin/$branch..$branch 2>/dev/null | grep -c '^commit' || echo 0)
                if [ "$unpushed" -gt 0 ]; then
                    log "[QUICK] $repo_name: $unpushed unpushed commits on $branch"
                    has_issues=1
                fi
            fi
        fi
    done

    return $has_issues
}

# Watch mode - continuous monitoring
watch_mode() {
    log "Starting watch mode (60s intervals)..."

    while true; do
        quick_check
        sleep 60
    done
}

# Export for autonomous daemon integration
daemon_integration() {
    # Quick check that can be called from v3-autonomous-daemon.sh
    quick_check

    if [ $? -eq 1 ]; then
        # Has issues - trigger full scan and update intelligence
        scan_all_projects > /dev/null 2>&1
    fi
}

# MCP GitHub API integration (placeholder for actual MCP calls)
# These would use the actual MCP tools when called from Claude
mcp_check_prs() {
    local owner="$1"
    local repo="$2"

    # This would call: mcp__github__list_pull_requests
    # For now, return empty as we don't have direct MCP access in bash
    echo "[]"
}

mcp_check_issues() {
    local owner="$1"
    local repo="$2"

    # This would call: mcp__github__list_issues
    echo "[]"
}

# Main command router
case "$1" in
    scan)
        scan_all_projects
        ;;
    summary|status)
        show_summary
        ;;
    quick)
        quick_check
        ;;
    watch)
        watch_mode
        ;;
    daemon)
        daemon_integration
        ;;
    *)
        echo "MCP GitHub Intelligence Tracker"
        echo ""
        echo "Usage: $0 {scan|summary|quick|watch|daemon}"
        echo ""
        echo "Commands:"
        echo "  scan     - Full scan of all repositories (writes to $INTELLIGENCE_FILE)"
        echo "  summary  - Display actionable summary"
        echo "  quick    - Fast check for issues (used by daemon)"
        echo "  watch    - Continuous monitoring mode"
        echo "  daemon   - Integration hook for autonomous daemon"
        echo ""
        echo "Files:"
        echo "  Intelligence: $INTELLIGENCE_FILE"
        echo "  Log: $LOG"
        echo ""
        exit 1
        ;;
esac
