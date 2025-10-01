#!/bin/bash
# GitHub Intelligence System - Quick Status Check

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "GitHub Intelligence System - Status"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if scripts exist and are executable
echo "Component Status:"
echo ""

check_component() {
    local file="$1"
    local name="$2"

    if [ -f "$file" ]; then
        if [ -x "$file" ]; then
            echo "  ✅ $name - executable"
        else
            echo "  ⚠️  $name - not executable (run: chmod +x $file)"
        fi
    else
        echo "  ❌ $name - missing"
    fi
}

check_component ~/.claude/scripts/mcp-github-tracker.sh "GitHub Tracker (bash)"
check_component ~/.claude/scripts/mcp-github-integration.py "GitHub Integration (python)"
check_component ~/.claude/scripts/mcp-github-enhanced.sh "MCP Enhanced Helpers"
check_component ~/.claude/scripts/github-demo.sh "Demo Script"

echo ""
echo "Data Files:"
echo ""

check_data() {
    local file="$1"
    local name="$2"

    if [ -f "$file" ]; then
        local size=$(du -h "$file" | awk '{print $1}')
        local age=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M" "$file" 2>/dev/null || stat -c "%y" "$file" | cut -d'.' -f1)
        echo "  ✅ $name - $size (updated: $age)"
    else
        echo "  ⚡ $name - not yet created (run: mcp-github-tracker.sh scan)"
    fi
}

check_data ~/.claude/memory/github-intelligence.json "Intelligence Data"
check_data ~/.claude/logs/github-tracker.log "Tracker Log"

if [ -d ~/.claude/cache/github ]; then
    local cache_count=$(find ~/.claude/cache/github -type f 2>/dev/null | wc -l | tr -d ' ')
    echo "  ✅ Cache Directory - $cache_count files"
else
    echo "  ⚡ Cache Directory - will be created on first run"
fi

echo ""
echo "Integration Status:"
echo ""

# Check autonomous daemon integration
if grep -q "mcp-github-tracker.sh" ~/.claude/scripts/v3-autonomous-daemon.sh 2>/dev/null; then
    echo "  ✅ Autonomous Daemon Integration - active"

    # Check if daemon is running
    if [ -f ~/.claude/pids/autonomous-daemon.pid ] && kill -0 $(cat ~/.claude/pids/autonomous-daemon.pid) 2>/dev/null; then
        local cycles=$(jq -r '.cycles' ~/.claude/memory/autonomous-state.json 2>/dev/null || echo "unknown")
        echo "  ✅ Daemon Running - cycle $cycles"
    else
        echo "  ⚠️  Daemon Not Running - start with: v3-autonomous-daemon.sh start"
    fi
else
    echo "  ❌ Daemon Integration - not found"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Quick Actions:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  Run scan:     ~/.claude/scripts/mcp-github-tracker.sh scan"
echo "  View summary: ~/.claude/scripts/mcp-github-tracker.sh summary"
echo "  Live demo:    ~/.claude/scripts/github-demo.sh"
echo "  Full docs:    cat ~/.claude/GITHUB-INTELLIGENCE-READY.md"
echo ""

# Show current intelligence if available
if [ -f ~/.claude/memory/github-intelligence.json ]; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Current Intelligence Snapshot:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    local metrics=$(jq -r '.metrics' ~/.claude/memory/github-intelligence.json)
    local total_repos=$(echo "$metrics" | jq -r '.total_repos')
    local uncommitted=$(echo "$metrics" | jq -r '.uncommitted_files')
    local unpushed=$(echo "$metrics" | jq -r '.unpushed_commits')
    local last_updated=$(jq -r '.last_updated' ~/.claude/memory/github-intelligence.json)

    echo "  Tracked Repositories: $total_repos"
    echo "  Uncommitted Files: $uncommitted"
    echo "  Unpushed Commits: $unpushed"
    echo "  Last Updated: $last_updated"

    # Show high priority suggestions
    local high_count=$(jq -r '.suggestions | map(select(.priority == "high")) | length' ~/.claude/memory/github-intelligence.json)
    if [ "$high_count" -gt 0 ]; then
        echo ""
        echo "  ⚠️  HIGH PRIORITY: $high_count action(s) needed"
        echo ""
        jq -r '.suggestions[] | select(.priority == "high") | "    → \(.repo): \(.message)"' ~/.claude/memory/github-intelligence.json
    fi

    echo ""
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "System Status: $([ -f ~/.claude/memory/github-intelligence.json ] && echo '✅ OPERATIONAL' || echo '⚡ READY TO SCAN')"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
