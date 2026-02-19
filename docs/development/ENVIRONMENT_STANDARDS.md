# Environment Configuration Standards

**Standard for all APIs in the Pravia platform**

## Environment Files Structure

### Required Files

```
api/
├── .env.local          # Local development (gitignored)
├── .env.development            # Azure/Cloud development (committed)
└── .env.qa             # QA/Testing (committed)
```

### File Purposes

| File | Purpose | NODE_ENV | PORT | TEST_ENDPOINTS | Git |
|------|---------|----------|------|----------------|-----|
| `.env.local` | Local development | `development` | Set (e.g., 4001) | `true` | Ignored |
| `.env.development` | Cloud development | `production` | Container-level | `false` | Committed |
| `.env.qa` | QA testing | `production` | Container-level | `true` | Committed |

## File Structure Template

### `.env.local`
```bash
# =============================================================================
# ENVIRONMENT: Local Development
# =============================================================================

# -----------------------------------------------------------------------------
# 1. CORE APPLICATION SETTINGS (Required)
# -----------------------------------------------------------------------------
# NODE_ENV=development enables hot-reload and detailed error messages
# Use 'development' for local development only
# Use 'production' for all deployed environments (dev, qa, prod)
NODE_ENV=development

# PORT is set at container level in Azure/AWS deployments
# Only needed for local development
PORT=4001

API_PREFIX=api

APP_TITLE=Your API Name
APP_DESCRIPTION=Your API description
SERVER_NAME=Your Server Name

# -----------------------------------------------------------------------------
# 2. PRIMARY DATA SOURCE (Required)
# -----------------------------------------------------------------------------
# Add your primary data source configuration here
# Example: Dataverse, Database, etc.

# -----------------------------------------------------------------------------
# 3. AUTHENTICATION & AUTHORIZATION
# -----------------------------------------------------------------------------
DISABLE_AUTH=true

# Supabase Authentication (if using)
SUPABASE_URL=your-supabase-url
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_KEY=your-service-key

# -----------------------------------------------------------------------------
# 4. DATABASE (If applicable)
# -----------------------------------------------------------------------------
DATABASE_ENABLED=true
DATABASE_CONNECTION=postgres
DATABASE_HOST=localhost
DATABASE_PORT=5432
DATABASE_USERNAME=postgres
DATABASE_PASSWORD=postgres
DATABASE_DB_NAME=your_db
DATABASE_SCHEMA_NAME=your_schema

# Database Connection Pool & ORM Settings (For future direct DB access)
DATABASE_POOL_SIZE=10
TYPE_ORM_LOGGER=advanced-console
TYPE_ORM_CACHE=false
TYPE_ORM_CACHE_DURATION=30000

# -----------------------------------------------------------------------------
# 5. TESTING & DEVELOPMENT
# -----------------------------------------------------------------------------
# Enable test-only endpoints (DELETE operations for cleanup)
# ⚠️ NEVER enable in production!
ENABLE_TEST_ENDPOINTS=true

# Logging level (debug, info, warn, error)
LOG_LEVEL=info

# -----------------------------------------------------------------------------
# 6. SWAGGER API DOCUMENTATION
# -----------------------------------------------------------------------------
SWAGGER_ICON_FILENAME=logo.svg
SWAGGER_PERSIST_AUTH=true
SWAGGER_GRADIENT_ENABLED=true
SWAGGER_GRADIENT_COLORS="#E67E22,#5DADE2,#2E86AB"
SWAGGER_GRADIENT_HEIGHT=60px
SWAGGER_WAVE_HEIGHT=25px
```

