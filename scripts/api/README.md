# API Generator

CLI tool to scaffold new NestJS + Fastify APIs from the base template.

## Usage

```bash
node scripts/api/generate-api.js
```

## Interactive Prompts

The generator will ask for:

| Prompt | Description | Default | Example |
|--------|-------------|---------|---------|
| **API name** | Lowercase name for the API | `contacts` | `providers` |
| **Display name** | Human-readable API name | Auto-generated from API name | `Providers` |
| **Description** | Package.json description | Auto-generated | `Providers Dataverse API for seamless integration` |
| **Port number** | Dev server port | `4007` | `4008` |
| **Package scope** | NPM package scope | `@asyml8` | `@asyml8` |

## What Gets Generated

The generator creates a new API in `/api/{api-name}` with:

### Directory Structure
```
api/{api-name}/
├── deploy/              # Deployment scripts and configs
├── public/              # Static assets
├── scripts/             # Build and utility scripts
├── src/                 # Application source code
│   ├── common/         # Shared utilities and decorators
│   ├── config/         # Configuration modules
│   ├── database/       # Database entities and migrations
│   ├── health/         # Health check endpoints
│   ├── modules/        # Feature modules
│   ├── app.module.ts   # Root application module
│   └── main.ts         # Application entry point
├── test/                # E2E tests
├── .env.example         # Environment template
├── Dockerfile           # Container configuration
├── package.json         # Package configuration
├── tsconfig.json        # TypeScript configuration
└── README.md            # API documentation
```

### Template Tokens

The following tokens are replaced throughout all files:

- `{{API_NAME}}` → API name (e.g., `providers`)
- `{{API_DISPLAY_NAME}}` → Display name (e.g., `Providers`)
- `{{API_DISPLAY_NAME_UPPER}}` → Uppercase display name (e.g., `PROVIDERS`)
- `{{API_DESCRIPTION}}` → Package description
- `{{PORT}}` → Dev server port
- `{{PACKAGE_NAME}}` → Full package name (e.g., `@asyml8/pravia-providers-api`)
- `{{APP_TITLE}}` → Application title (e.g., `Pravia Providers API`)
- `{{SERVER_NAME}}` → Server name (e.g., `Pravia Providers Server`)
- `{{SWAGGER_TITLE}}` → Swagger documentation title (e.g., `Providers API`)
- `{{SWAGGER_TAG}}` → Swagger tag (e.g., `providers`)

## Next Steps After Generation

```bash
# Navigate to the new API
cd api/{api-name}

# Install dependencies
pnpm install

# Copy environment template
cp .env.example .env.local

# Configure your .env.local file
# Set DATABASE_ENABLED=false if not using PostgreSQL

# Start development server
pnpm dev
```

## Template Source

The base template is located at `/scripts/api/base-api/` and includes:

- **NestJS + Fastify** - High-performance framework
- **TypeORM + PostgreSQL** - Database layer (optional)
- **Swagger/OpenAPI** - Auto-generated API documentation
- **Health Checks** - System monitoring endpoints
- **Docker** - Container configuration
- **Azure Deployment** - Container Apps deployment scripts

## Customization

To modify the base template:

1. Edit files in `/scripts/api/base-api/`
2. Use `{{TOKEN}}` syntax for values that should be parameterized
3. Update the `replacements` object in `generate-api.js` if adding new tokens

## Key Features

### Database Configuration
- Set `DATABASE_ENABLED=false` in `.env` to disable PostgreSQL
- Useful for Dataverse-only APIs

### Health Monitoring
- Overall health: `GET /api/health`
- Database health: `GET /api/health/database`
- Memory health: `GET /api/health/memory`

### API Documentation
- Swagger UI available at: `http://localhost:{PORT}/docs`
- OpenAPI spec at: `http://localhost:{PORT}/docs-json`

### Deployment
- Azure Container Apps deployment script included
- Builds for `linux/amd64` platform
- Automatic health check verification

## Excluded from Template

- `node_modules/` - Dependencies
- `dist/`, `build/` - Build outputs
- `package-lock.json` - Lock file (pnpm workspace uses pnpm-lock.yaml)
