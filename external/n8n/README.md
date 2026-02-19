# n8n Self-Hosted Automation Platform

Self-hosted n8n workflow automation platform with PostgreSQL database for the Pravia ecosystem.

## Version

**n8n**: v1.21.1  
**PostgreSQL**: 15-alpine

## Overview

n8n is a workflow automation tool that allows you to connect various services and automate tasks. This setup uses PostgreSQL for persistent storage instead of SQLite.

## Quick Start

### Start n8n

```bash
# From monorepo root
pnpm n8n:start

# Or from this directory
docker compose up -d
```

### Stop n8n

```bash
# From monorepo root
pnpm n8n:stop

# Or from this directory
docker compose down
```

### View Logs

```bash
docker compose logs -f n8n
```

## Access

- **URL**: http://localhost:5678
- **Initial Setup**: Create owner account on first access
  - Email: admin@localhost (or your email)
  - Password: Admin123 (or your choice)
  - First/Last Name: Your choice

## Configuration

### Environment Variables

Copy `.env.example` to `.env` and customize:

```bash
cp .env.example .env
```

Key settings:
- `N8N_BASIC_AUTH_USER`: Admin username
- `N8N_BASIC_AUTH_PASSWORD`: Admin password
- `POSTGRES_PASSWORD`: Database password
- `WEBHOOK_URL`: Webhook base URL for integrations
- `GENERIC_TIMEZONE`: Timezone for scheduled workflows

### Database

- **Type**: PostgreSQL 16 (shared nexus-postgres)
- **Host**: host.docker.internal
- **Port**: 5432
- **Database**: nexus_db
- **Schema**: external_n8n
- **User**: nexus

## Integration with Helix API

The Helix API (port 4005) is designed to work with n8n:

1. **Webhooks**: n8n can trigger Helix endpoints
2. **HTTP Requests**: Helix can call n8n webhooks
3. **Workflow Automation**: Use n8n to orchestrate Pravia services

### Example Webhook URL
```
http://localhost:5678/webhook/helix-trigger
```

## Data Persistence

All workflow data is persisted:
- **n8n_data**: Workflow definitions, credentials, executions (Docker volume)
- **external_n8n schema**: Database tables in shared nexus-postgres

## Security Notes

⚠️ **Production Deployment**:
- Use strong passwords (not Admin123)
- Enable HTTPS
- Configure proper authentication (OAuth, SAML)
- Restrict network access
- Use environment-specific secrets
- Enable 2FA if available

## Backup

### Backup Workflows

```bash
# Export all workflows
docker exec n8n n8n export:workflow --all --output=/home/node/.n8n/backups/

# Copy from container
docker cp n8n:/home/node/.n8n/backups/ ./backups/
```

### Backup Database

```bash
docker exec n8n-postgres pg_dump -U n8n n8n > backup.sql
```

## Troubleshooting

### Reset Database

```bash
docker compose down -v
docker compose up -d
```

### Check Container Status

```bash
docker compose ps
```

### View All Logs

```bash
docker compose logs
```

## Resources

- [n8n Documentation](https://docs.n8n.io/)
- [n8n Community](https://community.n8n.io/)
- [Docker Hub - n8n](https://hub.docker.com/r/n8nio/n8n)

## Version History

- **1.21.1** (Current) - Initial setup with PostgreSQL backend
