# Supabase AWS SES Email Configuration

## Problem
Local Supabase not sending emails through AWS SES - emails going to local inbucket instead of external SMTP.

## Root Cause
1. Supabase CLI requires `.env` file in `supabase/` directory with `SUPABASE_` prefixed variables
2. Email rate limit was set too low (2 emails/hour)
3. Missing environment variable resolution in config.toml

## Solution Steps

### 1. Create supabase/.env file
```bash
# /supabase/.env
SUPABASE_AWS_SES_SMTP_USERNAME=your_ses_smtp_username
SUPABASE_AWS_SES_SMTP_PASSWORD=your_ses_smtp_password
SUPABASE_AWS_SES_FROM_EMAIL=no-reply@yourdomain.com
```

### 2. Update supabase/config.toml
```toml
[auth.email.smtp]
enabled = true
host = "email-smtp.us-east-1.amazonaws.com"
port = 587
user = "env(SUPABASE_AWS_SES_SMTP_USERNAME)"
pass = "env(SUPABASE_AWS_SES_SMTP_PASSWORD)"
admin_email = "env(SUPABASE_AWS_SES_FROM_EMAIL)"
sender_name = "Your App Name"

[auth.rate_limit]
email_sent = 100  # Increase from default 2
```

### 3. Enable email confirmations (if needed)
```toml
[auth.email]
enable_confirmations = true
```

### 4. Restart Supabase
```bash
pnpm supabase:reset
```

## Verification
- Check container environment: `docker exec supabase_auth_pravia-monorepo env | grep GOTRUE_SMTP`
- Should show actual AWS credentials, not `env(VARIABLE_NAME)`
- Test via API: `curl -X POST 'http://localhost:54321/auth/v1/invite'`

## Key Points
- Use `SUPABASE_` prefix for environment variables
- Place `.env` file in same directory as `config.toml`
- Increase email rate limit for development
- AWS SES domain must be verified
- Check spam folder for test emails
