# Flux API - Dataverse Data API

## Overview
Flux is a high-performance data API that serves as the integration layer between the Pravia ecosystem and Microsoft Dataverse. It manages business data including accounts, contacts, submissions, and documents.

## Purpose
- Dataverse integration and data synchronization
- Business data management (accounts, contacts, submissions)
- Document and attachment handling
- Organization member management
- Form submission processing

## Technology Stack

| Technology | Version | Purpose |
|------------|---------|---------|
| NestJS | Latest | Framework with DI |
| Fastify | Latest | High-performance HTTP |
| TypeORM | Latest | Database ORM |
| PostgreSQL | 14+ | Database (Supabase) |
| Swagger/OpenAPI | Latest | API documentation |
| Jest | Latest | Testing |
| ESLint + Prettier | Latest | Code quality |

## Database Schema
**Name:** `external_dataverse`

**Purpose:** Stores business data and Dataverse integration information

## Directory Structure

```
api/flux/
├── src/
│   ├── common/              # Shared utilities and constants
│   ├── database/            # Database configuration and migrations
│   ├── modules/             # Feature modules
│   │   ├── accounts/        # Account management
│   │   ├── admin/           # Admin operations
│   │   ├── attachments/     # File attachments
│   │   ├── contacts/        # Contact management
│   │   ├── designees/       # Designee management
│   │   ├── document-types/  # Document type definitions
│   │   ├── document-urls/   # Document URL management
│   │   ├── health/          # Health check endpoints
│   │   ├── organization-members/  # Organization member management
│   │   ├── register/        # Registration processes
│   │   ├── submissions/     # Form submissions
│   │   ├── test-only/       # Testing utilities
│   │   └── validators/      # Custom validators
│   ├── app.module.ts        # Root module
│   ├── app.controller.ts    # Root controller
│   ├── app.service.ts       # Root service
│   └── main.ts              # Application entry point
├── test/                    # Test files
│   ├── integration/         # Integration tests
│   ├── mocks/              # Test mocks
│   ├── *.e2e-spec.ts       # E2E tests
│   └── setup-*.ts          # Test setup files
├── deploy/                  # Deployment scripts
│   ├── config.json         # Deployment configuration
│   ├── deploy-azure-*.sh   # Azure deployment scripts
│   └── AZURE_DEPLOYMENT.md # Deployment documentation
├── docs/                    # Documentation
│   ├── architecture-diagram.md
│   ├── BREAKING_CHANGES.md
│   ├── DATAVERSE_FLOWS.md
│   ├── ENVIRONMENT_CONFIG.md
│   ├── LINTING_SETUP.md
│   ├── MODULE_REFACTORING.md
│   ├── TESTING.md
│   └── use-cases/          # Use case documentation
├── genai_issues/           # AI-related issues tracking
├── public/                 # Static files
│   └── static/swagger/     # Swagger UI assets
├── scripts/                # Utility scripts
│   ├── migrate.sh          # Database migration script
│   ├── post-migration-processor.ts
│   └── update-build-info.js
├── .env.example            # Environment template
├── .env.development        # Development environment
├── .env.test               # Test environment
├── .env.qa                 # QA environment
├── .env.uat                # UAT environment
├── .env.local              # Local environment
├── Dockerfile              # Docker configuration
├── jest.config.js          # Jest configuration
├── nest-cli.json           # NestJS CLI configuration
├── package.json            # Dependencies and scripts
├── tsconfig.json           # TypeScript configuration
└── README.md               # Project documentation
```

## Modules

### 1. Accounts Module
**Path:** `src/modules/accounts/`

**Purpose:** Manage business accounts (companies, organizations)

**Features:**
- CRUD operations for accounts
- Account search and filtering
- Account relationships
- Dataverse synchronization

**Endpoints:**
- `GET /api/accounts` - List accounts
- `GET /api/accounts/:id` - Get account by ID
- `POST /api/accounts` - Create account
- `PUT /api/accounts/:id` - Update account
- `DELETE /api/accounts/:id` - Delete account

