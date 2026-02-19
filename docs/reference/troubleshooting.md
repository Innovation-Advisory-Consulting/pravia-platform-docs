# Troubleshooting

[← Back to Main](../../README.md) | [📋 All Docs](../../README.md#-quick-navigation)

## Supabase Instance Timeout Issues

### Symptoms
- Load balancer health checks show "Target.Timeout" 
- Direct connection to instance ports 3000/8000 times out
- Services appear unreachable despite instance running

### Diagnosis Steps
1. Check instance console logs:
   ```bash
   aws ec2 get-console-output --instance-id <instance-id> --region us-east-1
   ```

2. Look for user-data script execution evidence:
   - Docker installation logs
   - Supabase setup messages
   - Error messages during installation

### Root Cause: User-Data Script Failure
If console logs show normal Ubuntu boot but no Docker/Supabase installation logs, the user-data script failed to execute or complete.

## 504 Gateway Timeout Issues

### Symptoms
- **504 Gateway Timeout** errors when accessing Supabase Studio or API
- ALB health checks failing
- Load balancer shows "Target.Timeout" status
- Services appear unreachable through domain URLs

### Diagnosis Steps
1. **Check ALB Target Health:**
   ```bash
   # Get target group ARN from CloudFormation
   aws cloudformation describe-stack-resources --stack-name Pravia-Supabase-development \
     --query 'StackResources[?ResourceType==`AWS::ElasticLoadBalancingV2::TargetGroup`].PhysicalResourceId' --output text
   
   # Check target health
   aws elbv2 describe-target-health --target-group-arn [target-group-arn]
   ```

2. **Test Direct Instance Access:**
   ```bash
   # Get instance public IP
   aws cloudformation describe-stacks --stack-name Pravia-Supabase-development \
     --query 'Stacks[0].Outputs[?OutputKey==`PublicIP`].OutputValue' --output text
   
   # Test direct connectivity (bypass ALB)
   curl -I http://[public-ip]:3000  # Supabase Studio
   curl -I http://[public-ip]:8000/rest/v1/  # Supabase API
   ```

3. **Check Instance Status:**
   ```bash
   # Connect to instance
   aws ssm start-session --target [instance-id] --region us-east-1
   sudo su - ubuntu
   
   # Check if services are running
   docker ps
   /home/ubuntu/supabase-control.sh status
   ```

### Common Causes & Solutions

**Services Not Started:**
```bash
# Start Supabase services
/home/ubuntu/supabase-control.sh start

# Check logs for errors
/home/ubuntu/supabase-control.sh logs
```

**Port Binding Issues:**
```bash
# Check if ports are bound correctly
sudo netstat -tlnp | grep -E ':(3000|8000)'

# Restart services if needed
/home/ubuntu/supabase-control.sh restart
```

**User-Data Script Failed:**
- See "Failed First Deployment" section for complete redeployment steps

### Fix Options

**Option 1: Reboot (may work)**
```bash
aws ec2 reboot-instances --instance-ids <instance-id> --region us-east-1
```
Wait 15 minutes for installation to complete.

**Option 2: Recreate Instance (reliable)**
```bash
# Destroy and redeploy specific environment
cdk destroy -c environment=development
cdk deploy -c environment=development
```

## Failed First Deployment

### When Supabase Instance Fails to Initialize

**Symptoms:**
- Instance appears healthy but services don't respond
- User-data script didn't complete successfully
- Docker containers not running

**Complete Redeployment (Wipes All Data):**
```bash
# From project root - destroy the stack completely
pnpm supabase:destroy

# Wait for stack deletion to complete (5-10 minutes)
aws cloudformation describe-stacks --stack-name Pravia-Supabase-development --region us-east-1

# Redeploy from scratch
pnpm supabase:deploy:dev

# Or with custom parameters
cd infra/aws/cdk/supabase-infra
cdk destroy -c environment=development
cdk deploy -c environment=development
```

**⚠️ Warning:** This completely destroys the instance and all data. Only use when:
- Initial deployment failed
- Instance is corrupted and cannot be recovered
- You need a clean slate for development

**Alternative: Targeted Instance Replacement:**
```bash
# If you only need to replace the EC2 instance (keeps other resources)
# This requires manual CloudFormation stack modification
# Contact AWS support or use AWS Console to replace just the instance
```

## Common Issues

**Port conflicts:**
```bash
# Check what's using ports
lsof -i :3000
lsof -i :8000

# Kill processes if needed
kill -9 <PID>
```

**Docker issues:**
```bash
# Restart Docker Desktop
# Then try again
pnpm supabase:local
```

**pnpm install fails:**
```bash
# Clear cache and reinstall
pnpm store prune
rm -rf node_modules
pnpm install
```

**Build errors:**
```bash
# Clean and rebuild
pnpm clean
pnpm install
pnpm build
```

## Email Issues

**SMTP Authentication:**
- **"535 Authentication Credentials Invalid"**: Wrong SMTP credentials - recreate in SES Console

**Email Delivery:**
- **"Error sending confirmation email"**: Check SES sandbox mode, verify recipient email
- **No email received**: Check spam folder, verify domain DKIM records

**Domain Verification:**
- Check AWS SES Console after adding DNS records
- Verification typically takes 5-10 minutes
- Both domain and DKIM must be verified for email to work

## Getting Help
1. Check component-specific READMEs (linked above)
2. Look at error logs: `pnpm supabase:logs`
3. Verify prerequisites are installed
4. Check Docker Desktop is running
