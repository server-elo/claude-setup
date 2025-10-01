#!/bin/bash
# Project health monitoring

PROJECT_DIR="${1:-.}"
PROJECT_NAME=$(basename "$PROJECT_DIR")

echo "🏥 Health Check: $PROJECT_NAME"
echo "================================"

# Python project checks
if [ -f "$PROJECT_DIR/requirements.txt" ]; then
  echo "✅ Python project detected"
  
  # Check venv
  if [ -d "$PROJECT_DIR/.venv" ]; then
    echo "  ✅ Virtual environment exists"
  else
    echo "  ⚠️  No virtual environment found"
  fi
  
  # Check if deps installed
  if [ -d "$PROJECT_DIR/.venv/lib" ]; then
    INSTALLED=$(ls "$PROJECT_DIR/.venv/lib/python"*/site-packages 2>/dev/null | wc -l)
    echo "  📦 $INSTALLED packages installed"
  fi
fi

# Node project checks
if [ -f "$PROJECT_DIR/package.json" ]; then
  echo "✅ Node.js project detected"
  
  if [ -d "$PROJECT_DIR/node_modules" ]; then
    echo "  ✅ node_modules exists"
  else
    echo "  ⚠️  No node_modules found"
  fi
fi

# Git checks
if [ -d "$PROJECT_DIR/.git" ]; then
  cd "$PROJECT_DIR"
  BRANCH=$(git branch --show-current)
  UNCOMMITTED=$(git status --short | wc -l)
  echo "🔀 Git: $BRANCH ($UNCOMMITTED uncommitted changes)"
fi

# File count
FILES=$(find "$PROJECT_DIR" -type f 2>/dev/null | wc -l)
echo "📁 Total files: $FILES"

echo "================================"
