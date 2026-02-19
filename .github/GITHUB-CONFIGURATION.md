# .github - GitHub Configuration

## Overview
This directory contains GitHub-specific configuration files for repository automation and CI/CD workflows.

## Structure

```
.github/
└── workflows/          # GitHub Actions workflows
    └── deploy-mule-vite.yml
```

## Contents

### workflows/
Contains GitHub Actions workflow definitions for automated CI/CD pipelines.

#### `deploy-mule-vite.yml`
**Purpose:** Automated deployment pipeline for the mule-vite frontend application to Azure Static Web Apps.

**Triggers:**
- Push to `main` branch (when changes in `apps/mule-vite/**` or `packages/ui/**`)
- Manual workflow dispatch with environment selection (dev, qa, uat, test)

**Pipeline Steps:**
1. Checkout repository
2. Setup pnpm (v9) and Node.js (v20)
3. Install dependencies with frozen lockfile
4. Clean previous build artifacts
5. Build packages in order:
   - `packages/api-types`
   - `packages/ui`
   - `apps/mule-vite`
6. Deploy to Azure Static Web Apps

**Environment Variables:**
- `VITE_APP_ENV` - Application environment
- `VITE_SUPABASE_URL` - Supabase instance URL
- `VITE_SUPABASE_ANON_KEY` - Supabase anonymous key
- `VITE_AUTH_API_URL` - Authentication API endpoint
- `VITE_DATA_API_URL` - Data API endpoint
- `VITE_INVITE_REDIRECT_URL` - User invitation redirect URL
- `VITE_ENABLE_TOOLS` - Enable development tools
- `VITE_LOG_LEVEL` - Application logging level

**Secrets Required:**
- `AZURE_STATIC_WEB_APPS_API_TOKEN_MULE_VITE` - Azure deployment token
- `GITHUB_TOKEN` - Automatically provided by GitHub

**Deployment Target:** Azure Static Web Apps

## Usage

### Manual Deployment
1. Go to Actions tab in GitHub
2. Select "Deploy Mule Vite to Azure SWA"
3. Click "Run workflow"
4. Select target environment
5. Click "Run workflow" button

### Automatic Deployment
Automatically triggers on push to `main` when files in `apps/mule-vite/` or `packages/ui/` are modified.

## Notes
- Uses pnpm workspace for monorepo dependency management
- Build order is critical: api-types → ui → mule-vite
- Clean build ensures no stale artifacts
- Supports multiple deployment environments
