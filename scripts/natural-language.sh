#!/bin/bash
# Natural language command interface

interpret() {
    QUERY="$*"
    
    # Pattern matching for common intents
    case "$QUERY" in
        *"show"*"status"*|*"what"*"happening"*)
            dashboard
            ;;
        *"work"*"on"*|*"start"*"working"*)
            # Extract project name
            for proj in sofia quantum redteam guardrail whisper; do
                if [[ "$QUERY" =~ $proj ]]; then
                    cd ~/Desktop/*$proj* 2>/dev/null
                    echo "📂 Switched to $(basename $PWD)"
                    dashboard
                    break
                fi
            done
            ;;
        *"commit"*|*"save"*"changes"*)
            git status
            echo "Ready to commit? Run: git add . && git commit"
            ;;
        *"test"*|*"run"*"tests"*)
            if [ -f pytest.ini ] || [ -f pyproject.toml ]; then
                pytest
            elif [ -f package.json ]; then
                npm test
            fi
            ;;
        *"health"*|*"check"*)
            ~/.claude/scripts/dashboard.sh
            ;;
        *)
            echo "❓ Not sure what you mean. Try:"
            echo "  • 'show status'"
            echo "  • 'work on <project>'"
            echo "  • 'commit changes'"
            echo "  • 'run tests'"
            ;;
    esac
}

interpret "$@"
