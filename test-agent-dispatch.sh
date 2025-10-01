#!/bin/bash
# Simulate error scenario to test auto-dispatch

echo "🧪 Testing Agent Auto-Dispatch"
echo "================================"

# Simulate broken Python script
cat > /tmp/broken_test.py << 'PYTHON'
def calculate_total():
    items = [1, 2, 3]
    # Bug: trying to access non-existent index
    return items[10]

if __name__ == "__main__":
    result = calculate_total()
    print(f"Total: {result}")
PYTHON

echo "📝 Created broken test script"
echo ""
echo "Running broken script (this should trigger error pattern detection)..."
python3 /tmp/broken_test.py 2>&1 | tee /tmp/error_output.txt
EXIT_CODE=$?

echo ""
echo "❌ Exit code: $EXIT_CODE"
echo ""
echo "Error logged to: /tmp/error_output.txt"
cat /tmp/error_output.txt

# Log to error patterns
echo "[$(date)] TEST: IndexError in calculate_total - items[10] out of range" >> ~/.claude/memory/error-patterns.txt

echo ""
echo "✅ Error pattern logged for learning"
echo "📊 Check: tail ~/.claude/memory/error-patterns.txt"
