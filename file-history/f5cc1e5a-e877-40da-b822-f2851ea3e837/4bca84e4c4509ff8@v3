#!/bin/bash
# Fast Code Index Builder - Uses fd and proper JSON generation

set -euo pipefail

INDEX_DIR="$HOME/.claude/memory/code-index"
PROJECTS_DIR="$HOME/Desktop"
LOG="$HOME/.claude/logs/indexer.log"
TMP_INDEX="$INDEX_DIR/files.jsonl.tmp"

mkdir -p "$INDEX_DIR" "$(dirname "$LOG")" "$INDEX_DIR/by-project"

echo "🚀 Building code index..." | tee -a "$LOG"

# Remove old index
rm -f "$TMP_INDEX" "$INDEX_DIR/files.jsonl"

# Use fd if available (faster), fallback to find
if command -v fd &>/dev/null; then
    echo "📂 Using fd for fast file discovery..." | tee -a "$LOG"
    FILE_FINDER="fd -e py -e js -e ts -e go -e rs -e java -e cpp -e c -e h . '$PROJECTS_DIR'"
else
    echo "📂 Using find for file discovery..." | tee -a "$LOG"
    FILE_FINDER="find '$PROJECTS_DIR' -type f \( -name '*.py' -o -name '*.js' -o -name '*.ts' -o -name '*.go' -o -name '*.rs' -o -name '*.java' -o -name '*.cpp' -o -name '*.c' -o -name '*.h' \)"
fi

# Index files with proper JSON escaping
eval "$FILE_FINDER" 2>/dev/null | while IFS= read -r filepath; do
    # Skip if file doesn't exist or is too large (>5MB)
    [ -f "$filepath" ] || continue

    size=$(stat -f%z "$filepath" 2>/dev/null || stat -c%s "$filepath" 2>/dev/null || echo 0)
    [ "$size" -gt 5242880 ] && continue

    # Skip node_modules, .git, venv, etc.
    case "$filepath" in
        */node_modules/*|*/.git/*|*/.venv/*|*/venv/*|*/__pycache__/*|*/dist/*|*/build/*) continue ;;
    esac

    name=$(basename "$filepath")
    dir=$(dirname "$filepath")
    lines=$(wc -l < "$filepath" 2>/dev/null | tr -d ' ' || echo 0)

    # Generate valid JSON with proper escaping using jq
    printf '{"path":%s,"name":%s,"dir":%s,"lines":%d,"size":%d}\n' \
        "$(printf '%s' "$filepath" | jq -R .)" \
        "$(printf '%s' "$name" | jq -R .)" \
        "$(printf '%s' "$dir" | jq -R .)" \
        "$lines" \
        "$size" >> "$TMP_INDEX"
done

# Atomic move
if [ -f "$TMP_INDEX" ]; then
    mv "$TMP_INDEX" "$INDEX_DIR/files.jsonl"
else
    touch "$INDEX_DIR/files.jsonl"
fi

# Build symbol index
echo "🔎 Indexing symbols (functions, classes, types)..." | tee -a "$LOG"
rg '^(class|def|function|func|type|interface|const|let|var)\s+(\w+)' \
   "$PROJECTS_DIR" \
   --no-heading \
   --with-filename \
   --line-number \
   2>/dev/null | sort -u > "$INDEX_DIR/symbols.txt" || touch "$INDEX_DIR/symbols.txt"

# Build project-specific indexes
echo "📊 Creating project-specific indexes..." | tee -a "$LOG"
if [ -f "$INDEX_DIR/files.jsonl" ]; then
    jq -r '.dir' "$INDEX_DIR/files.jsonl" 2>/dev/null | \
        awk -F'/' '{
            for(i=1; i<=NF; i++) {
                if($i == "Desktop" && i<NF) {
                    print $(i+1);
                    break;
                }
            }
        }' | sort -u | while read -r project; do
            [ -n "$project" ] || continue
            grep "\"$PROJECTS_DIR/$project" "$INDEX_DIR/files.jsonl" > "$INDEX_DIR/by-project/$project.jsonl" 2>/dev/null || true
        done
fi

# Generate stats
total_files=$(wc -l < "$INDEX_DIR/files.jsonl" 2>/dev/null | tr -d ' ' || echo 0)
total_symbols=$(wc -l < "$INDEX_DIR/symbols.txt" 2>/dev/null | tr -d ' ' || echo 0)
total_size=$(stat -f%z "$INDEX_DIR/symbols.txt" 2>/dev/null || stat -c%s "$INDEX_DIR/symbols.txt" 2>/dev/null || echo 0)
size_mb=$((total_size / 1048576))

echo "✅ Indexed $total_files files, $total_symbols symbols" | tee -a "$LOG"
echo "📦 Index size: ${size_mb}MB" | tee -a "$LOG"
echo "📍 $INDEX_DIR" | tee -a "$LOG"

# Update metadata
cat > "$INDEX_DIR/metadata.json" <<EOF
{
  "version": "3.0",
  "built_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "total_files": $total_files,
  "total_symbols": $total_symbols,
  "index_size_mb": $size_mb,
  "projects_indexed": $(ls -1 "$INDEX_DIR/by-project" 2>/dev/null | wc -l | tr -d ' ')
}
EOF

echo "✨ Code index build complete!" | tee -a "$LOG"