### `.env.development`
```bash
# =============================================================================
# ENVIRONMENT: Development (Azure/Cloud)
# =============================================================================

# -----------------------------------------------------------------------------
# 1. CORE APPLICATION SETTINGS (Required)
# -----------------------------------------------------------------------------
# NODE_ENV=production enables optimizations (minification, caching, error handling)
# Use 'production' for all deployed environments (dev, qa, prod)
# Use 'development' only for local development with hot-reload
NODE_ENV=production

# PORT is set at container level in Azure/AWS deployments
# Uncomment only if needed for local testing of this config
# PORT=4001

API_PREFIX=api

# ... rest of configuration (same structure as .env.local)
# Key differences:
# - NODE_ENV=production
# - PORT commented out
# - ENABLE_TEST_ENDPOINTS=false
# - Production credentials
```

### `.env.qa`
```bash
# =============================================================================
# ENVIRONMENT: QA (Quality Assurance / Testing)
# =============================================================================

# -----------------------------------------------------------------------------
# 1. CORE APPLICATION SETTINGS (Required)
# -----------------------------------------------------------------------------
# NODE_ENV=production enables optimizations (minification, caching, error handling)
# Use 'production' for all deployed environments (dev, qa, prod)
# Use 'development' only for local development with hot-reload
NODE_ENV=production

# PORT is set at container level in Azure/AWS deployments
# Uncomment only if needed for local testing of this config
# PORT=4001

API_PREFIX=api

# ... rest of configuration (same structure as .env.local)
# Key differences:
# - NODE_ENV=production
# - PORT commented out
# - ENABLE_TEST_ENDPOINTS=true (for test cleanup)
# - QA-specific credentials
```

## NPM Scripts Standard

### Required Scripts in `package.json`

```json
{
  "scripts": {
    "dev": "nest start --watch",
    "dev:development": "node -r dotenv/config node_modules/.bin/nest start --watch dotenv_config_path=.env.development",
    "dev:qa": "node -r dotenv/config node_modules/.bin/nest start --watch dotenv_config_path=.env.qa",
    
    "build": "nest build",
    "build:development": "nest build",
    "build:qa": "nest build",
    
    "start": "node dist/src/main",
    "start:development": "node -r dotenv/config dist/src/main dotenv_config_path=.env.development",
    "start:qa": "node -r dotenv/config dist/src/main dotenv_config_path=.env.qa"
  }
}
```

### Script Naming Convention

**Pattern:** `action:environment`

- **Action:** `dev`, `build`, `start`, `test`
- **Environment:** `development`, `qa`, `production`
- **Default:** No suffix = local (uses `.env.local`)

### Examples

```bash
# Development (watch mode)
npm run dev                  # .env.local (default)
npm run dev:development      # .env.development
npm run dev:qa               # .env.qa

# Build
npm run build                # Default
npm run build:development    # For dev deployment
npm run build:qa             # For QA deployment

# Start (production mode)
npm run start                # .env.local
npm run start:development    # .env.development
npm run start:qa             # .env.qa
```

## .gitignore Configuration

Ensure root `.gitignore` includes:

```gitignore
# Environment files
.env
.env.*
*.env
.env.local
.env.developmentelopment.local
.env.test.local
.env.production.local

# But allow committed env files
!.env.development
!.env.qa
!.env.prod
```

## Required Dependencies

Add to `package.json`:

```json
{
  "dependencies": {
    "dotenv": "^16.4.0"
  }
}
```

## Environment Variable Categories

### 1. Core Application (Always Required)
- `NODE_ENV` - Runtime mode
- `PORT` - Server port (local only)
- `API_PREFIX` - API route prefix
- `APP_TITLE` - Application title
- `APP_DESCRIPTION` - Application description
- `SERVER_NAME` - Server name

### 2. Authentication (If using Supabase)
- `DISABLE_AUTH` - Toggle authentication
- `SUPABASE_URL` - Supabase project URL
- `SUPABASE_ANON_KEY` - Anonymous key
- `SUPABASE_SERVICE_KEY` - Service role key

