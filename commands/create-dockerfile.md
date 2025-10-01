---
name: create-dockerfile
description: Generate optimized Dockerfile for application containerization
---

Generate optimized Dockerfile and container configuration for the specified application.

**Application Path:** $ARGUMENTS

**Containerization Scope:**
1. **Base Image Selection**
   - Language-specific optimized images
   - Security-hardened base images
   - Multi-stage build considerations
   - Size optimization strategies

2. **Build Optimization**
   - Layer caching optimization
   - Dependency installation order
   - Multi-stage builds for size reduction
   - Build context optimization

3. **Security Hardening**
   - Non-root user configuration
   - Minimal attack surface
   - Secrets management
   - Vulnerability scanning integration

4. **Production Readiness**
   - Health check configuration
   - Signal handling
   - Graceful shutdown
   - Resource limits and constraints

**Dockerfile Features:**
- **Multi-stage builds** for production optimization
- **Layer caching** for faster builds
- **Security best practices** (non-root user, minimal packages)
- **Health checks** for container orchestration
- **Environment configuration** for different stages
- **Dependency scanning** integration

**Additional Configurations:**
- **.dockerignore** for build context optimization
- **docker-compose.yml** for local development
- **CI/CD integration** scripts
- **Kubernetes manifests** if applicable
- **Security scanning** configuration

**Application Types Supported:**
- **Node.js/JavaScript**: Express, React, Next.js applications
- **Python**: Flask, Django, FastAPI applications
- **Java**: Spring Boot, Maven/Gradle projects
- **Go**: Static binary and service applications
- **PHP**: Laravel, Symfony applications
- **Static Sites**: HTML/CSS/JS, SPA applications

**Best Practices Applied:**
- Use specific image tags (not 'latest')
- Minimize layers and image size
- Run as non-root user
- Use .dockerignore to exclude unnecessary files
- Implement proper signal handling
- Configure health checks
- Set resource limits

**Example Usage:**
- `/create-dockerfile` - Containerize current project
- `/create-dockerfile backend/` - Containerize backend service
- `/create-dockerfile frontend/react-app` - Containerize React application