# Pravia Platform Infrastructure

Multi-application infrastructure for the Pravia platform using Azure Developer CLI (azd) and Bicep templates.

## Applications

### Compliance Platform (`pravia-mule`)
Integration platform for compliance and data management services.

**Location:** `infra/azure/pravia-mule/`

**Services:**
- IDP API: Identity provider services
- Data API: Backend data services
- Auth API: Authentication services

### Incidents Platform (`pravia-incidents`)
Incident management and reporting platform.

**Location:** `infra/azure/pravia-incidents/`

**Services:**
- Incidents API: Core incidents management
- Notifications API: Alert and notification services
- Reporting API: Analytics and reporting

## Quick Start

### Compliance Platform
```bash
cd infra/azure/pravia-mule

# Deploy infrastructure
azd up --environment dev

# Configure application
./scripts/configure-environment.sh dev enable

# Deploy code changes
azd deploy --environment dev
```

### Incidents Platform
```bash
cd infra/azure/pravia-incidents

# Deploy infrastructure
azd up --environment dev

# Configure application
./scripts/configure-environment.sh dev enable

# Deploy code changes
azd deploy --environment dev
```

## Architecture

Both platforms share the same infrastructure pattern:

- **Container Registry**: Custom container images
- **Container App Environment**: Serverless container hosting
- **Storage Account**: Application data and configuration
- **Key Vault**: Secure secrets management
- **API Gateway**: Traffic routing (optional: APIM/AppGW/LB)
- **Static Web App**: Frontend hosting

## Environments

Each platform supports three environments:

| Environment | Gateway | Purpose | Monthly Cost |
|-------------|---------|---------|--------------|
| **dev** | none | Development | ~$10-16 |
| **qa** | Application Gateway | Testing | ~$93-99 |
| **prod** | API Management | Production | ~$196-202 |

## Resource Naming

Resources follow: `{type}-pravia-{platform}-{component}-{env}`

### Compliance Platform Examples
- `rg-pravia-mule-dev-eastus`
- `ca-pravia-data-api-dev`
- `app-pravia-idp-api-dev`

### Incidents Platform Examples
- `rg-pravia-incidents-dev-eastus`
- `ca-pravia-incidents-api-dev`
- `app-pravia-incidents-api-dev`

## Common Commands

### Deploy Infrastructure
```bash
# Compliance
cd infra/azure/pravia-mule
azd up --environment dev

# Incidents
cd infra/azure/pravia-incidents
azd up --environment dev
```

### Configure Applications
```bash
# Enable environment (set variables, scale up)
./scripts/configure-environment.sh dev enable

# Disable environment (scale to zero, save costs)
./scripts/configure-environment.sh dev disable

# Update specific variable
./scripts/configure-environment.sh dev update KEY=VALUE

# Check status
./scripts/configure-environment.sh dev status
```

### Deploy Code Only
```bash
# Fast deployment (~2 minutes)
azd deploy --environment dev
```

### View Environment
```bash
# Show deployment status
azd show --environment dev

# View all environment variables
azd env get-values --environment dev

# Set environment variable
azd env set KEY value

# Set secret (encrypted)
azd env set KEY value --secret
```

### Clean Up
```bash
# Remove all resources
azd down --environment dev

# Complete cleanup (removes local state)
azd down --environment dev --purge
```

## Configuration Management

### Two-Phase Deployment

**Phase 1: Provision Infrastructure**
```bash
cd infra/azure/pravia-mule  # or pravia-incidents
azd up --environment dev
```

**Phase 2: Configure Application**
```bash
# Store secrets
azd env set SUPABASE_URL "https://your-project.supabase.co"
azd env set SUPABASE_ANON_KEY "your-key" --secret
azd env set SUPABASE_SERVICE_KEY "your-key" --secret

# Enable environment
./scripts/configure-environment.sh dev enable
```

