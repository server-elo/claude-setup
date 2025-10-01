#!/bin/bash
# GitHub Intelligence Tracker - Example Usage and Integration Guide

echo "============================================"
echo "MCP GitHub Intelligence Tracker Examples"
echo "============================================"
echo ""

# Make scripts executable
chmod +x ~/.claude/scripts/mcp-github-tracker.sh
chmod +x ~/.claude/scripts/mcp-github-integration.py

echo "1. Running Initial Scan"
echo "   Discovers all repos in ~/Desktop and analyzes them"
echo ""
~/.claude/scripts/mcp-github-tracker.sh scan
echo ""

echo "2. Display Summary"
echo "   Shows actionable intelligence and suggestions"
echo ""
~/.claude/scripts/mcp-github-tracker.sh summary
echo ""

echo "3. Python Integration - Daemon Report"
echo "   Structured output for autonomous systems"
echo ""
python3 ~/.claude/scripts/mcp-github-integration.py daemon-report
echo ""

echo "4. Python Integration - Human Summary"
echo ""
python3 ~/.claude/scripts/mcp-github-integration.py summary
echo ""

echo "5. Check Specific Repository Health"
echo "   Example: GuardrailProxy"
echo ""
python3 ~/.claude/scripts/mcp-github-integration.py check GuardrailProxy
echo ""

echo "6. Intelligence File Location"
echo "   ~/.claude/memory/github-intelligence.json"
echo ""
if [ -f ~/.claude/memory/github-intelligence.json ]; then
    echo "   Current data:"
    jq -C . ~/.claude/memory/github-intelligence.json | head -30
fi
echo ""

echo "============================================"
echo "Integration Points"
echo "============================================"
echo ""
echo "Autonomous Daemon Integration:"
echo "  The v3-autonomous-daemon.sh now calls:"
echo "  - mcp-github-tracker.sh daemon (quick check)"
echo "  - mcp-github-integration.py daemon-report (structured data)"
echo ""
echo "Manual Commands:"
echo "  Full scan:     ~/.claude/scripts/mcp-github-tracker.sh scan"
echo "  Quick check:   ~/.claude/scripts/mcp-github-tracker.sh quick"
echo "  Summary:       ~/.claude/scripts/mcp-github-tracker.sh summary"
echo "  Watch mode:    ~/.claude/scripts/mcp-github-tracker.sh watch"
echo ""
echo "Python API:"
echo "  Scan:          python3 ~/.claude/scripts/mcp-github-integration.py scan"
echo "  Summary:       python3 ~/.claude/scripts/mcp-github-integration.py summary"
echo "  Check repo:    python3 ~/.claude/scripts/mcp-github-integration.py check <name>"
echo "  Daemon report: python3 ~/.claude/scripts/mcp-github-integration.py daemon-report"
echo ""

echo "============================================"
echo "Example Outputs"
echo "============================================"
echo ""

# Example of what intelligent suggestions look like
cat << 'EOF'
Example Intelligence Output:

{
  "repositories": {
    "GuardrailProxy": {
      "path": "/Users/tolga/Desktop/GuardrailProxy",
      "github_remote": "owner/GuardrailProxy",
      "status": {
        "uncommitted_files": 3,
        "changed_files": ["src/main.py", "README.md", "config.yaml"],
        "unpushed_commits": 2,
        "current_branch": "feature/mcp-integration",
        "last_commit": {
          "hash": "a1b2c3d",
          "message": "Add MCP GitHub tools",
          "time": "2 hours ago"
        }
      },
      "suggestions": [
        {
          "priority": "medium",
          "repo": "GuardrailProxy",
          "type": "commit",
          "message": "3 uncommitted files - suggest: commit and push"
        }
      ]
    }
  },
  "suggestions": [
    {
      "priority": "high",
      "repo": "quantum",
      "type": "commit",
      "message": "12 uncommitted files - suggest: review and commit in smaller chunks"
    },
    {
      "priority": "medium",
      "repo": "GuardrailProxy",
      "type": "push",
      "message": "2 unpushed commits on feature/mcp-integration - suggest: git push"
    }
  ],
  "metrics": {
    "total_repos": 4,
    "uncommitted_files": 15,
    "unpushed_commits": 5,
    "open_prs": 0,
    "open_issues": 0
  }
}

Actionable Suggestions:
  - GuardrailProxy: 3 uncommitted files - commit and push
  - quantum: 12 uncommitted files - review and commit in smaller chunks
  - quantum: 5 unpushed commits on main - git push
  - sofia-pers: No upstream tracking for main - set remote tracking
EOF

echo ""
echo "============================================"
echo "Setup Complete!"
echo "============================================"
echo ""
echo "The GitHub Intelligence Tracker is now:"
echo "  ✅ Installed and executable"
echo "  ✅ Integrated with autonomous daemon"
echo "  ✅ Ready to track ~/Desktop repositories"
echo ""
echo "Next Steps:"
echo "  1. Run initial scan: ~/.claude/scripts/mcp-github-tracker.sh scan"
echo "  2. View summary: ~/.claude/scripts/mcp-github-tracker.sh summary"
echo "  3. The autonomous daemon will now monitor GitHub activity every 60s"
echo ""
