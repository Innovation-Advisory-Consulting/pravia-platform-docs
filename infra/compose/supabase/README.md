# Supabase Self-Hosted Setup

This directory contains the self-hosted Supabase configuration for the Pravia CRM platform.

## Quick Start

### Local Development
```bash
# Start Supabase locally
pnpm supabase:local

# Stop Supabase
pnpm supabase:stop

# View logs
pnpm supabase:logs
```

### AWS Deployment
```bash
# Deploy to AWS
pnpm supabase:deploy

# Destroy AWS resources
pnpm supabase:destroy
```

## Architecture

### Local Development
- **Studio**: http://localhost:3000 (Web UI)
- **API**: http://localhost:8000 (REST API)
- **Database**: postgresql://postgres:supabase123@localhost:5432/postgres

### AWS Production
- **EC2 Instance**: t3.medium with Docker
- **Load Balancer**: ALB for HTTP/HTTPS traffic
- **Network Load Balancer**: For PostgreSQL access
- **S3 Storage**: File storage backend
- **SES**: Email delivery
- **Route53**: DNS management
- **ACM**: SSL certificates

## ⚠️ Critical Configuration Notes

### Environment Variable Conflicts
**IMPORTANT**: Some variables are mapped by docker-compose and should NOT be duplicated in .env:

```bash
# ❌ DON'T add these to .env (docker-compose maps them):
GOTRUE_SITE_URL                    # Mapped from SITE_URL
GOTRUE_EXTERNAL_EMAIL_ENABLED      # Mapped from ENABLE_EMAIL_SIGNUP  
GOTRUE_MAILER_AUTOCONFIRM         # Mapped from ENABLE_EMAIL_AUTOCONFIRM
GOTRUE_MAILER_URLPATHS_INVITE      # Mapped from MAILER_URLPATHS_INVITE
GOTRUE_MAILER_URLPATHS_CONFIRMATION # Mapped from MAILER_URLPATHS_CONFIRMATION
GOTRUE_MAILER_URLPATHS_RECOVERY    # Mapped from MAILER_URLPATHS_RECOVERY
GOTRUE_MAILER_URLPATHS_EMAIL_CHANGE # Mapped from MAILER_URLPATHS_EMAIL_CHANGE

# ✅ DO add these source variables to .env:
SITE_URL=https://your-domain.com
ENABLE_EMAIL_SIGNUP=true
ENABLE_EMAIL_AUTOCONFIRM=false
MAILER_URLPATHS_INVITE="/auth/v1/verify"
MAILER_URLPATHS_CONFIRMATION="/auth/v1/verify"
MAILER_URLPATHS_RECOVERY="/auth/v1/verify"
MAILER_URLPATHS_EMAIL_CHANGE="/auth/v1/verify"

# ✅ Direct GOTRUE variables (OK in .env):
GOTRUE_SMTP_HOST=email-smtp.us-east-1.amazonaws.com
GOTRUE_SMTP_PORT=587
GOTRUE_SMTP_SECURE=true
GOTRUE_SMTP_USER=YOUR_USERNAME
GOTRUE_SMTP_PASS=YOUR_PASSWORD
GOTRUE_SMTP_ADMIN_EMAIL=no-reply@yourdomain.com
GOTRUE_SMTP_SENDER_NAME=Your App Name
```

### Production Domain Configuration
For production deployments, ensure these match your domain:
```bash
SITE_URL=https://your-domain.com
API_EXTERNAL_URL=https://your-domain.com
SUPABASE_PUBLIC_URL=https://your-domain.com
```

### Email Configuration (AWS SES)
After deployment, you MUST manually create SES SMTP credentials:
1. AWS Console → SES → SMTP Settings → "Create SMTP Credentials"
2. Use the IAM user from CDK output `SESSmtpUser`
3. Update .env with downloaded credentials
4. Restart services: `/home/ubuntu/supabase-control.sh restart`

## Services

| Service | Port | Description |
|---------|------|-------------|
| Studio | 3000 | Supabase Dashboard |
| Kong | 8000 | API Gateway |
| Auth | 9999 | Authentication service |
| REST | 3000 | PostgREST API |
| Realtime | 4000 | Real-time subscriptions |
| Storage | 5000 | File storage API |
| Database | 5432 | PostgreSQL |
| Analytics | 4000 | Logflare analytics |

