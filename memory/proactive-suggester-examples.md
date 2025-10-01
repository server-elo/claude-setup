# Proactive Suggestion Engine - Examples & Documentation

## Overview
The proactive suggestion engine analyzes patterns and anticipates user needs BEFORE they ask, providing confidence-ranked suggestions based on multiple signal sources.

## Example Outputs with Confidence Scores

### Example 1: Morning Work Session
```bash
$ ~/.claude/scripts/proactive-suggester.sh analyze

[88%] sofia-pers has 5 uncommitted changes
   → cd ~/Desktop/elvi/sofia-pers && git status

[85%] Python project local-voice-ai-agent missing virtual environment
   → cd ~/Desktop/elvi/sofia-pers/local-voice-ai-agent && python3 -m venv .venv

[75%] You often work on sofia-pers at this time
   → cd ~/Desktop/elvi/sofia-pers

[72%] 3 files modified recently - run tests?
   → pytest OR npm test
```

### Example 2: Git Intelligence Alerts
```bash
$ ~/.claude/scripts/proactive-suggester.sh analyze

[90%] Branch main is 3 commits behind origin
   → git pull

[85%] Branch feature/voice-ai has 7 unpushed commits
   → git push

[80%] quantum has 12 uncommitted changes
   → cd ~/Desktop/quantum && git status
```

### Example 3: Error Pattern Detection
```bash
$ ~/.claude/scripts/proactive-suggester.sh analyze

[88%] Detected 4 pip installs without venv - activate venv first
   → source .venv/bin/activate

[82%] Command sequence detected 5 times: cd sofia-pers → ./start_sofia.sh
   → Create alias: alias sofia-run='cd ~/Desktop/elvi/sofia-pers && ./start_sofia.sh'

[75%] Recent file edits in sofia-hotel - run tests?
   → pytest tests/
```

### Example 4: Time-Based Predictions
```bash
$ ~/.claude/scripts/proactive-suggester.sh analyze

[85%] Evening pattern: You typically work on sofia-pers at 19:00
   → Pre-loading context...

[78%] Morning: 3 projects with uncommitted changes from yesterday
   → Review: sofia-pers (5 files), quantum (2 files), elo-deu (1 file)

[72%] End of day pattern: Consider committing work in progress
   → git status && git add . && git commit
```

### Example 5: Project Health Monitoring
```bash
$ ~/.claude/scripts/proactive-suggester.sh analyze

[90%] sofia-integrated missing dependencies (requirements.txt changed)
   → pip install -r requirements.txt

[85%] node_modules outdated in quantum project (15 days old)
   → npm install

[80%] .env.example exists but .env missing in elo-deu
   → cp .env.example .env
```

## Proactive Actions (Auto-Execute)

### Example 1: Auto-Activate Virtual Environment
```bash
$ ~/.claude/scripts/proactive-suggester.sh proactive

proactive_action:venv_activate:/Users/tolga/Desktop/elvi/sofia-pers/.venv
```

**Triggered when:**
- User in Python project directory
- Virtual environment exists but not activated
- About to run pip or python commands

### Example 2: Pre-Load Context
```bash
$ ~/.claude/scripts/proactive-suggester.sh proactive

proactive_action:morning_review:git status && git log -3
```

**Triggered when:**
- Time: 9:00-12:00 (morning hours)
- User just started working
- Git repository detected

### Example 3: Commit Warning
```bash
$ ~/.claude/scripts/proactive-suggester.sh proactive

proactive_suggestion:commit_before_switch:5 files uncommitted
```

**Triggered when:**
- User switching between projects
- Uncommitted changes detected
- Prevents losing work

### Example 4: Error Prevention
```bash
$ ~/.claude/scripts/proactive-suggester.sh proactive

proactive_warning:pip_without_venv:Activate venv first
```

**Triggered when:**
- User runs `pip install` command
- No virtual environment activated
- Pattern detected from error history

## Confidence Scoring System

### Base Confidence (0-100)

