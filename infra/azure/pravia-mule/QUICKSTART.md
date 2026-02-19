# Quick Start Guide

Get the Pravia Mule Platform infrastructure running in under 10 minutes.

## Prerequisites

### Required Tools

- [Azure Developer CLI (azd)](https://learn.microsoft.com/azure/developer/azure-developer-cli/install-azd)
- [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli)
- Azure subscription with appropriate permissions

### Required External Services

Before deploying infrastructure, you must have:

**Supabase Instance:**
- Active Supabase project
- Project URL (e.g., `https://xxxxx.supabase.co`)
- Anon key (public API key)
- Service role key (admin API key)
- Database connection details (host, username, password)

**Microsoft Dataverse (Optional):**
- Power Apps environment with Dataverse
- App registration in Azure AD with:
  - Client ID
  - Client Secret
  - Tenant ID
- Dataverse instance URL (e.g., `https://org.crm.dynamics.com`)

**Note:** These services must be provisioned and configured before running `azd up`. The infrastructure deployment will configure Container Apps to connect to these existing services.

## Installation

### 1. Authenticate with Azure

```bash
# Authenticate Azure CLI (for managing resources)
az login

# Authenticate Azure Developer CLI (for azd commands)
azd auth login
```

Both commands will open a browser for authentication. Use the same Azure account for both.

**Verify authentication:**
```bash
# Check Azure CLI is authenticated
az account show

# Check azd CLI is authenticated
azd env list
```

### 2. Initialize Environment

```bash
# Create a new environment (e.g., dev, qa, test, prod)
azd env new test

# The .azure/test/.env file is created with minimal settings
# You only need to verify/update:
# - AZURE_SUBSCRIPTION_ID (your Azure subscription)
# - AZURE_LOCATION (deployment region, default: eastus)
# - API_GATEWAY_OPTION (default: none)
```

**Note:** Application secrets are added AFTER infrastructure deployment.

### 3. Deploy Infrastructure

```bash
# Deploy all Azure resources (no secrets yet)
azd up --environment test
```

This creates:
- Resource Group
- Container Registry
- Container Apps (3x: IDP, Data, Auth APIs)
- Storage Account
- Key Vault (for future use)
- Static Web App

**Time:** ~5-7 minutes

**Note:** After deployment, `azd` automatically adds infrastructure outputs to `.azure/test/.env`:

```bash
# Example outputs added by azd:
containerRegistryLoginServer="acrpraviamuletest3luukm.azurecr.io"
dataContainerAppFqdn="ca-pravia-data-api-test.greensea-3d367080.eastus.azurecontainerapps.io"
authContainerAppFqdn="ca-pravia-auth-api-test.greensea-3d367080.eastus.azurecontainerapps.io"
keyVaultUri="https://kv-test-2fehwvbgpv.vault.azure.net/"
resourceGroupName="rg-pravia-mule-test-eastus"
# ... and more
```

Container Apps are created but not configured with application secrets yet.

## Configuration

### 4. Add Application Secrets

After infrastructure is deployed, `azd` will have added deployment outputs to `.azure/test/.env`. Now add your application secrets to the same file.

Edit the environment file:

```bash
nano .azure/test/.env
```

Add these values at the end of the file:

```bash
# Supabase Configuration
SUPABASE_URL="https://your-project.supabase.co"
SUPABASE_ANON_KEY="your-anon-key"
SUPABASE_SERVICE_KEY="your-service-key"

# Database Configuration (Supabase PostgreSQL)
DATABASE_HOST="your-db-host.supabase.com"
DATABASE_PORT="5432"
DATABASE_USERNAME="postgres.xxxxx"
DATABASE_PASSWORD="your-password"
DATABASE_DB_NAME="postgres"
DATABASE_SCHEMA_NAME="external_authentication"

# Optional: Dataverse configuration
DATAVERSE_URL="https://your-org.crm.dynamics.com"
DATAVERSE_CLIENT_ID="your-client-id"
DATAVERSE_CLIENT_SECRET="your-secret"
DATAVERSE_TENANT_ID="your-tenant-id"

# Email redirect URL
EMAIL_INVITE_REDIRECT_URL="https://your-static-app.azurestaticapps.net/auth/callback"
```

**Alternative:** Use `azd env set` for individual values:

```bash
azd env set SUPABASE_URL "https://your-project.supabase.co"
azd env set SUPABASE_ANON_KEY "your-anon-key" --secret
azd env set DATABASE_PASSWORD "your-password" --secret
# ... etc
```

### 5. Apply Secrets and Configuration

```bash
# Configure Container Apps with secrets and environment variables
./scripts/configure-environment.sh test enable
```

This script:
- Reads secrets from `.azure/test/.env`
- Sets secrets directly on Container Apps
- Configures all application environment variables
- Activates the environment
- Displays full configuration confirmation

**Time:** ~1-2 minutes

**Verify Configuration:**

```bash
# Show all configured variables and secrets with actual values
./scripts/configure-environment.sh test show
```

This displays:
- All environment variables for each Container App
- All secrets with their actual values
- Complete visibility into what's configured

## Verify Deployment

### Check Status

```bash
# View all resources
azd show --environment test

# Check environment status
./scripts/configure-environment.sh test status
```

### Access Endpoints

Your APIs are now available at:

- **IDP API:** `https://ca-pravia-idp-api-test.{region}.azurecontainerapps.io`
- **Data API:** `https://ca-pravia-data-api-test.{region}.azurecontainerapps.io`
- **Auth API:** `https://ca-pravia-auth-api-test.{region}.azurecontainerapps.io`
- **Frontend:** `https://swa-pravia-app-test.azurestaticapps.net`

### Test API

```bash
# Get your Data API URL
DATA_API_URL=$(azd env get-values | grep dataContainerAppFqdn | cut -d'=' -f2 | tr -d '"')

# Test health endpoint
curl https://$DATA_API_URL/health
```

## Daily Operations

### Update Configuration

```bash
# Update secrets in .env
nano .azure/test/.env

# Or use azd CLI
azd env set SUPABASE_URL "https://new-url.supabase.co"

# Apply changes to Container Apps
./scripts/configure-environment.sh test enable
```

**Note:** No need to redeploy infrastructure, script updates running Container Apps directly.

### Cost Savings

```bash
# Put environment on standby when not in use (scales to zero, keeps config)
./scripts/configure-environment.sh test standby

# Re-enable when needed
./scripts/configure-environment.sh test enable

# Disable environment completely (removes all secrets and configuration)
./scripts/configure-environment.sh test disable

# Verify what's configured
./scripts/configure-environment.sh test show
```

**Command comparison:**
- **`standby`**: Removes critical variables → apps scale to zero → quick to re-enable
- **`disable`**: Removes all configuration → complete cleanup → requires full reconfiguration

## Troubleshooting

### Container won't start

```bash
# Check logs
az containerapp logs show \
  --name ca-pravia-data-api-test \
  --resource-group rg-pravia-mule-test-eastus \
  --follow
```

### Missing environment variables

```bash
# List all variables
azd env get-values --environment test

# Verify required secrets are set
./scripts/configure-environment.sh test status
```

### Authentication issues

```bash
# Re-authenticate
az login
azd auth login

# Verify subscription
az account show
```

## Clean Up

```bash
# Remove all resources
azd down --environment test

# Complete cleanup (removes local state)
azd down --environment test --purge
```

## Next Steps

- Review [full documentation](./README.md) for advanced features
- Configure [API Gateway options](./README.md#api-gateway-options) for QA/Prod
- Set up [CI/CD pipelines](./README.md#cicd-integration)
- Review [cost optimization](./README.md#cost-optimization) strategies

## Support

- [Configuration Scripts Documentation](./scripts/README.md)
- [Azure Container Apps Docs](https://docs.microsoft.com/azure/container-apps/)
- [Azure Developer CLI Docs](https://docs.microsoft.com/azure/developer/azure-developer-cli/)