## Configuration

### Environment Variables
The `.env` file contains all necessary configuration. Key variables:

#### Database Configuration
```bash
POSTGRES_HOST=db                    # Database host (container name)
POSTGRES_DB=postgres               # Database name
POSTGRES_PORT=5432                 # Database port
POSTGRES_PASSWORD=supabase123      # Database password (change for production)
```

#### API Gateway (Kong)
```bash
KONG_HTTP_PORT=8000               # Kong HTTP port
KONG_HTTPS_PORT=8443              # Kong HTTPS port
API_EXTERNAL_URL=http://localhost:8000    # External API URL
SUPABASE_PUBLIC_URL=http://localhost:8000 # Public Supabase URL
```

#### Studio (Dashboard)
```bash
STUDIO_PORT=3000                  # Studio web interface port
STUDIO_DEFAULT_ORGANIZATION=Pravia CRM    # Default organization name
STUDIO_DEFAULT_PROJECT=Pravia Development # Default project name
```

#### Authentication
```bash
SITE_URL=http://localhost:3000    # Frontend URL for redirects
ADDITIONAL_REDIRECT_URLS=         # Additional allowed redirect URLs
DISABLE_SIGNUP=false              # Allow user registration
ENABLE_EMAIL_SIGNUP=true          # Enable email/password signup
ENABLE_EMAIL_AUTOCONFIRM=false    # Auto-confirm email signups
ENABLE_PHONE_SIGNUP=false         # Enable phone number signup
ENABLE_PHONE_AUTOCONFIRM=false    # Auto-confirm phone signups
ENABLE_ANONYMOUS_USERS=false      # Allow anonymous users
```

#### JWT Configuration
```bash
JWT_EXPIRY=3600                   # JWT token expiry (seconds)
JWT_SECRET=your-super-secret-jwt-token-with-at-least-32-characters-long
```

#### PostgREST
```bash
PGRST_DB_SCHEMAS=public,storage,graphql_public  # Exposed database schemas
```

#### Storage
```bash
IMGPROXY_ENABLE_WEBP_DETECTION=false  # Enable WebP image detection
```

#### Functions
```bash
FUNCTIONS_VERIFY_JWT=false        # Verify JWT for edge functions
```

#### Analytics
```bash
LOGFLARE_API_KEY=your-super-secret-and-long-logflare-key  # Analytics API key
```

#### Docker
```bash
DOCKER_SOCKET_LOCATION=/var/run/docker.sock  # Docker socket path
```

#### API Keys (Auto-generated)
```bash
# Public key for client-side usage
ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0

# Service role key for server-side usage (full access)
SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImV4cCI6MTk4MzgxMjk5Nn0.EGIM96RAZx35lJzdJsyH-qQwv8Hdp7fsn3W0YpN81IU
```

#### Email Configuration (SES for AWS)
```bash
GOTRUE_SMTP_ADMIN_EMAIL=no-reply@asyml8.com     # From email address
GOTRUE_SMTP_HOST=email-smtp.us-east-1.amazonaws.com  # SES SMTP host
GOTRUE_SMTP_PORT=587                            # SMTP port
GOTRUE_SMTP_USER=                               # SES SMTP username (set in AWS)
GOTRUE_SMTP_PASS=                               # SES SMTP password (set in AWS)
GOTRUE_SMTP_SENDER_NAME=Pravia CRM              # Email sender name
GOTRUE_EXTERNAL_EMAIL_ENABLED=true              # Enable email authentication
GOTRUE_MAILER_AUTOCONFIRM=false                 # Require email confirmation
```

#### Email URL Paths
```bash
GOTRUE_MAILER_URLPATHS_INVITE=/auth/v1/verify          # Invite confirmation path
GOTRUE_MAILER_URLPATHS_CONFIRMATION=/auth/v1/verify    # Email confirmation path
GOTRUE_MAILER_URLPATHS_RECOVERY=/auth/v1/verify        # Password recovery path
GOTRUE_MAILER_URLPATHS_EMAIL_CHANGE=/auth/v1/verify    # Email change confirmation path
```

