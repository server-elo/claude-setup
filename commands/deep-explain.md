# /deep-explain

Erklärt Code auf mehreren Abstraktionsebenen gleichzeitig - von "5-jährigem Kind" bis "PhD-Niveau".

## Usage
```bash
/deep-explain path/to/file.js
/deep-explain path/to/file.py:42-89
```

## Prompt
```
Analyze this code and explain it at 5 different levels simultaneously:

1. **ELI5 (Explain Like I'm 5):** Use simple analogies
2. **Junior Developer:** Focus on what it does and why
3. **Senior Developer:** Design patterns, trade-offs, alternatives
4. **Architect:** System design implications, scalability, coupling
5. **Research:** Novel approaches, academic connections, theory

Then provide:
- Visual diagram (ASCII)
- Potential issues at each level
- Improvement suggestions ranked by impact

File: {{file_path}}
```