### 3. Database (If applicable)
- `DATABASE_ENABLED` - Enable database
- `DATABASE_HOST` - Database host
- `DATABASE_PORT` - Database port
- `DATABASE_USERNAME` - Database username
- `DATABASE_PASSWORD` - Database password
- `DATABASE_DB_NAME` - Database name
- `DATABASE_SCHEMA_NAME` - Schema name
- `DATABASE_POOL_SIZE` - Connection pool size
- `TYPE_ORM_LOGGER` - TypeORM logger
- `TYPE_ORM_CACHE` - Enable cache
- `TYPE_ORM_CACHE_DURATION` - Cache duration

### 4. Testing & Development
- `ENABLE_TEST_ENDPOINTS` - Enable test-only endpoints
- `LOG_LEVEL` - Logging level

### 5. Swagger Documentation
- `SWAGGER_ICON_FILENAME` - Icon filename
- `SWAGGER_PERSIST_AUTH` - Persist authorization
- `SWAGGER_GRADIENT_ENABLED` - Enable gradient
- `SWAGGER_GRADIENT_COLORS` - Gradient colors
- `SWAGGER_GRADIENT_HEIGHT` - Gradient height
- `SWAGGER_WAVE_HEIGHT` - Wave height

## NODE_ENV Explained

### `development`
- **Purpose:** Local development
- **Features:** Hot-reload, detailed errors, source maps
- **Use:** `.env.local` only

### `production`
- **Purpose:** All deployed environments
- **Features:** Minification, optimized caching, production error handling
- **Use:** `.env.development`, `.env.qa`, `.env.prod`

## PORT Configuration

- **Local:** Set explicitly in `.env.local`
- **Cloud:** Managed by Azure App Service / AWS ECS
- **Why:** Cloud platforms bind ports automatically

## Security Best Practices

### ✅ DO
- Keep `.env.local` gitignored
- Commit `.env.development` and `.env.qa` with non-sensitive defaults
- Use Azure Key Vault / AWS Secrets Manager for production secrets
- Set `ENABLE_TEST_ENDPOINTS=false` in production
- Rotate credentials regularly
- Use different credentials per environment

### ❌ DON'T
- Commit `.env.local` to git
- Use production credentials in `.env.development` or `.env.qa`
- Enable test endpoints in production
- Share service keys publicly
- Hardcode secrets in code

## Pre-Commit Hook Configuration

All APIs must be integrated into the monorepo's pre-commit hook to ensure code quality.

### Setup

1. **Add format-lint script** to `package.json`:
```json
{
  "scripts": {
    "format": "prettier --write \"src/**/*.ts\" \"test/**/*.ts\"",
    "lint:fix": "eslint \"{src,apps,libs,test}/**/*.ts\" --fix",
    "format-lint": "pnpm format && pnpm lint:fix"
  }
}
```

2. **Update `.husky/pre-commit`** in monorepo root:
```bash
#!/bin/sh

# Check if your-api has changes
if git diff --cached --name-only | grep -q "^api/your-api/"; then
  echo "Running format-lint for your-api..."
  cd api/your-api && pnpm format-lint
  git add -u api/your-api/
  cd ../..
fi
```

### Key Points

- **Auto-fix on commit**: Prettier and ESLint auto-fix issues before commit
- **Auto-stage fixes**: Modified files are automatically re-staged
- **No infinite loops**: Pre-commit hooks only run once per commit
- **Idempotent**: Running lint:fix multiple times produces same result

### Testing

```bash
# Make a change and commit
echo "// test" >> src/main.ts
git add src/main.ts
git commit -m "test"

# Should see:
# Running format-lint for your-api...
# Files formatted and linted
# Changes auto-staged
# Commit succeeds
```

## Checklist for New APIs

