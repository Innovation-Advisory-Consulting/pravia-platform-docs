# Self-Hosted Supabase Infrastructure

## CDK Deployment

### Interactive vs Non-Interactive Deployment

**Interactive Mode** (prompts for configuration):
```bash
cdk deploy --profile AdministratorAccess-042428207581
```
The CDK will prompt you for:
- Domain (e.g., supabase.yourdomain.com)
- Environment (development/production)
- Instance Type (t3.small/t3.medium/t3.large)
- Company/Project prefix
- Enable Load Balancer (y/N)
- SMTP credentials (optional)

**Non-Interactive Mode** (use context parameters):
```bash
cdk deploy -c stackPrefix=mycompany -c environment=production --profile AdministratorAccess-042428207581
```

### Available Parameters

Deploy with custom configuration using context parameters:

```bash
# Basic deployment with defaults
cdk deploy --profile AdministratorAccess-042428207581

# Custom company/project prefix and environment
cdk deploy -c stackPrefix=mycompany -c environment=production --profile AdministratorAccess-042428207581

# Custom domain
cdk deploy -c domain=custom.example.com --profile AdministratorAccess-042428207581

# Larger instance type
cdk deploy -c instanceType=t3.large --profile AdministratorAccess-042428207581

# Disable load balancer (saves ~$40/month)
cdk deploy -c enableLoadBalancer=false --profile AdministratorAccess-042428207581

# Production configuration with company prefix
cdk deploy -c stackPrefix=mycompany -c environment=production -c instanceType=t3.large -c ebsVolumeSize=50 -c enableBackups=true -c enableCloudWatch=true --profile AdministratorAccess-042428207581

# Restricted network access
cdk deploy -c allowedCidrs=10.0.0.0/8,192.168.0.0/16 --profile AdministratorAccess-042428207581

# Email alerts
cdk deploy -c enableEmailAlerts=true -c alertEmail=your@email.com --profile AdministratorAccess-042428207581

# Disable monitoring (saves ~$3/month)
cdk deploy -c enableMonitoring=false --profile AdministratorAccess-042428207581

# SMTP credentials (optional - can be set manually later)
cdk deploy -c smtpUsername=AKIAEXAMPLE -c smtpPassword=secretkey --profile AdministratorAccess-042428207581
```

### Configuration Defaults
- **stackPrefix**: pravia (creates stack: pravia-supabase-development)
- **environment**: development
- **domain**: iam.pravia.demo.asyml8.com
- **instanceType**: t3.medium
- **enableLoadBalancer**: true
- **sesNoReplyEmail**: no-reply@asyml8.com
- **sesDomain**: asyml8.com
- **ebsVolumeSize**: 20 GB
- **allowedCidrs**: 0.0.0.0/0
- **enableBackups**: false
- **enableCloudWatch**: false
- **enableMonitoring**: true
- **enableEmailAlerts**: false
- **smtpUsername**: undefined (manual setup required)
- **smtpPassword**: undefined (manual setup required)

**Estimated monthly cost with defaults**: ~$79 (includes monitoring)

## ⚠️ CRITICAL: Manual SMTP Configuration Required

**After deployment, you MUST manually configure SMTP credentials for email functionality:**

### Step 1: Create SES SMTP Credentials
1. Go to AWS Console → SES → SMTP Settings
2. Click "Create SMTP Credentials"
3. Note the SMTP username and password

### Step 2: Configure Supabase SMTP
SSH into the instance and update the Docker environment file:

File: `/home/ubuntu/supabase/docker/.env`

**SMTP Configuration (Required for email functionality):**
```bash
SMTP_ADMIN_EMAIL=no-reply@asyml8.com
SMTP_HOST=email-smtp.us-east-1.amazonaws.com
SMTP_PORT=587
SMTP_USER=<YOUR_SES_SMTP_USERNAME>
SMTP_PASS=<YOUR_SES_SMTP_PASSWORD>
SMTP_SENDER_NAME=Asyml8
```

**URL Configuration (Domain/API access):**
```bash
API_EXTERNAL_URL=https://iam.pravia.demo.asyml8.com
SUPABASE_PUBLIC_URL=https://iam.pravia.demo.asyml8.com
SITE_URL=https://iam.pravia.demo.asyml8.com
```

### Step 3: Restart Auth Container
```bash
cd /home/ubuntu/supabase/docker
docker compose stop auth && docker compose rm -f auth && docker compose up -d auth
```

## Essential Configuration

**Domain**: https://iam.pravia.demo.asyml8.com
**Basic Auth**: Username `supabase`, Password `this_password_is_insecure_and_should_be_updated`

## Access URLs

- **Admin UI**: https://iam.pravia.demo.asyml8.com
- **API Base**: https://iam.pravia.demo.asyml8.com
- **Auth API**: https://iam.pravia.demo.asyml8.com/auth/v1/
- **REST API**: https://iam.pravia.demo.asyml8.com/rest/v1/

