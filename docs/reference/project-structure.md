# Project Structure

[← Back to Main](../../README.md) | [📋 All Docs](../../README.md#-quick-navigation)

## Root Directory

```
pravia-monorepo/
├── apps/                    # Frontend and backend applications
├── packages/                # Shared libraries and utilities
├── infra/                   # Infrastructure as Code
├── docs/                    # Documentation
├── docker-compose.*.yml     # Local development containers
├── package.json             # Root package configuration
└── pnpm-workspace.yaml      # Workspace configuration
```

## Applications (`/apps`)

```
apps/
├── pravia-web/              # Frontend Next.js app
├── pravia-platform-api/     # Core CRM API
├── pravia-data-api/         # Data sync API
├── pravia-auth-api/         # Authentication API
└── pravia-compliance-api/    # Compliance API
```

## Shared Packages (`/packages`)

```
packages/
├── ui/                      # Shared UI components (Storybook)
├── database/                # Database schemas and migrations
├── shared/                  # Common utilities and types
└── config/                  # Shared configuration
```

## Infrastructure (`/infra`)

```
infra/
├── cdk/
│   ├── foundation-infra/    # Shared AWS resources (DNS, SSL, SES)
│   └── supabase-infra/      # Application infrastructure (EC2, ALB)
└── compose/                 # Docker Compose configurations
```

## Documentation (`/docs`)

```
docs/
├── getting-started/         # Quick start guides
├── development/             # Local development setup
├── infrastructure/          # Deployment and AWS setup
└── reference/              # Technical reference materials
```

## Key Configuration Files

| File | Purpose |
|------|---------|
| `pnpm-workspace.yaml` | Defines workspace packages |
| `package.json` | Root scripts and dependencies |
| `docker-compose.*.yml` | Local development services |
| `supabase/config.toml` | Supabase local configuration |
| `infra/aws/cdk/*/cdk.json` | CDK application configuration |

## Development Workflow

1. **Root Level**: Run workspace commands (`pnpm dev`, `pnpm build`)
2. **App Level**: Individual application development
3. **Package Level**: Shared component development
4. **Infrastructure Level**: AWS deployment and configuration