- [ ] Create `.env.local`, `.env.development`, `.env.qa` files
- [ ] Create `.env.example` template file
- [ ] Add standard structure with all 6 sections
- [ ] Configure `NODE_ENV` correctly per environment
- [ ] Set `PORT` only in `.env.local`
- [ ] Add npm scripts with standard naming
- [ ] Install `dotenv-cli` dependency
- [ ] Update `.gitignore` to ignore `.env.local`
- [ ] Document environment-specific variables
- [ ] Test all npm scripts work correctly
- [ ] Verify environment loading in each mode
- [ ] Add `buildDate` property to package.json
- [ ] Create `scripts/update-build-info.js` for version bumping
- [ ] Add `build:ci` script for CI/CD pipelines
- [ ] Add `format-lint` script to package.json
- [ ] Update `.husky/pre-commit` hook to include new API
- [ ] Test pre-commit hook auto-fixes and auto-stages changes

## Build Versioning

All APIs should auto-increment version and update build date on each build.

### Setup

1. Add `buildDate` to package.json:
```json
{
  "name": "@asyml8/your-api",
  "version": "1.0.0",
  "buildDate": ""
}
```

2. Create `scripts/update-build-info.js`:
```javascript
const fs = require('fs');
const path = require('path');

const packagePath = path.join(__dirname, '../package.json');
const pkg = JSON.parse(fs.readFileSync(packagePath, 'utf8'));

const version = pkg.version || '1.0.0';
const [major, minor, patch] = version.split('.').map(Number);
const newVersion = `${major}.${minor}.${patch + 1}`;

pkg.version = newVersion;
pkg.buildDate = new Date().toISOString();

fs.writeFileSync(packagePath, JSON.stringify(pkg, null, 2) + '\n');

console.log(`✓ Build version updated to ${newVersion}`);
console.log(`✓ Build date updated to ${pkg.buildDate}`);
```

3. Update package.json scripts:
```json
{
  "scripts": {
    "prebuild": "node scripts/update-build-info.js && pnpm format-lint",
    "build": "nest build",
    "build:ci": "node scripts/update-build-info.js && nest build"
  }
}
```

### Usage

- **Local builds**: `npm run build` - Bumps version via prebuild hook
- **CI/CD builds**: `npm run build:ci` - Explicit version bump
- **Docker builds**: Uses plain `build` command (no version bump in container)

## .env.example Template

Each API must include a `.env.example` file committed to git as a template for developers.

### Purpose
- Provides a starting point for new developers
- Documents all required environment variables
- Shows the structure without exposing secrets
- Committed to git (unlike `.env.local`)

### Creating .env.example

Copy `.env.local` and replace all sensitive values with placeholders:

```bash
# =============================================================================
# API NAME - ENVIRONMENT EXAMPLE
# =============================================================================
# Copy this file to .env.local and fill in your actual values
# =============================================================================

# -----------------------------------------------------------------------------
# 1. CORE APPLICATION
# -----------------------------------------------------------------------------
NODE_ENV=development
PORT=4000
LOG_LEVEL=log,error,warn,debug,verbose
SERVER_URL=http://localhost:4000
LISTEN_ON=0.0.0.0
API_PREFIX=api

# -----------------------------------------------------------------------------
# 2. DATA SOURCE - Supabase
# -----------------------------------------------------------------------------
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
SUPABASE_SERVICE_KEY=your-service-key-here

# -----------------------------------------------------------------------------
# 3. AUTHENTICATION
# -----------------------------------------------------------------------------
DISABLE_AUTH=true
RATE_LIMIT_TTL=60
RATE_LIMIT_LIMIT=100

# -----------------------------------------------------------------------------
# 4. DATABASE - TypeORM Configuration
# -----------------------------------------------------------------------------
DATABASE_ENABLED=true
DATABASE_CONNECTION=postgres
DATABASE_HOST=localhost
DATABASE_PORT=5432
DATABASE_USERNAME=your-username
DATABASE_PASSWORD=your-password
DATABASE_DB_NAME=your-database
DATABASE_SCHEMA_NAME=public
DATABASE_POOL_SIZE=10
TYPE_ORM_LOGGER=advanced-console
TYPE_ORM_CACHE=false
TYPE_ORM_CACHE_DURATION=30000

# -----------------------------------------------------------------------------
# 5. TESTING
# -----------------------------------------------------------------------------
ENABLE_TEST_ENDPOINTS=true

# -----------------------------------------------------------------------------
# 6. SWAGGER / DOCUMENTATION
# -----------------------------------------------------------------------------
SWAGGER_ICON_FILENAME=logo.svg
SWAGGER_PERSIST_AUTH=true
```

