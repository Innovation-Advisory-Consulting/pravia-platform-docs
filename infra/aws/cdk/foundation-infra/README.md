# Pravia Foundation Stack

[← Back to Deployment Guide](../../../docs/infrastructure/README.md)

The foundation stack provides long-lived, shared infrastructure resources that support multiple Pravia applications.

## Current Status

⚠️ **Note**: The foundation resources already exist in the AWS account but are not managed by this CDK stack. The Supabase stack currently references these existing resources directly:

- **Route53 Hosted Zone**: `asyml8.com` (Z09388692KF0FZORR25QJ)
- **SSL Certificate**: `iam.pravia.demo.asyml8.com` 
- **S3 Storage Bucket**: `supabase-development-supabase-storage-042428207581`
- **SES Domain**: `asyml8.com`

To use this Foundation stack for new environments, deploy it first, then update the Supabase stack to use cross-stack references.

## Purpose & Value

The foundation stack establishes the core infrastructure that remains stable across application deployments. By separating foundational resources from application-specific infrastructure, you can safely redeploy applications without risking DNS outages, SSL certificate issues, or email delivery problems.

This architecture follows AWS best practices for multi-environment deployments, allowing you to share expensive resources (like Route53 hosted zones) across development, staging, and production while maintaining isolation where needed. The foundation stack typically deploys once and rarely changes, reducing operational overhead and deployment risks.

## 🏗️ What's Included

### **🌐 DNS & SSL**
- Route53 Hosted Zone (configurable domain)
- SSL Certificate (optional, configurable subdomain)
- Automatic DNS validation

### **📧 Email Infrastructure**
- SES Domain Identity (optional, configurable domain)
- DKIM signing configuration
- Email verification setup

### **💾 Storage**
- S3 Bucket for file storage (optional)
- Configurable versioning and lifecycle policies
- Retention protection

## 🚀 Deployment

### **Development Deployment**
```bash
cd infra/aws/cdk/foundation-infra
cdk deploy \
  --context environment=development \
  --context domain=dev-api.myapp.com \
  --context sesDomain=myapp.com \
  --context enableEncryption=false \
  --context enableAccessLogging=false \
  --context enableTransferAcceleration=false \
  --context removalPolicy=DESTROY \
  --context storageRetentionDays=7 \
  --context enableVersioning=false \
  --context enableLifecyclePolicy=false
```

### **Production Deployment**
```bash
cd infra/aws/cdk/foundation-infra
cdk deploy \
  --context environment=production \
  --context domain=api.myapp.com \
  --context sesDomain=myapp.com \
  --context enableEncryption=true \
  --context enableAccessLogging=true \
  --context enableTransferAcceleration=true \
  --context removalPolicy=RETAIN \
  --context storageRetentionDays=90 \
  --context enableVersioning=true \
  --context enableLifecyclePolicy=true
```

### **Full Configuration Example**
```bash
cdk deploy \
  --context environment=production \
  --context domain=api.myapp.com \
  --context sesDomain=myapp.com \
  --context enableSes=true \
  --context enableStorage=true \
  --context enableCertificate=true \
  --context storageRetentionDays=90 \
  --context enableVersioning=true \
  --context enableLifecyclePolicy=true \
  --context multipartUploadDays=7 \
  --context stackName=my-foundation
```

### **Environment Variables Alternative**
```bash
export ENVIRONMENT=production
export DOMAIN=api.myapp.com
export SES_DOMAIN=myapp.com
export ENABLE_SES=true
export ENABLE_STORAGE=true
export ENABLE_CERTIFICATE=true
export STORAGE_RETENTION_DAYS=90
export ENABLE_VERSIONING=true
export ENABLE_LIFECYCLE_POLICY=true
export MULTIPART_UPLOAD_DAYS=7
export STACK_NAME=my-foundation

cdk deploy
```

## ⚙️ Configuration Options

| Flag | Default | Description |
|------|---------|-------------|
| `environment` | `development` | Environment name (dev/staging/prod) |
| `domain` | `iam.pravia.demo.asyml8.com` | Full subdomain for SSL certificate |
| `sesDomain` | `asyml8.com` | Root domain for SES email identity |
| `enableSes` | `true` | Create SES email identity |
| `enableStorage` | `true` | Create S3 storage bucket |
| `enableCertificate` | `true` | Create SSL certificate |
| `storageRetentionDays` | `30` | Days to keep old object versions |
| `enableVersioning` | `true` | Enable S3 object versioning |
| `enableLifecyclePolicy` | `true` | Enable S3 lifecycle rules |
| `multipartUploadDays` | `7` | Days before cleaning incomplete uploads |
| `enableEncryption` | `true` | Enable S3 server-side encryption |
| `enableAccessLogging` | `false` | Enable S3 access logging |
| `enableTransferAcceleration` | `false` | Enable S3 transfer acceleration |
| `removalPolicy` | `RETAIN` | Stack removal policy (RETAIN/DESTROY) |
| `stackName` | `pravia-foundation-{environment}` | CloudFormation stack name |

### **Flag Details**

**Core Configuration:**
- `environment` - Used in resource naming and stack identification
- `domain` - The full subdomain where your app runs (e.g., `api.myapp.com`)
- `sesDomain` - The root domain for email sending (e.g., `myapp.com`)
- `stackName` - Override the default stack naming pattern

