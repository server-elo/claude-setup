# 🌍 MAKING CLAUDE CODE CONFIGURATIONS GLOBAL

## Current Status ✅

### MCPs (WORKING GLOBALLY)
- ✅ GitHub MCP: `claude mcp add --scope user github npx @modelcontextprotocol/server-github`
- ✅ Filesystem MCP: `claude mcp add --scope user filesystem npx @modelcontextprotocol/server-filesystem`
- ✅ Puppeteer MCP: `claude mcp add --scope user puppeteer npx @modelcontextprotocol/server-puppeteer`
- ✅ Sentry MCP: `claude mcp add --scope user sentry https://mcp.sentry.dev/mcp --transport sse`
- ✅ Atlassian MCP: `claude mcp add --scope user atlassian https://mcp.atlassian.com/v1/sse --transport sse`
- ⚠️ SQLite MCP: `claude mcp add --scope user sqlite npx @modelcontextprotocol/server-sqlite` (needs npm install)

**These are stored in:** `~/.claude.json` and work across all terminals/projects.

## Pending: Make Everything Else Global 🔄

### Approach 1: Symlink Method (Most Common)
```bash
# Create global Claude config directory
mkdir -p ~/.config/claude

# Symlink our configurations
ln -sf ~/.claude/agents ~/.config/claude/agents
ln -sf ~/.claude/commands ~/.config/claude/commands
ln -sf ~/.claude/hooks ~/.config/claude/hooks
ln -sf ~/.claude/settings.json ~/.config/claude/settings.json
```

### Approach 2: Copy Method
```bash
# Copy configurations to global location
cp -r ~/.claude/agents ~/Library/Application\ Support/Claude/
cp -r ~/.claude/commands ~/Library/Application\ Support/Claude/
cp -r ~/.claude/hooks ~/Library/Application\ Support/Claude/
```

### Approach 3: Environment Variables
```bash
# Add to ~/.zshrc or ~/.bashrc
export CLAUDE_AGENTS_PATH="$HOME/.claude/agents"
export CLAUDE_COMMANDS_PATH="$HOME/.claude/commands"
export CLAUDE_HOOKS_PATH="$HOME/.claude/hooks"
```

### Approach 4: Global Template Directory
```bash
# Move entire .claude to global template location
mv ~/.claude ~/.claude-global
ln -sf ~/.claude-global ~/.claude
```

## Testing Commands

After setup, test from any directory:
```bash
cd /tmp
claude mcp list        # Should show all MCPs
claude agents list     # Should show all subagents (if supported)
claude commands list   # Should show all commands (if supported)
```

## Current Working Directory Issue

Since you experienced "No MCP servers configured" in another terminal, there might be:
1. **Session isolation** - Each Claude Code session is independent
2. **Directory dependency** - Claude Code might need to be run from specific directory
3. **Config loading issue** - Global config might not be loading properly

## Next Steps

1. **Test MCPs globally** - Confirm `claude mcp list` works from new terminal
2. **Find subagent global pattern** - Research/test how to make subagents global
3. **Find commands global pattern** - Research/test how to make slash commands global
4. **Find hooks global pattern** - Research/test how to make hooks global

## Alternative: Project Template Approach

If global configs don't work, we can create a **project template**:
```bash
# Create template
mkdir -p ~/.claude-template
cp -r ~/.claude/* ~/.claude-template/

# For each new project
cp -r ~/.claude-template/* ./
```

This would make our powerful setup available to any project by copying the template.