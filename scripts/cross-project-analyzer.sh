#!/bin/bash
# Fast cross-project pattern analysis

echo "🔍 Cross-Project Intelligence"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Find common dependencies
echo "📦 Shared Dependencies:"
cat ~/Desktop/quantum/requirements.txt ~/Desktop/GuardrailProxy/requirements.txt 2>/dev/null | \
    grep -v "^#" | sort | uniq -d | head -5

# Find similar code patterns
echo ""
echo "🔁 Similar Functions:"
rg "^def \w+\(" ~/Desktop/quantum ~/Desktop/RedTeam ~/Desktop/GuardrailProxy --type py -h 2>/dev/null | \
    awk '{print $2}' | sort | uniq -c | sort -rn | awk '$1 > 1' | head -5

# Find common imports
echo ""
echo "📚 Common Imports:"
rg "^from \w+ import|^import \w+" ~/Desktop/quantum ~/Desktop/RedTeam ~/Desktop/GuardrailProxy --type py -h 2>/dev/null | \
    sort | uniq -c | sort -rn | head -5

# Database usage
echo ""
echo "💾 Database Usage:"
rg -l "sqlite|postgres|mysql|mongodb" ~/Desktop/quantum ~/Desktop/RedTeam ~/Desktop/GuardrailProxy --type py 2>/dev/null | \
    wc -l | xargs echo "Files with DB:"

# API frameworks
echo ""
echo "🌐 API Frameworks:"
rg -l "FastAPI|Flask|Django|Express" ~/Desktop/quantum ~/Desktop/RedTeam ~/Desktop/GuardrailProxy -i 2>/dev/null | \
    xargs -n1 basename | sort | uniq -c
