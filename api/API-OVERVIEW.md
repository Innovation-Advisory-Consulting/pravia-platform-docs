# API - Backend Microservices

## Overview
The API layer consists of two main microservices built with NestJS and Fastify, each serving distinct purposes in the Pravia ecosystem.

## Directory Structure

```
api/
├── flux/           # Dataverse Data API
└── foundry/        # Authentication & Authorization API
```

## Microservices Architecture

### Why Two Separate APIs?

**Separation of Concerns:**
- **Foundry** handles authentication/authorization (who you are, what you can do)
- **Flux** handles business data and Dataverse integration (business operations)

**Benefits:**
- Independent scaling (scale auth separately from data)
- Enhanced security (credentials isolated from business data)
- Independent deployment (update one without affecting the other)
- Team separation (security team vs business team)
- Reusability (Foundry can auth multiple applications)
- Compliance (separate audit trails)

**Communication Flow:**
```
Frontend → Foundry (login) → JWT Token
Frontend → Flux (with JWT) → Validates token → Returns data
```

## Shared Technologies

Both APIs share common technology stack:

| Technology | Version | Purpose |
|------------|---------|---------|
| NestJS | Latest | Framework with dependency injection |
| Fastify | Latest | High-performance HTTP server |
| TypeORM | Latest | Database ORM |
| PostgreSQL | 14+ | Database (Supabase) |
| Swagger/OpenAPI | Latest | API documentation |
| Jest | Latest | Testing framework |
| ESLint + Prettier | Latest | Code quality |
| pnpm | 9+ | Package manager |

## Environment Configuration

Both APIs support multiple environments:

| Environment | .env File | Purpose | Supabase Project |
|-------------|-----------|---------|------------------|
| Local | `.env.local` | Local development | localhost:54321 |
| Development | `.env.development` | Active development | ahanrwalkdrbbhlhjxzr |
| Test | `.env.test` | Testing | gurgyegmjqbisdhbvoww |
| QA | `.env.qa` | Quality assurance | Per environment |
| UAT | `.env.uat` | User acceptance | laorysvmqjaxatyzsgkj |
| Production | `.env.prod` | Production | TBD |

## Common Features

### Health Monitoring
Both APIs include health check endpoints:
- System health status
- Database connectivity
- Performance metrics
- Uptime information

### API Documentation
Auto-generated Swagger/OpenAPI documentation:
- Interactive API explorer
- Request/response schemas
- Authentication requirements
- Example requests

### Testing
Comprehensive test coverage:
- Unit tests (Jest)
- Integration tests
- E2E tests
- Test helpers and mocks

### Deployment
Azure deployment support:
- Docker containerization
- Azure Container Apps
- Environment-specific configs
- Automated deployment scripts

### Code Quality
Enforced code standards:
- ESLint for linting
- Prettier for formatting
- TypeScript strict mode
- Pre-commit hooks (Husky)

## Development Workflow

### Installation
```bash
# Install dependencies
pnpm install

# Copy environment file
cp .env.example .env

# Configure environment variables
```

### Development
```bash
# Start development server
pnpm dev

# Run tests
pnpm test

# Run E2E tests
pnpm test:e2e

# Lint and format
pnpm lint:fix
pnpm format-lint
```

### Build & Deploy
```bash
# Build for production
pnpm build

# Start production server
pnpm start:prod

# Deploy to Azure
./deploy/deploy-azure-<env>.sh
```

## Database Schemas

### Foundry Schema
**Name:** `external_authentication`

**Purpose:** User authentication and authorization data

**Tables:**
- User profiles
- Roles and permissions
- Auth audit logs
- User contacts

### Flux Schema
**Name:** `external_dataverse`

**Purpose:** Business data and Dataverse integration

**Tables:**
- Accounts
- Contacts
- Submissions
- Attachments
- Document types
- Organization members

## API Communication

### Authentication Flow
```
1. User logs in → Foundry
2. Foundry validates credentials
3. Foundry returns JWT token
4. Frontend stores token
5. Frontend makes request to Flux with JWT
6. Flux validates JWT with Foundry
7. Flux returns data if authorized
```

### Token Validation
- JWT tokens issued by Foundry
- Tokens include user ID, roles, permissions
- Flux validates token signature
- Flux checks token expiration
- Flux enforces role-based access

## Monitoring & Observability

### Logging
- Structured logging
- Request/response logging
- Error tracking
- Performance metrics

### Health Checks
- `/health` endpoint
- Database connectivity
- External service status
- System resources

### Metrics
- Request count
- Response times
- Error rates
- Database query performance

## Security

### Authentication
- JWT-based authentication
- Refresh token support
- Token expiration
- Secure token storage

### Authorization
- Role-based access control (RBAC)
- Permission-based access
- Resource-level permissions
- Audit logging

### Data Protection
- Environment variable encryption
- Secure database connections
- HTTPS enforcement
- Input validation

## Best Practices

### Code Organization
- Module-based architecture
- Separation of concerns
- Dependency injection
- Repository pattern

### Error Handling
- Centralized error handling
- Consistent error responses
- Error logging
- User-friendly messages

### Performance
- Database query optimization
- Caching strategies
- Connection pooling
- Lazy loading

### Testing
- Test-driven development
- High test coverage
- Integration testing
- E2E testing

## Troubleshooting

### Common Issues

**Database Connection Failed**
```bash
# Verify environment variables
cat .env

# Test database connection
pnpm test:db

# Check Supabase status
```

**Port Already in Use**
```bash
# Kill process on port
lsof -ti:3000 | xargs kill -9

# Or change port in .env
PORT=3001
```

**Build Errors**
```bash
# Clean build artifacts
rm -rf dist

# Reinstall dependencies
rm -rf node_modules
pnpm install

# Rebuild
pnpm build
```

## Related Documentation

### Foundry API
- `api/foundry/FOUNDRY-API.md` - Detailed Foundry documentation
- `api/foundry/docs/` - Architecture, endpoints, testing

### Flux API
- `api/flux/FLUX-API.md` - Detailed Flux documentation
- `api/flux/docs/` - Architecture, endpoints, testing

### Deployment
- `api/foundry/deploy/AZURE_DEPLOYMENT.md` - Foundry deployment
- `api/flux/deploy/AZURE_DEPLOYMENT.md` - Flux deployment

### Development
- `docs/development/API_BEST_PRACTICES.md` - API development guidelines
- `docs/development/ENVIRONMENT_STANDARDS.md` - Environment configuration