**90-100**: Critical/Urgent
- Uncommitted changes before project switch
- Git conflicts detected
- Missing dependencies preventing execution

**80-89**: High Priority
- Multiple uncommitted files
- Error patterns (3+ occurrences)
- Missing venv with recent pip errors

**70-79**: Medium Priority
- Time-based work patterns
- Command sequence optimization
- Project health warnings

**60-69**: Low Priority
- Alias suggestions
- Optional optimizations
- Quality of life improvements

### Adjustments

**+5-10**: Historical acceptance rate
- Suggestion type accepted 80%+ of the time
- User frequently acts on this type

**+3**: Time relevance
- Work hours (9-18) boost
- Pattern matches current time

**-5**: Low priority items
- Nice-to-have improvements
- Non-blocking suggestions

**-10**: Previously rejected
- User dismissed this type 3+ times
- Learning from feedback

## Learning & Feedback Loop

### Recording Acceptance
```bash
$ ~/.claude/scripts/proactive-suggester.sh feedback git_uncommitted true

Feedback recorded: git_uncommitted → true
```

### Recording Rejection
```bash
$ ~/.claude/scripts/proactive-suggester.sh feedback command_sequence false

Feedback recorded: command_sequence → false
```

### Viewing Statistics
```bash
$ ~/.claude/scripts/proactive-suggester.sh stats

=== SUGGESTION STATISTICS ===

Total suggestions shown: 47

By type:
  12 git_uncommitted
   8 venv_warning
   7 time_pattern
   6 test_suggestion
   5 command_sequence
   4 missing_venv
   3 git_behind
   2 git_ahead

Acceptance rate by type:
git_uncommitted true 10
git_uncommitted false 2
venv_warning true 7
venv_warning false 1
time_pattern true 4
time_pattern false 3
```

## Signal Sources

### 1. Time Patterns (analyze_time_patterns)
- Historical command timing
- Day of week patterns
- Hour-based project preferences
- Work session detection

### 2. Command Sequences (analyze_command_sequences)
- Repeated command pairs
- Workflow patterns
- Automation opportunities
- Alias candidates

### 3. Project Health (analyze_project_health)
- Missing virtual environments
- Uncommitted git changes
- Dependency status
- Configuration files

### 4. Git Intelligence (analyze_git_intelligence)
- Behind/ahead commit counts
- Stashed changes
- Branch status
- Merge conflicts

### 5. Error Patterns (analyze_error_patterns)
- Recurring failures
- Module not found errors
- Permission issues
- Common mistakes

### 6. File Modifications (analyze_file_modifications)
- Recently edited files
- Test file changes
- Config modifications
- Code changes needing tests

## Integration with Autonomous Daemon

The proactive suggester is integrated into the V3 autonomous daemon:

```bash
# Daemon runs every 60 seconds
while true; do
    monitor_git
    predict_next_action
    monitor_errors
    run_proactive_suggester  # <-- NEW: Generates suggestions
    proactive_health_check
    sleep 60
done
```

### Daemon Log Example
```
[2025-09-30 19:15:00] 🚀 V3 Autonomous Daemon started (PID: 12345)
[2025-09-30 19:15:00] GitHub Intelligence: 5 uncommitted files, 0 unpushed commits
[2025-09-30 19:15:05] 🔮 PREDICTION: User likely to work on sofia-pers (evening pattern)
[2025-09-30 19:15:05] ⚡ PRE-LOADING: sofia-pers context...
[2025-09-30 19:15:10] 🔮 Running proactive suggestion engine...
[2025-09-30 19:15:12] 💡 SUGGESTIONS:
[2025-09-30 19:15:12]    [88%] sofia-pers has 5 uncommitted changes
[2025-09-30 19:15:12]    → cd ~/Desktop/elvi/sofia-pers && git status
[2025-09-30 19:15:12]
[2025-09-30 19:15:12]    [75%] You often work on sofia-pers at this time
[2025-09-30 19:15:12]    → cd ~/Desktop/elvi/sofia-pers
[2025-09-30 19:15:13] ⚡ AUTO-ACTION: proactive_action:morning_review:git status && git log -3
```

