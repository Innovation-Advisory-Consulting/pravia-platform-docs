# ⚠️ CRITICAL: CDK-Deployed Infrastructure Warning

## NEVER modify Docker containers or docker-compose files for CDK-deployed stacks

### ❌ DO NOT:
- Create manual Docker containers
- Modify docker-compose.yml files
- Run `docker run` commands manually
- Stop/start containers outside of CDK
- Change port mappings manually
- Modify container configurations directly

### ✅ DO INSTEAD:
- Update CDK stack code for infrastructure changes
- Use `cdk deploy` to apply changes
- Only modify configuration files (`.env`, `config.toml`)
- Use CDK-provided restart scripts
- Work within the CDK-managed infrastructure

### Why This Matters:
- CDK manages infrastructure as code
- Manual changes create conflicts with CDK state
- Container name conflicts break deployments
- Manual containers are not tracked by CDK
- Destroys infrastructure reproducibility

### For Configuration Changes:
- Update `.env` files ✅
- Use existing restart scripts ✅
- Modify CDK stack for structural changes ✅
- Redeploy with `cdk deploy` ✅

### Emergency Recovery:
If manual changes break CDK deployment:
```bash
cdk destroy --force
cdk deploy
```

**Remember: CDK-deployed = CDK-managed. Respect the infrastructure boundaries.**
