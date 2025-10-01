# /instant-context

Liest gesamten Projektkontext in Sekundenschnelle (nutzt 200K Context Window).

## Usage
```bash
/instant-context
```

## Prompt
```
Read and internalize the entire codebase context in parallel:

**Phase 1: Rapid Scan (Parallel)**
- Read all package.json, requirements.txt, go.mod, Cargo.toml
- Read all README, CLAUDE.md, docs/*.md
- Scan directory structure
- Identify main entry points

**Phase 2: Architecture Understanding (Parallel)**
- Map all imports/dependencies
- Identify design patterns
- Find core abstractions
- Detect frameworks/libraries used

**Phase 3: Business Logic (Parallel)**
- Read core business logic files
- Understand data models
- Map API endpoints/interfaces
- Find configuration files

**Phase 4: Context Graph**
Build a complete mental model showing:
- Component relationships
- Data flow
- Critical paths
- Tech stack

**Output:**
Concise summary (< 500 words) + "Ready to work on: [X]"

Use maximum parallelization. Read up to 100 files simultaneously.
```