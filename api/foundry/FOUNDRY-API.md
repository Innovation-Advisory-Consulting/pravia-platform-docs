# Foundry API - Authentication & Authorization

## Overview
Foundry is the authentication and authorization API for the Pravia ecosystem. It provides secure user management, JWT-based authentication, Supabase integration, and government compliance features including comprehensive audit trails.

## Purpose
- User authentication and authorization
- JWT token management (access + refresh tokens)
- Supabase Admin API integration (15 methods)
- User profile management
- Role-based access control (RBAC)
- Government compliance and audit trails
- User lifecycle management

## Technology Stack

| Technology | Version | Purpose |
|------------|---------|---------|
| NestJS | Latest | Framework with DI |
| Fastify | Latest | High-performance HTTP |
| TypeORM | Latest | Database ORM |
| PostgreSQL | 14+ | Database (Supabase) |
| Supabase | Latest | Auth + Admin API |
| Redis | 6+ | Caching and sessions |
| JWT | Latest | Token authentication |
| Swagger/OpenAPI | Latest | API documentation |
| Jest | Latest | Testing |
| Artillery | Latest | Load testing |

## Database Schema
**Name:** `external_authentication`

**Purpose:** User authentication, profiles, roles, and audit logs

**Multi-Schema Architecture:**
```sql
-- Supabase Managed (Read-Only)
auth.users                    -- Supabase authentication
auth.audit_log_entries        -- Supabase system logs
auth.sessions                 -- User sessions

-- Pravia Business Schema
pravia.user_profiles          -- Extended user data
pravia.audit_log_entries      -- Custom audit logs

-- Materialized Views (Performance)
pravia.user_profiles_with_auth    -- Joined auth + profile
pravia.audit_trail_view           -- Audit with context
pravia.user_activity_summary      -- Analytics
```

## Directory Structure

```
api/foundry/
├── src/
│   ├── common/              # Shared utilities
│   │   ├── constants.ts
│   │   ├── guards/         # Auth guards
│   │   └── README.md
│   ├── database/            # Database configuration
│   │   ├── data-source.ts
│   │   ├── database.module.ts
│   │   ├── migrations/     # Database migrations
│   │   └── scripts/        # Database scripts
│   ├── modules/             # Feature modules
│   │   ├── auth-admin/     # Authentication & Supabase
│   │   ├── auth-audit/     # Audit trails
│   │   ├── contacts/       # User contacts
│   │   ├── dev/            # Development utilities
│   │   ├── health/         # Health monitoring
│   │   ├── role/           # Role management
│   │   ├── user-profile/   # User profiles & admin
│   │   ├── validators/     # Custom validators
│   │   └── _archive/       # Archived modules
│   ├── types/              # TypeScript types
│   ├── app.module.ts       # Root module
│   ├── app.controller.ts   # Root controller
│   ├── app.service.ts      # Root service
│   └── main.ts             # Application entry
├── test/                    # Test files
│   ├── *.e2e-spec.ts       # E2E tests
│   ├── setup-e2e.ts        # E2E setup
│   ├── setup.ts            # Test setup
│   └── test-setup.ts       # Test configuration
├── deploy/                  # Deployment scripts
│   ├── config.json         # Deployment config
│   ├── deploy-azure-*.sh   # Azure deployment
│   ├── AZURE_DEPLOYMENT.md
│   └── DEPLOYMENT_SUCCESS.md
├── docs/                    # Documentation
│   ├── API_ENDPOINTS.md    # Endpoint documentation
│   ├── ARCHITECTURE.md     # System architecture
│   ├── CONFIGURATION.md    # Configuration guide
│   ├── ENTITY_NAMING_GUIDE.md
│   ├── ERD.md              # Database ERD
│   ├── LINTING_SETUP.md
│   └── TESTING.md          # Testing guide
├── load-tests/             # Load testing
│   ├── admin-operations.yml
│   ├── auth-flow.yml
│   ├── setup.js
│   └── stress-test.yml
├── public/                 # Static files
│   └── static/swagger/     # Swagger UI
├── scripts/                # Utility scripts
│   ├── migrate.sh
│   ├── post-migration-processor.ts
│   ├── query-contacts.mjs
│   ├── update-build-info.js
│   └── _archive/           # Archived scripts
├── .env.example            # Environment template
├── .env.local              # Local environment
├── .env.development        # Development
├── .env.test               # Test environment
├── .env.qa                 # QA environment
├── Dockerfile              # Docker configuration
├── jest.config.js          # Jest configuration
├── nest-cli.json           # NestJS CLI config
├── package.json            # Dependencies
├── tsconfig.json           # TypeScript config
├── DISABLE_AUTH_FIX.md     # Auth disable guide
├── SCHEMA_COMPARISON.md    # Schema comparison
└── README.md               # Project documentation
```

