# Monitoring & Dashboards

[← Back to Main](../../README.md) | [📋 All Docs](../../README.md#-quick-navigation)

## Access Monitoring Dashboards

### AWS Console Web Access
1. **Sign in to AWS Console**: https://console.aws.amazon.com/
2. **Navigate to CloudWatch**: Services → CloudWatch
3. **View Dashboard**: Dashboards → "Pravia-Supabase-development-Dashboard"

### AWS Resource Explorer
1. **Open Resource Explorer**: Services → Resource Explorer
2. **Search for resources**: 
   ```
   type:cloudformation:stack name:Pravia-Supabase-development
   ```
3. **View stack resources**: Click on stack name to see all deployed resources
4. **Quick access to services**:
   - EC2 instances
   - Load balancers
   - CloudWatch dashboards
   - Log groups

### Direct Dashboard URL
```bash
# Get dashboard URL from CDK output
aws cloudformation describe-stacks --stack-name Pravia-Supabase-development \
  --query 'Stacks[0].Outputs[?OutputKey==`DashboardURL`].OutputValue' --output text

# Or construct URL manually
# https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#dashboards:name=Pravia-Supabase-development-Dashboard
```

## Access CloudWatch Dashboard
```bash
# Get dashboard URL from CDK output
aws cloudformation describe-stacks --stack-name Pravia-Supabase-development \
  --query 'Stacks[0].Outputs[?OutputKey==`DashboardURL`].OutputValue' --output text

# Or navigate manually in AWS Console
# CloudWatch → Dashboards → "Pravia-Supabase-development-Dashboard"
```

## Key Metrics to Monitor

### Instance Health
- CPU Utilization (target: <80%)
- Memory Usage (target: <85%)
- Disk Usage (target: <90%)
- Network I/O

### Application Performance
- ALB Request Count
- ALB Response Time (target: <2s)
- Target Health Status
- HTTP Error Rates (4xx/5xx)

### Supabase Services
- Database Connections
- Active Sessions
- Storage Usage
- API Response Times

## CloudWatch Alarms

### Automatic Alerts (if `enableEmailAlerts=true`)
- High CPU (>80% for 5 minutes)
- High Memory (>85% for 5 minutes)
- Instance Status Check Failed
- ALB Unhealthy Targets

### View Active Alarms
```bash
# List all alarms for your stack
aws cloudwatch describe-alarms --alarm-name-prefix "Pravia-Supabase-development" --region us-east-1

# Check alarm history
aws cloudwatch describe-alarm-history --alarm-name "Pravia-Supabase-development-HighCPU" --region us-east-1
```

## Log Analysis

### CloudWatch Logs Groups
- `/aws/ec2/pravia-supabase-development` - Instance system logs
- `/aws/applicationloadbalancer/app/pravia-supabase-development-alb` - Load balancer logs

### View Recent Logs
```bash
# Instance logs
aws logs tail /aws/ec2/pravia-supabase-development --follow --region us-east-1

# ALB access logs
aws logs tail /aws/applicationloadbalancer/app/pravia-supabase-development-alb --follow --region us-east-1
```

## Performance Optimization

### High CPU Usage
```bash
# Connect to instance and check processes
aws ssm start-session --target $INSTANCE_ID --region us-east-1
top -p $(pgrep -d',' docker)

# Check Docker container resource usage
docker stats
```

### High Memory Usage
```bash
# Check memory breakdown
free -h
docker stats --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"

# Restart services if needed
/home/ubuntu/supabase-control.sh restart
```

### Slow Response Times
```bash
# Check ALB target health
aws elbv2 describe-target-health --target-group-arn [target-group-arn]

# Test direct connectivity
curl -w "@curl-format.txt" -o /dev/null -s "https://api.yourdomain.com/rest/v1/"
```

## Cost Monitoring

### View CloudWatch Costs
```bash
# Get current month costs for CloudWatch
aws ce get-cost-and-usage \
  --time-period Start=2024-12-01,End=2024-12-31 \
  --granularity MONTHLY \
  --metrics BlendedCost \
  --group-by Type=DIMENSION,Key=SERVICE \
  --region us-east-1
```

### Monitoring Costs (approximate monthly)
- CloudWatch Dashboard: $3/month
- CloudWatch Alarms: $0.10/alarm/month
- CloudWatch Logs: $0.50/GB ingested
- SNS Email Notifications: $2/month (if enabled)

## Related Documentation
- [Deployment Guide](./README.md) - Production deployment steps
- [Cost Estimation](./cost-estimation.md) - Monthly cost breakdown
- [Foundation Stack](../../infra/aws/cdk/foundation-infra/README.md) - Shared infrastructure
- [Supabase Stack](../../infra/aws/cdk/supabase-infra/README.md) - Application infrastructure