**Components:**
- `accounts.controller.ts` - HTTP endpoints
- `accounts.service.ts` - Business logic
- `accounts.module.ts` - Module definition
- `dto/` - Data transfer objects
- `entity/` - Database entities
- `mappers/` - Data transformation
- `repository/` - Data access layer

### 2. Admin Module
**Path:** `src/modules/admin/`

**Purpose:** Administrative operations and system management

**Features:**
- System administration
- Data management
- Configuration management

**Components:**
- `admin.service.ts` - Admin operations
- `admin.module.ts` - Module definition
- `controllers/` - Admin endpoints

### 3. Attachments Module
**Path:** `src/modules/attachments/`

**Purpose:** File attachment management

**Features:**
- Upload attachments
- Download attachments
- Attachment metadata
- File validation

**Endpoints:**
- `GET /api/attachments` - List attachments
- `GET /api/attachments/:id` - Get attachment
- `POST /api/attachments` - Upload attachment
- `DELETE /api/attachments/:id` - Delete attachment

**Components:**
- `attachments.controller.ts` - HTTP endpoints
- `attachments.service.ts` - Business logic
- `attachments.module.ts` - Module definition
- `dto/` - Data transfer objects
- `entity/` - Database entities
- `mappers/` - Data transformation

### 4. Contacts Module
**Path:** `src/modules/contacts/`

**Purpose:** Contact management (people associated with accounts)

**Features:**
- CRUD operations for contacts
- Contact search and filtering
- Contact relationships
- Dataverse synchronization

**Endpoints:**
- `GET /api/contacts` - List contacts
- `GET /api/contacts/:id` - Get contact by ID
- `POST /api/contacts` - Create contact
- `PUT /api/contacts/:id` - Update contact
- `DELETE /api/contacts/:id` - Delete contact

**Components:**
- `contacts.controller.ts` - HTTP endpoints
- `contacts.service.ts` - Business logic
- `contacts.module.ts` - Module definition
- `dto/` - Data transfer objects
- `entities/` - Database entities
- `mappers/` - Data transformation
- `repositories/` - Data access layer

### 5. Designees Module
**Path:** `src/modules/designees/`

**Purpose:** Manage designated representatives

**Features:**
- Designee assignment
- Designee management
- Authorization tracking

**Endpoints:**
- `GET /api/designees` - List designees
- `GET /api/designees/:id` - Get designee
- `POST /api/designees` - Create designee
- `PUT /api/designees/:id` - Update designee

**Components:**
- `designees.controller.ts` - HTTP endpoints
- `designee.service.ts` - Business logic
- `designees.module.ts` - Module definition
- `dto/` - Data transfer objects
- `entity/` - Database entities
- `mappers/` - Data transformation

### 6. Document Types Module
**Path:** `src/modules/document-types/`

**Purpose:** Define and manage document type classifications

**Features:**
- Document type definitions
- Type categorization
- Validation rules

**Endpoints:**
- `GET /api/document-types` - List document types
- `GET /api/document-types/:id` - Get document type
- `POST /api/document-types` - Create document type
- `PUT /api/document-types/:id` - Update document type

**Components:**
- `document-types.controller.ts` - HTTP endpoints
- `document-types.service.ts` - Business logic
- `document-types.module.ts` - Module definition
- `dto/` - Data transfer objects
- `entity/` - Database entities
- `mappers/` - Data transformation

### 7. Document URLs Module
**Path:** `src/modules/document-urls/`

**Purpose:** Manage document URL references

**Features:**
- URL generation
- URL validation
- Access control

**Endpoints:**
- `GET /api/document-urls` - List document URLs
- `GET /api/document-urls/:id` - Get document URL
- `POST /api/document-urls` - Create document URL

**Components:**
- `document-urls.controller.ts` - HTTP endpoints
- `document-url.service.ts` - Business logic
- `document-urls.module.ts` - Module definition
- `dto/` - Data transfer objects
- `entity/` - Database entities
- `mappers/` - Data transformation

### 8. Health Module
**Path:** `src/modules/health/`

**Purpose:** System health monitoring

**Features:**
- Overall health status
- Database connectivity check
- Memory usage monitoring
- Uptime tracking

**Endpoints:**
- `GET /api/health` - Overall health
- `GET /api/health/database` - Database health
- `GET /api/health/memory` - Memory health

