# Step-by-Step Development Prompts

This document contains individual prompts for each development step to build the Pravia Auth API incrementally.

## **File Naming Conventions**

**Standard NestJS Files (use dot notation):**
- `*.module.ts`, `*.controller.ts`, `*.service.ts`, `*.entity.ts`, `*.dto.ts`
- `*.guard.ts`, `*.strategy.ts`, `*.interceptor.ts`, `*.decorator.ts`
- `*.spec.ts`, `*.e2e-spec.ts`

**Custom/Utility Files (use kebab-case):**
- `post-migration-processor.ts`, `database-seeder.ts`, `email-template-builder.ts`

## **Step 1: Bootstrap NestJS Application** ✅ COMPLETED

**Prompt:**
```
Create a NestJS application bootstrap with Fastify adapter including:
1. main.ts with Fastify, global validation, CORS, and Swagger (no Pino initially)
2. app.module.ts with ConfigModule only (add other modules later)
3. Basic app.controller.ts and app.service.ts with application info endpoint
4. Install @fastify/static dependency for Swagger support
5. Use app.enableCors() instead of @fastify/cors plugin
6. Test that server starts and responds at /api endpoint
7. Ensure Swagger docs are accessible at /docs
8. Follow standard NestJS naming conventions (dot notation)
```

**Files Created:**
- `src/main.ts` - Application bootstrap with working Swagger
- `src/app.module.ts` - Minimal module with ConfigModule
- `src/app.controller.ts` - Basic controller with Swagger docs
- `src/app.service.ts` - Basic service with app info

**Key Fixes Applied:**
- Added `@fastify/static` dependency for Swagger
- Used `app.enableCors()` instead of Fastify plugin
- Started with minimal modules to avoid startup issues
- Removed Pino logger initially to prevent hanging

---

## **Step 2: Database Layer Setup**

**Prompt:**
```
Set up the database layer for the NestJS application:
1. Create TypeORM configuration with PostgreSQL connection
2. Create base entity class with common fields (id, createdAt, updatedAt, deletedAt)
3. Set up data source configuration for migrations
4. Create database module and integrate with app.module.ts
5. Add Redis connection configuration for caching
6. Ensure TypeORM is properly configured with path mapping (@/) support
7. Use standard NestJS naming conventions (dot notation)
8. Use kebab-case only for custom utility files like migration processors
```

**Expected Files:**
- `src/libs/database/database.module.ts`
- `src/libs/database/entities/base.entity.ts`
- `src/data-source.ts`
- `src/libs/database/database.config.ts`
- `src/database/scripts/post-migration-processor.ts` (kebab-case for custom utility)

---

## **Step 3: Core Libraries**

**Prompt:**
```
Create shared libraries and utilities:
1. Custom decorators for common functionality (CurrentUser, Roles, etc.)
2. Interceptors for logging, response transformation, and error handling
3. Guards for JWT authentication and role-based access control
4. Global exception filters with structured error responses
5. Validation pipes and DTOs with Zod integration
6. Ensure all libraries use proper TypeScript types and path mapping
```

**Expected Files:**
- `src/libs/decorators/`
- `src/libs/interceptors/`
- `src/libs/guards/`
- `src/libs/filters/`
- `src/libs/pipes/`

---

## **Step 4: Health Module**

**Prompt:**
```
Create a comprehensive health monitoring module:
1. Health controller with multiple health check endpoints
2. Health service with database, memory, and network checks
3. Integration with @nestjs/terminus for health checks
4. Custom health indicators for Redis and external services
5. Swagger documentation for all health endpoints
6. Proper error handling and response formatting
```

**Expected Files:**
- `src/modules/health/health.module.ts`
- `src/modules/health/health.controller.ts`
- `src/modules/health/health.service.ts`
- `src/modules/health/indicators/`

---

## **Step 5: Auth Module Foundation**

**Prompt:**
```
Create the authentication module foundation:
1. JWT strategy with Passport integration
2. Supabase client configuration and service
3. Auth service with token validation and generation
4. Auth controller with login, refresh, logout endpoints
5. User entity with proper relationships
6. Integration with existing guards and decorators
7. Swagger documentation for auth endpoints
```

**Expected Files:**
- `src/modules/auth/auth.module.ts`
- `src/modules/auth/auth.controller.ts`
- `src/modules/auth/auth.service.ts`
- `src/modules/auth/strategies/jwt.strategy.ts`
- `src/modules/auth/entities/user.entity.ts`

---

## **Step 6: User Management Setup**

**Prompt:**
```
Create user management system:
1. User entity with roles and permissions
2. User repository with custom methods
3. User service with CRUD operations
4. User controller with proper validation
5. Role-based permission system
6. Integration with auth module
7. Proper DTOs for user operations
```

**Expected Files:**
- `src/modules/user-management/user-management.module.ts`
- `src/modules/user-management/user-management.controller.ts`
- `src/modules/user-management/user-management.service.ts`
- `src/modules/user-management/entities/`
- `src/modules/user-management/dto/`

---

## **Step 7: Authentication Flow**

**Prompt:**
```
Implement complete authentication flow:
1. OAuth integration with Supabase (Google, GitHub, Discord, Apple)
2. JWT token generation and validation
3. Refresh token mechanism with Redis storage
4. Session management and cleanup
5. Password reset and email verification
6. Rate limiting for auth endpoints
7. Comprehensive error handling
```

