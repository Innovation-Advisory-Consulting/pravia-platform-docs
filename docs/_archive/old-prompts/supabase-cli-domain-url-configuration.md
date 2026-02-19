# Supabase CLI Domain URL Configuration - Critical Issues & Solutions

## CRITICAL PROBLEM: Supabase CLI Hardcodes Localhost URLs

**The Supabase CLI has a fundamental flaw:** It hardcodes localhost URLs in GOTRUE environment variables, completely ignoring config.toml settings and environment variable overrides when using custom domains.

## The Issue Explained

### What Happens
1. You configure `site_url` and `api_url` in config.toml with your domain
2. Supabase CLI starts containers with hardcoded localhost URLs anyway
3. Email invite links use `http://127.0.0.1:54321/auth/v1/verify` instead of your domain
4. Users click invite links and get redirected to localhost (broken)

### Root Cause
The Supabase CLI generates Docker containers with these hardcoded environment variables:
```bash
GOTRUE_JWT_ISSUER=http://127.0.0.1:54321/auth/v1
GOTRUE_MAILER_URLPATHS_INVITE=http://127.0.0.1:54321/auth/v1/verify
GOTRUE_MAILER_URLPATHS_CONFIRMATION=http://127.0.0.1:54321/auth/v1/verify
GOTRUE_MAILER_URLPATHS_RECOVERY=http://127.0.0.1:54321/auth/v1/verify
GOTRUE_MAILER_URLPATHS_EMAIL_CHANGE=http://127.0.0.1:54321/auth/v1/verify
```

**These URLs are used in email templates and JWT tokens, NOT the config.toml settings.**

## Failed Solutions (Don't Work)

### ❌ Config.toml Settings
```toml
# These are IGNORED by the CLI for email URLs
site_url = "https://yourdomain.com"
api_url = "https://yourdomain.com"
```

### ❌ Environment Variable Overrides
```bash
# These are IGNORED when starting Supabase
export GOTRUE_JWT_ISSUER="https://yourdomain.com/auth/v1"
export GOTRUE_MAILER_URLPATHS_INVITE="https://yourdomain.com/auth/v1/verify"
supabase start  # Still uses localhost URLs
```

### ❌ Config File Modifications
```toml
# This syntax doesn't exist and causes errors
[auth.gotrue_env]
GOTRUE_JWT_ISSUER = "https://yourdomain.com/auth/v1"
```

## ✅ Working Solutions

### Solution 1: Manual Container Recreation (Immediate Fix)
```bash
# Stop and remove the auth container
docker stop supabase_auth_ubuntu
docker rm supabase_auth_ubuntu

# Recreate with correct environment variables
docker run -d --name supabase_auth_ubuntu \
  --network supabase_default \
  --restart unless-stopped \
  -p 9999:9999 \
  -e GOTRUE_API_HOST=0.0.0.0 \
  -e GOTRUE_API_PORT=9999 \
  -e GOTRUE_DB_DRIVER=postgres \
  -e GOTRUE_DB_DATABASE_URL=postgresql://supabase_auth_admin:postgres@supabase_db_ubuntu:5432/postgres \
  -e GOTRUE_SITE_URL=https://yourdomain.com \
  -e GOTRUE_JWT_ISSUER=https://yourdomain.com/auth/v1 \
  -e GOTRUE_MAILER_URLPATHS_INVITE=https://yourdomain.com/auth/v1/verify \
  -e GOTRUE_MAILER_URLPATHS_CONFIRMATION=https://yourdomain.com/auth/v1/verify \
  -e GOTRUE_MAILER_URLPATHS_RECOVERY=https://yourdomain.com/auth/v1/verify \
  -e GOTRUE_MAILER_URLPATHS_EMAIL_CHANGE=https://yourdomain.com/auth/v1/verify \
  -e GOTRUE_SMTP_HOST=your-smtp-host \
  -e GOTRUE_SMTP_PORT=587 \
  -e GOTRUE_SMTP_USER=your-smtp-user \
  -e GOTRUE_SMTP_PASS=your-smtp-password \
  -e GOTRUE_SMTP_ADMIN_EMAIL=your-admin-email \
  -e GOTRUE_JWT_SECRET=super-secret-jwt-token-with-at-least-32-characters-long \
  -e GOTRUE_JWT_EXP=3600 \
  -e GOTRUE_JWT_AUD=authenticated \
  -e GOTRUE_DISABLE_SIGNUP=false \
  -e GOTRUE_EXTERNAL_EMAIL_ENABLED=true \
  public.ecr.aws/supabase/gotrue:v2.158.1 auth
```

### Solution 2: CDK/Infrastructure Automation
Add this to your CDK user data script AFTER `supabase start`:

```bash
# Wait for Supabase to start
sleep 30

# Recreate auth container with correct domain URLs
docker stop supabase_auth_ubuntu
docker rm supabase_auth_ubuntu

docker run -d --name supabase_auth_ubuntu \
  --network supabase_default \
  --restart unless-stopped \
  -p 9999:9999 \
  -e GOTRUE_SITE_URL=https://${domain} \
  -e GOTRUE_JWT_ISSUER=https://${domain}/auth/v1 \
  -e GOTRUE_MAILER_URLPATHS_INVITE=https://${domain}/auth/v1/verify \
  -e GOTRUE_MAILER_URLPATHS_CONFIRMATION=https://${domain}/auth/v1/verify \
  -e GOTRUE_MAILER_URLPATHS_RECOVERY=https://${domain}/auth/v1/verify \
  -e GOTRUE_MAILER_URLPATHS_EMAIL_CHANGE=https://${domain}/auth/v1/verify \
  # ... other environment variables
  public.ecr.aws/supabase/gotrue:v2.158.1 auth
```

