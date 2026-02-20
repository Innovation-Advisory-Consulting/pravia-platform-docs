# Pravia Platform Documentation

> **Comprehensive architecture and development documentation for the Pravia CRM Platform**

[![Status](https://img.shields.io/badge/status-completed-success)](https://github.com/yourorg/pravia-platform-docs)
[![Version](https://img.shields.io/badge/version-1.0.0-blue)](https://github.com/yourorg/pravia-platform-docs)
[![Last Updated](https://img.shields.io/badge/updated-Feb%202026-orange)](https://github.com/yourorg/pravia-platform-docs)

---

## 📚 Quick Access

### 🎯 Main Documentation
- **[Platform Architecture Guide](./PLATFORM-ARCHITECTURE-GUIDE.md)** - Complete platform documentation (Markdown)
- **[Platform Architecture Guide](./PLATFORM-ARCHITECTURE-GUIDE.docx)** - Complete platform documentation (Word)

### 📖 Documentation by Component

| Component | Description | Documentation |
|-----------|-------------|---------------|
| **APIs** | Backend microservices (Foundry, Flux) | [api/README.md](./api/README.md) |
| **Apps** | Frontend applications (mule-vite) | [apps/README.md](./apps/README.md) |
| **Packages** | Shared packages (api-core, api-types, ui) | [packages/README.md](./packages/README.md) |
| **Infrastructure** | AWS, Azure, Docker, K8s | [infra/README.md](./infra/README.md) |
| **External Services** | n8n, Supabase | [external/README.md](./external/README.md) |
| **Scripts** | Generation and deployment scripts | [scripts/README.md](./scripts/README.md) |
| **Tools** | MCP servers, monitoring, quickstart | [tools/README.md](./tools/README.md) |
| **Docs** | Development guides and references | [docs/README.md](./docs/README.md) |

---

## 🚀 What's Included

### Platform Overview
- **Architecture:** Microservices with pnpm workspaces
- **Backend:** NestJS + Fastify APIs
- **Frontend:** React + Vite + Material-UI
- **Database:** PostgreSQL (Supabase)
- **Infrastructure:** AWS CDK + Azure Bicep
- **Deployment:** Azure Container Apps + Static Web Apps

### Documentation Coverage

✅ **Backend APIs**
- Foundry API (Authentication & Authorization)
- Flux API (Dataverse Data)
- API architecture and best practices

✅ **Frontend Applications**
- mule-vite (Main CRM application)
- State management (Zustand + TanStack Query)
- UI component library

✅ **Shared Packages**
- api-core (Backend utilities)
- api-types (TypeScript types & API contracts)
- ui (React component library)

✅ **Infrastructure**
- AWS CDK stacks (Foundation, Supabase)
- Azure Bicep templates (Container Apps)
- Docker Compose configurations
- Kubernetes manifests

✅ **Development Tools**
- MCP servers for AI-assisted development
- Monitoring tools (Faro Agent)
- Code generation scripts
- Deployment automation

✅ **External Services**
- n8n (Workflow automation)
- Supabase (Backend-as-a-Service)

---

## 📋 Table of Contents

The [Platform Architecture Guide](./PLATFORM-ARCHITECTURE-GUIDE.md) includes:

1. Project Overview
2. Project Structure
3. APIs - Backend Microservices
4. Kiro CLI Configuration
5. Husky - Git Hooks Manager
6. GitHub Configuration
7. Frontend Applications
8. Deployment
9. Shared Packages
10. Infrastructure
11. Tools and Scripts
12. Development Tools
13. Documentation
14. External Services
15. Change Log
16. Documentation Files Index

---

## 🎯 Quick Start Guides

### For New Developers
1. Read [Getting Started](./docs/getting-started/README.md)
2. Review [Architecture Overview](./docs/getting-started/architecture.md)
3. Follow [Development Workflow](./docs/development/README.md)

### For DevOps/Infrastructure
1. Review [Infrastructure Guide](./infra/README.md)
2. Check [Deployment Guide](./docs/infrastructure/README.md)
3. Review [Cost Estimation](./docs/infrastructure/cost-estimation.md)

### For API Development
1. Read [API Best Practices](./docs/development/API_BEST_PRACTICES.md)
2. Follow [Environment Standards](./docs/development/ENVIRONMENT_STANDARDS.md)
3. Use [API Generator](./scripts/api/README.md)

### For Frontend Development
1. Review [UI Components Guide](./docs/development/ui-components.md)
2. Check [Development Standards](./docs/development/standards.md)
3. Use [App Generator](./scripts/app/README.md)

---

## 🏗️ Architecture Highlights

### Multi-Cloud Strategy
- **AWS:** Foundation infrastructure (DNS, SSL, Email), Supabase hosting
- **Azure:** Container Apps for APIs, Static Web Apps for frontend

### Technology Stack
- **Backend:** NestJS, Fastify, TypeORM, PostgreSQL
- **Frontend:** React 19, Vite, Material-UI 7, Zustand, TanStack Query
- **Infrastructure:** AWS CDK, Azure Bicep, Docker, Kubernetes
- **Monitoring:** CloudWatch, Application Insights, Faro Agent

### Key Features
- Microservices architecture
- Monorepo with pnpm workspaces
- Self-hosted Supabase
- Auto-generated API types
- Shared UI component library
- CI/CD with GitHub Actions
- Multi-environment support

---

## 📊 Project Statistics

- **Total Folders Documented:** 12
- **Total README Files:** 12+
- **Documentation Files:** 150+
- **Lines of Documentation:** 5000+
- **Last Updated:** February 19, 2026

---

## 🤝 Contributing

This is a documentation repository. For contributions to the actual platform, please refer to the main project repository.

For documentation updates:
1. Fork this repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

---

## 📝 Version History

| Version | Date | Description |
|---------|------|-------------|
| 1.0.0 | Feb 19, 2026 | Initial complete documentation |
