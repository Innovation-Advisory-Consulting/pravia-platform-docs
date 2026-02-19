# Infrastructure as Code

This directory contains infrastructure definitions for deploying the Pravia CRM Platform across multiple cloud providers and orchestration platforms.

## Directory Structure

```
infra/
├── aws/            # AWS infrastructure (CDK)
├── azure/          # Azure infrastructure (Bicep)
├── compose/        # Docker Compose configurations
├── docker/         # Dockerfiles and container configs
└── k8s/            # Kubernetes manifests
```

---

## 1. AWS Infrastructure (CDK)

**Purpose:** AWS Cloud Development Kit (CDK) stacks for deploying Pravia infrastructure on AWS.

**Location:** `infra/aws/cdk/`

### CDK Stacks

#### Foundation Stack
**Path:** `infra/aws/cdk/foundation-infra/`

**Purpose:** Long-lived, shared infrastructure resources that support multiple applications.

**What's Included:**
- **DNS & SSL**
  - Route53 Hosted Zone (configurable domain)
  - SSL Certificate with automatic DNS validation
- **Email Infrastructure**
  - SES Domain Identity
  - DKIM signing configuration
  - Email verification setup
- **Storage**
  - S3 Bucket for file storage
  - Versioning and lifecycle policies
  - Retention protection

**Deployment:**
```bash
cd infra/aws/cdk/foundation-infra
cdk deploy \
  --context environment=development \
  --context domain=dev-api.myapp.com \
  --context sesDomain=myapp.com
```

**Why Separate?**
Foundation resources remain stable across application deployments. You can safely redeploy applications without risking DNS outages, SSL issues, or email delivery problems.

**Current Status:**
⚠️ Foundation resources already exist in AWS but are not managed by CDK. Supabase stack references them directly.

**Documentation:** `infra/aws/cdk/foundation-infra/README.md`

---

#### Supabase Stack
**Path:** `infra/aws/cdk/supabase-infra/`

**Purpose:** Self-hosted Supabase infrastructure on AWS EC2.

**What's Included:**
- EC2 instance running Supabase Docker containers
- VPC with public/private subnets
- Security groups and network configuration
- EBS volumes for data persistence
- Optional Application Load Balancer
- CloudWatch monitoring and alarms
- Automated backups (optional)

**Deployment Modes:**

**Interactive Mode:**
```bash
cdk deploy --profile AdministratorAccess-042428207581
```
Prompts for:
- Domain (e.g., supabase.yourdomain.com)
- Environment (development/production)
- Instance Type (t3.small/t3.medium/t3.large)
- Company/Project prefix
- Enable Load Balancer (y/N)
- SMTP credentials (optional)

**Non-Interactive Mode:**
```bash
cdk deploy \
  -c stackPrefix=mycompany \
  -c environment=production \
  -c instanceType=t3.large \
  -c enableLoadBalancer=false \
  --profile AdministratorAccess-042428207581
```

**Available Parameters:**
- `stackPrefix` - Company/project prefix
- `environment` - development/production
- `domain` - Custom domain
- `instanceType` - t3.small/t3.medium/t3.large
- `ebsVolumeSize` - EBS volume size (GB)
- `enableLoadBalancer` - Enable ALB (saves ~$40/month if disabled)
- `enableBackups` - Enable automated backups
- `enableCloudWatch` - Enable CloudWatch monitoring
- `allowedCidrs` - Restrict network access
- `alertEmail` - Email for CloudWatch alarms

**Cost Optimization:**
- Disable Load Balancer for development (saves ~$40/month)
- Use t3.small for development, t3.large for production
- Enable backups only in production

**Documentation:**
- `infra/aws/cdk/supabase-infra/README.md` - Main documentation
- `infra/aws/cdk/supabase-infra/README-MODULAR.md` - Modular architecture

---

#### API Infrastructure Stacks

**Deprecated/Legacy Stacks:**
- `auth-api-infra/` - Authentication API infrastructure
- `compliance-api-infra/` - Compliance API infrastructure
- `data-api-infra/` - Data API infrastructure
- `platform-api-infra/` - Platform API infrastructure

**Note:** These stacks are legacy. Current deployment uses Azure Container Apps (see `deploy/api/`).

---

## 2. Azure Infrastructure (Bicep)

**Purpose:** Azure infrastructure definitions using Bicep templates.

**Location:** `infra/azure/`

### Azure Projects

#### Pravia Mule
**Path:** `infra/azure/pravia-mule/`

**Purpose:** Main Pravia CRM platform infrastructure on Azure.

**What's Included:**
- Azure Container Apps for APIs
- Azure Container Registry
- Virtual Network and subnets
- Application Insights
- Log Analytics Workspace
- Managed Identity
- Key Vault (optional)