## CI/CD Deployment

```bash
#!/bin/bash
# Deploy Supabase infrastructure
cd infra/aws/cdk/supabase-infra
cdk deploy --profile AdministratorAccess-042428207581 --require-approval never

# Post-deployment: Update SMTP credentials via SSM
INSTANCE_ID=$(aws cloudformation describe-stacks --stack-name pravia-supabase-development \
  --query 'Stacks[0].Outputs[?OutputKey==`InstanceId`].OutputValue' --output text)

aws ssm send-command --instance-ids $INSTANCE_ID --document-name "AWS-RunShellScript" \
  --parameters 'commands=[
    "cd /home/ubuntu/supabase/docker",
    "sed -i \"s/SMTP_USER=.*/SMTP_USER=$SES_SMTP_USER/\" .env",
    "sed -i \"s/SMTP_PASS=.*/SMTP_PASS=$SES_SMTP_PASS/\" .env",
    "docker compose stop auth && docker compose rm -f auth && docker compose up -d auth"
  ]'
```

## CDK Stack Outputs

After deployment, you'll see outputs similar to these:

### Core Infrastructure Outputs
```
DomainURL = https://iam.pravia.demo.asyml8.com
DirectAccessURL = http://54.123.45.67:8000
LoadBalancerURL = http://pravia-applicationloadbalancer-1234567890.us-east-1.elb.amazonaws.com
CertificateArn = arn:aws:acm:us-east-1:042428207581:certificate/56843d02-35ee-4110-bea4-816167730ecc
```

### Instance Management Outputs
```
SSHCommand = aws ssm start-session --target i-047fbfb893664b3bf --region us-east-1
SupabaseControlScript = /home/ubuntu/supabase-control.sh {start|stop|restart|status|logs}
InstanceType = t3.medium
```

### Storage & Email Outputs
```
S3StorageBucket = supabase-development-supabase-storage-042428207581
S3BucketArn = arn:aws:s3:::supabase-development-supabase-storage-042428207581
SESIdentityOutput = no-reply@asyml8.com
SESRegion = us-east-1
SESVerificationRecord = _amazonses.asyml8.com TXT (configured in Foundation stack)
SESDKIMRecords = Check SES Console for asyml8.com DKIM records
```

### Monitoring Outputs (if enabled)
```
DashboardURL = https://us-east-1.console.aws.amazon.com/cloudwatch/home?region=us-east-1#dashboards:name=pravia-supabase-development-monitoring
AlertTopicArn = arn:aws:sns:us-east-1:042428207581:pravia-supabase-development-alerts
MonitoringCost = ~$5-6/month (dashboard + alarms + SNS + email)
```

### Cost Estimates
```
EstimatedMonthlyCost = $76/month (medium + 20GB + LB)
# OR without load balancer:
EstimatedMonthlyCost = $32/month (medium + 20GB)
```

### Post-Deployment Instructions
```
PostDeploymentSteps = ⚠️ CRITICAL: Manual steps required for email functionality

NextSteps = 
1. Wait 3-5 minutes for services to start
2. Access Supabase Studio: https://iam.pravia.demo.asyml8.com
3. Default login: supabase / this_password_is_insecure_and_should_be_updated
4. Configure SMTP: cat /home/ubuntu/SETUP-EMAIL.md
5. Test user registration and email invites
6. Update default passwords in production

ManagementCommands = 
SSH: aws ssm start-session --target i-047fbfb893664b3bf
Control: /home/ubuntu/supabase-control.sh {start|stop|restart|status|logs}
Logs: tail -f /var/log/user-data.log
```

## PostgreSQL Remote Access

**Connection Details:**
- **Host:** Use `DirectAccessURL` IP from stack outputs (e.g., `13.220.4.28`)
- **Port:** `5432`
- **Database:** `postgres`
- **User:** `postgres`
- **Password:** `your-super-secret-and-long-postgres-password`

**Connection Methods:**
```bash
# Command line
psql -h 13.220.4.28 -p 5432 -U postgres -d postgres

# Connection string
postgresql://postgres:your-super-secret-and-long-postgres-password@13.220.4.28:5432/postgres

# Get current credentials
aws ssm send-command --instance-ids i-047fbfb893664b3bf \
  --document-name "AWS-RunShellScript" \
  --parameters 'commands=["grep POSTGRES_PASSWORD /home/ubuntu/supabase/docker/.env"]'
```

**Security:** Current setup allows global access (`0.0.0.0/0`). To restrict:
```bash
# Restrict to your IP only
cdk deploy -c allowedCidrs="$(curl -s ifconfig.me)/32" --profile dev
```

## Instance Management

```bash
# Connect via Session Manager
aws ssm start-session --target i-047fbfb893664b3bf --region us-east-1

# Control script
/home/ubuntu/supabase-control.sh [start|stop|restart|status|logs]
```
