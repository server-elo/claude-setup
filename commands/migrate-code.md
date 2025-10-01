---
name: migrate-code
description: Systematic code migration and modernization
---

Perform systematic code migration, refactoring, and modernization for the specified target.

**Migration Target:** $ARGUMENTS

**Migration Types:**
1. **Language Migration**
   - Python 2 → Python 3
   - JavaScript → TypeScript
   - Java 8 → Java 17+
   - Legacy frameworks → Modern alternatives

2. **Framework Migration**
   - AngularJS → Angular/React/Vue
   - Express → Fastify/Koa
   - jQuery → Vanilla JS/Modern frameworks
   - Bootstrap 4 → Bootstrap 5/Tailwind

3. **Database Migration**
   - SQL schema changes
   - NoSQL to SQL (or vice versa)
   - Data format transformations
   - Index optimization

4. **Infrastructure Migration**
   - Monolith → Microservices
   - On-premise → Cloud
   - Docker containerization
   - Kubernetes orchestration

**Migration Process:**
1. **Analysis Phase**
   - Current state assessment
   - Dependency mapping
   - Risk identification
   - Effort estimation

2. **Planning Phase**
   - Migration strategy selection
   - Timeline and milestones
   - Rollback plan creation
   - Testing strategy

3. **Implementation Phase**
   - Incremental migration approach
   - Continuous validation
   - Performance monitoring
   - Quality assurance

4. **Validation Phase**
   - Functional testing
   - Performance benchmarking
   - Security validation
   - User acceptance testing

**Migration Strategies:**
- **Strangler Fig**: Gradually replace old system
- **Big Bang**: Complete replacement at once
- **Parallel Run**: Run both systems simultaneously
- **Database First**: Migrate data layer first
- **API First**: Modernize interfaces first

**Quality Assurance:**
- Automated test suite creation
- Data integrity validation
- Performance regression testing
- Security vulnerability scanning
- Rollback procedure testing

**Deliverables:**
- Migration plan with timeline
- Risk assessment and mitigation
- Automated migration scripts
- Testing and validation procedures
- Documentation and training materials
- Performance comparison reports

**Example Usage:**
- `/migrate-code python2-to-python3`
- `/migrate-code legacy-auth-system`
- `/migrate-code mysql-to-postgresql`