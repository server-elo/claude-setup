# /fix-cascade

Findet und behebt einen Bug, PLUS alle damit verbundenen Bugs in der gesamten Codebase.

## Usage
```bash
/fix-cascade "bug description"
/fix-cascade file.py:42  # specific line
```

## Prompt
```
Multi-stage cascading bug fix:

**Stage 1: Root Cause (Deep Analysis)**
{{bug_description}}

Analyze:
1. What is the immediate bug?
2. What is the root cause?
3. Why did this happen?
4. What mental model error led to this?

**Stage 2: Ripple Effect (Codebase Scan)**
Search entire codebase for:
- Similar patterns that likely have the same bug
- Code that depends on this buggy behavior
- Tests that might be wrong due to this bug
- Documentation that needs updating

**Stage 3: Fix Strategy**
- Fix root cause (not just symptoms)
- Fix all instances found in Stage 2
- Add safeguards to prevent recurrence
- Update tests
- Update docs

**Stage 4: Verification**
- Run all tests
- Check for new issues introduced
- Verify fix quality

Execute all stages. Show what you're fixing and why.
```