# /parallel-debug

Verfolgt einen Bug durch mehrere Hypothesen gleichzeitig (parallel debugging).

## Usage
```bash
/parallel-debug "error message or description"
```

## Prompt
```
Parallel hypothesis debugging: {{error}}

**Strategy: Test multiple hypotheses simultaneously**

**Phase 1: Generate Hypotheses (3-5 possibilities)**
Example:
1. Off-by-one error in loop
2. Race condition in async code
3. Type mismatch not caught by linter
4. Environment variable missing
5. Dependency version conflict

**Phase 2: Parallel Investigation**
For EACH hypothesis in parallel:
- What evidence would support it?
- Check code for that evidence
- Check logs, configs, tests
- Rate likelihood: Low/Medium/High

**Phase 3: Hypothesis Ranking**
```
Hypothesis                  Evidence    Likelihood
1. Race condition           🔴🔴🔴      HIGH (90%)
2. Off-by-one error         🔴          LOW (20%)
3. Type mismatch            🔴🔴        MEDIUM (60%)
...
```

**Phase 4: Solution**
- Fix most likely cause
- Add test to prevent recurrence
- Verify fix handles other hypotheses too

**Output:** Root cause found with confidence level + complete fix.
```