### ⚠️ CRITICAL: SES SMTP Credentials Setup

**Email functionality requires manual SMTP credential creation AFTER deployment:**

#### Why Manual Setup is Required
- AWS SES SMTP credentials are **different** from regular IAM access keys
- They can **only be generated** through the AWS SES Console
- **Cannot be automated** via CDK/CloudFormation

#### Post-Deployment Steps (Required)
1. **AWS SES Console** → SMTP Settings → **Create SMTP Credentials**
2. **Download credentials** (special SMTP username/password)
3. **Update deployed Supabase:**
   ```bash
   # SSH to instance
   aws ssm start-session --target [instance-id] --region us-east-1
   
   # Update credentials
   cd /home/ubuntu/supabase/docker
   sed -i 's/GOTRUE_SMTP_USER=.*/GOTRUE_SMTP_USER=[smtp-username]/' .env
   sed -i 's/GOTRUE_SMTP_PASS=.*/GOTRUE_SMTP_PASS=[smtp-password]/' .env
   docker restart supabase-auth
   ```

#### Troubleshooting
- **"535 Authentication Credentials Invalid"**: Wrong SMTP credentials - recreate in SES Console
- **Emails not sending**: Check SES sandbox mode, verify recipient emails
- **DNS issues**: Wait 5-10 minutes for DNS propagation

### Production Configuration Changes

For production deployment, update these values:

```bash
# Security
POSTGRES_PASSWORD=your-secure-production-password
JWT_SECRET=your-production-jwt-secret-at-least-32-characters

# URLs
SITE_URL=https://your-domain.com
API_EXTERNAL_URL=https://api.your-domain.com
SUPABASE_PUBLIC_URL=https://api.your-domain.com

# Email (MUST be updated post-deployment)
GOTRUE_SMTP_USER=your-ses-smtp-username
GOTRUE_SMTP_PASS=your-ses-smtp-password
GOTRUE_SMTP_ADMIN_EMAIL=no-reply@your-domain.com

# Signup
DISABLE_SIGNUP=true  # Disable public signup for production
ENABLE_EMAIL_AUTOCONFIRM=false  # Require email confirmation
```

## AWS Integration
- S3 bucket for file storage
- SES for email delivery
- IAM roles for permissions
- VPC for network isolation

### SES Email Setup (Required for Email Features)

After deployment, you'll need to verify your domain with AWS SES:

#### What are DKIM Records?
**DKIM** (DomainKeys Identified Mail) records:
- **Prove email authenticity** - Cryptographically sign emails from your domain
- **Prevent email spoofing** - Stop others from sending fake emails as you  
- **Improve deliverability** - Gmail, Outlook trust DKIM-signed emails more
- **Reduce spam filtering** - Legitimate emails less likely to go to spam

For Supabase, this ensures user registration emails, password resets, and notifications are properly authenticated and don't go to spam.

#### 1. Get DNS Records from CDK Output
```bash
# After deployment, CDK will output:
SESVerificationRecord = "_amazonses.asyml8.com TXT abc123def456"
SESDKIMRecords = "Check SES Console for asyml8.com DKIM records"
```

#### 2. Add DNS Records to Route53
The DKIM records are automatically added to Route53 during deployment. However, you may need to manually add these additional records:

**Required DNS Records:**
| Record Name | Type | Value |
|-------------|------|-------|
| (blank) | TXT | `"MS=ms62355523""v=spf1 include:secureserver.net include:spf.protection.outlook.com -all"` |
| autodiscover | CNAME | `autodiscover.outlook.com` |
| email | CNAME | `email.secureserver.net` (optional if keeping GoDaddy legacy mail) |
| (blank) | MX | `0 [domain]-com.mail.protection.outlook.com` |

**Note**: Replace `[domain]` with your actual domain name (e.g., `asyml8-com.mail.protection.outlook.com` for `asyml8.com`)

#### 3. Verify Domain
```bash
# Check verification status
aws ses get-identity-verification-attributes --identities [your-domain].com --region us-east-1
```

