# SES Email Verification Best Practices for Amazon Q CLI

## CRITICAL: Always Use Domain Verification for Business Domains

When configuring AWS SES for email sending with business domains (like `asyml8.com`), **ALWAYS prioritize domain verification over individual email verification**.

## The Right Approach: Domain Verification First

### 1. Check Existing Domain Verification Status
```bash
aws ses get-identity-verification-attributes --identities "yourdomain.com" --region us-east-1
```

### 2. If Domain Not Verified, Verify the Entire Domain
```bash
# Verify domain (returns verification token)
aws ses verify-domain-identity --domain "yourdomain.com" --region us-east-1

# Add DNS TXT record to Route53 (if using Route53)
aws route53 change-resource-record-sets --hosted-zone-id "YOUR_ZONE_ID" --change-batch '{
  "Changes": [{
    "Action": "UPSERT",
    "ResourceRecordSet": {
      "Name": "_amazonses.yourdomain.com",
      "Type": "TXT",
      "TTL": 300,
      "ResourceRecords": [{"Value": "\"VERIFICATION_TOKEN_FROM_STEP_1\""}]
    }
  }]
}'
```

### 3. Wait for Domain Verification (1-5 minutes)
```bash
# Check verification status
aws ses get-identity-verification-attributes --identities "yourdomain.com" --region us-east-1
```

## Why Domain Verification is Superior

### ✅ Benefits of Domain Verification:
- **One verification covers ALL emails** on the domain (`no-reply@domain.com`, `support@domain.com`, etc.)
- **No individual email setup** required
- **Scalable** - new email addresses work automatically
- **Professional** - proper business domain setup
- **Future-proof** - any subdomain emails work too

### ❌ Problems with Individual Email Verification:
- **Requires separate verification** for each email address
- **Manual process** for every new email
- **Verification emails** must be received and clicked
- **Not scalable** for business use
- **Easy to forget** verification for new addresses

## Common SES Error Messages and Solutions

### Error: "Email address is not verified"
```
554 Message rejected: Email address is not verified. The following identities failed the check in region US-EAST-1: no-reply@yourdomain.com
```

**Solution:** Verify the domain, not the individual email.

### Error: "Domain verification pending"
**Solution:** Check DNS propagation and wait 1-5 minutes for verification to complete.

## Implementation Checklist for Supabase/GoTrue

When configuring email for Supabase or any application:

1. **✅ Verify domain first** - `aws ses verify-domain-identity`
2. **✅ Add DNS record** - `_amazonses.yourdomain.com` TXT record
3. **✅ Wait for verification** - Check status until "Success"
4. **✅ Configure application** - Use any `@yourdomain.com` email
5. **✅ Test email sending** - Should work immediately

## Configuration Examples

### Supabase config.toml
```toml
[auth.email.smtp]
host = "email-smtp.us-east-1.amazonaws.com"
port = 587
user = "YOUR_SMTP_USERNAME"
pass = "env(SES_SMTP_PASSWORD)"
admin_email = "no-reply@yourdomain.com"  # Works once domain is verified
sender_name = "Your Company"
```

### Environment Variables
```bash
export SES_SMTP_PASSWORD="your_smtp_password"
```

## Troubleshooting Steps

### If emails still fail after domain verification:

1. **Check domain verification status:**
   ```bash
   aws ses get-identity-verification-attributes --identities "yourdomain.com"
   ```

2. **Verify SMTP credentials work:**
   ```python
   import smtplib
   s = smtplib.SMTP('email-smtp.us-east-1.amazonaws.com', 587)
   s.starttls()
   s.login('USERNAME', 'PASSWORD')
   print('SES login successful')
   s.quit()
   ```

3. **Check application logs** for specific error messages

4. **Verify DNS propagation:**
   ```bash
   dig TXT _amazonses.yourdomain.com +short
   ```

## AWS CLI Commands Reference

### Domain Operations
```bash
# Verify domain
aws ses verify-domain-identity --domain "yourdomain.com"

# Check domain status
aws ses get-identity-verification-attributes --identities "yourdomain.com"

# List all verified identities
aws ses list-identities
```

### SMTP User Management
```bash
# Create SMTP user
aws iam create-user --user-name ses-smtp-user --path /ses/

# Attach SES sending policy
aws iam attach-user-policy --user-name ses-smtp-user --policy-arn arn:aws:iam::aws:policy/AmazonSESFullAccess

# Create access keys
aws iam create-access-key --user-name ses-smtp-user
```

## Key Takeaways for Amazon Q CLI

1. **NEVER start with individual email verification** for business domains
2. **ALWAYS check domain verification first** before troubleshooting email issues
3. **Domain verification is the scalable, professional solution**
4. **Individual email verification is only for personal/testing use cases**
5. **Wait for DNS propagation** - domain verification takes 1-5 minutes
6. **Test SMTP credentials separately** from application configuration

## When to Use Each Approach

### Use Domain Verification When:
- ✅ Business/production environment
- ✅ Multiple email addresses needed
- ✅ Professional domain (company.com)
- ✅ Scalable email solution required

### Use Individual Email Verification When:
- ❌ Personal projects only
- ❌ Single email address
- ❌ Testing/development with personal emails
- ❌ No access to domain DNS

---

**Remember: For business domains like `asyml8.com`, domain verification is always the correct first step. Individual email verification is a fallback for personal use cases only.**
