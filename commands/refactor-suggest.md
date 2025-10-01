# /refactor-suggest

Schlägt Refactorings vor die ein Mensch nie sehen würde (cross-file patterns).

## Usage
```bash
/refactor-suggest
/refactor-suggest src/components/
```

## Prompt
```
Deep refactoring analysis: {{path}}

**What humans miss (but AI can see):**

**1. Scattered Responsibilities**
Find code doing the same thing in 5+ places
→ Suggest extraction + single source of truth

**2. Hidden Abstractions**
Find patterns that repeat but with slight variations
→ Suggest abstraction that handles all cases

**3. Implicit Coupling**
Find files that always change together
→ Suggest merging or making dependency explicit

**4. Dead Code Paths**
Find code that's never executed (trace from entry points)
→ Suggest removal

**5. Performance Patterns**
Find O(n²) where O(n) is possible
Find repeated computations that could be cached
→ Suggest optimizations

**6. Type Inconsistencies**
Find places where types are converted back and forth
→ Suggest consistent types

**Output Format:**
```
Found 12 refactoring opportunities:

🔴 HIGH IMPACT: Duplicated validation logic (8 places)
   Savings: -247 LOC, +1 maintainability point
   Effort: 2 hours
   [Show details + diff preview]

🟡 MEDIUM IMPACT: Extract payment processing abstraction
   Savings: Better testability, +clarity
   Effort: 4 hours
   [Show details]
...
```

Rank by: Impact / Effort ratio
```