**Expected Files:**
- `src/modules/auth/oauth/`
- `src/modules/auth/dto/`
- `src/modules/auth/guards/`
- Updated auth service and controller

---

## **Step 8: Organization Module**

**Prompt:**
```
Create multi-tenant organization system:
1. Organization entity with relationships
2. Organization service with tenant isolation
3. Organization controller with CRUD operations
4. Member management within organizations
5. Usage tracking and analytics
6. Proper authorization for organization resources
7. Integration with user management
```

**Expected Files:**
- `src/modules/organizations/organizations.module.ts`
- `src/modules/organizations/organizations.controller.ts`
- `src/modules/organizations/organizations.service.ts`
- `src/modules/organizations/entities/`
- `src/modules/organizations/dto/`

---

## **Step 9: File Management Module**

**Prompt:**
```
Create file management system:
1. Supabase Storage integration
2. AWS S3 backup configuration
3. File upload/download with streaming
4. Permission-based file access
5. File metadata and organization
6. Virus scanning integration
7. File sharing and expiration
```

**Expected Files:**
- `src/modules/file-management/file-management.module.ts`
- `src/modules/file-management/file-management.controller.ts`
- `src/modules/file-management/file-management.service.ts`
- `src/modules/file-management/entities/`
- `src/modules/file-management/dto/`

---

## **Step 10: Email Service Module**

**Prompt:**
```
Create email service with AWS SES:
1. AWS SES configuration and service
2. Email templates system
3. User invitation emails
4. Notification system
5. Email queue with Bull
6. Email tracking and analytics
7. Unsubscribe management
```

**Expected Files:**
- `src/modules/email/email.module.ts`
- `src/modules/email/email.controller.ts`
- `src/modules/email/email.service.ts`
- `src/modules/email/templates/`
- `src/modules/email/dto/`

---

## **Step 11: Analytics Module**

**Prompt:**
```
Create analytics and monitoring system:
1. Usage metrics collection
2. Performance monitoring
3. Audit trail system
4. Dashboard data endpoints
5. Real-time analytics with WebSockets
6. Data export functionality
7. Privacy-compliant tracking
```

**Expected Files:**
- `src/modules/analytics/analytics.module.ts`
- `src/modules/analytics/analytics.controller.ts`
- `src/modules/analytics/analytics.service.ts`
- `src/modules/analytics/entities/`
- `src/modules/analytics/dto/`

---

## **Step 12: WebSocket Gateway**

**Prompt:**
```
Create real-time communication system:
1. WebSocket gateway with Socket.IO
2. Real-time notifications
3. Presence system
4. Live updates for organizations
5. Event broadcasting
6. Authentication for WebSocket connections
7. Room management and permissions
```

**Expected Files:**
- `src/modules/websocket/websocket.module.ts`
- `src/modules/websocket/websocket.gateway.ts`
- `src/modules/websocket/websocket.service.ts`
- `src/modules/websocket/dto/`

---

## **Step 13: Security & Performance**

**Prompt:**
```
Implement advanced security and performance features:
1. Rate limiting implementation with Redis
2. Request validation with Zod schemas
3. Caching strategies for different endpoints
4. Security headers and CORS configuration
5. Input sanitization and XSS protection
6. SQL injection prevention
7. Performance monitoring and optimization
```

**Expected Files:**
- `src/libs/security/`
- `src/libs/performance/`
- Updated guards and interceptors

---

## **Step 14: Comprehensive Testing**

**Prompt:**
```
Create comprehensive test suite:
1. Unit tests for all services and controllers
2. E2E tests for critical user flows
3. Integration tests for external services
4. Performance testing setup
5. Test utilities and mocks
6. CI/CD pipeline configuration
7. Coverage reporting and thresholds
```

**Expected Files:**
- Unit tests (*.spec.ts)
- E2E tests (*.e2e-spec.ts)
- Test utilities
- Updated Jest configuration

---

## **Step 15: Production Readiness**

**Prompt:**
```
Prepare application for production deployment:
1. Docker containerization with multi-stage builds
2. Environment validation and configuration
3. Logging and monitoring setup
4. Health checks for load balancers
5. Graceful shutdown handling
6. Performance optimization
7. Security hardening
```

**Expected Files:**
- `Dockerfile`
- `docker-compose.yml`
- `.dockerignore`
- Production configuration files

---

## **Usage Instructions:**

1. **Complete each step in order** - Dependencies build on previous steps
2. **Test after each step** - Ensure functionality works before proceeding
3. **Use the exact prompts** - Copy and paste for consistency
4. **Validate builds** - Run `pnpm build` and `pnpm test` after each step
5. **Update documentation** - Keep README and API docs current

## **Troubleshooting:**

**Connection Refused:**
- Check if Redis is running (or make it optional)
- Start with minimal configuration
- Add modules incrementally

**Build Failures:**
- Install missing dependencies (`@fastify/static`)
- Check TypeScript configuration
- Verify import paths

**Server Won't Start:**
- Remove complex modules temporarily
- Check for circular dependencies
- Validate environment variables

## **Current Status:**
- ✅ **Step 1: Bootstrap NestJS Application** - COMPLETED
- ⏳ **Step 2: Database Layer Setup** - NEXT
