---
name: review-security
description: Comprehensive security audit of codebase
---

Perform a comprehensive security audit of the provided code or entire codebase using the Security Auditor subagent.

**Security Review Scope:**
- OWASP Top 10 vulnerability assessment
- Static code analysis for security flaws
- Configuration security review
- Dependency vulnerability scan
- Authentication/authorization analysis
- Data protection and encryption review

**Files to analyze:** $ARGUMENTS

**Review Process:**
1. Use Security Auditor subagent for detailed analysis
2. Check for hardcoded secrets and credentials
3. Analyze input validation and sanitization
4. Review authentication and session management
5. Assess authorization and access controls
6. Check for injection vulnerabilities (SQL, XSS, Command)
7. Verify secure communication and data protection
8. Review error handling and information disclosure

**Deliverables:**
- Security assessment report with severity ratings
- Prioritized list of vulnerabilities
- Remediation recommendations with timelines
- Compliance notes for relevant standards

**Example Usage:**
- `/review-security` - Audit entire codebase
- `/review-security src/auth/` - Audit authentication module
- `/review-security file.js` - Audit specific file