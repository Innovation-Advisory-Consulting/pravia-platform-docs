# Workspace Dependencies in Docker Builds

## Problem

When building Docker images for monorepo services that depend on workspace packages (like `@asyml8/api-core`, `@asyml8/api-types`), the build fails because Docker builds from the service directory and doesn't have access to the workspace root or other packages.

## Solution

For any service that uses workspace dependencies, the Dockerfile MUST include the entire workspace context:

### Required Dockerfile Pattern

```dockerfile
# Single-stage build for [service-name] with workspace dependencies
FROM node:20-alpine

# Install pnpm
RUN npm install -g pnpm

WORKDIR /app

# Copy workspace root files (REQUIRED for workspace resolution)
COPY ../../../package.json ./
COPY ../../../pnpm-lock.yaml ./
COPY ../../../pnpm-workspace.yaml ./

# Copy ALL workspace packages (REQUIRED for @asyml8/* dependencies)
COPY ../../../packages ./packages

# Copy this service
COPY . ./apps/[service-name]

# Install all dependencies (workspace packages will be resolved locally)
RUN pnpm install --no-frozen-lockfile

# Build the service
RUN cd apps/[service-name] && pnpm build

# Create non-root user
RUN addgroup -g 1001 -S nodejs && adduser -S nestjs -u 1001
RUN chown -R nestjs:nodejs /app
USER nestjs

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/health', (res) => { process.exit(res.statusCode === 200 ? 0 : 1) })"

# Start the application
CMD ["node", "apps/[service-name]/dist/src/main.js"]
```

### Key Requirements

1. **Build from monorepo root**: `docker build -f apps/service/Dockerfile .`
2. **Copy workspace files**: `package.json`, `pnpm-lock.yaml`, `pnpm-workspace.yaml`
3. **Copy packages directory**: Contains all `@asyml8/*` workspace packages
4. **Use `--no-frozen-lockfile`**: Lockfile may be out of sync in Docker context
5. **Correct CMD path**: `apps/[service-name]/dist/src/main.js`

### What Gets Copied

```
/app/
├── package.json              # Root workspace config
├── pnpm-lock.yaml            # Dependency resolution
├── pnpm-workspace.yaml       # Workspace definition
├── packages/                 # All workspace packages
│   ├── api-core/            # @asyml8/api-core
│   ├── api-types/           # @asyml8/api-types
│   └── ui/                  # @asyml8/ui
└── apps/
    └── [service-name]/      # The service being built
        └── dist/
            └── src/
                └── main.js  # Built application
```

### Common Mistakes to Avoid

❌ **DON'T** remove workspace dependencies from package.json
❌ **DON'T** try to install workspace packages from npm registry
❌ **DON'T** build from service directory without workspace context
❌ **DON'T** use multi-stage builds that lose workspace packages

✅ **DO** copy the entire workspace context
✅ **DO** use pnpm with workspace support
✅ **DO** build from monorepo root
✅ **DO** include all packages directory

### Services That Need This Pattern

Any service with workspace dependencies in package.json:
- `pravia-data-api` (uses `@asyml8/api-core`, `@asyml8/api-types`)
- `pravia-auth-api` (if it uses workspace packages)
- `pravia-idp-api` (if it uses workspace packages)

### Services That Don't Need This

Services with only external npm dependencies can use simpler Dockerfiles.

### Azure Container Apps Deployment

When deploying to Azure Container Apps with `azd`, the build context is automatically set correctly:
- azd builds from the service directory but includes the workspace context
- The Dockerfile paths (`../../../`) resolve correctly
- Workspace dependencies are available during build and runtime

### Testing Locally

```bash
# Test Docker build from monorepo root
cd /path/to/monorepo
docker build -f apps/pravia-data-api/Dockerfile -t test-data-api .

# Verify workspace dependencies are available
docker run --rm test-data-api node -e "console.log(require('@asyml8/api-core'))"
```

## Summary

Always include the full workspace context in Dockerfiles for services that use `@asyml8/*` workspace dependencies. This ensures the monorepo structure is preserved in the container and workspace packages are available at runtime.
