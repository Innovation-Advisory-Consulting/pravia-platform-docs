# Cost Estimation

[← Back to Main](../../README.md) | [📋 All Docs](../../README.md#-quick-navigation)

## Monthly Cost Breakdown

### Development Environment
| Component | Monthly Cost |
|-----------|--------------|
| EC2 t3.medium | ~$30 |
| EBS 20GB gp3 | ~$2 |
| Application Load Balancer | ~$20 |
| Network Load Balancer | ~$20 |
| S3 Storage (minimal) | ~$1 |
| Data Transfer | ~$3 |
| CloudWatch Monitoring | ~$2-3 |
| Foundation Stack | ~$1.50 |
| **Total Development** | **~$80-82/month** |

### Production Environment
| Component | Monthly Cost |
|-----------|--------------|
| EC2 t3.large | ~$60 |
| EBS 50GB gp3 + backups | ~$8 |
| Application Load Balancer | ~$20 |
| Network Load Balancer | ~$20 |
| S3 Storage | ~$5 |
| CloudWatch monitoring | ~$5-6 |
| Data Transfer | ~$10 |
| Foundation Stack | ~$1.50 |
| **Total Production** | **~$130-135/month** |

## Foundation Stack Costs
| Component | Monthly Cost |
|-----------|--------------|
| Route53 Hosted Zone | $0.50 |
| SSL Certificate | Free |
| SES Domain Identity | Free |
| S3 Bucket (minimal) | ~$1 |
| **Foundation Total** | **~$1.50/month** |

## Monitoring Costs
| Component | Monthly Cost |
|-----------|--------------|
| CloudWatch Dashboard | ~$3.00 |
| CloudWatch Alarms (2-4) | ~$0.20-0.40 |
| CloudWatch Metrics | ~$0.30 |
| SNS Topic (if enabled) | ~$0.50 |
| SNS Email (if enabled) | ~$2.00 |
| **Monitoring (no email)** | **~$2-3/month** |
| **Monitoring (with email)** | **~$5-6/month** |

## Cost Optimization Options

### Instance Size Optimization
| Instance Type | Monthly Cost | Use Case |
|---------------|--------------|----------|
| t3.small | ~$15 | Light development |
| t3.medium | ~$30 | Standard development |
| t3.large | ~$60 | Production |
| t3.xlarge | ~$120 | High-traffic production |

### Feature-Based Savings
- **Disable Load Balancer**: Save ~$40/month (direct EC2 access)
- **Disable Monitoring**: Save ~$2-3/month (no dashboard/alerts)
- **Smaller EBS volume**: Save ~$1/month per 10GB reduction
- **Spot instances**: Save ~50% on EC2 costs (dev environments)
- **Scheduled shutdown**: Save ~70% for dev environments

### Budget Configurations

**Minimal Development** (~$42/month):
```bash
cdk deploy -c environment=development \
  -c instanceType=t3.small \
  -c enableLoadBalancer=false \
  -c enableMonitoring=false
```

**Standard Development** (~$82/month):
```bash
cdk deploy -c environment=development
```

**Production** (~$135/month):
```bash
cdk deploy -c environment=production \
  -c instanceType=t3.large \
  -c ebsVolumeSize=50 \
  -c enableEmailAlerts=true
```

## Cost Monitoring

Use AWS Cost Explorer and set up billing alerts:
```bash
# Tag resources for cost tracking
# All Pravia resources are prefixed with "pravia-"
```

---
**Navigation**: [← Deployment Guide](./README.md) | [Back to Main](../../README.md)