**Cost Optimization:**
- `enableSes` - Skip SES (~$0/month savings for dev environments)
- `enableStorage` - Skip S3 bucket (~$1/month savings for minimal setups)
- `enableCertificate` - Skip SSL cert (free, but reduces complexity)
- `enableEncryption` - Disable for dev (faster performance, no cost impact)
- `enableAccessLogging` - Disable for dev/staging (reduces log storage costs)
- `enableTransferAcceleration` - Disable for dev/staging (saves $0.04/GB)

**Storage Cost Controls:**
- `storageRetentionDays` - Lower values = less storage cost for old versions
- `enableVersioning` - Disable to avoid storing multiple object versions
- `enableLifecyclePolicy` - Disable to skip automatic cleanup rules
- `multipartUploadDays` - Faster cleanup = lower storage costs
- `removalPolicy` - DESTROY for dev (easy cleanup), RETAIN for prod (data safety)

## 🎯 Environment Presets

### **Development (Cost-Optimized)**
```bash
cdk deploy --context environment=development
```
- Includes: SES, SSL, S3 (minimum requirements)
- 7-day retention, no versioning, no lifecycle policies
- Cost: ~$1.50/month

### **Staging**
```bash
cdk deploy --context environment=staging
```
- Includes: All features with moderate retention
- 7-day retention, no versioning
- Cost: ~$2/month

### **Production (Full Features)**
```bash
cdk deploy --context environment=production
```
- Includes: All features with full data protection
- 90-day retention, versioning enabled, lifecycle policies
- Cost: ~$3-5/month (depends on usage)

## 📋 Post-Deployment Steps

### **1. DNS Configuration**
After deployment, configure your domain registrar:

```bash
# Get nameservers from Route53 console or CDK output
# Update your root domain nameservers to point to Route53
```

### **2. SES Email Setup**
```bash
# Get DKIM tokens
aws ses get-identity-dkim-attributes --identities {sesDomain} --region us-east-1

# Add DKIM CNAME records to your DNS:
# [token1]._domainkey.{sesDomain} → [token1].dkim.amazonses.com
# [token2]._domainkey.{sesDomain} → [token2].dkim.amazonses.com  
# [token3]._domainkey.{sesDomain} → [token3].dkim.amazonses.com
```

### **3. Create SMTP Credentials (Manual)**
SMTP credentials cannot be created via IaC and must be done manually:

```bash
# 1. Go to AWS Console → SES → SMTP Settings
# 2. Click "Create SMTP Credentials"
# 3. Enter IAM User Name (e.g., ses-smtp-user-{environment})
# 4. Download credentials CSV file
# 5. Store credentials securely (AWS Secrets Manager, etc.)

# SMTP Endpoint: email-smtp.us-east-1.amazonaws.com
# Port: 587 (TLS) or 465 (SSL)
```

## ⚠️ CRITICAL: Post-Deployment Email Setup

**🚨 EMAIL WILL NOT WORK UNTIL YOU COMPLETE THIS MANUAL STEP 🚨**

**Why manual?** AWS SES SMTP credentials can ONLY be created through the AWS Console - they cannot be automated via CDK/CloudFormation.

### Step 1: Create SES SMTP Credentials
1. **AWS Console** → **SES** → **SMTP Settings** → **"Create SMTP Credentials"**
2. **IAM User Name**: Use `ses-smtp-user-{environment}` format
3. **Download credentials** (Username starts with `AKIA...`)

### Step 2: Configure Your Application
```bash
# Use the downloaded SMTP credentials in your application:
SMTP_HOST=email-smtp.us-east-1.amazonaws.com
SMTP_PORT=587
SMTP_USER=YOUR_SMTP_USERNAME  # From downloaded CSV
SMTP_PASS=YOUR_SMTP_PASSWORD  # From downloaded CSV
```

### Step 3: Test Email Functionality
```bash
# Test that SES can send emails using your SMTP credentials
# Implementation depends on your application framework
```

## 🔗 Cross-Stack Usage

Other stacks reference foundation resources:

```typescript
// Import hosted zone
const hostedZone = route53.HostedZone.fromHostedZoneId(this, 'HostedZone',
  cdk.Fn.importValue('{stackName}-HostedZoneId'));

// Import certificate (if enabled)
const certificate = acm.Certificate.fromCertificateArn(this, 'Certificate',
  cdk.Fn.importValue('{stackName}-CertificateArn'));

// Import storage bucket (if enabled)
const bucket = s3.Bucket.fromBucketName(this, 'StorageBucket',
  cdk.Fn.importValue('{stackName}-StorageBucketName'));
```

## 🗑️ Cleanup

**⚠️ Warning**: Destroying the foundation stack will break all dependent applications.

```bash
# Only destroy if removing ALL infrastructure
cdk destroy {stackName}
```

## 📤 Outputs

The foundation stack exports these values for other stacks:

- `{stackName}-HostedZoneId` (always created)
- `{stackName}-CertificateArn` (if `enableCertificate=true`)
- `{stackName}-StorageBucketName` (if `enableStorage=true`)
- `{stackName}-StorageBucketArn` (if `enableStorage=true`)
- `{stackName}-SESIdentityName` (if `enableSes=true`)
