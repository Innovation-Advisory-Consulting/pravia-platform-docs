# Pravia Mule Platform Infrastructure

Environment-specific infrastructure for the Pravia Mule integration platform using Azure Developer CLI (azd) and Bicep templates.

## Table of Contents

- [Architecture](#architecture)
- [Deployment](#deployment)
- [Configuration Management](#configuration-management)
- [Resource Naming](#resource-naming-convention)
- [API Gateway Options](#api-gateway-options)
- [Container Apps vs App Services](#container-apps-vs-app-services)
- [Environment Costs](#environment-costs)
- [Endpoints](#endpoints)
- [Management Commands](#management-commands)
- [Monitoring](#monitoring-and-troubleshooting)
- [Security](#security-considerations)
- [Cost Optimization](#cost-optimization)

## Architecture

### Infrastructure Components

- **Container Registry**: Custom container images
- **Container App Environment**: Serverless container hosting
- **Storage Account**: Application data and configuration
- **Key Vault**: Secure secrets management
- **API Gateway**: Traffic routing (optional: APIM/AppGW/LB)
- **Static Web App**: Frontend hosting

### Container Apps (Serverless)

- **IDP API**: Identity provider services
- **Data API**: Backend data services  
- **Auth API**: Authentication services

**Features:**
- Serverless scaling (0-20 replicas based on environment)
- Consumption-based pricing (pay per use)
- External ingress enabled
- ACR integration configured
- URLs: `*.azurecontainerapps.io`

### App Services (Traditional)

- **IDP App Service**: Alternative containerized deployment
- **Web App Service Plan**: Shared hosting plan

**Features:**
- Always-on (minimum 1 instance)
- Fixed monthly cost
- Custom domains support
- URLs: `*.azurewebsites.net`

## Deployment

### Two-Phase Deployment (Recommended)

This approach separates infrastructure provisioning from application configuration, enabling flexible environment management and cost optimization.

#### Phase 1: Provision Infrastructure

```bash
# Create all Azure resources
azd up --environment dev
```

This creates:
- Resource Group
- Storage Account
- Container Registry
- Key Vault
- Container App Environment
- Container Apps (3)
- Web App Service Plan
- Static Web App
- API Gateway (if configured)

#### Phase 2: Configure Application

```bash
# Store secrets securely in azd environment
azd env set SUPABASE_URL "https://your-project.supabase.co"
azd env set SUPABASE_ANON_KEY "your-key" --secret
azd env set SUPABASE_SERVICE_KEY "your-key" --secret
azd env set DATAVERSE_URL "https://your-org.crm.dynamics.com"
azd env set DATAVERSE_CLIENT_ID "your-client-id"
azd env set DATAVERSE_CLIENT_SECRET "your-secret" --secret
azd env set DATAVERSE_TENANT_ID "your-tenant-id"
azd env set DATABASE_HOST "your-db-host.supabase.com"
azd env set DATABASE_USERNAME "postgres.xxxxx"
azd env set DATABASE_PASSWORD "your-password" --secret

# Enable environment (sets all app variables)
./scripts/configure-environment.sh dev enable
```

See [Configuration Management Scripts](./scripts/README.md) for detailed usage.

### Single-Phase Deployment (Legacy)

```bash
# Set all variables upfront
azd env set SUPABASE_URL "https://your-project.supabase.co"
# ... set all other variables

# Deploy everything at once
azd up --environment dev
```

### Environment-Specific Deployments

```bash
# Development (no gateway)
azd up --environment dev

# QA/Test (Application Gateway)
azd up --environment qa

# Production (API Management)
azd up --environment prod
```

## Configuration Management

### Overview

Manage application environment variables independently from infrastructure provisioning. This enables:

- **Flexible Environment Control**: Enable/disable environments without destroying resources
- **Cost Optimization**: Scale non-production environments to zero when not in use
- **Fast Configuration Updates**: Change app settings without full redeployment
- **Security**: Separate infrastructure credentials from application secrets
- **Team Collaboration**: Different teams can manage infrastructure vs configuration

### Architecture

**Infrastructure Variables** (set by Bicep during `azd up`):
- Registry credentials
- Storage connection strings
- Key Vault URI

**Application Variables** (set by script after provisioning):
- Supabase credentials
- Dataverse configuration
- Database settings
- Application features (Swagger, etc.)

### Commands

```bash
# Enable environment (activate apps, scale up)
./scripts/configure-environment.sh dev enable

# Disable environment (scale to zero, save costs)
./scripts/configure-environment.sh dev disable

# Update specific variable
./scripts/configure-environment.sh dev update SUPABASE_URL=https://new-url.supabase.co

# Check environment status
./scripts/configure-environment.sh dev status
```

### Workflow Examples

**Daily Development:**
```bash
# Make code changes
git commit -am "feat: new feature"

# Deploy code only (fast, ~2 minutes)
azd deploy
```

**Weekend Cost Savings:**
```bash
# Friday evening - disable non-prod environments
./scripts/configure-environment.sh dev disable
./scripts/configure-environment.sh qa disable

# Monday morning - re-enable
./scripts/configure-environment.sh dev enable
./scripts/configure-environment.sh qa enable
```

**Configuration Updates:**
```bash
# Update Supabase URL across all apps
azd env set SUPABASE_URL "https://new-project.supabase.co"
./scripts/configure-environment.sh dev enable

# Or update just one variable
./scripts/configure-environment.sh dev update NODE_ENV=production
```

### Environment Variables Managed

**Data API Container App:**
- `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_KEY`
- `DATAVERSE_URL`, `DATAVERSE_CLIENT_ID`, `DATAVERSE_CLIENT_SECRET`, `DATAVERSE_TENANT_ID`
- `DATABASE_ENABLED`, `APP_URL`
- `SWAGGER_*` (7 configuration variables)

**Auth API Container App:**
- `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_KEY`
- `DATABASE_ENABLED`, `DATABASE_HOST`, `DATABASE_PORT`, `DATABASE_USERNAME`, `DATABASE_PASSWORD`
- `DATABASE_DB_NAME`, `DATABASE_SCHEMA_NAME`
- `NODE_ENV`
- `SWAGGER_*` (6 configuration variables)

**IDP API Container App:**
- Currently minimal, extensible for future needs

### CI/CD Integration

```yaml
# GitHub Actions example
- name: Provision Infrastructure
  run: azd up --environment prod --no-prompt

- name: Configure Application
  run: ./scripts/configure-environment.sh prod enable

- name: Deploy Code
  run: azd deploy --environment prod
```

## Resource Naming Convention

Resources follow the pattern: `{type}-{app}-{component}-{environment}`

**Examples:**
- `rg-pravia-mule-dev-eastus` (Resource Group)
- `ca-pravia-data-api-dev` (Container App)
- `app-pravia-idp-api-dev` (App Service)
- `acrpraviamuledevxyz123` (Container Registry)
- `kv-dev-xyz1234567` (Key Vault)

## API Gateway Options

Configure via `apiGatewayOption` parameter in `main.bicep`:

### Development: `none` (Default)
- Direct access to Container Apps
- No gateway overhead
- Lowest cost (~$10-16/month)

### Test/QA: `appgw`
- Application Gateway for load balancing
- SSL termination
- Basic routing capabilities
- Cost: +$83/month

### Production: `apim`
- Full API Management features
- Advanced security and throttling
- Analytics and monitoring
- Cost: +$186/month

### Alternative: `lb`
- Azure Load Balancer
- Most cost-effective gateway option
- Basic traffic distribution

## Container Apps vs App Services

### Container Apps (Serverless) - Recommended

**Scaling:**
- Dev: 0-3 replicas (0.75 vCPU, 1.5GB)
- QA/Test: 0-5 replicas (0.5 vCPU, 1GB)
- Prod: 1-20 replicas (1.0 vCPU, 2GB)

**Pricing:** Consumption-based (pay per use)

**Best for:** Variable workloads, cost optimization, modern cloud-native apps

**URLs:** `*.azurecontainerapps.io`

### App Services (Traditional)

**Scaling:** Always-on (minimum 1 instance)

**Pricing:** Fixed monthly cost (~$55/month for 3x B1 instances)

**Best for:** Consistent workloads, custom domains, legacy apps

**URLs:** `*.azurewebsites.net`

## Environment Costs

### Development Environment
**Monthly Cost: ~$10-16** (Container Apps only)

| Resource | Type | Cost |
|----------|------|------|
| Container Apps (3x) | Consumption | ~$2-8 |
| Container Registry | Basic | ~$5 |
| Storage Account | Standard | ~$2 |
| Key Vault | Standard | ~$1 |
| **Total** | | **~$10-16** |

*Note: Costs assume apps scale to zero when not in use*

### QA/Test Environment
**Monthly Cost: ~$93-99**

| Resource | Cost |
|----------|------|
| Base infrastructure | ~$10-16 |
| Application Gateway | ~$83 |
| **Total** | **~$93-99** |

### Production Environment
**Monthly Cost: ~$196-202**

| Resource | Cost |
|----------|------|
| Base infrastructure | ~$10-16 |
| API Management | ~$186 |
| **Total** | **~$196-202** |

## Endpoints

### Development URLs

**Container Apps:**
- IDP API: `https://ca-pravia-idp-api-dev.{region}.azurecontainerapps.io`
- Data API: `https://ca-pravia-data-api-dev.{region}.azurecontainerapps.io`
- Auth API: `https://ca-pravia-auth-api-dev.{region}.azurecontainerapps.io`

**App Services:**
- IDP API: `https://app-pravia-idp-api-dev.azurewebsites.net`

**Static Web App:**
- Frontend: `https://swa-pravia-app-dev.azurestaticapps.net`

**Swagger Documentation:**
- Container App: `https://ca-pravia-data-api-dev.{region}.azurecontainerapps.io/api`
- App Service: `https://app-pravia-idp-api-dev.azurewebsites.net/api`

## Management Commands

### Azure Developer CLI

```bash
# View deployment status
azd show --environment dev

# Update infrastructure only
azd provision --environment dev

# Deploy code changes only
azd deploy --environment dev

# View environment variables
azd env get-values --environment dev

# Set environment variable
azd env set KEY value

# Set secret (encrypted)
azd env set KEY value --secret

# Clean up environment
azd down --environment dev

# Complete cleanup (removes local state)
azd down --environment dev --purge
```

### Configuration Management

```bash
# Enable environment
./scripts/configure-environment.sh dev enable

# Disable environment
./scripts/configure-environment.sh dev disable

# Update variable
./scripts/configure-environment.sh dev update KEY=VALUE

# Check status
./scripts/configure-environment.sh dev status
```

### Container Operations

```bash
# Build and push images
docker build --platform linux/amd64 -t {registry}.azurecr.io/pravia-data-api:latest ./data-api
az acr login --name {registry}
docker push {registry}.azurecr.io/pravia-data-api:latest

# View Container App logs
az containerapp logs show \
  --name ca-pravia-data-api-dev \
  --resource-group rg-pravia-mule-dev-eastus \
  --follow

# Check Container App status
az containerapp show \
  --name ca-pravia-data-api-dev \
  --resource-group rg-pravia-mule-dev-eastus

# List replicas
az containerapp replica list \
  --name ca-pravia-data-api-dev \
  --resource-group rg-pravia-mule-dev-eastus
```

## Monitoring and Troubleshooting

### Container Apps Monitoring

```bash
# Check running status
az containerapp show \
  --name ca-pravia-data-api-dev \
  --resource-group rg-pravia-mule-dev-eastus \
  --query "properties.runningStatus"

# View replica count
az containerapp replica list \
  --name ca-pravia-data-api-dev \
  --resource-group rg-pravia-mule-dev-eastus

# Stream logs
az containerapp logs show \
  --name ca-pravia-data-api-dev \
  --resource-group rg-pravia-mule-dev-eastus \
  --follow
```

### Common Issues

**Container fails to start:**
- Check container logs for errors
- Verify port configuration (default: 3000)
- Ensure image exists in ACR
- Verify environment variables are set

**Registry authentication:**
- Verify ACR admin is enabled
- Check registry credentials in Container App secrets

**Scaling issues:**
- Monitor replica count
- Check resource limits (CPU/Memory)
- Verify health check endpoints

**Environment won't scale up after enable:**
- Verify required secrets are set: `azd env get-values`
- Check Container App logs for startup errors
- Ensure critical variables are present (SUPABASE_URL, DATABASE_HOST, etc.)

## Security Considerations

### Container Registry
- Admin access enabled for deployment
- Consider using managed identity in production
- Regular image vulnerability scanning
- Use Azure Defender for container registries

### Key Vault
- RBAC authorization enabled
- Soft delete enabled (7-day retention)
- Access policies for applications
- Audit logging enabled

### Network Security
- Container Apps use private networking by default
- External ingress only where needed
- Consider VNet integration for production
- Use Azure Front Door for DDoS protection

### Secrets Management
- Never commit secrets to source control
- Use `azd env set --secret` for sensitive values
- Store secrets in Key Vault
- Rotate secrets regularly
- Use managed identities where possible

## Cost Optimization

### Best Practices

1. **Use Container Apps for variable workloads** - Scales to zero when not in use
2. **Disable non-production environments** - Use configuration script to scale to zero
3. **Share Container Apps Environment** - Multiple apps share same environment
4. **Monitor usage patterns** - Adjust scaling rules based on actual usage
5. **Use Basic tier for development** - Upgrade only when needed
6. **Right-size resources** - Don't over-provision CPU/Memory
7. **Use consumption-based pricing** - Avoid always-on services in dev/test

### Cost Comparison

**Container Apps (Recommended):**
- Dev: ~$10-16/month (scales to zero)
- Can disable when not in use: $0/month

**App Services (Traditional):**
- Dev: ~$55-65/month (always-on)
- Cannot scale to zero

**Savings:** ~$40-50/month per environment with Container Apps

### Monitoring Costs

```bash
# View resource costs in Azure Portal
az consumption usage list \
  --start-date 2025-12-01 \
  --end-date 2025-12-31

# Check Container App replica count (0 = no cost)
./scripts/configure-environment.sh dev status
```

## Performance Optimization

### Container Apps
- Right-size CPU/Memory based on workload
- Configure appropriate scaling rules (min/max replicas)
- Use health checks for reliability
- Implement graceful shutdown
- Optimize container startup time
- Use multi-stage Docker builds

### App Services
- Use appropriate pricing tier
- Enable Application Insights
- Configure auto-scaling rules
- Optimize container image size
- Use CDN for static assets

## Migration Path

### From App Services to Container Apps

1. **Containerize applications** (if not already)
2. **Push images to ACR**
3. **Deploy Container Apps** via Bicep
4. **Test thoroughly** in dev environment
5. **Update DNS/routing** to new endpoints
6. **Monitor performance** and costs
7. **Decommission App Services** when stable

**Benefits:**
- Cost savings: ~$40-50/month per service
- Better scaling: True serverless (scale to zero)
- Modern architecture: Cloud-native containers
- Improved efficiency: Pay only for actual usage

## Support and Documentation

- [Azure Container Apps Documentation](https://docs.microsoft.com/en-us/azure/container-apps/)
- [Azure Developer CLI Documentation](https://docs.microsoft.com/en-us/azure/developer/azure-developer-cli/)
- [Configuration Management Scripts](./scripts/README.md)
- [Bicep Updates](./BICEP_UPDATES.md)

## Contributing

When making infrastructure changes:

1. Test in dev environment first
2. Update documentation
3. Follow naming conventions
4. Add appropriate tags
5. Consider cost implications
6. Update CI/CD pipelines if needed