#### 4. Email Features Available After Verification
- User registration emails
- Password reset emails  
- Email confirmations
- Custom email templates

**Note**: DNS propagation can take up to 72 hours, but usually completes within 15 minutes.

### AWS Integration
- S3 bucket for file storage
- SES for email delivery
- IAM roles for permissions
- VPC for network isolation

## Management

### Local Commands
```bash
# Service management
docker compose up -d        # Start all services
docker compose down         # Stop all services
docker compose restart     # Restart services
docker compose ps          # Check status
docker compose logs -f     # Follow logs

# Individual services
docker compose up -d db     # Start only database
docker compose logs auth   # View auth logs
```

### AWS Commands
```bash
# Connect to instance
aws ssm start-session --target <instance-id> --region us-east-1

# On the instance
/home/ubuntu/supabase-control.sh start    # Start services
/home/ubuntu/supabase-control.sh stop     # Stop services
/home/ubuntu/supabase-control.sh status   # Check status
/home/ubuntu/supabase-control.sh logs     # View logs
```

## Security

### Local Development
- Default passwords (change for production)
- No SSL (use reverse proxy if needed)
- All services exposed on localhost

### AWS Production
- VPC with security groups
- SSL termination at load balancer
- IAM roles with least privilege
- S3 bucket with private access
- SES for secure email delivery

## Monitoring

### Health Checks
- All services have health check endpoints
- Load balancer monitors service health
- Auto-restart on failure

### Logs
- Centralized logging via Vector
- Logflare for analytics
- CloudWatch integration (AWS)

## Backup & Recovery

### Database
```bash
# Backup
docker compose exec db pg_dump -U postgres postgres > backup.sql

# Restore
docker compose exec -T db psql -U postgres postgres < backup.sql
```

### Storage
- S3 versioning enabled
- Lifecycle policies configured
- Cross-region replication (optional)

## Troubleshooting

### Common Issues
1. **Services not starting**: Check Docker daemon
2. **Port conflicts**: Ensure ports 3000, 5432, 8000 are free
3. **Permission errors**: Check file ownership in volumes
4. **Database connection**: Verify POSTGRES_PASSWORD

### Debug Commands
```bash
# Check service status
docker compose ps

# View service logs
docker compose logs <service-name>

# Connect to database
docker compose exec db psql -U postgres

# Check network connectivity
docker compose exec studio curl http://db:5432
```

## Cost Estimation (AWS)

| Resource | Monthly Cost |
|----------|--------------|
| t3.medium EC2 | ~$30 |
| 20GB EBS | ~$2 |
| Application LB | ~$20 |
| Network LB | ~$20 |
| S3 Storage | ~$1-5 |
| Data Transfer | ~$3-10 |
| **Total** | **~$76-87** |

## Troubleshooting

### Email Templates Show Localhost
**Problem**: Email templates contain `http://localhost:3000` instead of production domain
**Solution**: 
1. Ensure `SITE_URL=https://your-domain.com` in .env
2. Remove any `GOTRUE_SITE_URL` from .env (docker-compose maps it)
3. Restart auth service: `docker compose restart auth`

### SMTP Authentication Failed (535 Error)
**Problem**: "535 Authentication Credentials Invalid"
**Solution**: 
1. SES SMTP credentials must be created manually via AWS Console
2. Cannot be automated - use the IAM user from CDK output
3. Update .env with actual downloaded credentials

### Email Not Sending
**Problem**: "Noop mail client" or no emails sent
**Solution**:
1. Check SES sandbox mode - verify recipient emails
2. Verify domain DKIM records are configured
3. Ensure all SMTP variables are set correctly
4. Check for duplicate environment variables

### Container Shows Wrong Environment Variables
**Problem**: `docker exec container env` shows unexpected values
**Solution**:
1. Check for duplicate variables in .env vs docker-compose mappings
2. Use `docker compose down && docker compose up -d --force-recreate`
3. Verify .env file has correct values

## Next Steps

1. **Configure SES**: Set up email domain verification
2. **SSL Certificate**: Configure custom domain
3. **Monitoring**: Set up CloudWatch alarms
4. **Backup**: Implement automated backups
5. **Scaling**: Consider RDS for production database
