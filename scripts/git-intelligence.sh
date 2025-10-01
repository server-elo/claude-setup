#!/bin/bash
# Git repository intelligence

# Track all git repos
discover_repos() {
    find ~/Desktop -name ".git" -type d 2>/dev/null | while read gitdir; do
        REPO=$(dirname "$gitdir")
        REPO_NAME=$(basename "$REPO")
        
        cd "$REPO"
        
        # Get repo state
        BRANCH=$(git branch --show-current 2>/dev/null)
        UNCOMMITTED=$(git status --short | wc -l | tr -d ' ')
        UNPUSHED=$(git log --branches --not --remotes | wc -l | tr -d ' ')
        LAST_COMMIT=$(git log -1 --format='%ar' 2>/dev/null)
        
        echo "{\"name\":\"$REPO_NAME\",\"branch\":\"$BRANCH\",\"uncommitted\":$UNCOMMITTED,\"unpushed\":$UNPUSHED,\"last_commit\":\"$LAST_COMMIT\"}"
    done | jq -s '.' > ~/.claude/memory/git-state.json
    
    echo "✅ Discovered $(jq length ~/.claude/memory/git-state.json) git repositories"
}

# Analyze commit patterns
analyze_commits() {
    REPO="$1"
    cd "$REPO"
    
    # Commit frequency
    git log --since="1 month ago" --format='%ad' --date=short | sort | uniq -c
    
    # Busiest files
    git log --since="1 month ago" --name-only --format='' | sort | uniq -c | sort -rn | head -10
}

# Suggest actions
suggest_actions() {
    jq -r '.[] | select(.uncommitted > 5) | "⚠️  \(.name): \(.uncommitted) uncommitted changes - consider committing"' \
        ~/.claude/memory/git-state.json
    
    jq -r '.[] | select(.unpushed > 0) | "📤 \(.name): \(.unpushed) unpushed commits - consider pushing"' \
        ~/.claude/memory/git-state.json
}

case "$1" in
    discover)
        discover_repos
        ;;
    analyze)
        analyze_commits "$2"
        ;;
    suggest)
        suggest_actions
        ;;
    *)
        echo "Usage: $0 {discover|analyze <repo>|suggest}"
        ;;
esac