## Dashboard Integration

Top 3 suggestions appear on dashboard:

```
## 🔮 PROACTIVE SUGGESTIONS (Top 3)
  [88%] sofia-pers has 5 uncommitted changes
  [85%] Python project local-voice-ai-agent missing virtual environment
  [75%] You often work on sofia-pers at this time
```

## Continuous Improvement

### Learning Cycle
1. **Generate**: Analyze signals → create suggestions
2. **Show**: Present top suggestions (>70% confidence)
3. **Log**: Record suggestion + timestamp
4. **Feedback**: Track user action (accepted/rejected)
5. **Adjust**: Update confidence scores based on acceptance rate
6. **Improve**: Refine patterns and thresholds

### Self-Optimization
- Suggestions with 80%+ acceptance rate get +10 confidence boost
- Suggestions rejected 3+ times get deprioritized
- New patterns emerge from interaction logs
- Time-based weights adjust automatically

## Real-World Usage Patterns

### Pattern 1: Morning Startup
```
07:00 - User starts work
07:01 - Suggester: "3 projects uncommitted from yesterday"
07:02 - User: git status on all 3 → ACCEPTED
07:15 - Confidence boost: uncommitted_changes +5
```

### Pattern 2: Error Prevention
```
14:30 - User: pip install package
14:30 - Suggester: "No venv active - activate first?"
14:30 - User: source .venv/bin/activate → ACCEPTED
14:31 - Learning: pip_without_venv pattern confirmed
```

### Pattern 3: Workflow Optimization
```
15:00 - Detected: cd sofia-pers → ./start_sofia.sh (5 times)
15:01 - Suggester: "Create alias for this sequence?"
15:01 - User: ignores → REJECTED
15:02 - Confidence: command_sequence -5
16:00 - Same pattern detected (ignored)
Next day - Pattern no longer suggested (learned)
```

## Configuration & Tuning

### Confidence Threshold
Default: 70% (only show suggestions above this)

Adjust in script:
```bash
local filtered=$(echo "$ranked" | jq '[.[] | select(.confidence > 70)]')
```

### Suggestion Frequency
Default: Every 60 seconds via daemon

Adjust daemon sleep interval:
```bash
sleep 60  # Change to desired seconds
```

### Priority Weights
```bash
case "$priority" in
    high) confidence=$((confidence + 5)) ;;
    medium) confidence=$((confidence + 0)) ;;
    low) confidence=$((confidence - 5)) ;;
esac
```

## Advanced Features

### Context-Aware Suggestions
- Sofia project: Voice AI specific checks
- Python projects: Venv and dependency checks
- Node projects: npm and node_modules checks
- Git repos: Branch and commit intelligence

### Multi-Project Awareness
- Tracks 12+ projects simultaneously
- Cross-project pattern detection
- Project switching optimization
- Resource allocation suggestions

### Temporal Intelligence
- Work hours vs off-hours patterns
- Day of week preferences
- Session duration estimates
- Break time recommendations

## Files & Locations

**Script**: `/Users/tolga/.claude/scripts/proactive-suggester.sh`
**Log**: `/Users/tolga/.claude/memory/suggestions.jsonl`
**Dashboard**: `/Users/tolga/.claude/memory/dashboard.txt`
**State**: `/Users/tolga/.claude/memory/autonomous-state.json`

## Next Steps

1. Run initial analysis: `~/.claude/scripts/proactive-suggester.sh analyze`
2. Check daemon status: `~/.claude/scripts/v3-autonomous-daemon.sh status`
3. Monitor logs: `tail -f ~/.claude/logs/autonomous-daemon.log`
4. View statistics: `~/.claude/scripts/proactive-suggester.sh stats`
5. Provide feedback: `~/.claude/scripts/proactive-suggester.sh feedback <type> <true/false>`
