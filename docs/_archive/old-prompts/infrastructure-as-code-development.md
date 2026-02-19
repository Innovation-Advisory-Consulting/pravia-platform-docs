# Infrastructure as Code (IaC) Development Guide

## Overview
This prompt guides the development of robust, debuggable Infrastructure as Code using AWS CDK, incorporating lessons learned from real deployment challenges and failures.

## Core Principles

### 1. Defensive Programming
- **Never use `set -e` in user data scripts** - causes immediate exit on any error
- **Implement checkpoint systems** for tracking installation progress
- **Use explicit error handling** with conditional logic instead of relying on shell error propagation
- **Provide fallback mechanisms** for critical installation steps

### 2. Observability First
- **CloudWatch integration from the start** - don't add logging as an afterthought
- **Progress tracking mechanisms** - checkpoint files, status endpoints, health checks
- **Detailed error reporting** - capture both stdout and stderr with context
- **Real-time monitoring** - dashboards and alarms for deployment health

### 3. Incremental Validation
- **Test each component independently** before integration
- **Validate resource creation** before dependent resources
- **Health check endpoints** for service readiness verification
- **Graceful degradation** when optional components fail

## User Data Script Best Practices

### Error Handling Pattern
```bash
#!/bin/bash
# DO NOT use 'set -e' - it causes early exit on errors

# Checkpoint system for progress tracking
CHECKPOINT_FILE="/tmp/deployment-checkpoint"
checkpoint() {
  echo "$1" > $CHECKPOINT_FILE
  echo "$(date): Checkpoint: $1" | tee -a /var/log/deployment.log
}

# Function-based installation with error handling
install_component() {
  local component=$1
  local retries=3
  local count=0
  
  while [ $count -lt $retries ]; do
    if timeout 300 perform_installation; then
      checkpoint "$component installed successfully"
      return 0
    fi
    count=$((count + 1))
    checkpoint "$component installation attempt $count failed, retrying..."
    sleep 30
  done
  
  checkpoint "FAILED: $component installation after $retries attempts"
  return 1
}

# Usage with explicit error handling
if ! install_component "docker"; then
  checkpoint "CRITICAL: Docker installation failed - deployment cannot continue"
  exit 1
fi
```

### CloudWatch Integration
```typescript
// Create log group BEFORE instance creation
const logGroup = new logs.LogGroup(this, 'DeploymentLogGroup', {
  logGroupName: '/aws/ec2/deployment/userdata',
  retention: logs.RetentionDays.ONE_WEEK,
  removalPolicy: cdk.RemovalPolicy.DESTROY,
});

// Grant permissions BEFORE user data runs
role.addToPolicy(new iam.PolicyStatement({
  effect: iam.Effect.ALLOW,
  actions: ['logs:CreateLogStream', 'logs:PutLogEvents'],
  resources: [logGroup.logGroupArn],
}));
```

### Progress Monitoring
```bash
# In user data script - create status endpoint immediately
mkdir -p /var/www/html
echo "INITIALIZING" > /var/www/html/status
systemctl start nginx

# Update status throughout deployment
echo "INSTALLING_DOCKER" > /var/www/html/status
# ... docker installation ...
echo "DOCKER_COMPLETE" > /var/www/html/status

# Final status
echo "DEPLOYMENT_COMPLETE" > /var/www/html/status
```

## CDK Development Patterns

### 1. Resource Dependencies
```typescript
// Explicit dependency management
const foundationStack = new FoundationStack(app, 'Foundation', props);
const applicationStack = new ApplicationStack(app, 'Application', {
  ...props,
  foundationOutputs: {
    vpcId: foundationStack.vpc.vpcId,
    certificateArn: foundationStack.certificate.certificateArn,
  }
});

// Ensure deployment order
applicationStack.addDependency(foundationStack);
```

### 2. Cross-Stack References
```typescript
// Export values from foundation stack
new cdk.CfnOutput(this, 'VpcId', {
  value: this.vpc.vpcId,
  exportName: `${props.stackName}-VpcId`,
});

// Import in dependent stack
const vpcId = Fn.importValue(`${props.foundationStackName}-VpcId`);
const vpc = ec2.Vpc.fromVpcAttributes(this, 'ImportedVpc', {
  vpcId,
  availabilityZones: ['us-east-1a', 'us-east-1b'],
});
```

### 3. Conditional Resource Creation
```typescript
// Environment-based resource creation
const enableMonitoring = props.environment === 'production';
const enableBackups = props.environment !== 'development';

if (enableMonitoring) {
  const dashboard = new cloudwatch.Dashboard(this, 'Dashboard', {
    dashboardName: `${props.stackName}-monitoring`,
  });
}
```

## Debugging Strategies

### 1. Deployment Failure Investigation
```bash
# Check CloudFormation events
aws cloudformation describe-stack-events --stack-name <stack-name>

# Check user data execution
aws ssm send-command --instance-ids <instance-id> \
  --document-name "AWS-RunShellScript" \
  --parameters 'commands=["cat /tmp/deployment-checkpoint"]'

# Monitor CloudWatch logs
aws logs tail /aws/ec2/deployment/userdata --follow
```

