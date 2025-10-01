#!/usr/bin/env python3
"""
MCP GitHub Integration Layer
Bridges bash scripts with MCP GitHub tools through Claude
Provides programmatic access to GitHub intelligence
"""

import json
import os
import subprocess
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional

INTELLIGENCE_FILE = Path.home() / ".claude/memory/github-intelligence.json"
CACHE_DIR = Path.home() / ".claude/cache/github"

CACHE_DIR.mkdir(parents=True, exist_ok=True)


class GitHubIntelligence:
    """GitHub intelligence data structure"""

    def __init__(self):
        self.data = self._load_intelligence()

    def _load_intelligence(self) -> dict:
        """Load intelligence from JSON file"""
        if INTELLIGENCE_FILE.exists():
            with open(INTELLIGENCE_FILE) as f:
                return json.load(f)
        return {
            "last_updated": "",
            "repositories": {},
            "suggestions": [],
            "alerts": [],
            "metrics": {
                "total_repos": 0,
                "uncommitted_files": 0,
                "unpushed_commits": 0,
                "open_prs": 0,
                "open_issues": 0,
            },
        }

    def save(self):
        """Save intelligence to JSON file"""
        self.data["last_updated"] = datetime.utcnow().isoformat() + "Z"
        with open(INTELLIGENCE_FILE, "w") as f:
            json.dump(self.data, f, indent=2)

    def get_suggestions(self, priority: Optional[str] = None) -> List[dict]:
        """Get suggestions, optionally filtered by priority"""
        suggestions = self.data.get("suggestions", [])
        if priority:
            return [s for s in suggestions if s.get("priority") == priority]
        return suggestions

    def get_repo_status(self, repo_name: str) -> Optional[dict]:
        """Get status for a specific repository"""
        return self.data.get("repositories", {}).get(repo_name)

    def get_metrics(self) -> dict:
        """Get overall metrics"""
        return self.data.get("metrics", {})

    def add_alert(self, alert: dict):
        """Add a new alert"""
        alerts = self.data.setdefault("alerts", [])
        alerts.append(
            {
                **alert,
                "timestamp": datetime.utcnow().isoformat() + "Z",
            }
        )
        self.save()

    def get_repositories_needing_attention(self) -> List[tuple]:
        """Get repos with uncommitted or unpushed changes"""
        repos = []
        for name, info in self.data.get("repositories", {}).items():
            status = info.get("status", {})
            uncommitted = status.get("uncommitted_files", 0)
            unpushed = status.get("unpushed_commits", 0)

            if uncommitted > 0 or unpushed > 0:
                repos.append((name, uncommitted, unpushed))

        return sorted(repos, key=lambda x: (x[1] + x[2]), reverse=True)


def run_github_scan():
    """Run the GitHub tracker scan"""
    script = Path.home() / ".claude/scripts/mcp-github-tracker.sh"
    subprocess.run([str(script), "scan"], check=True)


def get_actionable_summary() -> str:
    """Get human-readable summary of GitHub intelligence"""
    intel = GitHubIntelligence()
    metrics = intel.get_metrics()

    lines = ["GitHub Intelligence Summary", "=" * 40, ""]

    # Metrics
    lines.append("Metrics:")
    lines.append(f"  Total repos: {metrics.get('total_repos', 0)}")
    lines.append(f"  Uncommitted files: {metrics.get('uncommitted_files', 0)}")
    lines.append(f"  Unpushed commits: {metrics.get('unpushed_commits', 0)}")
    lines.append("")

    # High priority suggestions
    high_priority = intel.get_suggestions("high")
    if high_priority:
        lines.append("HIGH PRIORITY ACTIONS:")
        for s in high_priority:
            lines.append(f"  {s['repo']}: {s['message']}")
        lines.append("")

    # Repos needing attention
    repos = intel.get_repositories_needing_attention()
    if repos:
        lines.append("Repositories Needing Attention:")
        for name, uncommitted, unpushed in repos:
            status = []
            if uncommitted > 0:
                status.append(f"{uncommitted} uncommitted")
            if unpushed > 0:
                status.append(f"{unpushed} unpushed")
            lines.append(f"  {name}: {', '.join(status)}")
        lines.append("")

    return "\n".join(lines)


def check_repo_health(repo_name: str) -> dict:
    """Check health of a specific repository"""
    intel = GitHubIntelligence()
    repo_status = intel.get_repo_status(repo_name)

    if not repo_status:
        return {"status": "unknown", "message": f"Repository {repo_name} not tracked"}

    status = repo_status.get("status", {})
    issues = []

    uncommitted = status.get("uncommitted_files", 0)
    unpushed = status.get("unpushed_commits", 0)

    if uncommitted > 0:
        issues.append(f"{uncommitted} uncommitted files")
    if unpushed > 0:
        issues.append(f"{unpushed} unpushed commits")

    stale_branches = repo_status.get("stale_branches", [])
    if stale_branches:
        issues.append(f"{len(stale_branches)} stale branches")

    if not issues:
        return {"status": "healthy", "message": "No issues detected"}

    return {
        "status": "needs_attention",
        "issues": issues,
        "suggestions": repo_status.get("suggestions", []),
    }


def generate_daemon_report() -> dict:
    """Generate report for autonomous daemon"""
    intel = GitHubIntelligence()
    metrics = intel.get_metrics()

    # Determine if action needed
    action_needed = (
        metrics.get("uncommitted_files", 0) > 10
        or metrics.get("unpushed_commits", 0) > 5
    )

    return {
        "timestamp": datetime.utcnow().isoformat() + "Z",
        "action_needed": action_needed,
        "metrics": metrics,
        "high_priority_count": len(intel.get_suggestions("high")),
        "repos_needing_attention": len(intel.get_repositories_needing_attention()),
    }


if __name__ == "__main__":
    import sys

    if len(sys.argv) < 2:
        print("Usage: mcp-github-integration.py {scan|summary|check|daemon-report}")
        sys.exit(1)

    command = sys.argv[1]

    if command == "scan":
        run_github_scan()
        print("Scan complete")

    elif command == "summary":
        print(get_actionable_summary())

    elif command == "check":
        if len(sys.argv) < 3:
            print("Usage: mcp-github-integration.py check <repo-name>")
            sys.exit(1)
        repo_name = sys.argv[2]
        result = check_repo_health(repo_name)
        print(json.dumps(result, indent=2))

    elif command == "daemon-report":
        report = generate_daemon_report()
        print(json.dumps(report, indent=2))

    else:
        print(f"Unknown command: {command}")
        sys.exit(1)