**Components:**
- `health.controller.ts` - HTTP endpoints
- `health.service.ts` - Health checks
- `health.module.ts` - Module definition

### 9. Organization Members Module
**Path:** `src/modules/organization-members/`

**Purpose:** Manage organization membership and roles

**Features:**
- Member management
- Role assignment
- Document associations
- Access control

**Sub-modules:**
- **Organization Contact Document** - Document management for members
- **Organization Contact Role** - Role management for members

**Endpoints:**
- `GET /api/organization-contact-documents` - List member documents
- `POST /api/organization-contact-documents` - Create member document
- `GET /api/organization-contact-roles` - List member roles
- `POST /api/organization-contact-roles` - Assign role

**Components:**
- `organization-contact-document.controller.ts` - Document endpoints
- `organization-contact-document.service.ts` - Document logic
- `organization-contact-document.repository.ts` - Document data access
- `organization-contact-role.controller.ts` - Role endpoints
- `organization-contact-role.service.ts` - Role logic
- `organization-contact-role.repository.ts` - Role data access
- `organization-members.module.ts` - Module definition
- `dto/` - Data transfer objects
- `entity/` - Database entities
- `mappers/` - Data transformation

### 10. Register Module
**Path:** `src/modules/register/`

**Purpose:** Registration process management

**Features:**
- Registration workflows
- Process tracking
- Status management
- Dataverse integration

**Endpoints:**
- `GET /api/register` - List registrations
- `GET /api/register/:id` - Get registration
- `POST /api/register` - Create registration
- `PUT /api/register/:id` - Update registration

**Components:**
- `register.controller.ts` - HTTP endpoints
- `register.service.ts` - Business logic
- `register.service.spec.ts` - Unit tests
- `register.module.ts` - Module definition
- `dto/` - Data transfer objects
- `entity/` - Database entities
- `mappers/` - Data transformation
- `repository/` - Data access layer

### 11. Submissions Module
**Path:** `src/modules/submissions/`

**Purpose:** Form submission management

**Features:**
- Form submission processing
- Submission validation
- Status tracking
- Data persistence

**Endpoints:**
- `GET /api/submissions` - List submissions
- `GET /api/submissions/:id` - Get submission
- `POST /api/submissions` - Create submission
- `PUT /api/submissions/:id` - Update submission

**Components:**
- `submissions.controller.ts` - HTTP endpoints
- `submissions.service.ts` - Business logic
- `submissions.module.ts` - Module definition
- `dto/` - Data transfer objects
- `entity/` - Database entities
- `mappers/` - Data transformation

### 12. Test-Only Module
**Path:** `src/modules/test-only/`

**Purpose:** Testing utilities and endpoints (disabled in production)

**Features:**
- Test data creation
- Test data cleanup
- Test helpers

**Note:** Only available in non-production environments

**Endpoints:**
- `POST /api/test-only/cleanup` - Clean test data
- `POST /api/test-only/seed` - Seed test data

**Components:**
- `test-only.controller.ts` - Test endpoints
- `test-only.service.ts` - Test operations
- `test-only.module.ts` - Module definition
- `dto/` - Data transfer objects
- `services/` - Test services
- `README.md` - Test module documentation

### 13. Validators Module
**Path:** `src/modules/validators/`

**Purpose:** Custom validation decorators

**Features:**
- Entity existence validation
- Unique value validation
- Custom validation rules

**Validators:**
- `IsExist` - Validates entity exists in database
- `IsNotExist` - Validates entity doesn't exist

**Components:**
- `is-exist.validator.ts` - Existence validator
- `is-not-exist.validator.ts` - Non-existence validator
- `validators.module.ts` - Module definition
- `index.ts` - Exports

## Common Components

### Database
**Path:** `src/database/`

**Components:**
- `data-source.ts` - TypeORM data source configuration
- `database.module.ts` - Database module
- `migrations/` - Database migration files

**Features:**
- TypeORM configuration
- Connection management
- Migration support
- Schema synchronization

### Common Utilities
**Path:** `src/common/`

**Components:**
- `constants.ts` - Application constants
- `README.md` - Common utilities documentation

