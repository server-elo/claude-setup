---
name: generate-tests
description: Generate comprehensive test suite for code
---

Generate comprehensive test suite using the Test Engineer subagent for the specified code or feature.

**Target:** $ARGUMENTS

**Test Generation Scope:**
1. **Unit Tests**
   - Individual function/method testing
   - Mock external dependencies
   - Edge cases and boundary conditions
   - Error handling scenarios

2. **Integration Tests**
   - Component interaction testing
   - Database operations
   - API endpoint testing
   - Service integration

3. **End-to-End Tests**
   - Critical user workflows
   - Business process validation
   - Cross-browser compatibility
   - Performance scenarios

**Testing Strategy:**
- Follow TDD (Test-Driven Development) approach
- Implement AAA pattern (Arrange, Act, Assert)
- Target 80%+ code coverage
- Include performance benchmarks
- Add security test cases

**Test Categories:**
- **Happy Path**: Normal operation scenarios
- **Edge Cases**: Boundary conditions and limits
- **Error Cases**: Exception handling and recovery
- **Security Tests**: Input validation and authentication
- **Performance Tests**: Load and stress testing

**Deliverables:**
- Complete test suite implementation
- Test data factories and fixtures
- CI/CD integration configuration
- Coverage reports and metrics
- Test documentation and maintenance guide

**Example Usage:**
- `/generate-tests src/user-service.js`
- `/generate-tests payment-module`
- `/generate-tests api/auth`