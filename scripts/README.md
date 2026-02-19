# Generation Scripts

This directory contains CLI tools and templates for scaffolding new applications, APIs, and deploying packages in the Pravia CRM Platform monorepo.

## Directory Structure

```
scripts/
├── api/            # API generator (NestJS + Fastify)
├── app/            # Frontend app generator (Vite + React)
└── packages/       # Package deployment scripts
```

---

## 1. API Generator

**Purpose:** Scaffold new NestJS + Fastify backend APIs from a standardized template.

**Location:** `scripts/api/`

### Usage

```bash
# From monorepo root
node scripts/api/generate-api.js
```

### Interactive Prompts

| Prompt | Description | Default | Example |
|--------|-------------|---------|---------|
| API name | Lowercase name | `contacts` | `providers` |
| Display name | Human-readable name | Auto-generated | `Providers` |
| Description | Package description | Auto-generated | `Providers Dataverse API` |
| Port number | Dev server port | `4007` | `4008` |
| Package scope | NPM scope | `@asyml8` | `@asyml8` |

### What Gets Generated

Creates a new API in `/api/{api-name}` with:

**Directory Structure:**
```
api/{api-name}/
├── deploy/              # Deployment scripts
├── public/              # Static assets
├── scripts/             # Build utilities
├── src/
│   ├── common/         # Shared utilities
│   ├── config/         # Configuration
│   ├── database/       # Entities and migrations
│   ├── health/         # Health checks
│   ├── modules/        # Feature modules
│   ├── app.module.ts   # Root module
│   └── main.ts         # Entry point
├── test/                # E2E tests
├── .env.example         # Environment template
├── Dockerfile           # Container config
├── package.json         # Package config
└── README.md            # Documentation
```

**Template Tokens:**
- `{{API_NAME}}` → API name (e.g., `providers`)
- `{{API_DISPLAY_NAME}}` → Display name (e.g., `Providers`)
- `{{API_DESCRIPTION}}` → Package description
- `{{PORT}}` → Dev server port
- `{{PACKAGE_NAME}}` → Full package name
- `{{SWAGGER_TITLE}}` → Swagger title

### Template Features

**Technology Stack:**
- NestJS + Fastify - High-performance framework
- TypeORM + PostgreSQL - Database layer (optional)
- Swagger/OpenAPI - Auto-generated API docs
- Health Checks - System monitoring
- Docker - Container configuration
- Azure Deployment - Container Apps scripts

**Key Features:**
- Database configuration (can be disabled)
- Health monitoring endpoints
- Swagger UI at `/docs`
- Azure Container Apps deployment
- Shared `@asyml8/api-core` integration

### Next Steps After Generation

```bash
cd api/{api-name}
pnpm install
cp .env.example .env.local
# Configure .env.local
pnpm dev
```

**Documentation:** `scripts/api/README.md`

---

## 2. App Generator

**Purpose:** Scaffold new Vite + React frontend applications from the `mule-vite` template.

**Location:** `scripts/app/`

### Usage

```bash
# From monorepo root
node scripts/app/generate-app.js
```

### Interactive Prompts

| Prompt | Description | Default | Example |
|--------|-------------|---------|---------|
| App name | Lowercase, kebab-case | `my-app` | `provider-portal` |
| Display name | Human-readable name | Auto-generated | `Provider Portal` |
| Description | Package description | Auto-generated | `Provider Portal application` |
| Port number | Dev server port | `8081` | `8082` |
| Package scope | NPM scope | `@asyml8` | `@asyml8` |
| Author | Package author | `Tony Henderson` | `Tony Henderson` |

### What Gets Generated

Creates a new app in `/apps/{app-name}` with:

**Directory Structure:**
```
apps/{app-name}/
├── public/              # Static assets
├── scripts/             # Build utilities
├── src/
│   ├── api/            # API clients
│   ├── components/     # React components
│   ├── constants/      # App constants
│   ├── contexts/       # React contexts
│   ├── guards/         # Route guards
│   ├── hooks/          # Custom hooks
│   ├── layouts/        # Page layouts
│   ├── lib/            # Third-party configs
│   ├── locales/        # i18n translations
│   ├── pages/          # Page components
│   ├── routes/         # Route definitions
│   ├── sections/       # Feature sections
│   ├── services/       # Business logic
│   ├── store/          # State management
│   ├── types/          # TypeScript types
│   └── utils/          # Utilities
├── .env                # Base environment
├── .env.localhost      # Local overrides
├── .env.development    # Dev environment
├── index.html          # HTML entry
├── package.json        # Package config
├── vite.config.ts      # Vite config
└── README.md           # Documentation
```