**Deployment:**
```bash
cd infra/azure/pravia-mule
az deployment group create \
  --resource-group rg-pravia-mule-dev \
  --template-file infra/main.bicep \
  --parameters infra/main.parameters.json
```

**Configuration:**
- `infra/main.bicep` - Main Bicep template (14KB)
- `infra/main.parameters.json` - Parameters file
- `infra/modules/` - Reusable Bicep modules
- `scripts/configure-environment.sh` - Environment setup script (24KB)

**Documentation:**
- `infra/azure/pravia-mule/README.md` - Main documentation (16KB)
- `infra/azure/pravia-mule/QUICKSTART.md` - Quick start guide (8KB)
- `infra/azure/pravia-mule/BICEP_UPDATES.md` - Bicep updates log

---

#### Pravia Incidents
**Path:** `infra/azure/pravia-incidents/`

**Purpose:** Incidents management system infrastructure on Azure.

**What's Included:**
- Azure Container Apps for Incidents API
- Azure Container Registry
- Virtual Network
- Application Insights
- Managed Identity

**Deployment:**
```bash
cd infra/azure/pravia-incidents
az deployment group create \
  --resource-group rg-pravia-incidents-dev \
  --template-file infra/main.bicep \
  --parameters infra/main.parameters.json
```

**Configuration:**
- `infra/main.bicep` - Main Bicep template (14KB)
- `infra/main.parameters.json` - Parameters file
- `infra/modules/` - Reusable Bicep modules
- `scripts/configure-environment.sh` - Environment setup script (13KB)

**Documentation:**
- `infra/azure/pravia-incidents/README.md` - Main documentation (16KB)
- `infra/azure/pravia-incidents/scripts/README.md` - Scripts documentation

---

## 3. Docker Compose

**Purpose:** Local development and testing with Docker Compose.

**Location:** `infra/compose/`

### Compose Configurations

#### Development Compose
**File:** `infra/compose/docker-compose.dev.yml`

**Purpose:** Local development environment with all services.

**Services:**
- APIs (Foundry, Flux, Incidents)
- PostgreSQL database
- Supabase (optional)
- n8n (optional)

**Usage:**
```bash
docker compose -f infra/compose/docker-compose.dev.yml up -d
```

---

#### Supabase Compose
**Path:** `infra/compose/supabase/`

**Purpose:** Self-hosted Supabase for local development.

**Services:**
- Supabase Studio
- PostgreSQL database
- PostgREST API
- GoTrue (auth)
- Realtime server
- Storage API
- Kong API Gateway

**Usage:**
```bash
cd infra/compose/supabase
./start-local.sh
```

**Configuration:**
- `docker-compose.yml` - Supabase services (12KB)
- `.env.example` - Environment template
- `start-local.sh` - Startup script
- `volumes/` - Persistent data

**Access:**
- Studio: http://localhost:54323
- API: http://localhost:54321
- Database: postgresql://postgres:postgres@localhost:54322/postgres

**Documentation:** `infra/compose/supabase/README.md` (15KB)

---

## 4. Docker

**Purpose:** Dockerfiles for building container images.

**Location:** `infra/docker/`

### Dockerfiles

- `auth-api.Dockerfile` - Foundry API container
- `data-api.Dockerfile` - Flux API container
- `platform-api.Dockerfile` - Platform API container (legacy)
- `gateway-api.Dockerfile` - Gateway API container (legacy)

### Compose Files

- `docker-compose.minimal.yml` - Minimal setup (APIs only)
- `docker-compose.pgadmin.yml` - PostgreSQL admin interface
- `docker-compose.supabase.yml` - Supabase reference

**Note:** Individual API Dockerfiles are now located in each API directory (e.g., `api/foundry/Dockerfile`).

---

## 5. Kubernetes

**Purpose:** Kubernetes manifests for container orchestration.

**Location:** `infra/k8s/`

**Current Status:** Minimal configuration

**Files:**
- `namespace.yaml` - Kubernetes namespace definition

**Note:** Kubernetes deployment is not actively used. Current deployment targets are Azure Container Apps and AWS ECS.

---

## Infrastructure Architecture

### Multi-Cloud Strategy

**AWS:**
- Foundation infrastructure (DNS, SSL, Email, Storage)
- Self-hosted Supabase on EC2
- CloudWatch monitoring

**Azure:**
- Container Apps for APIs (Foundry, Flux, Incidents)
- Container Registry
- Application Insights
- Log Analytics

**Why Multi-Cloud?**
- Leverage best services from each provider
- Avoid vendor lock-in
- Cost optimization
- Regional availability

### Deployment Targets

