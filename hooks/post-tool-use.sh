#!/bin/bash

# PostToolUse Hook - Executes after tool completion
# Environment Variables Available:
# - TOOL_NAME: Name of the tool that was used
# - FILE_PATH: Path to file that was modified (for Edit/Write tools)
# - ARGUMENTS: Tool arguments
# - EXIT_CODE: Tool exit code (0 = success)

set -euo pipefail

# Log the tool completion
echo "$(date '+%Y-%m-%d %H:%M:%S') - PostToolUse: ${TOOL_NAME} completed with exit code ${EXIT_CODE:-0}" >> ~/.claude/logs/tool-usage.log

# Handle successful file modifications
if [[ "$TOOL_NAME" == "Edit" || "$TOOL_NAME" == "Write" ]] && [[ "${EXIT_CODE:-0}" == "0" ]]; then
    if [[ -n "${FILE_PATH:-}" && -f "$FILE_PATH" ]]; then
        echo "✅ File modified successfully: $FILE_PATH"

        # Run appropriate linting/checking based on file type
        case "${FILE_PATH##*.}" in
            js|jsx|ts|tsx)
                # ESLint check
                if command -v eslint >/dev/null 2>&1; then
                    echo "🔍 Running ESLint check..."
                    if eslint "$FILE_PATH" 2>/dev/null; then
                        echo "✅ ESLint: No issues found"
                    else
                        echo "⚠️ ESLint: Issues detected (run 'eslint $FILE_PATH' for details)"
                    fi
                fi

                # TypeScript check for .ts/.tsx files
                if [[ "$FILE_PATH" =~ \.(ts|tsx)$ ]] && command -v tsc >/dev/null 2>&1; then
                    echo "🔍 Running TypeScript type check..."
                    if tsc --noEmit "$FILE_PATH" 2>/dev/null; then
                        echo "✅ TypeScript: No type errors"
                    else
                        echo "⚠️ TypeScript: Type errors detected"
                    fi
                fi
                ;;

            py)
                # Python syntax check
                if command -v python3 >/dev/null 2>&1; then
                    echo "🔍 Checking Python syntax..."
                    if python3 -m py_compile "$FILE_PATH" 2>/dev/null; then
                        echo "✅ Python: Syntax is valid"
                    else
                        echo "⚠️ Python: Syntax errors detected"
                    fi
                fi

                # Flake8 check
                if command -v flake8 >/dev/null 2>&1; then
                    echo "🔍 Running Flake8 check..."
                    if flake8 "$FILE_PATH" 2>/dev/null; then
                        echo "✅ Flake8: No issues found"
                    else
                        echo "⚠️ Flake8: Issues detected"
                    fi
                fi
                ;;

            go)
                # Go format and vet
                if command -v go >/dev/null 2>&1; then
                    echo "🔍 Running Go checks..."
                    if go vet "$FILE_PATH" 2>/dev/null; then
                        echo "✅ Go vet: No issues found"
                    else
                        echo "⚠️ Go vet: Issues detected"
                    fi
                fi
                ;;

            json)
                # JSON validation
                if command -v jq >/dev/null 2>&1; then
                    echo "🔍 Validating JSON syntax..."
                    if jq empty "$FILE_PATH" 2>/dev/null; then
                        echo "✅ JSON: Valid syntax"
                    else
                        echo "⚠️ JSON: Invalid syntax"
                    fi
                fi
                ;;

            yaml|yml)
                # YAML validation
                if command -v yamllint >/dev/null 2>&1; then
                    echo "🔍 Validating YAML syntax..."
                    if yamllint "$FILE_PATH" 2>/dev/null; then
                        echo "✅ YAML: Valid syntax"
                    else
                        echo "⚠️ YAML: Issues detected"
                    fi
                fi
                ;;
        esac

        # Run tests if test files were modified or if in test directory
        if [[ "$FILE_PATH" =~ (test|spec) ]] || [[ "$FILE_PATH" =~ /__tests__/ ]]; then
            echo "🧪 Test file modified - consider running test suite"

            # Auto-run tests if package.json exists and has test script
            if [[ -f "package.json" ]] && grep -q '"test"' package.json; then
                echo "🚀 Auto-running tests..."
                if npm test 2>/dev/null; then
                    echo "✅ Tests passed"
                else
                    echo "⚠️ Tests failed - review test output"
                fi
            fi
        fi

        # Security scan for sensitive patterns
        echo "🛡️ Running security scan..."
        SECURITY_ISSUES=0

        # Check for potential secrets
        if grep -qiE "(password|secret|key|token).*=.*['\"][^'\"]{8,}" "$FILE_PATH" 2>/dev/null; then
            echo "⚠️ SECURITY: Potential hardcoded secrets detected"
            SECURITY_ISSUES=$((SECURITY_ISSUES + 1))
        fi

        # Check for SQL injection patterns
        if grep -qE "(query|execute).*\+.*\|.*\$" "$FILE_PATH" 2>/dev/null; then
            echo "⚠️ SECURITY: Potential SQL injection pattern detected"
            SECURITY_ISSUES=$((SECURITY_ISSUES + 1))
        fi

        # Check for eval/exec usage
        if grep -qE "(eval|exec|system)\(" "$FILE_PATH" 2>/dev/null; then
            echo "⚠️ SECURITY: Potentially dangerous function usage detected"
            SECURITY_ISSUES=$((SECURITY_ISSUES + 1))
        fi

        if [[ $SECURITY_ISSUES -eq 0 ]]; then
            echo "✅ Security scan: No obvious issues detected"
        fi

        # Git add if in git repository
        if command -v git >/dev/null 2>&1 && git rev-parse --git-dir > /dev/null 2>&1; then
            echo "📝 Adding file to git staging area..."
            git add "$FILE_PATH"
            echo "✅ File staged for commit"
        fi
    fi
fi

# Performance monitoring for search operations
if [[ "$TOOL_NAME" == "Grep" || "$TOOL_NAME" == "Glob" ]]; then
    START_TIME_FILE="/tmp/claude_search_start_$$"
    if [[ -f "$START_TIME_FILE" ]]; then
        START_TIME=$(cat "$START_TIME_FILE")
        END_TIME=$(date +%s)
        DURATION=$((END_TIME - START_TIME))
        echo "⏱️ Search completed in ${DURATION}s"
        rm -f "$START_TIME_FILE"

        # Log slow searches
        if [[ $DURATION -gt 5 ]]; then
            echo "$(date '+%Y-%m-%d %H:%M:%S') - SLOW SEARCH: ${TOOL_NAME} took ${DURATION}s" >> ~/.claude/logs/performance.log
        fi
    fi
fi

# Bash command completion logging
if [[ "$TOOL_NAME" == "Bash" ]]; then
    COMMAND="${ARGUMENTS:-}"
    if [[ "${EXIT_CODE:-0}" == "0" ]]; then
        echo "✅ Command executed successfully: $COMMAND"
    else
        echo "⚠️ Command failed with exit code ${EXIT_CODE}: $COMMAND"
        echo "$(date '+%Y-%m-%d %H:%M:%S') - FAILED COMMAND: $COMMAND (exit code: ${EXIT_CODE})" >> ~/.claude/logs/command-failures.log
    fi
fi

# Create logs directory if it doesn't exist
mkdir -p ~/.claude/logs

echo "✅ PostToolUse processing completed for $TOOL_NAME"