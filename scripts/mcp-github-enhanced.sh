#!/bin/bash
# MCP GitHub Enhanced Tracker
# Extension functions that Claude can use with MCP GitHub tools

INTELLIGENCE_FILE=~/.claude/memory/github-intelligence.json

# Function: Request Claude to check GitHub PRs via MCP
request_pr_check() {
    local owner="$1"
    local repo="$2"

    cat << EOF
REQUEST TO CLAUDE:
When user next interacts, use MCP tools to check:

mcp__github__list_pull_requests({
  owner: "$owner",
  repo: "$repo",
  state: "open"
})

Then update $INTELLIGENCE_FILE with:
- Open PR count
- PRs with conflicts
- PRs awaiting review
- PRs older than 7 days
EOF
}

# Function: Request Claude to check GitHub issues via MCP
request_issue_check() {
    local owner="$1"
    local repo="$2"

    cat << EOF
REQUEST TO CLAUDE:
When user next interacts, use MCP tools to check:

mcp__github__list_issues({
  owner: "$owner",
  repo: "$repo",
  state: "open"
})

Then categorize issues by:
- Priority labels
- Bug vs feature
- Unassigned issues
- Issues mentioning "critical" or "urgent"
EOF
}

# Function: Request Claude to analyze commits via MCP
request_commit_analysis() {
    local owner="$1"
    local repo="$2"

    cat << EOF
REQUEST TO CLAUDE:
When user next interacts, use MCP tools to check:

mcp__github__list_commits({
  owner: "$owner",
  repo: "$repo",
  per_page: 20
})

Then analyze:
- Commit frequency
- Active contributors
- Commit message patterns
- Files frequently changed
EOF
}

# Function: Generate MCP integration wishlist
generate_mcp_wishlist() {
    echo "MCP GitHub Integration Wishlist"
    echo "================================"
    echo ""
    echo "When Claude is invoked with MCP tools, it can:"
    echo ""
    echo "1. PR Intelligence"
    echo "   - Check for open PRs across all tracked repos"
    echo "   - Detect merge conflicts"
    echo "   - Find PRs awaiting review"
    echo "   - Alert on stale PRs (7+ days old)"
    echo ""
    echo "2. Issue Intelligence"
    echo "   - Categorize issues by priority"
    echo "   - Find unassigned critical issues"
    echo "   - Track issue age and activity"
    echo "   - Suggest issue triage actions"
    echo ""
    echo "3. Commit Intelligence"
    echo "   - Analyze commit patterns"
    echo "   - Identify active contributors"
    echo "   - Detect code hotspots"
    echo "   - Compare local vs remote commits"
    echo ""
    echo "4. Repository Intelligence"
    echo "   - Search user's repositories"
    echo "   - Discover new projects"
    echo "   - Track repository health metrics"
    echo "   - Compare repository activity"
    echo ""
    echo "5. File Intelligence"
    echo "   - Compare local vs GitHub file contents"
    echo "   - Check for config drift"
    echo "   - Detect uncommitted changes remotely"
    echo "   - Analyze file change frequency"
    echo ""
}

# Function: Create MCP task template for Claude
create_mcp_task_template() {
    local task_type="$1"

    case "$task_type" in
        pr-check)
            cat << 'EOF'
# MCP Task: Check All Open PRs

## Objective
Use MCP GitHub tools to check all open pull requests across tracked repositories.

## Steps
1. Load github-intelligence.json
2. For each repository with github_remote:
   - Extract owner/repo from remote
   - Call mcp__github__list_pull_requests
   - Analyze PR status:
     * Has conflicts?
     * Awaiting review?
     * Older than 7 days?
     * Has failing checks?
3. Generate suggestions:
   - "PR #X has conflicts - suggest: resolve"
   - "PR #Y awaiting review for 10 days - suggest: review or close"
4. Update intelligence file with PR metrics
5. Log high-priority PR actions

## Expected Output
- Updated metrics.open_prs count
- New suggestions array with PR actions
- Alerts for critical PR issues
EOF
            ;;
        issue-triage)
            cat << 'EOF'
# MCP Task: Intelligent Issue Triage

## Objective
Use MCP GitHub tools to analyze and categorize all open issues.

## Steps
1. Load github-intelligence.json
2. For each repository with github_remote:
   - Call mcp__github__list_issues
   - Categorize by:
     * Priority labels
     * Bug vs feature
     * Has assignee?
     * Contains "critical" or "urgent"?
3. Generate suggestions:
   - "Issue #X critical bug unassigned - suggest: investigate"
   - "5 issues labeled 'bug' - suggest: triage session"
4. Update intelligence file with issue metrics
5. Prioritize by impact and urgency

## Expected Output
- Updated metrics.open_issues count
- Categorized issues by priority
- Actionable triage suggestions
EOF
            ;;
        sync-check)
            cat << 'EOF'
# MCP Task: Local vs Remote Sync Check

## Objective
Compare local repository state with GitHub remote using MCP tools.

## Steps
1. Load github-intelligence.json
2. For each repository:
   - Get local last commit (from status)
   - Call mcp__github__list_commits (limit: 1)
   - Compare:
     * Are they the same?
     * Is local behind?
     * Is local ahead? (we know from unpushed count)
3. Check if remote has changes not in local:
   - Suggest: "Remote has 3 new commits - suggest: git pull"
4. Cross-reference with unpushed commits:
   - Suggest: "Local has 2 unpushed, remote has 1 new - suggest: pull then push"

## Expected Output
- Sync status for each repository
- Alerts for diverged branches
- Suggestions for pull/push actions
EOF
            ;;
        *)
            echo "Unknown task type: $task_type"
            echo "Available: pr-check, issue-triage, sync-check"
            ;;
    esac
}

# Main
case "$1" in
    wishlist)
        generate_mcp_wishlist
        ;;
    task-template)
        create_mcp_task_template "$2"
        ;;
    request-pr)
        request_pr_check "$2" "$3"
        ;;
    request-issue)
        request_issue_check "$2" "$3"
        ;;
    request-commit)
        request_commit_analysis "$2" "$3"
        ;;
    *)
        echo "MCP GitHub Enhanced Tracker"
        echo ""
        echo "Usage: $0 {wishlist|task-template|request-pr|request-issue|request-commit}"
        echo ""
        echo "Commands:"
        echo "  wishlist              - Show MCP integration capabilities"
        echo "  task-template <type>  - Generate MCP task template (pr-check, issue-triage, sync-check)"
        echo "  request-pr <owner> <repo>     - Generate PR check request"
        echo "  request-issue <owner> <repo>  - Generate issue check request"
        echo "  request-commit <owner> <repo> - Generate commit analysis request"
        echo ""
        exit 1
        ;;
esac
