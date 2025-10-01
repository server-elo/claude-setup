# Snapshot file
# Unset all aliases to avoid conflicts with functions
unalias -a 2>/dev/null || true
# Functions
chpwd () {
	local NEW_DIR=$(basename "$PWD") 
	if [ -f ~/.claude/memory/projects/${NEW_DIR}.json ]
	then
		echo "💡 Known project: $NEW_DIR"
		jq -r '.entry_point // .type // "unknown"' ~/.claude/memory/projects/${NEW_DIR}.json 2> /dev/null
	fi
}
precmd () {
	local EXIT_CODE=$? 
	local LAST_CMD=$(fc -ln -1) 
	if [[ ! "$LAST_CMD" =~ ^(ls|cd|pwd|echo)$ ]]
	then
		echo "{\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\"cmd\":\"$LAST_CMD\",\"exit\":$EXIT_CODE,\"pwd\":\"$PWD\"}" >> ~/.claude/memory/interactions.jsonl 2> /dev/null
	fi
	if [ $EXIT_CODE -ne 0 ]
	then
		echo "[$(date)] FAILED: $LAST_CMD (exit $EXIT_CODE)" >> ~/.claude/memory/error-patterns.txt
	fi
}
smart () {
	~/.claude/scripts/execution-predictor.sh "$*"
	if [ $? -eq 0 ]
	then
		eval "$*"
		~/.claude/scripts/self-metrics.sh context-hit
	else
		echo "Command prediction failed. Run anyway? (y/n)"
		read response
		if [ "$response" = "y" ]
		then
			eval "$*"
			~/.claude/scripts/self-metrics.sh context-miss
		fi
	fi
}
sofia () {
	cd ~/Desktop/elvi/sofia-pers/"$1" 2> /dev/null || cd ~/Desktop/elvi/sofia-pers
	[ -d .venv ] && source .venv/bin/activate
	claude --dangerously-skip-permissions
}
# Shell Options
setopt nohashdirs
setopt login
# Aliases
alias -- ask='~/.claude/scripts/natural-language.sh'
alias -- autonomous='~/.claude/scripts/v3-autonomous-daemon.sh'
alias -- check-audio='system_profiler SPAudioDataType | grep -A 10 '\''Input\|Output'\'
alias -- claude-global='~/.claude/scripts/setup-claude-copy.sh here'
alias -- cr='claude --dangerously-skip-permissions --resume'
alias -- cs='claude --dangerously-skip-permissions'
alias -- dashboard='~/.claude/scripts/dashboard.sh'
alias -- desk='cd ~/Desktop'
alias -- desktop='cd ~/Desktop'
alias -- elvi='cd ~/Desktop/elvi'
alias -- find=fd
alias -- find-py='fd -e py'
alias -- gitintel='~/.claude/scripts/git-intelligence.sh'
alias -- grep=rg
alias -- grep-code=rg
alias -- install-py='pip3 install -r requirements.txt'
alias -- list-audio='python3 -c '\''import pyaudio; p=pyaudio.PyAudio(); [print(f"{i}: {p.get_device_info_by_index(i)['\''name'\'']}") for i in range(p.get_device_count())]'\'' 2>/dev/null'
alias -- metrics='~/.claude/scripts/self-metrics.sh report'
alias -- predict='~/.claude/scripts/execution-predictor.sh'
alias -- preload='~/.claude/scripts/context-preloader.sh'
alias -- python=/opt/homebrew/bin/python3
alias -- record='~/.claude/scripts/workflow-recorder.sh'
alias -- run-help=man
alias -- sofia='cd ~/Desktop/elvi/sofia-pers'
alias -- sofia-dev='cd ~/Desktop/elvi/sofia-pers && source .venv/bin/activate && python3 agent.py console'
alias -- sofia-en='cd ~/Desktop/elvi/sofia-pers/sofia-en'
alias -- sofia-local='cd ~/Desktop/elvi/sofia-pers/sofia-local'
alias -- sofia-venv='source ~/Desktop/elvi/sofia-pers/.venv/bin/activate'
alias -- sofiacon='cd ~/Desktop/elvi/sofia-pers && python3 agent.py console'
alias -- sofiadev='cd ~/Desktop/elvi/sofia-pers && python3 agent.py dev'
alias -- sp='cd ~/Desktop/elvi/sofia-pers'
alias -- venv-activate='source .venv/bin/activate'
alias -- venv-create='python3 -m venv .venv'
alias -- visual='~/.claude/scripts/visual-dashboard.sh open'
alias -- which-command=whence
alias -- workflows='~/.claude/scripts/workflow-recorder.sh list'
# Check for rg availability
if ! command -v rg >/dev/null 2>&1; then
  alias rg='/opt/homebrew/lib/node_modules/\@anthropic-ai/claude-code/vendor/ripgrep/arm64-darwin/rg'
fi
export PATH=/Applications/Docker.app/Contents/Resources/bin\:/opt/homebrew/bin\:/usr/local/bin\:/System/Cryptexes/App/usr/bin\:/usr/bin\:/bin\:/usr/sbin\:/sbin\:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin\:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin\:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin\:/opt/homebrew/bin\:/Users/tolga/.lmstudio/bin
