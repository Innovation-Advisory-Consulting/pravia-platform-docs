# Supabase Modular CDK Stack

A production-ready, modular CDK implementation of self-hosted Supabase on AWS using ECS Fargate.

## 🏗️ Architecture

- **ECS Fargate** - Serverless containers (Kong, Auth, REST, Realtime, Storage)
- **Aurora Serverless** - Auto-scaling PostgreSQL database
- **Application Load Balancer** - HTTPS termination and routing
- **Service Connect** - Internal service discovery
- **S3** - Object storage backend
- **Secrets Manager** - JWT and SMTP credentials
- **CloudWatch** - Monitoring and alerting (optional)

## 📁 Project Structure

```
lib/
├── constructs/
│   ├── database.ts              # Aurora v1/v2, RDS PostgreSQL
│   ├── networking.ts            # VPC, Security Groups
│   ├── secrets.ts               # JWT, SMTP secrets
│   ├── supabase-services.ts     # 5 Supabase microservices
│   ├── load-balancer-config.ts  # ALB, Route53, SSL
│   └── monitoring-config.ts     # CloudWatch dashboards & alarms
├── types/
│   └── stack-props.ts           # TypeScript interfaces
├── utils/
│   └── cost-calculator.ts       # Cost estimation
└── supabase-stack-modular.ts    # Main orchestration
```

## 🚀 Quick Start

### 1. Prerequisites
- AWS CLI configured with appropriate permissions
- CDK v2 installed
- Existing Route53 hosted zone (optional)
- Existing SES SMTP credentials (optional)

### 2. Development Deployment (Recommended Default)
```bash
cdk deploy SupabaseModularStack \
  --context databaseType=aurora-v1 \
  --context taskSize=small \
  --context enableHighAvailability=false \
  --context enableDashboard=true \
  --context enableAlerts=false
```
**Cost: ~$25/month** | **Features**: Auto-pause DB, dashboard, no alerts

### 3. Production Deployment (High Availability)
```bash
cdk deploy SupabaseModularStack \
  --context databaseType=aurora-v2 \
  --context taskSize=medium \
  --context enableHighAvailability=true \
  --context minACU=2 \
  --context maxACU=16 \
  --context domain=api.yourdomain.com \
  --context hostedZoneId=Z1234567890ABC \
  --context certificateArn=arn:aws:acm:us-east-1:123456789012:certificate/... \
  --context enableDashboard=true \
  --context enableAlerts=true \
  --context alertEmail=admin@yourdomain.com
```
**Cost: ~$200/month** | **Features**: HA, monitoring, email alerts

### 4. With Existing SES
```bash
cdk deploy SupabaseModularStack \
  --context smtpUsername=AKIA1234567890EXAMPLE \
  --context smtpPassword=your-smtp-password \
  --context sesNoReplyEmail=noreply@yourdomain.com
```

### 5. Ultra-Low Cost (Testing Only)
```bash
cdk deploy SupabaseModularStack \
  --context databaseType=rds-postgres \
  --context instanceType=t4g.micro \
  --context taskSize=micro \
  --context enableHighAvailability=false \
  --context enableDashboard=false \
  --context enableAlerts=false
```
**Cost: ~$15/month** | **Features**: Minimal resources, no monitoring

## ⚙️ Configuration Options

### Database Types
| Type | Description | Cost | Use Case |
|------|-------------|------|----------|
| `aurora-v1` | Auto-pause serverless | $0-15/month | **Development (Default)** |
| `aurora-v2` | No cold starts | $15-100/month | Production |
| `rds-postgres` | Fixed instance | $9-72/month | Predictable workloads |

### Task Sizes
| Size | CPU | Memory | Cost/Service | Use Case |
|------|-----|--------|--------------|----------|
| `micro` | 256 | 512MB | $18/month | Testing only |
| `small` | 512 | 1GB | $36/month | **Development (Default)** |
| `medium` | 1024 | 2GB | $72/month | Production |
| `large` | 2048 | 4GB | $144/month | High load |

### Monitoring Options
| Setting | Default | Description | Cost |
|---------|---------|-------------|------|
| `enableDashboard` | `true` | CloudWatch dashboard | $3/month |
| `enableAlerts` | `false` | CPU/memory alarms + email | $2/month |
| `alertEmail` | `undefined` | Email for notifications | Free |

### Context Parameters
```bash
# Database
--context databaseType=aurora-v1|aurora-v2|rds-postgres
--context instanceType=t4g.micro  # For RDS only
--context minACU=0.5 maxACU=4      # For Aurora only

# Compute
--context taskSize=micro|small|medium|large
--context enableHighAvailability=true|false

# Domain & SSL
--context domain=api.yourdomain.com
--context hostedZoneId=Z1234567890ABC  # Your existing hosted zone
--context certificateArn=arn:aws:acm:...

# Email (Use existing SES)
--context smtpUsername=AKIA...
--context smtpPassword=your-password
--context sesNoReplyEmail=noreply@yourdomain.com

# Monitoring
--context enableDashboard=true|false
--context enableAlerts=true|false
--context alertEmail=admin@yourdomain.com

# General
--context stackPrefix=MyCompany
```