## Modules

### 1. Auth Admin Module
**Path:** `src/modules/auth-admin/`

**Purpose:** Core authentication and Supabase integration

**Features:**
- Token validation (Supabase → Internal JWT)
- User synchronization
- Supabase Admin API (15 methods)
- Session management

**Supabase Admin API Methods:**
- `createUser()` - Create new users
- `updateUser()` - Update user data
- `deleteUser()` - Delete users
- `listUsers()` - List/search users
- `resetUserPassword()` - Reset passwords
- `updateUserMetadata()` - Update metadata
- `verifyToken()` - Validate tokens
- `refreshToken()` - Refresh sessions
- `revokeUserSessions()` - Force logout
- `generatePasswordResetLink()` - Admin password reset
- `generateMagicLink()` - Admin magic link
- `inviteUserByEmail()` - Send invitations
- `banUser()` / `unbanUser()` - User management
- `getAuditLogs()` - Retrieve audit logs
- `getUserActivity()` - Activity tracking

**Endpoints:**
- `POST /api/auth/validate` - Validate Supabase token
- `POST /api/auth/refresh` - Refresh session
- `GET /api/auth/me` - Get current user
- `POST /api/auth/logout` - Logout user

**Components:**
- `auth-admin.controller.ts` - Auth endpoints
- `auth-admin.service.ts` - Token validation & sync
- `supabase.service.ts` - Supabase Admin API
- `auth-admin.service.spec.ts` - Unit tests
- `supabase.service.spec.ts` - Unit tests
- `dto/` - Request/response DTOs

### 2. User Profile Module
**Path:** `src/modules/user-profile/`

**Purpose:** User profile management and admin operations

**Features:**
- User profile CRUD
- Admin user management
- Profile synchronization
- Metadata management

**Endpoints:**

**Profile Management:**
- `GET /api/user-management/profiles` - List profiles
- `GET /api/user-management/:userId/profile` - Get profile
- `POST /api/user-management/:userId/profile` - Create profile
- `PUT /api/user-management/:userId/profile` - Update profile
- `DELETE /api/user-management/:userId/profile` - Delete profile

**Admin Operations:**
- `POST /api/user-management/admin/users` - Create user
- `GET /api/user-management/admin/users` - List users (paginated)
- `GET /api/user-management/admin/users/:id` - Get user
- `PUT /api/user-management/admin/users/:id` - Update user
- `DELETE /api/user-management/admin/users/:id` - Delete user
- `POST /api/user-management/admin/users/:id/reset-password` - Reset password
- `POST /api/user-management/admin/users/:id/magic-link` - Generate magic link
- `POST /api/user-management/admin/users/:id/ban` - Ban user
- `POST /api/user-management/admin/users/:id/unban` - Unban user
- `POST /api/user-management/admin/users/:id/revoke-sessions` - Force logout
- `POST /api/user-management/admin/users/invite` - Invite user

**Components:**
- `user-profile.controller.ts` - Profile + Admin endpoints
- `user-profile.service.ts` - Business logic
- `user-profile.repository.ts` - Data access
- `user-profile.service.spec.ts` - Unit tests
- `user-profile.repository.spec.ts` - Repository tests
- `entity/` - UserProfile entity
- `dto/` - Data transfer objects
- `mappers/` - Data transformation

### 3. Auth Audit Module
**Path:** `src/modules/auth-audit/`

