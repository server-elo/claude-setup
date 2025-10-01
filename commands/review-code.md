---
name: review-code
description: Comprehensive code quality review
---

Perform comprehensive code quality review using the Code Reviewer subagent.

**Code to Review:** $ARGUMENTS

**Review Scope:**
1. **Code Quality Analysis**
   - Clarity, maintainability, and readability
   - Coding standards and best practices adherence
   - Design patterns and architecture assessment
   - Error handling and logging review

2. **Security Assessment**
   - OWASP Top 10 vulnerability check
   - Input validation and sanitization
   - Authentication and authorization review
   - Secrets and sensitive data exposure

3. **Performance Evaluation**
   - Algorithm efficiency analysis
   - Resource usage optimization
   - Database query performance
   - Memory management review

4. **Testing Coverage**
   - Unit test completeness
   - Integration test scenarios
   - Edge case coverage
   - Test quality assessment

**Review Criteria:**
- **Functionality**: Does the code work as intended?
- **Readability**: Is the code clear and well-documented?
- **Maintainability**: Can it be easily modified and extended?
- **Performance**: Is it efficient and scalable?
- **Security**: Are security best practices followed?
- **Testing**: Is it adequately tested?

**Output Categories:**
- **Critical Issues (🚨)**: Security vulnerabilities, major bugs
- **Important Issues (⚠️)**: Performance problems, design flaws
- **Minor Issues (💡)**: Style improvements, optimizations
- **Recommendations (✨)**: Best practices, future improvements

**Approval Status:**
- ✅ Approved - Ready for production
- ⚠️ Approved with minor changes
- ❌ Requires changes before approval
- 🔄 Major revision needed

**Example Usage:**
- `/review-code src/payment/processor.js`
- `/review-code pull-request-123`
- `/review-code user-authentication-module`