**Template Tokens:**
- `{{APP_NAME}}` → Package name (e.g., `provider-portal`)
- `{{APP_DISPLAY_NAME}}` → Display name (e.g., `Provider Portal`)
- `{{APP_TITLE}}` → HTML title
- `{{APP_DESCRIPTION}}` → Package description
- `{{AUTHOR}}` → Author name
- `{{VERSION}}` → Initial version (`1.0.0`)
- `{{BUILD_DATE}}` → Generation timestamp
- `{{PORT}}` → Dev server port

### Template Features

**Technology Stack:**
- React 18+ with TypeScript
- Vite (build tool)
- Material-UI 5+ (UI components)
- Zustand (client state)
- TanStack Query (server state)
- React Router 6+ (routing)
- React Hook Form + Zod (forms)
- i18next (internationalization)
- Supabase (authentication)

**Includes:**
- Complete authentication flow
- Dashboard layout
- State management setup
- API integration layer
- i18n support (EN/ES)
- Theme system
- Route guards

### Next Steps After Generation

```bash
cd apps/{app-name}
pnpm install
pnpm dev
```

**Documentation:** `scripts/app/README.md`

---

## 3. Package Deployment Scripts

**Purpose:** Deploy monorepo packages to private git repositories for distribution.

**Location:** `scripts/packages/`

### Prerequisites

**SSH Setup (Required):**

1. Generate SSH key:
```bash
ssh-keygen -t ed25519 -C "your.email@example.com" -f ~/.ssh/id_ed25519 -N ""
```

2. Add to SSH agent:
```bash
ssh-add ~/.ssh/id_ed25519
```

3. Add public key to GitHub/GitLab/Bitbucket:
```bash
cat ~/.ssh/id_ed25519.pub
# Copy and add to: https://github.com/settings/keys
```

4. Test connection:
```bash
ssh -T git@github.com
```

### Configuration

**deploy-config.env:**
Maps package paths to git repository URLs.

```bash
# Format: <package-path>=<git-repo-url>
packages/api-types=git@github.com:yourorg/api-types.git
packages/ui=git@github.com:yourorg/ui-components.git
packages/api-core=git@github.com:yourorg/api-core.git
```

### Usage

**Deploy a package:**
```bash
# From monorepo root
pnpm deploy:api-types

# Or directly
bash scripts/packages/deploy.sh packages/api-types

# Or with custom repo
bash scripts/packages/deploy-to-git.sh packages/api-types git@github.com:org/repo.git
```

### Scripts

**deploy.sh:**
Wrapper script that reads configuration and deploys packages.

**deploy-to-git.sh:**
Core deployment script with full logging and error handling.

**What it does:**
1. Validates package exists
2. Reads package name and version from `package.json`
3. Runs `pnpm build`
4. Copies deployment files to temp directory:
   - `dist/` (build output)
   - `package.json`
   - `README.md`
   - `LICENSE`
   - `.npmignore`
5. Initializes git repo (if needed)
6. Commits with message: `Release vX.Y.Z - timestamp`
7. Force pushes to remote `main` branch
8. Creates and pushes version tag `vX.Y.Z`
9. Cleans up temp directory
10. Saves log file: `deploy_YYYYMMDD_HHMMSS.log`

**Environment Variables:**
- `GIT_USER_NAME` - Git commit author (default: "CI Deploy")
- `GIT_USER_EMAIL` - Git commit email (default: "deploy@pravia.local")

### Logging

Each deployment creates a timestamped log file with color-coded output:

- **[INFO]** - General information (blue)
- **[SUCCESS]** - Successful operations (green)
- **[WARN]** - Warnings (yellow)
- **[ERROR]** - Errors (red)

**Log file:** `deploy_YYYYMMDD_HHMMSS.log`

### CI/CD Integration

