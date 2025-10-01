---
name: debug-issue
description: Systematic debugging and root cause analysis
---

Perform systematic debugging and root cause analysis using the Debugger subagent for the reported issue.

**Issue Description:** $ARGUMENTS

**Debugging Process:**
1. **Issue Assessment**
   - Severity: Critical/High/Medium/Low
   - Scope: Affected systems and users
   - Timeline: When did it start occurring?
   - Environment: Production/staging/development?

2. **Information Gathering**
   - Collect relevant logs and error messages
   - Check system resources and performance
   - Analyze recent changes and deployments
   - Review monitoring data and alerts

3. **Root Cause Analysis**
   - Form hypotheses based on evidence
   - Test each hypothesis systematically
   - Use binary search for large codebases
   - Add targeted debugging instrumentation

4. **Resolution & Validation**
   - Implement minimal viable fix
   - Test fix in isolated environment
   - Monitor production deployment
   - Document solution and prevention

**Expected Output:**
- Debugging analysis report
- Root cause identification
- Immediate fix recommendations
- Long-term prevention strategy
- Monitoring improvements

**Example Usage:**
- `/debug-issue API returning 500 errors`
- `/debug-issue Database connection timeouts`
- `/debug-issue Memory leak in user service`