## Environment Configuration

### Environment Files

| File | Purpose | Supabase Project |
|------|---------|------------------|
| `.env` | Default configuration | - |
| `.env.local` | Local development | localhost |
| `.env.development` | Development | ahanrwalkdrbbhlhjxzr |
| `.env.test` | Testing | gurgyegmjqbisdhbvoww |
| `.env.qa` | Quality assurance | Per environment |
| `.env.uat` | User acceptance | laorysvmqjaxatyzsgkj |
| `.env.example` | Template | - |

### Key Environment Variables

```bash
# Application
NODE_ENV=development
PORT=4001
DATABASE_ENABLED=true

# Database (Supabase)
DATABASE_HOST=aws-0-us-east-1.pooler.supabase.com
DATABASE_PORT=5432
DATABASE_USERNAME=postgres.xxxxx
DATABASE_PASSWORD=xxxxx
DATABASE_DB_NAME=postgres
DATABASE_SCHEMA=external_dataverse

# API Configuration
API_PREFIX=api
SWAGGER_ENABLED=true

# Dataverse Integration
DATAVERSE_URL=https://org.crm.dynamics.com
DATAVERSE_CLIENT_ID=xxxxx
DATAVERSE_CLIENT_SECRET=xxxxx
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

# Production mode
pnpm build
pnpm start:prod

# Watch mode
pnpm start:dev
```

### Database Operations
```bash
# Generate migration
pnpm migration:generate

# Run migrations
pnpm migration:run

# Revert migration
pnpm migration:revert

# Run migration script
./scripts/migrate.sh
```

## Testing

### Test Structure
```
test/
├── integration/           # Integration tests
│   ├── accounts/
│   ├── register/
│   ├── contacts.integration-spec.ts
│   └── sample-contact-data.ts
├── mocks/                # Test mocks
│   └── dataverse.mock.ts
├── app.e2e-spec.ts       # App E2E tests
├── contacts.e2e-spec.ts  # Contacts E2E tests
├── setup-e2e.ts          # E2E setup
├── setup-integration.ts  # Integration setup
├── setup.ts              # General setup
├── test-helper.ts        # Test utilities
└── jest-*.json           # Jest configurations
```

### Running Tests
```bash
# Unit tests
pnpm test

# E2E tests
pnpm test:e2e

# Integration tests
pnpm test:integration

# Test coverage
pnpm test:cov

# Watch mode
pnpm test:watch
```

### Test Configuration
- `jest.config.js` - Main Jest configuration
- `test/jest-e2e.json` - E2E test configuration
- `test/jest-integration.json` - Integration test configuration

## API Documentation

### Swagger UI
Once running, access interactive API documentation:
- **URL:** `http://localhost:4001/docs`
- **Features:**
  - Interactive API explorer
  - Request/response schemas
  - Try-it-out functionality
  - Authentication testing

### Swagger Configuration
- Auto-generated from decorators
- Organized by tags (modules)
- Includes authentication requirements
- Request/response examples

## Deployment

### Azure Container Apps

**Deployment Scripts:**
- `deploy/deploy-azure-dev.sh` - Deploy to development
- `deploy/deploy-azure-qa.sh` - Deploy to QA
- `deploy/deploy-azure-test.sh` - Deploy to test
- `deploy/deploy-azure-uat.sh` - Deploy to UAT

**Deployment Process:**
```bash
# Navigate to flux directory
cd api/flux

# Deploy to development
./deploy/deploy-azure-dev.sh
```

**What the script does:**
1. Builds Docker image for linux/amd64
2. Pushes to Azure Container Registry
3. Verifies PORT environment variable (should NOT be set)
4. Updates Container App with latest image
5. Verifies deployment health

**Important Notes:**
- App listens on port 3000 (default)
- DO NOT set PORT environment variable in Azure
- Setting PORT causes health check failures

### Docker

**Dockerfile Features:**
- Multi-stage build
- Optimized layer caching
- Production-ready image
- Health check included

**Build Image:**
```bash
docker build -t flux-api .
```

**Run Container:**
```bash
docker run -p 4001:3000 flux-api
```

## Documentation

