# Snapshot file
# Unset all aliases to avoid conflicts with functions
unalias -a 2>/dev/null || true
# Functions
sofia () {
	cd ~/Desktop/elvi/sofia-pers/"$1" 2> /dev/null || cd ~/Desktop/elvi/sofia-pers
	[ -d .venv ] && source .venv/bin/activate
	claude --dangerously-skip-permissions
}
# Shell Options
setopt nohashdirs
setopt login
# Aliases
alias -- check-audio='system_profiler SPAudioDataType | grep -A 10 '\''Input\|Output'\'
alias -- claude-global='~/.claude/scripts/setup-claude-copy.sh here'
alias -- cr='claude --dangerously-skip-permissions --resume'
alias -- cs='claude --dangerously-skip-permissions'
alias -- desk='cd ~/Desktop'
alias -- elvi='cd ~/Desktop/elvi'
alias -- list-audio='python3 -c '\''import pyaudio; p=pyaudio.PyAudio(); [print(f"{i}: {p.get_device_info_by_index(i)['\''name'\'']}") for i in range(p.get_device_count())]'\'' 2>/dev/null'
alias -- python=/opt/homebrew/bin/python3
alias -- run-help=man
alias -- sofia-venv='source ~/Desktop/elvi/sofia-pers/.venv/bin/activate'
alias -- sofiacon='cd ~/Desktop/elvi/sofia-pers && python3 agent.py console'
alias -- sofiadev='cd ~/Desktop/elvi/sofia-pers && python3 agent.py dev'
alias -- sp='cd ~/Desktop/elvi/sofia-pers'
alias -- which-command=whence
# Check for rg availability
if ! command -v rg >/dev/null 2>&1; then
  alias rg='/opt/homebrew/lib/node_modules/\@anthropic-ai/claude-code/vendor/ripgrep/arm64-darwin/rg'
fi
export PATH=/Applications/Docker.app/Contents/Resources/bin\:/opt/homebrew/bin\:/usr/local/bin\:/System/Cryptexes/App/usr/bin\:/usr/bin\:/bin\:/usr/sbin\:/sbin\:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin\:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin\:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin\:/opt/homebrew/bin\:/Users/tolga/.lmstudio/bin
