# /code-translator

Übersetzt Code zwischen Sprachen/Frameworks unter Beibehaltung von Idiomen und Best Practices.

## Usage
```bash
/code-translator file.js --to=python
/code-translator file.py --to=rust --style=idiomatic
/code-translator react-component.jsx --to=vue
```

## Prompt
```
Intelligent code translation: {{source_file}} → {{target_language}}

**Not a literal translation. Do this:**

1. **Understand Intent:** What is this code trying to accomplish?
2. **Idiomatic Target:** How would a native {{target_language}} expert write this?
3. **Preserve Semantics:** Keep exact behavior, but adapt style
4. **Modern Practices:** Use current best practices for target language
5. **Type Safety:** Add proper types if target supports it
6. **Error Handling:** Adapt to target language idioms
7. **Performance:** Use target language performance patterns
8. **Comments:** Explain non-obvious translations

**Example Transformations:**
- JS promises → Python async/await
- Python decorators → Rust macros/traits
- Java getters/setters → Kotlin properties
- React hooks → Vue Composition API

Output both old and new code with explanation of key decisions.
```