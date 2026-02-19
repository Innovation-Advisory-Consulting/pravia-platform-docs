# API Deployment System

## Overview
Unified container deployment system for all API services across environments. Provides centralized deployment scripts with configuration-driven approach.

## Purpose
- Centralized deployment for Flux, Foundry, and other APIs
- Environment-specific configurations
- Multi-stack support (e.g., Foundry compliance/incidents)
- Azure Container Apps deployment
- Backward compatibility with existing scripts

## Structure

```
deploy/api/
├── deploy-container.sh      # Unified deployment script
├── MIGRATION_SUMMARY.md     # Migration documentation
└── README.md                # Usage documentation

api/{service}/deploy/
├── config.json              # Environment configurations
├── deploy-azure-{env}-new.sh  # New wrapper scripts
└── deploy-azure-{env}.sh    # Original scripts (backup)
```

## Unified Deployment Script

**File:** `deploy-container.sh`

**Purpose:** Single parameterized script for deploying all API containers.

**Features:**
- Supports all environments (dev, qa, test, uat)
- Multi-stack deployments (Foundry)
- Configuration-driven (JSON)
- Docker build and push
- Azure Container Apps update
- Health check verification

**Usage:**
```bash
# From monorepo root
./deploy/api/deploy-container.sh <service> <environment> [--stack <stack>]

# Examples
./deploy/api/deploy-container.sh flux dev
./deploy/api/deploy-container.sh flux qa
./deploy/api/deploy-container.sh foundry dev --stack compliance
./deploy/api/deploy-container.sh foundry dev --stack incidents
```

**Parameters:**
- `<service>` - Service name (flux, foundry, incidents)
- `<environment>` - Target environment (dev, qa, test, uat)
- `--stack <stack>` - Optional stack name for multi-stack services

## Configuration System

### Configuration Files
Each service has a `config.json` in its deploy directory:

**Location:** `api/{service}/deploy/config.json`

**Structure:**
```json
{
  "dev": {
    "registry": "acrpraviamuledevereh4t.azurecr.io",
    "registryName": "acrpraviamuledevereh4t",
    "imageName": "pravia-mule/pravia-data-api-dev",
    "containerApp": "ca-pravia-data-api-dev",
    "resourceGroup": "rg-pravia-mule-dev-eastus",
    "subscriptionId": "efd96f35-607f-499d-8be1-b71dc236c1ec",
    "apiUrl": "ca-pravia-data-api-dev.graybay-593c9998.eastus.azurecontainerapps.io",
    "setNodeEnv": true
  },
  "qa": { ... },
  "test": { ... },
  "uat": { ... }
}
```

**Configuration Fields:**
- `registry` - Azure Container Registry URL
- `registryName` - ACR name for login
- `imageName` - Docker image name and tag
- `containerApp` - Azure Container App name
- `resourceGroup` - Azure resource group
- `subscriptionId` - Azure subscription ID
- `apiUrl` - API endpoint URL
- `setNodeEnv` - Whether to set NODE_ENV=production

### Multi-Stack Configuration

For services with multiple stacks (e.g., Foundry):

```json
{
  "dev": {
    "stacks": {
      "compliance": {
        "registry": "...",
        "imageName": "pravia-mule/pravia-auth-api-dev",
        "containerApp": "ca-pravia-auth-api-dev",
        ...
      },
      "incidents": {
        "registry": "...",
        "imageName": "pravia-mule/pravia-incidents-api-dev",
        "containerApp": "ca-pravia-incidents-api-dev",
        ...
      }
    }
  }
}
```

## Wrapper Scripts

### Purpose
Backward-compatible wrapper scripts that call the unified deployment script.

### Naming Convention
- **New scripts:** `deploy-azure-{env}-new.sh`
- **Original scripts:** `deploy-azure-{env}.sh` (preserved as backup)

### Example Wrapper
```bash
#!/bin/bash
# deploy-azure-dev-new.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MONOREPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

"$MONOREPO_ROOT/deploy/api/deploy-container.sh" flux dev
```

### Usage
```bash
# From service deploy directory
cd api/flux/deploy
./deploy-azure-dev-new.sh

cd api/foundry/deploy
./deploy-azure-dev-new.sh  # Defaults to compliance stack
```

## Deployment Process

### Step-by-Step Flow

1. **Read Configuration**
   - Load config.json for service and environment
   - Extract deployment parameters

2. **Docker Build**
   ```bash
   docker build --platform linux/amd64 \
     -t $imageName \
     -f api/$service/Dockerfile .
   ```

3. **Azure Login**
   ```bash
   az acr login --name $registryName
   ```

4. **Push Image**
   ```bash
   docker push $registry/$imageName
   ```

5. **Update Container App**
   ```bash
   az containerapp update \
     --name $containerApp \
     --resource-group $resourceGroup \
     --image $registry/$imageName
   ```

6. **Health Check**
   ```bash
   curl https://$apiUrl/api/health
   ```

## Supported Services

### Flux API
**Environments:** dev, qa, test, uat

**Configuration:** `api/flux/deploy/config.json`

**Deployment:**
```bash
./deploy/api/deploy-container.sh flux dev
./deploy/api/deploy-container.sh flux qa
./deploy/api/deploy-container.sh flux test
./deploy/api/deploy-container.sh flux uat
```

### Foundry API
**Environments:** dev (2 stacks), qa, test, uat

