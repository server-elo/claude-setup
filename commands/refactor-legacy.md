---
name: refactor-legacy
description: Systematic legacy code refactoring and modernization
---

Perform systematic refactoring and modernization of legacy code to improve maintainability, performance, and security.

**Legacy Code Target:** $ARGUMENTS

**Refactoring Scope:**
1. **Code Structure Modernization**
   - Extract functions and classes
   - Eliminate code duplication
   - Improve naming conventions
   - Implement design patterns

2. **Performance Optimization**
   - Algorithm efficiency improvements
   - Memory usage optimization
   - Database query optimization
   - Caching implementation

3. **Security Hardening**
   - Fix security vulnerabilities
   - Implement input validation
   - Update authentication mechanisms
   - Secure configuration management

4. **Testing Implementation**
   - Add comprehensive test coverage
   - Implement test automation
   - Create integration tests
   - Establish quality gates

**Refactoring Strategies:**
- **Strangler Fig Pattern**: Gradually replace components
- **Branch by Abstraction**: Create abstraction layers
- **Extract Class/Method**: Break down large components
- **Replace Conditional**: Simplify complex logic
- **Introduce Parameter Object**: Reduce parameter lists

**Legacy Code Patterns to Address:**
- **God Objects**: Large classes with too many responsibilities
- **Long Methods**: Functions that do too much
- **Duplicate Code**: Repeated logic across codebase
- **Magic Numbers**: Hardcoded values without context
- **Global State**: Shared mutable state
- **Deep Inheritance**: Complex inheritance hierarchies

**Modernization Opportunities:**
- **Language Features**: Use modern language constructs
- **Library Updates**: Replace deprecated dependencies
- **Framework Migration**: Upgrade to current versions
- **API Modernization**: RESTful/GraphQL API patterns
- **Database Optimization**: Modern query patterns

**Quality Assurance:**
- **Behavior Preservation**: Ensure functionality remains intact
- **Performance Benchmarking**: Measure improvements
- **Security Testing**: Validate security enhancements
- **Regression Testing**: Prevent introduction of bugs

**Refactoring Process:**
1. **Analysis**: Understand current code structure and issues
2. **Planning**: Prioritize refactoring tasks by impact/effort
3. **Implementation**: Apply refactoring patterns incrementally
4. **Testing**: Validate each change thoroughly
5. **Documentation**: Update documentation and comments

**Risk Mitigation:**
- **Incremental Changes**: Small, manageable modifications
- **Comprehensive Testing**: Extensive test coverage
- **Feature Flags**: Safe deployment of changes
- **Rollback Plan**: Quick reversion strategy
- **Monitoring**: Track system behavior post-refactoring

**Example Usage:**
- `/refactor-legacy user-management-module`
- `/refactor-legacy payment-processing`
- `/refactor-legacy legacy-api-endpoints`