**Purpose:** Compliance and audit trail management

**Features:**
- Audit log creation
- Audit log querying
- Compliance reporting
- Activity tracking

**Endpoints:**
- `GET /api/auth-audit/logs` - List audit logs
- `GET /api/auth-audit/logs/:id` - Get audit log
- `POST /api/auth-audit/logs` - Create audit log
- `GET /api/auth-audit/user/:userId/activity` - User activity

**Components:**
- `auth-audit.controller.ts` - Audit endpoints
- `auth-audit.service.ts` - Audit logic
- `auth-audit.repository.ts` - Data access
- `entity/` - Audit entities

**Note:** Currently commented out pending schema migration

### 4. Role Module
**Path:** `src/modules/role/`

**Purpose:** Role management for RBAC

**Features:**
- Role CRUD operations
- Role assignment
- Permission management

**Endpoints:**
- `GET /api/roles` - List roles
- `GET /api/roles/:id` - Get role
- `POST /api/roles` - Create role
- `PUT /api/roles/:id` - Update role
- `DELETE /api/roles/:id` - Delete role

**Components:**
- `role.controller.ts` - Role endpoints
- `role.service.ts` - Business logic
- `role.repository.ts` - Data access
- `entity/` - Role entity
- `dto/` - Data transfer objects
- `mappers/` - Data transformation

**Note:** Currently commented out pending schema migration

### 5. Contacts Module
**Path:** `src/modules/contacts/`

**Purpose:** User contact information management

**Features:**
- Contact CRUD operations
- Contact validation
- Contact synchronization

**Endpoints:**
- `GET /api/contacts` - List contacts
- `GET /api/contacts/:id` - Get contact
- `POST /api/contacts` - Create contact
- `PUT /api/contacts/:id` - Update contact

**Components:**
- `contacts.controller.ts` - Contact endpoints
- `contacts.service.ts` - Business logic
- `dto/` - Data transfer objects

### 6. Health Module
**Path:** `src/modules/health/`

**Purpose:** System health monitoring

**Features:**
- Overall health status
- Database connectivity
- Memory usage
- Network status

**Endpoints:**
- `GET /api/health` - Overall health
- `GET /api/health/database` - Database health
- `GET /api/health/memory` - Memory health
- `GET /api/health/network` - Network health

**Components:**
- `health.controller.ts` - Health endpoints
- `health.service.ts` - Health checks

### 7. Dev Module
**Path:** `src/modules/dev/`

**Purpose:** Development utilities (disabled in production)

**Features:**
- Test token generation
- Development helpers

**Endpoints:**
- `GET /api/auth/dev/test-token` - Get test JWT

**Components:**
- `dev.controller.ts` - Dev endpoints

**Note:** Only available in non-production environments

### 8. Validators Module
**Path:** `src/modules/validators/`

**Purpose:** Custom validation decorators

**Features:**
- Entity existence validation
- Unique value validation

**Validators:**
- `IsExist` - Validates entity exists
- `IsNotExist` - Validates entity doesn't exist

**Components:**
- `is-exist.validator.ts`
- `is-not-exist.validator.ts`
- `validators.module.ts`

## Authentication Flow

### Token Validation Flow
```
1. Client sends Supabase JWT → Foundry
2. Foundry validates with Supabase
3. Foundry syncs/creates UserProfile
4. Foundry generates internal JWT
5. Client uses internal JWT for API calls
6. Other APIs validate internal JWT
```

### User Creation Flow
```
1. Admin calls POST /admin/users
2. Foundry creates user in Supabase
3. Foundry creates UserProfile in database
4. Foundry returns user data + tokens
```

### Password Reset Flow
```
1. Admin calls POST /admin/users/:id/reset-password
2. Foundry generates reset link via Supabase
3. Foundry returns reset link
4. User clicks link and resets password
```

## Environment Configuration

### Environment Files

| File | Purpose | Supabase |
|------|---------|----------|
| `.env` | Default | - |
| `.env.local` | Local development | localhost:54321 |
| `.env.development` | Development | ahanrwalkdrbbhlhjxzr |
| `.env.test` | Testing | gurgyegmjqbisdhbvoww |
| `.env.qa` | Quality assurance | Per environment |
| `.env.example` | Template | - |

