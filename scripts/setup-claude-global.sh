#!/bin/bash

# Claude Code Global Setup Script
# This script makes Claude Code configurations available globally

set -euo pipefail

CLAUDE_MASTER_DIR="$HOME/.claude"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

echo "🚀 Setting up Claude Code Global Configuration..."

# Function to setup Claude in current directory
setup_claude_here() {
    local target_dir="${1:-.}"

    echo "📁 Setting up Claude Code in: $(realpath "$target_dir")"

    # Create .claude directory if it doesn't exist
    mkdir -p "$target_dir/.claude"

    # Create symlinks to master configuration
    ln -sf "$CLAUDE_MASTER_DIR/agents" "$target_dir/.claude/agents"
    ln -sf "$CLAUDE_MASTER_DIR/commands" "$target_dir/.claude/commands"
    ln -sf "$CLAUDE_MASTER_DIR/hooks" "$target_dir/.claude/hooks"
    ln -sf "$CLAUDE_MASTER_DIR/settings.json" "$target_dir/.claude/settings.json"

    # Copy project-level files (not symlink, so they can be customized)
    cp "$CLAUDE_MASTER_DIR/CLAUDE.md" "$target_dir/.claude/CLAUDE.md" 2>/dev/null || true
    cp "$CLAUDE_MASTER_DIR/enterprise-config.json" "$target_dir/.claude/enterprise-config.json" 2>/dev/null || true

    echo "✅ Claude Code configured with global agents, commands, and hooks!"
    echo "🔧 Run 'claude agents list' to see available subagents"
    echo "⚡ Run 'claude mcp list' to see available MCP servers"
}

# Function to setup global alias
setup_global_alias() {
    local shell_config=""

    if [[ "$SHELL" == *"zsh"* ]]; then
        shell_config="$HOME/.zshrc"
    elif [[ "$SHELL" == *"bash"* ]]; then
        shell_config="$HOME/.bashrc"
    else
        echo "⚠️  Unsupported shell: $SHELL"
        return 1
    fi

    # Add alias if not already present
    if ! grep -q "alias claude-setup" "$shell_config" 2>/dev/null; then
        echo "" >> "$shell_config"
        echo "# Claude Code Global Setup" >> "$shell_config"
        echo "alias claude-setup='$SCRIPT_DIR/setup-claude-global.sh here'" >> "$shell_config"
        echo "alias claude-init='$SCRIPT_DIR/setup-claude-global.sh here'" >> "$shell_config"
        echo "✅ Added 'claude-setup' and 'claude-init' aliases to $shell_config"
        echo "🔄 Run 'source $shell_config' or restart your terminal"
    else
        echo "ℹ️  Aliases already exist in $shell_config"
    fi
}

# Function to create a new project with Claude
create_claude_project() {
    local project_name="$1"

    if [[ -z "$project_name" ]]; then
        echo "❌ Please provide a project name"
        exit 1
    fi

    echo "🆕 Creating new Claude-enabled project: $project_name"
    mkdir -p "$project_name"
    cd "$project_name"

    setup_claude_here "."

    echo "🎉 Project '$project_name' created with full Claude Code setup!"
    echo "📁 cd $project_name && claude"
}

# Main command handling
case "${1:-help}" in
    "here"|".")
        setup_claude_here "."
        ;;
    "alias"|"global")
        setup_global_alias
        ;;
    "new"|"create")
        create_claude_project "${2:-}"
        ;;
    "help"|*)
        echo "🔧 Claude Code Global Setup Script"
        echo ""
        echo "Usage:"
        echo "  $0 here          # Setup Claude in current directory"
        echo "  $0 alias         # Add global aliases to shell config"
        echo "  $0 new <name>    # Create new project with Claude setup"
        echo "  $0 help          # Show this help"
        echo ""
        echo "Examples:"
        echo "  cd my-project && $0 here"
        echo "  $0 alias  # Then use 'claude-setup' command anywhere"
        echo "  $0 new my-awesome-project"
        echo ""
        echo "🎯 Master configuration: $CLAUDE_MASTER_DIR"
        ;;
esac