**Stacks:**
- `compliance` - Main authentication API
- `incidents` - Incidents management API

**Configuration:** `api/foundry/deploy/config.json`

**Deployment:**
```bash
# Compliance stack
./deploy/api/deploy-container.sh foundry dev --stack compliance
./deploy/api/deploy-container.sh foundry qa

# Incidents stack
./deploy/api/deploy-container.sh foundry dev --stack incidents
```

## Benefits

### Code Reduction
- **Before:** 12+ redundant deployment scripts
- **After:** 1 unified script + config files
- **Reduction:** ~95% code reduction

### Maintainability
- Single source of truth
- Bug fixes apply everywhere
- Consistent deployment process
- Easy to extend

### Configuration-Driven
- JSON-based configuration
- Environment-specific settings
- Type-safe configuration
- Validation prevents errors

### Backward Compatible
- Original scripts preserved
- Wrapper scripts for compatibility
- Gradual migration path
- Easy rollback

## Migration Status

### Completed
- ✅ Unified script created (`deploy-container.sh`)
- ✅ Config files created for Flux and Foundry
- ✅ Wrapper scripts created (`*-new.sh`)
- ✅ Original scripts preserved as backup
- ✅ Documentation created

### Pending
- ⏳ Testing in all environments
- ⏳ Migration of incidents service
- ⏳ Removal of old scripts (after validation)
- ⏳ Rename `-new.sh` scripts (remove `-new` suffix)

## Testing

### Test Plan

**1. Test Flux Dev:**
```bash
./deploy/api/deploy-container.sh flux dev
curl https://ca-pravia-data-api-dev.graybay-593c9998.eastus.azurecontainerapps.io/api/health
```

**2. Test Foundry Dev (Compliance):**
```bash
./deploy/api/deploy-container.sh foundry dev --stack compliance
curl https://ca-pravia-auth-api-dev.graybay-593c9998.eastus.azurecontainerapps.io/api/health
```

**3. Test Foundry Dev (Incidents):**
```bash
./deploy/api/deploy-container.sh foundry dev --stack incidents
curl https://ca-pravia-incidents-api-dev.graybay-593c9998.eastus.azurecontainerapps.io/api/health
```

**4. Test Other Environments:**
```bash
./deploy/api/deploy-container.sh flux qa
./deploy/api/deploy-container.sh flux test
./deploy/api/deploy-container.sh flux uat
```

### Verification Checklist
- [ ] Docker image builds successfully
- [ ] Image pushes to ACR
- [ ] Container App updates
- [ ] Health endpoint responds
- [ ] Application functions correctly
- [ ] Environment variables set correctly

## Rollback Strategy

### If Issues Occur

**Option 1: Use Original Scripts**
```bash
cd api/flux/deploy
./deploy-azure-dev.sh  # Original script
```

**Option 2: Manual Deployment**
```bash
# Build and push manually
docker build -t image .
docker push registry/image

# Update Container App manually
az containerapp update --name app --image registry/image
```

### Rollback Steps
1. Identify the issue
2. Use original deployment script
3. Verify deployment works
4. Report issue for unified script fix
5. Re-test unified script after fix

## Troubleshooting

### Common Issues

**Docker Build Fails**
```bash
# Check Dockerfile exists
ls api/$service/Dockerfile

# Check build context
docker build --platform linux/amd64 -t test -f api/$service/Dockerfile .
```

**ACR Login Fails**
```bash
# Verify Azure login
az account show

# Check ACR access
az acr login --name $registryName
```

**Container App Update Fails**
```bash
# Verify Container App exists
az containerapp show --name $containerApp --resource-group $resourceGroup

# Check subscription
az account set --subscription $subscriptionId
```

**Health Check Fails**
```bash
# Wait for deployment to complete
sleep 30

# Check Container App logs
az containerapp logs show --name $containerApp --resource-group $resourceGroup

# Verify URL
curl -v https://$apiUrl/api/health
```

## Best Practices

### Configuration Management
1. Keep config.json in version control
2. Use environment-specific values
3. Validate JSON before committing
4. Document configuration changes

### Deployment Process
1. Test in dev environment first
2. Verify health checks pass
3. Monitor application logs
4. Deploy to higher environments sequentially
5. Keep rollback plan ready

### Security
1. Never commit credentials to config.json
2. Use Azure CLI authentication
3. Rotate ACR credentials regularly
4. Use managed identities when possible

### Monitoring
1. Check Container App logs after deployment
2. Monitor health endpoints
3. Verify application metrics
4. Set up alerts for failures

## Future Enhancements

### Planned Features
- [ ] Automated rollback on health check failure
- [ ] Blue-green deployment support
- [ ] Canary deployment support
- [ ] Deployment notifications (Slack, email)
- [ ] Deployment metrics and logging
- [ ] CI/CD pipeline integration
- [ ] Multi-region deployment support

### Configuration Enhancements
- [ ] Schema validation for config.json
- [ ] Environment variable templates
- [ ] Secrets management integration
- [ ] Configuration inheritance

## Related Documentation
- Flux Deployment: `api/flux/deploy/AZURE_DEPLOYMENT.md`
- Foundry Deployment: `api/foundry/deploy/AZURE_DEPLOYMENT.md`
- GitHub Actions: `.github/workflows/deploy-mule-vite.yml`
- Parent: `DOCUMENTACION-COMPLETA.md`