### Key Environment Variables

```bash
# Application
NODE_ENV=development
PORT=4000

# Database (Supabase)
DATABASE_HOST=aws-0-us-east-1.pooler.supabase.com
DATABASE_PORT=5432
DATABASE_USERNAME=postgres.xxxxx
DATABASE_PASSWORD=xxxxx
DATABASE_DB_NAME=postgres
DATABASE_SCHEMA=external_authentication

# Supabase
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_ANON_KEY=xxxxx
SUPABASE_SERVICE_KEY=xxxxx  # For Admin API

# JWT
JWT_SECRET=your-secret-key
JWT_EXPIRES_IN=15m
JWT_REFRESH_SECRET=your-refresh-secret
JWT_REFRESH_EXPIRES_IN=7d

# Redis
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=xxxxx

# API
API_PREFIX=api
SWAGGER_ENABLED=true
```

## Development

### Installation
```bash
# Install dependencies
pnpm install

# Copy environment file
cp .env.example .env

# Configure environment variables
```

### Running the Application
```bash
# Development mode
pnpm dev

# Development with local Supabase
pnpm dev:local

# Production mode
pnpm build
pnpm start:prod
```

### Database Operations
```bash
# Generate migration
pnpm migration:generate

# Run migrations
pnpm migration:run

# Revert migration
pnpm migration:revert

# Sync schema (dev only)
pnpm schema:sync
```

## Testing

### Test Types
- **Unit Tests** - Service methods
- **E2E Tests** - Full API flow
- **Load Tests** - Performance testing
- **Admin Tests** - HTTP endpoint testing

### Running Tests
```bash
# All tests
pnpm test:all

# Unit tests
pnpm test

# E2E tests
pnpm test:e2e

# Test coverage
pnpm test:cov

# Watch mode
pnpm test:watch
```

### Load Testing
```bash
# Setup test users
pnpm load:setup

# Quick load test
pnpm load:quick

# Full auth flow
pnpm load:test

# Stress test
pnpm load:stress

# Admin operations
pnpm load:admin

# Generate report
pnpm load:report
```

### Load Test Configuration
**Files:**
- `load-tests/auth-flow.yml` - Auth flow testing
- `load-tests/admin-operations.yml` - Admin endpoint testing
- `load-tests/stress-test.yml` - Stress testing
- `load-tests/setup.js` - Test setup

**Features:**
- Randomized test data (Faker.js)
- Automatic cleanup
- Parallel safe
- Real Supabase integration
- Government compliance thresholds

## API Documentation

### Swagger UI
Once running, access at:
- **URL:** `http://localhost:4000/docs`
- **OpenAPI JSON:** `http://localhost:4000/docs-json`

### Authorization in Swagger

**Quick Start (Development):**
```bash
1. Start API: pnpm dev
2. Open: http://localhost:4000/docs
3. Call: GET /api/auth/dev/test-token
4. Copy internalJWT
5. Click "Authorize"
6. Enter: Bearer <token>
```

**Production-like:**
```bash
1. Get Supabase token
2. Call: POST /api/auth/validate
3. Copy accessToken
4. Use in Swagger: Bearer <accessToken>
```

## Deployment

### Azure Container Apps

**Deployment Scripts:**
- `deploy/deploy-azure-dev.sh` - Deploy to development
- `deploy/deploy-azure-qa.sh` - Deploy to QA
- `deploy/deploy-azure-test.sh` - Deploy to test
- `deploy/deploy-azure-uat.sh` - Deploy to UAT

**Deployment Process:**
```bash
cd api/foundry
./deploy/deploy-azure-dev.sh
```

**What it does:**
1. Builds Docker image (linux/amd64)
2. Pushes to Azure Container Registry
3. Verifies PORT not set (should use default 3000)
4. Updates Container App
5. Verifies deployment health

**Important:** DO NOT set PORT environment variable in Azure

### Docker

**Build:**
```bash
docker build -t foundry-api .
```

