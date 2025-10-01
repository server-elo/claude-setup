#!/bin/bash
# Establish performance baselines

PROJECT_DIR="${1:-.}"
PROJECT_NAME=$(basename "$PROJECT_DIR")
OUTPUT="~/.claude/memory/projects/${PROJECT_NAME}-perf.json"

echo "⚡ Performance baseline: $PROJECT_NAME"

START=$(date +%s%N)

# File operations
FILE_COUNT=$(fd -t f . "$PROJECT_DIR" 2>/dev/null | wc -l)
FILE_TIME=$(($(date +%s%N) - START))

# Search performance
START=$(date +%s%N)
SEARCH_RESULTS=$(rg -l "def |class |function " "$PROJECT_DIR" 2>/dev/null | wc -l)
SEARCH_TIME=$(($(date +%s%N) - START))

# Git operations (if applicable)
GIT_TIME=0
if [ -d "$PROJECT_DIR/.git" ]; then
  START=$(date +%s%N)
  git -C "$PROJECT_DIR" status --short &>/dev/null
  GIT_TIME=$(($(date +%s%N) - START))
fi

cat << EOJSON | tee "$OUTPUT"
{
  "project": "$PROJECT_NAME",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "metrics": {
    "file_count": $FILE_COUNT,
    "file_scan_ns": $FILE_TIME,
    "search_results": $SEARCH_RESULTS,
    "search_time_ns": $SEARCH_TIME,
    "git_status_ns": $GIT_TIME
  },
  "performance_grade": "baseline"
}
EOJSON