## 💰 Cost Examples

### Development (Recommended Default)
```bash
# Aurora v1 + Small tasks + Dashboard only
# Cost: ~$25/month
--context databaseType=aurora-v1 --context taskSize=small --context enableDashboard=true --context enableAlerts=false
```

### Production
```bash
# Aurora v2 + Medium tasks + HA + Full monitoring
# Cost: ~$205/month  
--context databaseType=aurora-v2 --context taskSize=medium --context enableHighAvailability=true --context enableDashboard=true --context enableAlerts=true
```

### Ultra-Low Cost
```bash
# RDS micro + Micro tasks + No monitoring
# Cost: ~$15/month
--context databaseType=rds-postgres --context instanceType=t4g.micro --context taskSize=micro --context enableDashboard=false
```

## 🔧 Post-Deployment

### 1. Access Supabase
- **API URL**: Check CloudFormation outputs
- **Database**: Use connection string from Secrets Manager
- **Storage**: S3 bucket created automatically
- **Dashboard**: CloudWatch dashboard URL in outputs (if enabled)

### 2. Configure Email (if not using existing SES)
1. Verify domain in SES Console
2. Create SMTP credentials
3. Update Secrets Manager with real credentials
4. Restart Auth service

### 3. Security Hardening
- Update default passwords
- Configure Row Level Security
- Set up API keys and policies
- Enable audit logging

## 🛠️ Management Commands

```bash
# View stack outputs
aws cloudformation describe-stacks --stack-name SupabaseModularStack --query 'Stacks[0].Outputs'

# Update service (zero-downtime)
cdk deploy SupabaseModularStack --context taskSize=medium

# Scale services manually
aws ecs update-service --cluster [cluster-name] --service [service-name] --desired-count 3

# View logs
aws logs tail /aws/ecs/supabase --follow

# Enable monitoring after deployment
cdk deploy SupabaseModularStack --context enableDashboard=true --context enableAlerts=true --context alertEmail=admin@yourdomain.com
```

## 🔍 Troubleshooting

### Common Issues

**Services not starting**
```bash
# Check ECS service events
aws ecs describe-services --cluster [cluster] --services [service]

# Check container logs
aws logs tail /aws/ecs/supabase/[service] --follow
```

**Database connection issues**
```bash
# Verify security groups allow ECS → RDS
# Check database credentials in Secrets Manager
```

**Email not working**
```bash
# Verify SES domain/email identity
# Check SMTP credentials in Secrets Manager
# Ensure SES is out of sandbox mode
```

**Monitoring not showing data**
```bash
# Ensure enableDashboard=true was set
# Check CloudWatch dashboard URL in stack outputs
# Verify services are running and generating metrics
```

## 📊 Monitoring

### What's Included (if enabled)
- **CloudWatch Dashboard** - Service metrics, ALB performance, database stats
- **CPU/Memory Alarms** - Per-service alerting
- **Email Notifications** - SNS alerts to specified email
- **ECS Service Connect** - Service mesh observability  
- **Application Load Balancer** - HTTP metrics
- **Aurora/RDS** - Database performance metrics

### Default Monitoring Settings
- **Development**: Dashboard enabled, alerts disabled
- **Production**: Both dashboard and alerts enabled
- **Cost**: $3/month (dashboard) + $2/month (alerts)

## 🔄 Updates & Maintenance

### Update Supabase versions
```bash
# Edit image tags in supabase-services.ts
image: 'public.ecr.aws/supabase/gotrue:v2.150.0'  # Update version
```

### Scale for traffic
```bash
# Increase task size
--context taskSize=large

# Enable auto-scaling
--context enableHighAvailability=true
```

### Database maintenance
```bash
# Aurora Serverless auto-scales
# RDS requires manual instance size changes
```

## 🚨 Production Checklist

- [ ] Custom domain configured with your hosted zone ID
- [ ] SSL certificate attached
- [ ] SES domain verified and out of sandbox
- [ ] Database backups enabled
- [ ] Monitoring and alerting set up (`enableDashboard=true enableAlerts=true`)
- [ ] Security groups reviewed
- [ ] API keys rotated from defaults
- [ ] Row Level Security policies configured
- [ ] Load testing completed
- [ ] Disaster recovery plan documented

## 📞 Support

For issues with:
- **CDK/AWS**: Check AWS documentation
- **Supabase**: Check [Supabase docs](https://supabase.com/docs)
- **This implementation**: Create GitHub issue

## 📄 License

[Your License Here]