### Solution 3: Docker Compose Override (Alternative)
Create a `docker-compose.override.yml`:

```yaml
version: '3.8'
services:
  auth:
    environment:
      GOTRUE_SITE_URL: https://yourdomain.com
      GOTRUE_JWT_ISSUER: https://yourdomain.com/auth/v1
      GOTRUE_MAILER_URLPATHS_INVITE: https://yourdomain.com/auth/v1/verify
      GOTRUE_MAILER_URLPATHS_CONFIRMATION: https://yourdomain.com/auth/v1/verify
      GOTRUE_MAILER_URLPATHS_RECOVERY: https://yourdomain.com/auth/v1/verify
      GOTRUE_MAILER_URLPATHS_EMAIL_CHANGE: https://yourdomain.com/auth/v1/verify
```

## Critical Environment Variables for Email URLs

### Must Override These Variables:
```bash
GOTRUE_JWT_ISSUER=https://yourdomain.com/auth/v1
GOTRUE_MAILER_URLPATHS_INVITE=https://yourdomain.com/auth/v1/verify
GOTRUE_MAILER_URLPATHS_CONFIRMATION=https://yourdomain.com/auth/v1/verify
GOTRUE_MAILER_URLPATHS_RECOVERY=https://yourdomain.com/auth/v1/verify
GOTRUE_MAILER_URLPATHS_EMAIL_CHANGE=https://yourdomain.com/auth/v1/verify
```

### Keep These for Site Redirects:
```bash
GOTRUE_SITE_URL=https://yourdomain.com
```

## Verification Steps

### 1. Check Container Environment Variables
```bash
docker exec supabase_auth_ubuntu env | grep -E "(GOTRUE_JWT_ISSUER|GOTRUE_MAILER_URLPATHS_INVITE)"
```

**Expected Output:**
```
GOTRUE_JWT_ISSUER=https://yourdomain.com/auth/v1
GOTRUE_MAILER_URLPATHS_INVITE=https://yourdomain.com/auth/v1/verify
```

### 2. Test Email Invite
1. Generate a new user invite in Supabase Studio
2. Check the email content - URLs should use your domain
3. Click "Accept Invite" - should redirect to your domain, not localhost

### 3. Check JWT Token Issuer
```bash
# Decode a JWT token and check the 'iss' field
echo "JWT_TOKEN_HERE" | base64 -d
```

The `iss` field should be `https://yourdomain.com/auth/v1`, not localhost.

## Common Mistakes to Avoid

### ❌ Don't Rely on Config.toml Alone
```toml
# This won't fix email URLs
site_url = "https://yourdomain.com"
api_url = "https://yourdomain.com"
```

### ❌ Don't Use Environment Variables with supabase start
```bash
# This doesn't work
export GOTRUE_JWT_ISSUER="https://yourdomain.com/auth/v1"
supabase start  # Ignores the export
```

### ❌ Don't Forget to Delete Old Invites
Old invite tokens contain the old localhost URLs and can't be changed. Always generate fresh invites after fixing the URLs.

## CDK Implementation Pattern

```typescript
// Add to CDK user data script
'# Start Supabase first',
'sudo -u ubuntu bash -c "cd /home/ubuntu/supabase && supabase start"',
'',
'# Wait for containers to be ready',
'sleep 30',
'',
'# Fix the auth container URLs',
'docker stop supabase_auth_ubuntu',
'docker rm supabase_auth_ubuntu',
'',
domain ? `docker run -d --name supabase_auth_ubuntu --network supabase_default --restart unless-stopped -p 9999:9999 -e GOTRUE_SITE_URL=https://${domain} -e GOTRUE_JWT_ISSUER=https://${domain}/auth/v1 -e GOTRUE_MAILER_URLPATHS_INVITE=https://${domain}/auth/v1/verify -e GOTRUE_MAILER_URLPATHS_CONFIRMATION=https://${domain}/auth/v1/verify -e GOTRUE_MAILER_URLPATHS_RECOVERY=https://${domain}/auth/v1/verify -e GOTRUE_MAILER_URLPATHS_EMAIL_CHANGE=https://${domain}/auth/v1/verify [OTHER_ENV_VARS] public.ecr.aws/supabase/gotrue:v2.158.1 auth` : '',
```

## Why This Happens

1. **Supabase CLI is designed for local development** - it assumes localhost URLs
2. **Production deployment is an afterthought** - no built-in domain configuration
3. **Environment variable precedence is broken** - CLI overrides user settings
4. **Docker container generation is hardcoded** - no customization options

## Alternative: Use Supabase Cloud

If these workarounds are too complex, consider using Supabase Cloud instead of self-hosting. The cloud version handles domain configuration properly.

## Key Takeaways

1. **Supabase CLI hardcodes localhost URLs** - this is a fundamental limitation
2. **Config.toml settings don't affect email URLs** - only container environment variables matter
3. **Manual container recreation is required** for production domains
4. **Always test email invites** after any Supabase configuration changes
5. **Delete old invites** - they contain cached localhost URLs
6. **Automate the fix in your deployment scripts** - don't rely on manual steps

---

**Remember: This is a Supabase CLI bug/limitation, not a configuration error. The workarounds are necessary until the CLI properly supports custom domains.**