**GitHub Actions:**
```yaml
name: Deploy Package
on:
  push:
    tags: ['v*']

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: pnpm/action-setup@v2
      - name: Setup SSH
        uses: webfactory/ssh-agent@v0.8.0
        with:
          ssh-private-key: ${{ secrets.DEPLOY_SSH_KEY }}
      - run: pnpm install
      - run: pnpm deploy:api-types
```

**GitLab CI:**
```yaml
deploy:
  stage: deploy
  before_script:
    - eval $(ssh-agent -s)
    - echo "$DEPLOY_SSH_KEY" | tr -d '\r' | ssh-add -
  script:
    - pnpm install
    - pnpm deploy:api-types
  only:
    - tags
```

### Package Requirements

**Required:**
- `package.json` with `name` and `version`
- `build` script in `package.json`

**Recommended:**
- `README.md` - Package documentation
- `LICENSE` - License file
- `.npmignore` - Files to exclude

**Example package.json:**
```json
{
  "name": "@pravia/api-types",
  "version": "1.2.3",
  "main": "./dist/index.js",
  "types": "./dist/index.d.ts",
  "scripts": {
    "build": "tsc",
    "deploy": "bash ../../scripts/packages/deploy.sh packages/api-types"
  }
}
```

**Documentation:** `scripts/packages/README.md`

---

## Base Templates

### API Base Template

**Location:** `scripts/api/base-api/`

Complete NestJS + Fastify API template with:
- Health monitoring
- Swagger documentation
- TypeORM integration
- Docker configuration
- Azure deployment scripts
- ESLint + Prettier
- Jest testing

### App Base Template

**Location:** `scripts/app/base-app/`

Complete Vite + React application template derived from `mule-vite` with:
- Authentication flow
- Dashboard layout
- State management (Zustand + TanStack Query)
- API integration
- i18n support
- Theme system
- Route guards
- Form handling

---

## Customization

### Modifying Templates

**For API template:**
1. Edit files in `scripts/api/base-api/`
2. Use `{{TOKEN}}` syntax for parameterized values
3. Update `replacements` object in `generate-api.js` for new tokens

**For App template:**
1. Edit files in `scripts/app/base-app/`
2. Use `{{TOKEN}}` syntax for parameterized values
3. Update `replacements` object in `generate-app.js` for new tokens

### Adding New Tokens

1. Add token to template files: `{{NEW_TOKEN}}`
2. Add replacement in generator script:
```javascript
const replacements = {
  '{{NEW_TOKEN}}': 'replacement-value',
  // ... other tokens
};
```

---

## Troubleshooting

### API Generator Issues

**Issue:** Generated API won't start
- Check `.env.local` configuration
- Set `DATABASE_ENABLED=false` if not using PostgreSQL
- Verify port is not in use

### App Generator Issues

**Issue:** Generated app won't build
- Run `pnpm install` in app directory
- Check environment variables in `.env` files
- Verify `@asyml8/ui` and `@asyml8/api-types` are built

### Deployment Issues

**SSH authentication fails:**
```bash
# Check SSH key is loaded
ssh-add -l

# Add key if needed
ssh-add ~/.ssh/id_ed25519

# Test connection
ssh -T git@github.com
```

**Build fails:**
- Verify package has `build` script
- Check dependencies are installed: `pnpm install`

**Push fails:**
- Ensure SSH key has write access
- Verify repo URL in `deploy-config.env`

---

## Best Practices

### API Generation

- Use descriptive, lowercase names
- Choose unique port numbers (avoid conflicts)
- Configure database settings before first run
- Review generated README for API-specific setup

### App Generation

- Use kebab-case for app names
- Choose unique port numbers
- Configure environment variables before running
- Review generated README for app-specific setup

### Package Deployment

- Always test build locally before deploying
- Bump version in `package.json` before each deploy
- Use semantic versioning (major.minor.patch)
- Review deployment logs for errors
- Test deployed package in consuming applications

---

## Related Documentation

- [API Development Guide](../docs/development/API_BEST_PRACTICES.md)
- [Environment Standards](../docs/development/ENVIRONMENT_STANDARDS.md)
- [Monorepo Best Practices](../docs/development/standards.md)
- [Deployment Guide](../docs/infrastructure/README.md)
