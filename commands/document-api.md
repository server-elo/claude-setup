---
name: document-api
description: Generate comprehensive API documentation
---

Generate comprehensive API documentation for the specified endpoints or entire API.

**API Target:** $ARGUMENTS

**Documentation Scope:**
1. **Endpoint Documentation**
   - HTTP methods and URLs
   - Request/response schemas
   - Parameter descriptions
   - Status codes and error handling
   - Authentication requirements

2. **Data Models**
   - Entity schemas and relationships
   - Field descriptions and validation rules
   - Example payloads
   - Enum values and constraints

3. **Authentication & Authorization**
   - Authentication methods (JWT, OAuth, API keys)
   - Authorization scopes and permissions
   - Security requirements per endpoint
   - Token management and refresh flows

4. **Usage Examples**
   - Request/response examples
   - Code samples in multiple languages
   - SDK usage examples
   - Integration patterns

**Documentation Format:**
- **OpenAPI/Swagger**: Machine-readable specification
- **Markdown**: Human-readable documentation
- **Postman Collection**: Interactive testing
- **Code Examples**: Multiple programming languages

**Sections to Include:**
- **Overview**: API purpose and capabilities
- **Getting Started**: Quick start guide
- **Authentication**: How to authenticate requests
- **Endpoints**: Detailed endpoint documentation
- **Models**: Data structure definitions
- **Examples**: Practical usage examples
- **Error Codes**: Complete error reference
- **Rate Limiting**: Usage limits and quotas
- **Changelog**: Version history and changes

**Quality Standards:**
- All endpoints documented with examples
- Request/response schemas defined
- Error scenarios covered
- Authentication flows explained
- Rate limiting documented
- Versioning strategy described

**Example Usage:**
- `/document-api user-management`
- `/document-api payments/stripe`
- `/document-api v2/orders`