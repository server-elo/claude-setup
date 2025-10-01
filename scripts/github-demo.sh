#!/bin/bash
# GitHub Intelligence Tracker - Live Demo
# Demonstrates tracking real repositories in ~/Desktop

echo "============================================"
echo "GitHub Intelligence Tracker - LIVE DEMO"
echo "============================================"
echo ""

# Make executable
chmod +x ~/.claude/scripts/mcp-github-tracker.sh
chmod +x ~/.claude/scripts/mcp-github-integration.py

echo "Step 1: Discovering repositories in ~/Desktop..."
echo ""

# Show what will be tracked
for dir in ~/Desktop/*; do
    if [ -d "$dir/.git" ]; then
        repo_name=$(basename "$dir")
        echo "  Found: $repo_name"

        cd "$dir"
        branch=$(git branch --show-current 2>/dev/null || echo "unknown")
        uncommitted=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
        remote=$(git remote get-url origin 2>/dev/null || echo "no remote")

        echo "    Branch: $branch"
        echo "    Uncommitted: $uncommitted files"
        echo "    Remote: $remote"
        echo ""
    fi
done

echo "============================================"
echo "Step 2: Running full intelligence scan..."
echo "============================================"
echo ""

~/.claude/scripts/mcp-github-tracker.sh scan

echo ""
echo "============================================"
echo "Step 3: Intelligence Summary"
echo "============================================"
echo ""

~/.claude/scripts/mcp-github-tracker.sh summary

echo ""
echo "============================================"
echo "Step 4: Python API - Daemon Report"
echo "============================================"
echo ""

python3 ~/.claude/scripts/mcp-github-integration.py daemon-report

echo ""
echo "============================================"
echo "Step 5: Raw Intelligence Data"
echo "============================================"
echo ""

if [ -f ~/.claude/memory/github-intelligence.json ]; then
    echo "Stored at: ~/.claude/memory/github-intelligence.json"
    echo ""
    jq -C . ~/.claude/memory/github-intelligence.json
else
    echo "Intelligence file not yet created. Run scan first."
fi

echo ""
echo "============================================"
echo "Step 6: Integration with Autonomous Daemon"
echo "============================================"
echo ""

echo "The v3-autonomous-daemon.sh monitor_git() function now uses:"
echo "  1. mcp-github-tracker.sh daemon (quick check)"
echo "  2. mcp-github-integration.py daemon-report (structured data)"
echo ""

echo "Check daemon status:"
~/.claude/scripts/v3-autonomous-daemon.sh status 2>/dev/null || echo "Daemon not running. Start with: ~/.claude/scripts/v3-autonomous-daemon.sh start"

echo ""
echo "============================================"
echo "Demo Complete!"
echo "============================================"
echo ""
echo "Your GitHub Intelligence Tracker is now:"
echo "  ✅ Tracking all ~/Desktop repositories"
echo "  ✅ Generating actionable suggestions"
echo "  ✅ Integrated with autonomous daemon"
echo "  ✅ Providing structured API access"
echo ""
echo "Next actions:"
echo "  - View logs: tail -f ~/.claude/logs/github-tracker.log"
echo "  - Check status: ~/.claude/scripts/mcp-github-tracker.sh summary"
echo "  - Watch live: ~/.claude/scripts/mcp-github-tracker.sh watch"
echo ""
