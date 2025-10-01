#!/bin/bash
# Analyze patterns ACROSS all projects

echo "🔍 Cross-Project Intelligence Analysis"
echo "======================================="

# Find common patterns
echo "Common imports:"
rg "^import |^from " ~/Desktop/*/. --type py -h 2>/dev/null | sort | uniq -c | sort -rn | head -10

echo ""
echo "Common function names:"
rg "def (\w+)" ~/Desktop/*/. --type py -o -r '$1' 2>/dev/null | sort | uniq -c | sort -rn | head -10

echo ""
echo "Common class patterns:"
rg "class (\w+)" ~/Desktop/*/. --type py -o -r '$1' 2>/dev/null | sort | uniq -c | sort -rn | head -10

echo ""
echo "API patterns:"
rg "FastAPI|Flask|express|@app\.|@router\." ~/Desktop/*/. -i -c 2>/dev/null | awk -F: '{print $1}' | xargs basename | sort | uniq -c

echo ""
echo "Database patterns:"
rg "SQLAlchemy|sqlalchemy|sqlite3|postgres|mysql" ~/Desktop/*/. -i -c 2>/dev/null | awk -F: '{sum+=$2} END {print "DB usage intensity:", sum}'

echo ""
echo "AI/LLM usage:"
rg "openai|anthropic|google\.generativeai|gemini|claude|gpt" ~/Desktop/*/. -i -l 2>/dev/null | wc -l | xargs echo "Projects using LLMs:"

