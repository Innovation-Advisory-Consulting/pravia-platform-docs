# Bicep Configuration Updates - Database Support

## Changes Made

Updated Azure Bicep templates to include database configuration for Pravia Foundry API.

### Files Modified

1. **`infra/modules/containerApp.bicep`**
   - Added database parameters
   - Added database password to secrets
   - Added database environment variables

2. **`infra/main.bicep`**
   - Updated `authContainerApp` module with database parameters
   - Added Supabase credentials
   - Configured for `external_authentication` schema

---

## New Parameters in containerApp.bicep

```bicep
@description('Database enabled flag')
param databaseEnabled string = 'false'

@description('Database host')
param databaseHost string = ''

@description('Database port')
param databasePort string = '5432'

@description('Database username')
param databaseUsername string = ''

@description('Database password')
@secure()
param databasePassword string = ''

@description('Database name')
param databaseName string = 'postgres'

@description('Database schema name')
param databaseSchemaName string = 'external_authentication'
```

---

## Auth Container App Configuration

```bicep
module authContainerApp 'modules/containerApp.bicep' = {
  params: {
    // ... existing params ...
    supabaseUrl: supabaseUrl
    supabaseAnonKey: supabaseAnonKey
    supabaseServiceKey: supabaseServiceKey
    databaseEnabled: 'true'
    databaseHost: 'aws-1-us-east-2.pooler.supabase.com'
    databasePort: '5432'
    databaseUsername: 'postgres.kcoscwspccqppdoqnsdm'
    databasePassword: 'pfm!qpa8ZJW8qfn8zhu'
    databaseName: 'postgres'
    databaseSchemaName: 'external_authentication'
  }
}
```

---

## Environment Variables Set

The following environment variables are now automatically configured:

- `DATABASE_ENABLED=true`
- `DATABASE_HOST=aws-1-us-east-2.pooler.supabase.com`
- `DATABASE_PORT=5432`
- `DATABASE_USERNAME=postgres.kcoscwspccqppdoqnsdm`
- `DATABASE_PASSWORD=secretref:database-password`
- `DATABASE_DB_NAME=postgres`
- `DATABASE_SCHEMA_NAME=external_authentication`

---

## Secrets Management

Database password is stored as a secret:
```bicep
{
  name: 'database-password'
  value: databasePassword
}
```

Referenced in environment variables:
```bicep
{
  name: 'DATABASE_PASSWORD'
  secretRef: 'database-password'
}
```

---

## Deployment

Future deployments using `azd up` will automatically include database configuration:

```bash
cd infra/azure/pravia-mule
azd up --environment dev
```

Or from monorepo root:
```bash
pnpm azure:up:dev
```

---

## Security Notes

⚠️ **Database password is hardcoded in bicep for dev environment**

For production:
1. Store password in Azure Key Vault
2. Reference Key Vault secret in bicep
3. Use managed identities where possible

Example for production:
```bicep
databasePassword: keyVault.getSecret('database-password')
```

---

## Testing

After bicep deployment, verify:

```bash
# Check environment variables
az containerapp show \
  --name ca-pravia-auth-api-dev \
  --resource-group rg-pravia-mule-dev-eastus \
  --query "properties.template.containers[0].env[?name=='DATABASE_ENABLED']"

# Test database health
curl https://ca-pravia-auth-api-dev.graybay-593c9998.eastus.azurecontainerapps.io/api/health/database
```

---

## Rollback

If issues occur, set `databaseEnabled: 'false'` in main.bicep and redeploy.

---

## Next Steps

- [ ] Move database password to Key Vault for production
- [ ] Add database connection pooling parameters
- [ ] Configure TypeORM logging levels per environment
- [ ] Add database migration automation
- [ ] Set up database backup strategy
