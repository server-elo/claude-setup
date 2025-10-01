#!/bin/bash
# Generate dependency graph for a project

PROJECT_DIR="${1:-.}"
PROJECT_NAME=$(basename "$PROJECT_DIR")
OUTPUT="${2:-~/.claude/memory/projects/${PROJECT_NAME}-deps.json}"

echo "📊 Analyzing dependencies: $PROJECT_NAME"

DEPS='{"project":"'$PROJECT_NAME'","dependencies":[],"dev_dependencies":[],"system_requirements":[]}'

# Python
if [ -f "$PROJECT_DIR/requirements.txt" ]; then
  PYTHON_DEPS=$(cat "$PROJECT_DIR/requirements.txt" | grep -v "^#" | grep -v "^$" | jq -R -s 'split("\n") | map(select(length > 0))')
  DEPS=$(echo "$DEPS" | jq ".dependencies += $PYTHON_DEPS")
fi

# Node.js
if [ -f "$PROJECT_DIR/package.json" ]; then
  NODE_DEPS=$(jq -r '.dependencies // {} | keys[]' "$PROJECT_DIR/package.json" 2>/dev/null | jq -R -s 'split("\n") | map(select(length > 0))')
  NODE_DEV=$(jq -r '.devDependencies // {} | keys[]' "$PROJECT_DIR/package.json" 2>/dev/null | jq -R -s 'split("\n") | map(select(length > 0))')
  DEPS=$(echo "$DEPS" | jq ".dependencies += $NODE_DEPS | .dev_dependencies += $NODE_DEV")
fi

# System requirements
if command -v python3 &>/dev/null; then
  DEPS=$(echo "$DEPS" | jq '.system_requirements += ["python3"]')
fi
if command -v node &>/dev/null; then
  DEPS=$(echo "$DEPS" | jq '.system_requirements += ["node"]')
fi

echo "$DEPS" | jq '.' | tee "$OUTPUT"
echo "✅ Saved to $OUTPUT"
