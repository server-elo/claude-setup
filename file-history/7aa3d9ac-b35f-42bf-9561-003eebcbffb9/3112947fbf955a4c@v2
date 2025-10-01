# /semantic-search

Sucht nach Bedeutung, nicht nach Keywords. Findet Code der etwas Ähnliches macht.

## Usage
```bash
/semantic-search "code that validates email addresses"
/semantic-search "functions that transform data asynchronously"
/semantic-search "authentication logic"
```

## Prompt
```
Semantic code search for: "{{query}}"

**Not keyword search. Understand MEANING:**

1. **Intent Analysis:** What is the user looking for conceptually?
2. **Semantic Scan:** Read codebase and understand what each part DOES
3. **Similarity Match:** Find code that accomplishes similar goals
4. **Ranking:** Rank by semantic similarity, not text match

**Search Strategy:**
- Ignore variable names (focus on behavior)
- Understand patterns (e.g., "validation" might be regex, conditionals, or library calls)
- Find related concepts (auth → login, session, token, jwt)
- Include near-misses that might be useful

**Output:**
```
Found 8 semantic matches:

1. ✅ user-validator.js:42-67 (95% match)
   Validates email using regex + DNS check

2. ✅ auth/validate.py:15-23 (87% match)
   Email validation with format + domain verification

3. 🔵 utils/email.ts:8 (72% match)
   Simple email format check (related but simpler)

[Show code snippets + why each matches]
```