# Infrastructure & Deployment

[← Back to Main](../../README.md) | [📋 All Docs](../../README.md#-quick-navigation)

## Two-Stack Architecture

Pravia uses a **foundation + application** deployment pattern:

1. **[Foundation Stack](../../infra/aws/cdk/foundation-infra/README.md)** - Long-lived shared resources (DNS, SSL, storage)
2. **[Supabase Stack](../../infra/aws/cdk/supabase-infra/README.md)** - Application infrastructure (EC2, load balancers, monitoring)

## Step 1: Deploy Foundation (Once)
```bash
# Development environment (from project root)
pnpm foundation:deploy

# Production environment (from project root)
pnpm foundation:deploy:prod

# Manual deployment with custom parameters
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

### Foundation Stack Flags

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

**What it creates**: Route53 zone, SSL certificate, SES domain, S3 storage
**Cost**: ~$1.50/month
**Frequency**: Deploy once, rarely change

## Step 2: Deploy Supabase (Multiple Environments)

```bash
# DEVELOPMENT (from project root)
pnpm supabase:deploy:dev

# STAGING (from project root)
pnpm supabase:deploy:staging

# PRODUCTION (from project root)
pnpm supabase:deploy:prod

# Manual deployment with custom parameters
cd infra/aws/cdk/supabase-infra
cdk deploy -c environment=production \
  -c instanceType=t3.large \
  -c ebsVolumeSize=50 \
  -c enableEmailAlerts=true \
  -c alertEmail=ops@yourcompany.com
```

## All Available Flags

| Flag | Default | Description |
|------|---------|-------------|
| `environment` | `development` | Environment name (appends to stack name) |
| `domain` | `iam.pravia.demo.asyml8.com` | Custom domain |
| `instanceType` | `t3.medium` | EC2 instance size |
| `enableLoadBalancer` | `true` | Create ALB + NLB |
| `sesNoReplyEmail` | `no-reply@asyml8.com` | SES sender email |
| `sesDomain` | `asyml8.com` | SES domain identity |
| `ebsVolumeSize` | `20` | EBS volume size (GB) |
| `enableMonitoring` | `true` | CloudWatch dashboard + alarms |
| `enableEmailAlerts` | `false` | SNS notifications |
| `alertEmail` | `undefined` | Email for alerts |

## ⚠️ CRITICAL: Post-Deployment Email Setup

**🚨 EMAIL WILL NOT WORK UNTIL YOU COMPLETE THIS MANUAL STEP 🚨**

### Create SES SMTP Credentials
1. **AWS Console** → **SES** → **SMTP Settings** → **"Create SMTP Credentials"**
2. **Download credentials** (Username starts with `AKIA...`)

### Update Supabase Configuration
```bash
# SSH to your instance (get command from CDK output)
aws ssm start-session --target [instance-id] --region us-east-1

# Update with your downloaded credentials
cd /home/ubuntu/supabase/docker
sed -i 's/GOTRUE_SMTP_USER=.*/GOTRUE_SMTP_USER=YOUR_SMTP_USERNAME/' .env
sed -i 's/GOTRUE_SMTP_PASS=.*/GOTRUE_SMTP_PASS=YOUR_SMTP_PASSWORD/' .env

# Restart Supabase
/home/ubuntu/supabase-control.sh restart
```

## Post-Deployment Verification

### 1. Get Instance Details
```bash
# Get instance ID and public IP from CDK output
aws cloudformation describe-stacks --stack-name Pravia-Supabase-development \
  --query 'Stacks[0].Outputs[?OutputKey==`InstanceId`].OutputValue' --output text

aws cloudformation describe-stacks --stack-name Pravia-Supabase-development \
  --query 'Stacks[0].Outputs[?OutputKey==`PublicIP`].OutputValue' --output text
```

### 2. Verify Endpoints
```bash
# Check ALB health (should return 200)
curl -I https://studio.yourdomain.com
curl -I https://api.yourdomain.com/rest/v1/

# Check direct instance (if needed)
curl -I http://[public-ip]:3000
curl -I http://[public-ip]:8000/rest/v1/
```

### 3. Access Supabase Studio
- **URL**: `https://studio.yourdomain.com`
- **Default Login**: Check `/home/ubuntu/supabase/docker/.env` for credentials

## Instance Management

### Connect via AWS Session Manager
```bash
# Get instance ID from CDK output or CloudFormation
INSTANCE_ID=$(aws cloudformation describe-stacks --stack-name Pravia-Supabase-development \
  --query 'Stacks[0].Outputs[?OutputKey==`InstanceId`].OutputValue' --output text)

# Connect to instance
aws ssm start-session --target $INSTANCE_ID --region us-east-1
```

### Supabase Control Commands
```bash
# Connect to instance and switch to ubuntu user
aws ssm start-session --target $INSTANCE_ID --region us-east-1
sudo su - ubuntu

# Once connected as ubuntu user
./supabase-control.sh status    # Check all services
./supabase-control.sh restart   # Restart all services
./supabase-control.sh logs      # View all logs
./supabase-control.sh stop      # Stop all services
./supabase-control.sh start     # Start all services
```

### Service-Specific Operations
```bash
# Connect to instance and switch to ubuntu user
aws ssm start-session --target $INSTANCE_ID --region us-east-1
sudo su - ubuntu

# View specific service logs
cd supabase/docker
docker compose logs -f kong          # API Gateway
docker compose logs -f auth          # Authentication
docker compose logs -f rest          # REST API
docker compose logs -f realtime      # WebSocket
docker compose logs -f storage       # File storage
docker compose logs -f db            # PostgreSQL

# Restart specific service
docker compose restart kong
docker compose restart auth

# Stop all services
docker compose down

# Start all services
docker compose up -d

# Restart all services
docker compose down && docker compose up -d
```

### Database Access
```bash
# Connect to PostgreSQL directly
docker exec -it supabase-db psql -U postgres -d postgres

# View database size and connections
docker exec -it supabase-db psql -U postgres -c "
SELECT 
  datname,
  pg_size_pretty(pg_database_size(datname)) as size,
  numbackends as connections
FROM pg_stat_database 
WHERE datname NOT IN ('template0', 'template1');
"
```

### Configuration Management
```bash
# Connect to instance and switch to ubuntu user
aws ssm start-session --target $INSTANCE_ID --region us-east-1
sudo su - ubuntu

# View current configuration
cat supabase/docker/.env

# Edit configuration (restart required)
sudo nano supabase/docker/.env

# Apply changes
./supabase-control.sh restart
```

## Troubleshooting

### Common Issues

**Services not starting:**
```bash
# Check Docker status
sudo systemctl status docker

# Check disk space
df -h

# Check memory usage
free -h

# View system logs
sudo journalctl -u docker -f
```

**Health check failures:**
```bash
# Test internal connectivity
curl localhost:3000
curl localhost:8000/rest/v1/

# Check ALB target health
aws elbv2 describe-target-health --target-group-arn [target-group-arn]
```

**Email not working:**
```bash
# Verify SMTP settings
grep SMTP /home/ubuntu/supabase/docker/.env

# Test SES connectivity
aws ses verify-email-identity --email-address test@yourdomain.com --region us-east-1
```

## Email Testing

### 1. Test SES Configuration
```bash
# Verify SES domain identity status
aws ses get-identity-verification-attributes --identities yourdomain.com --region us-east-1

# Send test email via SES
aws ses send-email \
  --source no-reply@yourdomain.com \
  --destination ToAddresses=test@yourdomain.com \
  --message Subject={Data="Test Email"},Body={Text={Data="This is a test email from SES"}} \
  --region us-east-1
```

### 2. Test Supabase Auth Emails
```bash
# Connect to instance
aws ssm start-session --target $INSTANCE_ID --region us-east-1

# Test auth email via Supabase API
curl -X POST 'https://api.yourdomain.com/auth/v1/recover' \
  -H "apikey: YOUR_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{"email": "test@yourdomain.com"}'

# Check auth service logs for email sending
docker compose -f /home/ubuntu/supabase/docker/docker-compose.yml logs auth | grep -i smtp
```

### 3. Verify Email Delivery
```bash
# Check SES sending statistics
aws ses get-send-statistics --region us-east-1

# View SES bounce/complaint notifications
aws ses get-identity-notification-attributes --identities yourdomain.com --region us-east-1

# Monitor auth service for email errors
docker compose logs -f auth | grep -E "(error|fail|smtp)"
```

### 4. Common Email Issues

**SMTP Authentication Failed:**
- **"535 Authentication Credentials Invalid"**: Wrong SMTP credentials - recreate in SES Console
- Verify SMTP credentials in `/home/ubuntu/supabase/docker/.env`
- Ensure SES SMTP credentials are active in AWS console

**Email Delivery Issues:**
- **"Error sending confirmation email"**: Check SES sandbox mode, verify recipient email
- **No email received**: Check spam folder, verify domain DKIM records

**Domain Not Verified:**
- Check SES domain verification status
- Verify DKIM records are added to DNS
- **Verification Status**: Check AWS SES Console after adding DNS records
- Verification typically takes 5-10 minutes
- Both domain and DKIM must be verified for email to work

**Emails Going to Spam:**
- Set up SPF record: `v=spf1 include:amazonses.com ~all`
- Verify DKIM records are properly configured
- Consider setting up DMARC policy

### Log Locations
- **Supabase Services**: `docker compose logs`
- **System Logs**: `/var/log/cloud-init-output.log`
- **User Data Script**: `/var/log/user-data.log`
- **Docker Logs**: `sudo journalctl -u docker`

## Backup & Recovery

### Manual Database Backup
```bash
# Create backup
docker exec supabase-db pg_dump -U postgres postgres > backup-$(date +%Y%m%d).sql

# Upload to S3 (if configured)
aws s3 cp backup-$(date +%Y%m%d).sql s3://your-backup-bucket/
```

### Restore from Backup
```bash
# Download backup
aws s3 cp s3://your-backup-bucket/backup-20241205.sql ./

# Restore database
docker exec -i supabase-db psql -U postgres -d postgres < backup-20241205.sql
```

## Related Documentation
- [Cost Estimation](./cost-estimation.md) - Monthly cost breakdown
- [Monitoring & Dashboards](./monitoring.md) - CloudWatch dashboards and alerts
- [Foundation Stack Details](../../infra/aws/cdk/foundation-infra/README.md)
- [Supabase Stack Details](../../infra/aws/cdk/supabase-infra/README.md)
