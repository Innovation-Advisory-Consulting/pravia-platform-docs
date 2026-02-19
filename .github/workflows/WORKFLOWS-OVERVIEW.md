# GitHub Actions Workflows

## Overview
This directory contains automated CI/CD workflow definitions that handle building, testing, and deploying applications in the Pravia Mule Platform.

## Available Workflows

### 1. Deploy Mule Vite to Azure Static Web Apps
**File:** `deploy-mule-vite.yml`

#### Purpose
Automates the complete build and deployment process of the mule-vite frontend application to Azure Static Web Apps infrastructure.

#### Workflow Configuration

**Trigger Events:**
```yaml
on:
  push:
    branches: [main]
    paths:
      - 'apps/mule-vite/**'
      - 'packages/ui/**'
  workflow_dispatch:
    inputs:
      environment: [dev, qa, uat, test]
```

**Runtime Environment:**
- **OS:** Ubuntu Latest
- **Node.js:** v20
- **Package Manager:** pnpm v9
- **Build Tool:** Vite

#### Detailed Pipeline Steps

**Step 1: Repository Checkout**
- Action: `actions/checkout@v4`
- Purpose: Clone the repository code

**Step 2: Environment Setup**
- Install pnpm package manager (v9)
- Setup Node.js runtime (v20)
- Configure package manager cache

**Step 3: Dependency Installation**
```bash
pnpm install --frozen-lockfile
```
- Installs all workspace dependencies
- Uses frozen lockfile to ensure reproducible builds
- Respects pnpm workspace configuration

**Step 4: Clean Build Artifacts**
```bash
rm -rf packages/api-types/dist
rm -rf packages/ui/dist
rm -rf apps/mule-vite/dist
```
- Removes previous build outputs
- Prevents stale artifact issues
- Ensures clean build state

**Step 5: Build Packages (Sequential)**

**5.1 Build api-types**
```bash
cd packages/api-types
pnpm build
```
- Generates TypeScript type definitions
- Creates shared API contracts
- Output: `packages/api-types/dist/`

**5.2 Build UI Package**
```bash
cd packages/ui
pnpm build
```
- Compiles shared UI components
- Bundles Material-UI customizations
- Output: `packages/ui/dist/`

**5.3 Build Mule Vite Application**
```bash
cd apps/mule-vite
pnpm build
```
- Compiles React application
- Optimizes assets for production
- Injects environment variables
- Output: `apps/mule-vite/dist/`

**Step 6: Deploy to Azure**
- Action: `Azure/static-web-apps-deploy@v1`
- Uploads build artifacts to Azure Static Web Apps
- Configures routing and headers
- Updates deployment status

#### Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `VITE_APP_ENV` | Target environment | `dev`, `qa`, `uat`, `test` |
| `VITE_SUPABASE_URL` | Supabase instance URL | `https://xxx.supabase.co` |
| `VITE_SUPABASE_ANON_KEY` | Supabase anonymous key | `eyJhbGc...` |
| `VITE_AUTH_API_URL` | Authentication API endpoint | `https://api.example.com/auth` |
| `VITE_DATA_API_URL` | Data API endpoint | `https://api.example.com/data` |
| `VITE_INVITE_REDIRECT_URL` | User invitation redirect | `https://app.example.com/invite` |
| `VITE_ENABLE_TOOLS` | Enable dev tools | `true`, `false` |
| `VITE_LOG_LEVEL` | Logging verbosity | `debug`, `info`, `warn`, `error` |

#### Required Secrets

| Secret | Purpose | Provider |
|--------|---------|----------|
| `AZURE_STATIC_WEB_APPS_API_TOKEN_MULE_VITE` | Azure deployment authentication | Azure Portal |
| `GITHUB_TOKEN` | GitHub API access | Auto-provided |

#### Build Dependencies

The build process requires packages to be built in this specific order due to dependencies:

```
packages/api-types (no dependencies)
    ↓
packages/ui (depends on api-types)
    ↓
apps/mule-vite (depends on ui and api-types)
```

#### Deployment Environments

**Development (dev)**
- Purpose: Active development testing
- Trigger: Automatic on main branch push
- Stability: Unstable, frequent updates

**Quality Assurance (qa)**
- Purpose: QA team testing
- Trigger: Manual workflow dispatch
- Stability: Semi-stable, tested features

**User Acceptance Testing (uat)**
- Purpose: Client/stakeholder validation
- Trigger: Manual workflow dispatch
- Stability: Stable, release candidates

**Testing (test)**
- Purpose: Integration and E2E testing
- Trigger: Manual workflow dispatch
- Stability: Stable, automated testing

#### Usage Examples

**Automatic Deployment (Push to Main):**
```bash
git add .
git commit -m "feat: update mule-vite"
git push origin main
# Workflow triggers automatically
```

**Manual Deployment:**
1. Navigate to: `https://github.com/[org]/[repo]/actions`
2. Select: "Deploy Mule Vite to Azure SWA"
3. Click: "Run workflow" button
4. Select: Target environment (dev/qa/uat/test)
5. Click: "Run workflow" to execute

#### Monitoring & Logs

**View Workflow Runs:**
- GitHub Actions tab → Workflow runs list
- Click on specific run for detailed logs
- Each step shows execution time and output

**Deployment Status:**
- Check Azure Static Web Apps dashboard
- View deployment history and URLs
- Monitor application health

#### Troubleshooting

**Common Issues:**

1. **Build Failure in api-types**
   - Check TypeScript compilation errors
   - Verify tsconfig.json configuration

2. **Build Failure in ui**
   - Ensure api-types built successfully
   - Check for missing dependencies

3. **Build Failure in mule-vite**
   - Verify all environment variables are set
   - Check for missing ui package exports

4. **Deployment Failure**
   - Verify Azure token is valid
   - Check Azure Static Web Apps quota
   - Ensure dist folder contains index.html

#### Performance Metrics

**Typical Build Times:**
- Dependency installation: ~2-3 minutes
- api-types build: ~30 seconds
- ui build: ~1-2 minutes
- mule-vite build: ~2-3 minutes
- Azure deployment: ~1-2 minutes
- **Total:** ~7-11 minutes

#### Best Practices

1. **Always use frozen lockfile** to ensure reproducible builds
2. **Clean artifacts** before building to prevent cache issues
3. **Build in correct order** to respect dependencies
4. **Test locally** before pushing to main
5. **Use manual dispatch** for non-dev environments
6. **Monitor deployment logs** for issues
7. **Verify deployment** by accessing the deployed URL

#### Related Documentation
- Azure Static Web Apps: [Azure Docs](https://docs.microsoft.com/azure/static-web-apps/)
- GitHub Actions: [GitHub Docs](https://docs.github.com/actions)
- pnpm Workspaces: [pnpm Docs](https://pnpm.io/workspaces)
