# /auto-document

Generiert perfekte Dokumentation durch Code-Verständnis (nicht nur Docstrings).

## Usage
```bash
/auto-document src/
/auto-document --style=tutorial  # für Tutorials
/auto-document --style=api       # für API docs
```

## Prompt
```
Generate comprehensive, intelligent documentation:

**Phase 1: Understanding**
- Read all code in {{path}}
- Understand what it does (not just how)
- Identify user-facing vs internal APIs
- Find examples in tests
- Understand design decisions

**Phase 2: Structure**
Create documentation with:

1. **Quick Start** (5 lines of code to get started)
2. **Core Concepts** (mental models needed)
3. **API Reference** (generated from code)
4. **Common Patterns** (real-world usage)
5. **Troubleshooting** (anticipate problems)
6. **Architecture** (high-level design)

**Phase 3: Quality**
- Write for humans, not robots
- Include "why" not just "what"
- Add diagrams (ASCII)
- Include code examples
- Anticipate questions

**Output:** Complete markdown documentation ready to ship.
```