**Run:**
```bash
docker run -p 4000:3000 foundry-api
```

## Documentation

### Available Documentation
- `docs/API_ENDPOINTS.md` - Complete endpoint guide
- `docs/ARCHITECTURE.md` - System architecture
- `docs/CONFIGURATION.md` - Setup guide
- `docs/ENTITY_NAMING_GUIDE.md` - Naming conventions
- `docs/ERD.md` - Database schema
- `docs/LINTING_SETUP.md` - Linting configuration
- `docs/TESTING.md` - Testing guide

### Additional Files
- `DISABLE_AUTH_FIX.md` - Auth disable guide
- `SCHEMA_COMPARISON.md` - Schema comparison
- `deploy/AZURE_DEPLOYMENT.md` - Deployment guide
- `deploy/DEPLOYMENT_SUCCESS.md` - Deployment success

## Code Quality

### Linting
```bash
# Run linter
pnpm lint

# Fix issues
pnpm lint:fix

# Format code
pnpm format

# Format and lint
pnpm format-lint
```

### Configuration
- `.eslintrc.js` - ESLint rules
- `.prettierrc` - Prettier config
- `.prettierignore` - Ignore patterns

## Security Features

### Authentication
- JWT-based authentication
- Refresh token support
- Token expiration (15min access, 7d refresh)
- Secure token storage

### Authorization
- Role-based access control (RBAC)
- Permission-based access
- Resource-level permissions
- Guard-based protection

### Audit & Compliance
- Comprehensive audit logging
- User activity tracking
- Government compliance ready
- Cross-schema audit trails

### Data Protection
- Environment variable encryption
- Secure database connections
- HTTPS enforcement
- Input validation
- SQL injection prevention

## Performance Features

### Materialized Views
- `user_profiles_with_auth` - Joined user data
- `audit_trail_view` - Audit with context
- `user_activity_summary` - Analytics

### Caching
- Redis integration
- Session caching
- Query result caching

### Database Optimization
- Connection pooling
- Query optimization
- Proper indexing
- Pagination support

## Troubleshooting

### Common Issues

**Database Connection Failed**
```bash
# Check environment
cat .env | grep DATABASE

# Test connection
psql -h $DATABASE_HOST -U $DATABASE_USERNAME -d $DATABASE_DB_NAME

# Verify schema
SELECT schema_name FROM information_schema.schemata 
WHERE schema_name = 'external_authentication';
```

**Port Already in Use**
```bash
# Find process
lsof -ti:4000

# Kill process
lsof -ti:4000 | xargs kill -9

# Or change port
PORT=4001
```

**Supabase Connection Issues**
```bash
# Verify Supabase URL
curl $SUPABASE_URL/rest/v1/

# Check service key
echo $SUPABASE_SERVICE_KEY

# Test Admin API
curl -H "apikey: $SUPABASE_SERVICE_KEY" \
     $SUPABASE_URL/auth/v1/admin/users
```

**Migration Errors**
```bash
# Check status
pnpm migration:show

# Revert
pnpm migration:revert

# Re-run
pnpm migration:run
```

## Best Practices

### Module Development
1. Follow NestJS patterns
2. Use dependency injection
3. Implement repository pattern
4. Create DTOs for endpoints
5. Add Swagger decorators
6. Write comprehensive tests
7. Document public APIs

### Security
1. Validate all inputs
2. Use guards for protection
3. Implement RBAC
4. Log security events
5. Rotate secrets regularly
6. Use HTTPS in production

### Testing
1. Write unit tests first
2. Add integration tests
3. Include E2E tests
4. Test error scenarios
5. Mock external services
6. Maintain high coverage

### Performance
1. Use caching strategically
2. Optimize database queries
3. Implement pagination
4. Use materialized views
5. Monitor performance
6. Profile bottlenecks

## Related Documentation
- Parent: `api/API-OVERVIEW.md`
- Flux API: `api/flux/FLUX-API.md`
- Development: `docs/development/API_BEST_PRACTICES.md`
- Environment: `docs/development/ENVIRONMENT_STANDARDS.md`
