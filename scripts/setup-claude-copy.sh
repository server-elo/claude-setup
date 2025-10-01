#!/bin/bash

# Claude Code Global Setup Script (Copy Method)
# This script copies Claude Code configurations to any directory

set -euo pipefail

CLAUDE_MASTER_DIR="$HOME/.claude"

echo "🚀 Setting up Claude Code (Copy Method)..."

# Function to setup Claude in current directory
setup_claude_here() {
    local target_dir="${1:-.}"

    echo "📁 Setting up Claude Code in: $(realpath "$target_dir")"

    # Create .claude directory if it doesn't exist
    mkdir -p "$target_dir/.claude"

    # Copy all configurations (not symlink)
    cp -r "$CLAUDE_MASTER_DIR/agents" "$target_dir/.claude/"
    cp -r "$CLAUDE_MASTER_DIR/commands" "$target_dir/.claude/"
    cp -r "$CLAUDE_MASTER_DIR/hooks" "$target_dir/.claude/"
    cp "$CLAUDE_MASTER_DIR/settings.json" "$target_dir/.claude/"
    cp "$CLAUDE_MASTER_DIR/CLAUDE.md" "$target_dir/.claude/" 2>/dev/null || true
    cp "$CLAUDE_MASTER_DIR/enterprise-config.json" "$target_dir/.claude/" 2>/dev/null || true

    echo "✅ Claude Code configured with full local copies!"
    echo "🔧 Run 'claude agents list' to see available subagents"
    echo "⚡ Run 'claude mcp list' to see available MCP servers"
    echo "📝 All configurations copied locally - you can customize them for this project"
}

case "${1:-help}" in
    "here"|".")
        setup_claude_here "."
        ;;
    "help"|*)
        echo "🔧 Claude Code Global Setup Script (Copy Method)"
        echo ""
        echo "Usage:"
        echo "  $0 here          # Setup Claude in current directory"
        echo ""
        echo "🎯 Master configuration: $CLAUDE_MASTER_DIR"
        ;;
esac