### 2. Resource State Validation
```bash
# Verify resource creation
aws ec2 describe-instances --instance-ids <instance-id>
aws elbv2 describe-target-health --target-group-arn <tg-arn>
aws route53 list-resource-record-sets --hosted-zone-id <zone-id>
```

### 3. Service Health Checks
```bash
# Test service endpoints
curl -I --connect-timeout 10 http://<endpoint>:8000
curl -I --connect-timeout 10 http://<load-balancer-dns>

# Check container status (if using Docker)
docker ps --format "table {{.Names}}\t{{.Status}}"
```

## Common Pitfalls & Solutions

### 1. Package Compatibility Issues
**Problem**: Package not available on target OS version
```bash
# Bad: Assuming package exists
apt-get install -y awslogs

# Good: Version-aware installation
if lsb_release -rs | grep -q "24.04"; then
  # Ubuntu 24.04 specific installation
  wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
  dpkg -i amazon-cloudwatch-agent.deb
else
  # Fallback for older versions
  apt-get install -y awslogs
fi
```

### 2. Certificate Domain Mismatches
**Problem**: SSL certificate doesn't match deployed domain
```typescript
// Bad: Hardcoded certificate reference
const certificate = acm.Certificate.fromCertificateArn(this, 'Cert', 
  'arn:aws:acm:us-east-1:123456789012:certificate/abc123');

// Good: Dynamic certificate creation or validation
const certificate = new acm.Certificate(this, 'Certificate', {
  domainName: props.domain,
  subjectAlternativeNames: [`*.${props.domain}`],
  validation: acm.CertificateValidation.fromDns(hostedZone),
});
```

### 3. Resource Timing Issues
**Problem**: Dependent resources created before dependencies are ready
```typescript
// Bad: No explicit dependencies
const instance = new ec2.Instance(this, 'Instance', { ... });
const targetGroup = new elbv2.ApplicationTargetGroup(this, 'TG', {
  targets: [new targets.InstanceTarget(instance)],
});

// Good: Explicit dependency management
const instance = new ec2.Instance(this, 'Instance', { ... });
const targetGroup = new elbv2.ApplicationTargetGroup(this, 'TG', { ... });
targetGroup.addTarget(new targets.InstanceTarget(instance));
targetGroup.node.addDependency(instance);
```

## Testing & Validation

### 1. Pre-Deployment Validation
```bash
# Syntax validation
cdk synth --strict

# Security validation
cdk diff --security-only

# Resource validation
cdk doctor
```

### 2. Post-Deployment Testing
```bash
# Infrastructure validation
aws cloudformation validate-template --template-body file://template.json

# Service validation
curl -f http://<endpoint>/health || echo "Health check failed"

# Load balancer validation
aws elbv2 describe-target-health --target-group-arn <arn>
```

### 3. Rollback Procedures
```bash
# Safe rollback with data preservation
cdk deploy --rollback --no-rollback-on-failure

# Emergency resource cleanup
aws cloudformation delete-stack --stack-name <stack-name>
```

## Documentation Requirements

### 1. Deployment Outputs
Always document actual deployment results:
```markdown
## Deployment Results
- **Status**: ✅ Successful (4 minutes)
- **Primary URL**: https://app.example.com
- **Direct Access**: http://1.2.3.4:8000
- **Dashboard**: https://console.aws.amazon.com/cloudwatch/...
- **SSH Access**: aws ssm start-session --target i-1234567890abcdef0
```

### 2. Troubleshooting Guide
Include real issues encountered:
```markdown
## Common Issues
### Issue: Package Installation Failure
**Symptom**: `awslogs` package not found
**Solution**: Use CloudWatch agent instead
**Commands**: [specific commands that worked]
```

### 3. Operational Procedures
```markdown
## Operations
### Start Services
`/home/ubuntu/service-control.sh start`

### Check Status
`docker ps --format "table {{.Names}}\t{{.Status}}"`

### View Logs
`docker compose logs -f`
```

## Implementation Checklist

- [ ] User data script uses checkpoint system
- [ ] CloudWatch logging configured before deployment
- [ ] Health check endpoints implemented
- [ ] Error handling for each critical component
- [ ] Retry logic for network operations
- [ ] Explicit resource dependencies defined
- [ ] Cross-stack references properly configured
- [ ] Environment-specific configurations
- [ ] Rollback procedures documented
- [ ] Post-deployment validation tests
- [ ] Monitoring and alerting configured
- [ ] Documentation includes real deployment results

## Success Metrics

- **Deployment Success Rate**: >95% first-time success
- **Mean Time to Recovery**: <30 minutes for failures
- **Debugging Time**: <10 minutes to identify failure point
- **Documentation Accuracy**: Real examples, not theoretical
- **Operational Readiness**: Clear procedures for common tasks

This guide ensures infrastructure deployments are reliable, debuggable, and maintainable based on real-world experience and lessons learned from deployment failures.