### Available Documentation
- `docs/architecture-diagram.md` - System architecture
- `docs/BREAKING_CHANGES.md` - Breaking changes log
- `docs/DATAVERSE_FLOWS.md` - Dataverse integration flows
- `docs/DISABLE_AUTH_FIX.md` - Auth disable configuration
- `docs/DTO_MIGRATION_ANALYSIS.md` - DTO migration guide
- `docs/ENVIRONMENT_CONFIG.md` - Environment configuration
- `docs/FLOW_ENDPOINTS.md` - Flow endpoint documentation
- `docs/LINTING_SETUP.md` - Linting configuration
- `docs/MODULE_PATTERN_ANALYSIS.md` - Module patterns
- `docs/MODULE_REFACTORING.md` - Refactoring guide
- `docs/SESSION_2025-12-14.md` - Development session notes
- `docs/SWAGGER_TAGS.md` - Swagger tag organization
- `docs/TESTING.md` - Testing guide
- `docs/TEST_ENDPOINTS.md` - Test endpoint documentation
- `docs/use-cases/` - Use case documentation

## Scripts

### Available Scripts
- `scripts/migrate.sh` - Database migration script
- `scripts/post-migration-processor.ts` - Post-migration processing
- `scripts/update-build-info.js` - Build info updater

## Code Quality

### Linting
```bash
# Run linter
pnpm lint

# Fix linting issues
pnpm lint:fix

# Format code
pnpm format

# Format and lint
pnpm format-lint
```

### Configuration Files
- `.eslintrc.js` - ESLint configuration
- `.prettierrc` - Prettier configuration
- `.prettierignore` - Prettier ignore patterns

## Health Monitoring

### Health Endpoints

**Overall Health:**
```bash
GET /api/health
```

**Database Health:**
```bash
GET /api/health/database
```

**Memory Health:**
```bash
GET /api/health/memory
```

### Health Check Response
```json
{
  "status": "ok",
  "info": {
    "database": {
      "status": "up"
    },
    "memory": {
      "status": "up",
      "heap": "50MB / 100MB"
    }
  },
  "error": {},
  "details": {
    "database": {
      "status": "up"
    },
    "memory": {
      "status": "up"
    }
  }
}
```

## Troubleshooting

### Common Issues

**Database Connection Failed**
```bash
# Check environment variables
cat .env | grep DATABASE

# Verify Supabase connection
psql -h $DATABASE_HOST -U $DATABASE_USERNAME -d $DATABASE_DB_NAME

# Check schema exists
SELECT schema_name FROM information_schema.schemata WHERE schema_name = 'external_dataverse';
```

**Port Already in Use**
```bash
# Find process using port
lsof -ti:4001

# Kill process
lsof -ti:4001 | xargs kill -9

# Or change port in .env
PORT=4002
```

**Migration Errors**
```bash
# Check migration status
pnpm migration:show

# Revert last migration
pnpm migration:revert

# Re-run migrations
pnpm migration:run
```

**Build Errors**
```bash
# Clean build
rm -rf dist

# Reinstall dependencies
rm -rf node_modules
pnpm install

# Rebuild
pnpm build
```

## Best Practices

### Module Development
1. Follow NestJS module pattern
2. Use dependency injection
3. Implement repository pattern
4. Create DTOs for all endpoints
5. Add Swagger decorators
6. Write unit tests
7. Write integration tests

### API Design
1. Use RESTful conventions
2. Consistent error responses
3. Proper HTTP status codes
4. Request validation
5. Response transformation
6. Pagination support
7. Filtering and sorting

### Database
1. Use migrations for schema changes
2. Schema-qualified table names
3. Proper indexing
4. Connection pooling
5. Query optimization
6. Transaction management

### Security
1. Input validation
2. SQL injection prevention
3. Authentication required
4. Authorization checks
5. Rate limiting
6. CORS configuration

## Related Documentation
- Parent: `api/API-OVERVIEW.md`
- Foundry API: `api/foundry/FOUNDRY-API.md`
- Development: `docs/development/API_BEST_PRACTICES.md`
- Environment: `docs/development/ENVIRONMENT_STANDARDS.md`
