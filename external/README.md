# External Services

This directory contains configuration and setup for external third-party services that integrate with the Pravia CRM Platform. These services are self-hosted or managed separately from the main application stack.

## Directory Structure

```
external/
├── n8n/            # Workflow automation platform
└── supabase/       # Backend-as-a-Service (Database, Auth, Storage)
```

---

## 1. n8n - Workflow Automation Platform

**Purpose:** Self-hosted workflow automation tool for orchestrating tasks and integrating services across the Pravia ecosystem.

**Version:**
- n8n: v1.21.1
- PostgreSQL: 15-alpine

### What is n8n?

n8n is a workflow automation platform that allows you to:
- Connect different services and APIs
- Automate repetitive tasks
- Create complex workflows with visual editor
- Trigger actions based on events
- Schedule automated jobs

### Use Cases in Pravia

- **Data Synchronization** - Sync data between Dataverse and Supabase
- **Notification Workflows** - Send emails, SMS, or push notifications
- **API Orchestration** - Chain multiple API calls together
- **Scheduled Tasks** - Run periodic data processing jobs
- **Webhook Handlers** - Process incoming webhooks from external services

### Configuration

**Docker Compose Setup:**
- n8n container (port 5678)
- PostgreSQL database for persistence
- Shared network with other services

**Database:**
- Type: PostgreSQL 16
- Host: host.docker.internal
- Port: 5432
- Database: nexus_db
- Schema: external_n8n
- User: nexus

**Environment Variables:**
- `N8N_BASIC_AUTH_USER` - Admin username
- `N8N_BASIC_AUTH_PASSWORD` - Admin password
- `POSTGRES_PASSWORD` - Database password
- `WEBHOOK_URL` - Webhook base URL
- `GENERIC_TIMEZONE` - Timezone for scheduled workflows

### Quick Start

**Start n8n:**
```bash
# From monorepo root
pnpm n8n:start

# Or from external/n8n directory
docker compose up -d
```

**Stop n8n:**
```bash
pnpm n8n:stop
```

**View Logs:**
```bash
docker compose logs -f n8n
```

**Access:**
- URL: http://localhost:5678
- Initial Setup: Create owner account on first access
  - Email: admin@localhost
  - Password: Admin123 (change in production)

### Integration with APIs

**Helix API Integration (port 4005):**
- n8n can trigger Helix endpoints via HTTP requests
- Helix can call n8n webhooks for workflow automation
- Use n8n to orchestrate multi-service workflows

**Example Webhook URL:**
```
http://localhost:5678/webhook/helix-trigger
```

### Data Persistence

- **n8n_data volume** - Workflow definitions, credentials, executions
- **external_n8n schema** - Database tables in shared PostgreSQL

### Backup

**Export Workflows:**
```bash
docker exec n8n n8n export:workflow --all --output=/home/node/.n8n/backups/
docker cp n8n:/home/node/.n8n/backups/ ./backups/
```

**Backup Database:**
```bash
docker exec n8n-postgres pg_dump -U n8n n8n > backup.sql
```

### Security Notes

⚠️ **Production Deployment:**
- Use strong passwords (not Admin123)
- Enable HTTPS
- Configure proper authentication (OAuth, SAML)
- Restrict network access
- Use environment-specific secrets
- Enable 2FA if available

### Documentation Files

- `external/n8n/README.md` - Complete documentation
- `external/n8n/SETUP.md` - Installation summary
- `external/n8n/WORKFLOW_SETUP.md` - Workflow setup guide
- `external/n8n/docker-compose.yml` - Docker configuration
- `external/n8n/.env.example` - Environment template
- `external/n8n/create-workflow.sh` - Workflow creation script

### Resources

