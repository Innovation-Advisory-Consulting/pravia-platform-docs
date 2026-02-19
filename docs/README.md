# Documentation Directory

This directory contains comprehensive documentation for the Pravia CRM Platform, organized into specialized sections covering development, deployment, architecture, and tooling.

## Directory Structure

### `/development/`
Development guidelines and best practices for building and maintaining the platform:
- **API Best Practices** - Standards for API design, error handling, and endpoint structure
- **Environment Standards** - Configuration management and environment variable conventions
- **Testing Guide** - Jest testing strategies and Playwright roadmap
- **UI Components** - Reusable component library documentation
- **Standards** - Code quality, linting, and formatting rules
- **Swagger Exclusions** - API documentation configuration
- **Register API Frontend** - Guide for connecting new APIs to frontend applications

### `/getting-started/`
Quick start guides for new developers:
- **Quick Start** - Get the platform running in 2 minutes
- **Architecture Overview** - System design, microservices structure, and component relationships
- **Essential Commands** - Key pnpm commands for development workflow

### `/infrastructure/`
Production deployment and infrastructure management:
- **Deployment Guide** - Step-by-step AWS deployment using CDK
- **Monitoring & Dashboards** - CloudWatch setup, metrics, and alerting
- **Cost Estimation** - Monthly AWS cost breakdown and optimization strategies

### `/reference/`
Technical reference materials:
- **Project Structure** - Directory organization and workspace layout
- **API Documentation** - Links to Swagger/OpenAPI endpoints for each service
- **Troubleshooting** - Common issues, error messages, and solutions

### `/tools/`
AI-assisted development and automation:
- **MCP Extensions** - Model Context Protocol servers for enhanced AI capabilities
- **Coding Standards** - AI-specific coding guidelines and patterns
- **Component Extraction** - Automated component refactoring summaries
- **Contributing Guide** - How to contribute to the project

### `/_archive/`
Historical documentation and implementation records:
- **app-migrations/** - Legacy deduplication and migration guides
- **cortex-sessions/** - N8N workflow integration session logs
- **cortex-ui-plans/** - Workflow builder UI implementation plans
- **forge-tus-implementation/** - TUS resumable upload implementation logs
- **foundry-prompts/** - Historical AI prompts and boilerplate templates
- **kiro-sessions/** - Forge-Cortex integration session records
- **mule-client-prompts/** - Frontend integration guides (DataTable, Navigation)
- **nexus-implementation/** - Architecture specs and stored procedure migrations
- **old-prompts/** - Legacy AI prompts for various features
- **routing-implementation/** - Routing abstraction implementation logs
- **ui-implementations/** - UI feature implementation records (Dashboard, KB, Workflow Builder)
- **ui-tus-implementation/** - Frontend TUS upload integration guides

## Documentation Philosophy

- **Living Documentation** - Updated alongside code changes
- **Practical Examples** - Real-world code snippets and CLI commands
- **Progressive Disclosure** - Quick starts for beginners, deep dives for experts
- **AI-Friendly** - Structured for consumption by AI development tools via MCP

## Key Documentation Flows

### For New Developers
1. Start with `/getting-started/README.md`
2. Review `/getting-started/architecture.md`
3. Follow `/development/README.md` for local setup
4. Reference `/getting-started/commands.md` for daily workflow

### For DevOps/Infrastructure
1. Review `/infrastructure/README.md` for deployment overview
2. Check `/infrastructure/cost-estimation.md` for budget planning
3. Follow `/infrastructure/monitoring.md` for observability setup
4. Reference CDK stack READMEs in `/infra/aws/cdk/`

### For API Development
1. Read `/development/API_BEST_PRACTICES.md`
2. Follow `/development/ENVIRONMENT_STANDARDS.md`
3. Use `/development/REGISTER_API_FRONTEND.md` for frontend integration
4. Reference `/development/SWAGGER_EXCLUSIONS.md` for documentation

### For Frontend Development
1. Review `/development/ui-components.md`
2. Check `/development/standards.md` for code quality
3. Reference archived UI implementation guides in `/_archive/ui-implementations/`

## Maintenance

- Archive outdated documentation to `/_archive/` with timestamp
- Keep main sections focused on current implementation
- Update links when file structure changes
- Add new sections as platform evolves