| Component | Platform | Tool |
|-----------|----------|------|
| Foundation (DNS, SSL, Email) | AWS | CDK |
| Supabase | AWS EC2 | CDK |
| APIs (Foundry, Flux, Incidents) | Azure Container Apps | Bicep |
| Frontend (mule-vite) | Azure Static Web Apps | GitHub Actions |
| Local Development | Docker Compose | Docker |

---

## Development Workflow

### Local Development

**Start all services:**
```bash
# Supabase
cd infra/compose/supabase
./start-local.sh

# n8n
pnpm n8n:start

# APIs
cd api/foundry && pnpm dev
cd api/flux && pnpm dev

# Frontend
cd apps/mule-vite && pnpm dev
```

### AWS Deployment

**Deploy Foundation:**
```bash
cd infra/aws/cdk/foundation-infra
cdk deploy --context environment=development
```

**Deploy Supabase:**
```bash
cd infra/aws/cdk/supabase-infra
cdk deploy --profile AdministratorAccess-042428207581
```

### Azure Deployment

**Deploy APIs:**
```bash
# Foundry API
cd api/foundry/deploy
./deploy-azure-dev.sh

# Flux API
cd api/flux/deploy
./deploy-azure-dev.sh
```

**Deploy Frontend:**
```bash
# Automatic via GitHub Actions on push to main
# Or manual:
cd apps/mule-vite
pnpm build
# Deploy to Azure Static Web Apps
```

---

## Cost Estimation

### AWS Costs (Monthly)

| Resource | Development | Production |
|----------|-------------|------------|
| Route53 Hosted Zone | $0.50 | $0.50 |
| SSL Certificate | Free | Free |
| SES (Email) | $0.10/1000 emails | Variable |
| S3 Storage | $0.023/GB | $0.023/GB |
| EC2 (Supabase) t3.small | ~$15 | - |
| EC2 (Supabase) t3.large | - | ~$60 |
| EBS Volume (50GB) | $5 | $5 |
| Application Load Balancer | $16 | $16 |
| **Total (without ALB)** | **~$21** | **~$66** |
| **Total (with ALB)** | **~$37** | **~$82** |

### Azure Costs (Monthly)

| Resource | Development | Production |
|----------|-------------|------------|
| Container Apps (3 APIs) | ~$30 | ~$100 |
| Container Registry | $5 | $5 |
| Application Insights | $2 | $10 |
| Static Web Apps | Free | Free |
| **Total** | **~$37** | **~$115** |

### Total Platform Cost

| Environment | AWS | Azure | Total |
|-------------|-----|-------|-------|
| Development | ~$21 | ~$37 | **~$58/month** |
| Production | ~$66 | ~$115 | **~$181/month** |

**Cost Optimization Tips:**
- Disable ALB in development (saves $16/month)
- Use t3.small for Supabase in development
- Scale down Container Apps when not in use
- Use Azure Free Tier for Static Web Apps

---

## Security Best Practices

### Network Security
- Use VPCs/VNets with private subnets
- Restrict security groups to necessary ports
- Use CIDR restrictions for sensitive services
- Enable VPN or bastion hosts for SSH access

### Secrets Management
- Use AWS Secrets Manager or Azure Key Vault
- Never commit secrets to git
- Rotate credentials regularly
- Use managed identities where possible

### Monitoring
- Enable CloudWatch/Application Insights
- Set up alerts for critical metrics
- Monitor costs and usage
- Enable audit logging

### Backup and Recovery
- Enable automated backups for databases
- Test restore procedures regularly
- Use versioning for S3 buckets
- Document disaster recovery procedures

---

## Troubleshooting

### CDK Deployment Issues

**Issue:** CDK bootstrap required
```bash
cdk bootstrap aws://ACCOUNT-ID/REGION --profile PROFILE_NAME
```

**Issue:** Context values not applied
```bash
# Clear CDK context
rm cdk.context.json
cdk deploy -c key=value
```

### Azure Deployment Issues

**Issue:** Bicep validation fails
```bash
# Validate template
az deployment group validate \
  --resource-group rg-name \
  --template-file main.bicep
```

**Issue:** Container App not starting
```bash
# Check logs
az containerapp logs show \
  --name app-name \
  --resource-group rg-name
```

### Docker Compose Issues

**Issue:** Port conflicts
```bash
# Check ports in use
docker ps
netstat -an | grep LISTEN
```

**Issue:** Volume permissions
```bash
# Fix permissions
sudo chown -R $USER:$USER volumes/
```

---

## Related Documentation

- [Deployment Guide](../docs/infrastructure/README.md)
- [Monitoring & Dashboards](../docs/infrastructure/monitoring.md)
- [Cost Estimation](../docs/infrastructure/cost-estimation.md)
- [API Deployment](../deploy/api/API-DEPLOYMENT.md)
- [Environment Standards](../docs/development/ENVIRONMENT_STANDARDS.md)