- [n8n Documentation](https://docs.n8n.io/)
- [n8n Community](https://community.n8n.io/)
- [Docker Hub - n8n](https://hub.docker.com/r/n8nio/n8n)

---

## 2. Supabase - Backend-as-a-Service

**Purpose:** Self-hosted Supabase instance providing PostgreSQL database, authentication, storage, and real-time subscriptions.

### What is Supabase?

Supabase is an open-source Firebase alternative that provides:
- **PostgreSQL Database** - Relational database with full SQL support
- **Authentication** - User management, JWT tokens, OAuth providers
- **Storage** - File storage with CDN
- **Real-time** - WebSocket subscriptions for live data
- **Auto-generated APIs** - REST and GraphQL APIs from database schema
- **Row Level Security** - Database-level access control

### Use Cases in Pravia

- **User Authentication** - JWT-based auth for all applications
- **Database** - Primary data store for application data
- **File Storage** - Document uploads, attachments, media files
- **Real-time Updates** - Live data synchronization across clients
- **Admin API** - User management via Supabase Admin SDK

### Configuration

**config.toml:**
- Main Supabase configuration file
- Defines services, ports, and settings
- Configures auth providers and email templates

**Email Templates:**
Located in `external/supabase/templates/`:
- `confirm.html` - Email confirmation template
- `invite.html` - User invitation template
- `magic_link.html` - Magic link login template
- `email_change.html` - Email change confirmation
- `recovery.html` - Password recovery template

### Environment Setup

**Local Development:**
```bash
# Start Supabase locally
supabase start

# Access:
# - Studio: http://localhost:54323
# - API: http://localhost:54321
# - DB: postgresql://postgres:postgres@localhost:54322/postgres
```

**Environment Files:**
- `.env` - Local Supabase configuration
- Contains API keys and connection strings

### Database Schemas

Supabase hosts multiple schemas for different services:

| Schema | Purpose | Used By |
|--------|---------|---------|
| `external_authentication` | User auth and profiles | Foundry API |
| `external_dataverse` | Business data | Flux API |
| `external_n8n` | Workflow automation | n8n |
| `public` | Supabase system tables | Supabase |

### Integration with APIs

**Foundry API (Authentication):**
- Uses Supabase Admin SDK for user management
- Validates JWT tokens from Supabase Auth
- Manages user profiles in `external_authentication` schema

**Flux API (Data):**
- Connects to `external_dataverse` schema
- Manages business data (accounts, contacts, submissions)
- Uses Supabase connection pooling

**Frontend Applications:**
- Use Supabase Client SDK for authentication
- Direct database access via Supabase APIs
- Real-time subscriptions for live updates

### Deployment Environments

| Environment | Project ID | URL |
|-------------|-----------|-----|
| Local | localhost | http://localhost:54321 |
| Development | ahanrwalkdrbbhlhjxzr | https://ahanrwalkdrbbhlhjxzr.supabase.co |
| Test | gurgyegmjqbisdhbvoww | https://gurgyegmjqbisdhbvoww.supabase.co |
| UAT | laorysvmqjaxatyzsgkj | https://laorysvmqjaxatyzsgkj.supabase.co |

### Email Configuration

Supabase uses AWS SES for email delivery:
- Configured in `config.toml`
- Custom HTML templates in `templates/` directory
- Supports email confirmation, invites, password recovery

### Security

**Authentication:**
- JWT-based authentication
- Refresh token rotation
- Session management
- OAuth provider support (Google, GitHub, etc.)

**Row Level Security (RLS):**
- Database-level access control
- Policies defined per table
- User-specific data isolation

**API Keys:**
- `anon` key - Public, client-side use
- `service_role` key - Private, server-side only (full access)

### Backup and Migration

**Database Migrations:**
```bash
# Create migration
supabase migration new migration_name

# Apply migrations
supabase db push
```

**Backup:**
```bash
# Dump database
pg_dump -h localhost -p 54322 -U postgres postgres > backup.sql
```

### Monitoring

- **Supabase Studio** - Web UI for database management
- **Logs** - Real-time logs for auth, database, storage
- **Metrics** - API usage, database performance

### Documentation Files

- `external/supabase/config.toml` - Main configuration (13KB)
- `external/supabase/.env` - Environment variables
- `external/supabase/templates/` - Email templates (5 files)
  - confirm.html
  - invite.html
  - magic_link.html
  - email_change.html
  - recovery.html

### Resources

- [Supabase Documentation](https://supabase.com/docs)
- [Supabase CLI](https://supabase.com/docs/guides/cli)
- [Self-Hosting Guide](https://supabase.com/docs/guides/self-hosting)

---

## Service Dependencies

### Dependency Graph

```
Frontend Apps (mule-vite)
    ↓
Supabase (Auth + Database)
    ↓
Backend APIs (Foundry, Flux)
    ↓
n8n (Workflow Automation)
```

### Network Communication

- **Frontend → Supabase** - Direct connection for auth and data
- **APIs → Supabase** - Database connections via connection string
- **APIs → n8n** - HTTP webhooks for workflow triggers
- **n8n → APIs** - HTTP requests for service orchestration

---

## Development Workflow

### Starting All External Services

```bash
# Start Supabase
supabase start

# Start n8n
pnpm n8n:start

# Verify services
curl http://localhost:54321/health  # Supabase
curl http://localhost:5678          # n8n
```

### Stopping Services

```bash
# Stop n8n
pnpm n8n:stop

# Stop Supabase
supabase stop
```

---

## Best Practices

### n8n

- **Version Control** - Export workflows regularly
- **Credentials** - Use environment variables, not hardcoded values
- **Error Handling** - Add error workflows for failed executions
- **Testing** - Test workflows in development before production
- **Monitoring** - Set up alerts for failed workflows

### Supabase

- **Migrations** - Always use migrations for schema changes
- **RLS Policies** - Enable RLS on all tables with sensitive data
- **Backups** - Regular database backups
- **API Keys** - Never expose `service_role` key to clients
- **Connection Pooling** - Use connection pooling for high traffic

---

## Troubleshooting

### n8n Issues

**Issue:** Cannot connect to n8n
```bash
# Check container status
docker compose ps

# View logs
docker compose logs n8n
```

**Issue:** Database connection failed
```bash
# Restart services
docker compose down
docker compose up -d
```

### Supabase Issues

**Issue:** Supabase not starting
```bash
# Check status
supabase status

# View logs
supabase logs
```

**Issue:** Database migration failed
```bash
# Reset local database
supabase db reset
```

---

## Related Documentation

- [Infrastructure Guide](../docs/infrastructure/README.md)
- [API Documentation](../api/API-OVERVIEW.md)
- [Deployment Guide](../docs/infrastructure/README.md)
- [Environment Standards](../docs/development/ENVIRONMENT_STANDARDS.md)