### Weekend Cost Savings
```bash
# Friday evening - disable non-prod
cd infra/azure/pravia-mule
./scripts/configure-environment.sh dev disable
./scripts/configure-environment.sh qa disable

cd ../pravia-incidents
./scripts/configure-environment.sh dev disable
./scripts/configure-environment.sh qa disable

# Monday morning - re-enable
cd infra/azure/pravia-mule
./scripts/configure-environment.sh dev enable
./scripts/configure-environment.sh qa enable

cd ../pravia-incidents
./scripts/configure-environment.sh dev enable
./scripts/configure-environment.sh qa enable
```

## Endpoints

### Compliance Platform (dev)
- IDP API: `https://ca-pravia-idp-api-dev.{region}.azurecontainerapps.io`
- Data API: `https://ca-pravia-data-api-dev.{region}.azurecontainerapps.io`
- Auth API: `https://ca-pravia-auth-api-dev.{region}.azurecontainerapps.io`
- Frontend: `https://swa-pravia-app-dev.azurestaticapps.net`

### Incidents Platform (dev)
- Incidents API: `https://ca-pravia-incidents-api-dev.{region}.azurecontainerapps.io`
- Notifications API: `https://ca-pravia-notifications-api-dev.{region}.azurecontainerapps.io`
- Reporting API: `https://ca-pravia-reporting-api-dev.{region}.azurecontainerapps.io`
- Frontend: `https://swa-pravia-incidents-dev.azurestaticapps.net`

## Monitoring

### Container Apps
```bash
# Check status
az containerapp show \
  --name ca-pravia-{service}-api-dev \
  --resource-group rg-pravia-{platform}-dev-eastus \
  --query "properties.runningStatus"

# View logs
az containerapp logs show \
  --name ca-pravia-{service}-api-dev \
  --resource-group rg-pravia-{platform}-dev-eastus \
  --follow

# List replicas
az containerapp replica list \
  --name ca-pravia-{service}-api-dev \
  --resource-group rg-pravia-{platform}-dev-eastus
```

Replace `{service}` with: `data`, `auth`, `idp`, `incidents`, `notifications`, or `reporting`  
Replace `{platform}` with: `mule` or `incidents`

## Cost Optimization

### Best Practices
1. **Use Container Apps** - Scales to zero when not in use
2. **Disable non-production environments** - Use configuration scripts
3. **Share Container Apps Environment** - Multiple apps share same environment
4. **Monitor usage patterns** - Adjust scaling rules
5. **Right-size resources** - Don't over-provision CPU/Memory

### Cost Comparison Per Platform

**Container Apps (Recommended):**
- Dev: ~$10-16/month (scales to zero)
- Can disable when not in use: $0/month

**App Services (Traditional):**
- Dev: ~$55-65/month (always-on)
- Cannot scale to zero

**Savings:** ~$40-50/month per platform with Container Apps

### Total Platform Costs

| Configuration | Monthly Cost |
|---------------|--------------|
| Both platforms (dev only) | ~$20-32 |
| Both platforms (dev + qa) | ~$206-230 |
| Both platforms (all envs) | ~$412-466 |

## Security

### Secrets Management
- Never commit secrets to source control
- Use `azd env set --secret` for sensitive values
- Store secrets in Key Vault
- Rotate secrets regularly
- Use managed identities where possible

### Network Security
- Container Apps use private networking by default
- External ingress only where needed
- Consider VNet integration for production
- Use Azure Front Door for DDoS protection

## Documentation

- [Compliance Platform Details](./pravia-mule/README.md)
- [Incidents Platform Details](./pravia-incidents/README.md)
- [Configuration Scripts](./pravia-mule/scripts/README.md)
- [Azure Container Apps](https://docs.microsoft.com/en-us/azure/container-apps/)
- [Azure Developer CLI](https://docs.microsoft.com/en-us/azure/developer/azure-developer-cli/)

## Support

For platform-specific details, see the README in each application folder:
- Compliance: `infra/azure/pravia-mule/README.md`
- Incidents: `infra/azure/pravia-incidents/README.md`