## Verification Checklist

Use this checklist to verify an API follows the environment standards:

### File Structure
- [ ] `.env.local` exists and is gitignored
- [ ] `.env.development` exists and is committed
- [ ] `.env.qa` exists and is committed
- [ ] `.env.example` exists and is committed
- [ ] No `.env` file exists (should be deleted)
- [ ] `.gitignore` includes `.env.local`

### File Organization
- [ ] All env files use 6-section structure with comments
- [ ] Section 1: Core Application (NODE_ENV, PORT, LOG_LEVEL, etc.)
- [ ] Section 2: Data Source (Supabase, Dataverse, etc.)
- [ ] Section 3: Authentication
- [ ] Section 4: Database (TypeORM)
- [ ] Section 5: Testing (ENABLE_TEST_ENDPOINTS)
- [ ] Section 6: Swagger/Documentation
- [ ] Each file has header comment explaining purpose

### Environment-Specific Settings
- [ ] `.env.local` has `NODE_ENV=development`
- [ ] `.env.development` has `NODE_ENV=production`
- [ ] `.env.qa` has `NODE_ENV=production`
- [ ] Only `.env.local` has PORT set
- [ ] `.env.development` and `.env.qa` do NOT have PORT
- [ ] `.env.local` has `ENABLE_TEST_ENDPOINTS=true`
- [ ] `.env.development` has `ENABLE_TEST_ENDPOINTS=false`
- [ ] `.env.qa` has `ENABLE_TEST_ENDPOINTS=true`

### Package.json Scripts
- [ ] `dotenv-cli` is installed as devDependency
- [ ] `dev` script loads `.env.local`
- [ ] `dev:development` script loads `.env.development`
- [ ] `dev:qa` script loads `.env.qa`
- [ ] `start` script loads `.env.local`
- [ ] `start:development` script loads `.env.development`
- [ ] `start:qa` script loads `.env.qa`
- [ ] Scripts use format: `dotenv -e .env.X -- command`

### Build Versioning
- [ ] `buildDate` property exists in package.json
- [ ] `scripts/update-build-info.js` exists
- [ ] `prebuild` script runs update-build-info.js
- [ ] `build:ci` script exists for CI/CD

### Testing
- [ ] Run `npm run dev` - should load `.env.local`
- [ ] Run `npm run dev:development` - should load `.env.development`
- [ ] Run `npm run dev:qa` - should load `.env.qa`
- [ ] Verify correct environment variables are loaded in each mode
- [ ] Check logs show correct NODE_ENV value

## Troubleshooting

### Environment not loading
```bash
# Verify dotenv is installed
npm list dotenv

# Test environment loading
node -r dotenv/config -e "console.log(process.env.APP_TITLE)" dotenv_config_path=.env.local
```

### Wrong environment loaded
```bash
# Check which env file is being used
npm run start:development  # Should use .env.development
npm run start:qa           # Should use .env.qa
```

### Port conflicts
```bash
# Find process using port
lsof -ti:4001

# Kill process
lsof -ti:4001 | xargs kill
```

## Examples

See implementation in:
- `api/flux` - Reference implementation
- `api/foundry` - User management API

## Updates

This standard should be reviewed and updated as the platform evolves. All APIs must follow the latest version of this standard.

**Last Updated:** 2025-12-14  
**Version:** 1.0.0
