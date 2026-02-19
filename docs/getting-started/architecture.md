# Architecture Overview

[← Back to Main](../../README.md) | [📋 All Docs](../../README.md#-quick-navigation)

## Introduction

The Pravia CRM platform is built with a modern, scalable architecture that combines the flexibility of microservices with the developer experience of a monorepo. This design enables rapid development while maintaining production-grade reliability, security, and performance.

Our architecture emphasizes:
- **Modularity** - Independent services with clear boundaries
- **Scalability** - Serverless and containerized components that scale automatically
- **Developer Experience** - Shared tooling, type safety, and hot reload across all services
- **Production Ready** - Built-in monitoring, security, and compliance features
- **Modern UI/UX** - Material Design System with accessibility-first components and responsive design
- **Container-First** - Docker-native development and deployment for consistency across environments
- **Infrastructure as Code** - CDK-first approach ensuring reproducible, version-controlled infrastructure
- **Platform Accelerator** - Pre-built patterns and templates for rapid feature development
- **GenAI Ready** - API-first architecture with structured data models optimized for AI integration
- **Enterprise Security** - Role-based access control, audit trails, and compliance-ready frameworks

## System Architecture

```
┌─────────────────────┐    ┌─────────────────────┐    ┌─────────────────────┐
│      Frontend       │    │    Backend APIs     │    │   Infrastructure    │
│                     │    │                     │    │                     │
│ • pravia-web        │◄──►│ • pravia-platform   │◄──►│ • Self-hosted       │
│ • Next.js/React     │    │ • pravia-auth       │    │   Supabase          │
│ • MUI Components    │    │ • pravia-data       │◄─┐ │   - PostgreSQL      │
│                     │    │ • pravia-compliance │  │ │   - Auth Service    │
│                     │    │                     │  │ │   - File Storage    │
│                     │    │                     │  │ │   - Realtime API    │
│                     │    │                     │  │ │ • AWS (CDK)         │
│                     │    │                     │  │ │   - EC2/ECS         │
│                     │    │                     │  │ │   - Lambda          │
│                     │    │                     │  │ │   - Load Balancer   │
│                     │    │                     │  │ │   - S3 Storage      │
│                     │    │                     │  │ │   - SES Email       │
└─────────────────────┘    └─────────────────────┘  │ └─────────────────────┘
                                                    │
                           ┌────────────────────────┘
                           │
                           ▼
                    ┌─────────────────────┐    ┌─────────────────────┐
                    │   External Systems  │    │     Monitoring      │
                    │                     │    │                     │
                    │ • Dataverse         │    │ • CloudWatch        │
                    │   (or other         │    │ • SNS Alerts        │
                    │    platforms)       │    │ • Application Logs  │
                    └─────────────────────┘    │ • Performance       │
                                               │   Metrics           │
                                               └─────────────────────┘
```

## 🛠️ Tech Stack

### **Frontend & UI**
- **[Next.js 15](https://nextjs.org/)** - React framework with App Router and Server Components
- **[React](https://react.dev/)** - Latest version with concurrent features and Suspense
- **[TypeScript](https://www.typescriptlang.org/)** - Type-safe development with strict mode
- **[Material-UI v7](https://mui.com/)** - Modern design system with Material Design 3
- **[TanStack Query](https://tanstack.com/query/latest)** - Advanced data fetching with optimistic updates
- **[Storybook](https://storybook.js.org/)** - Component development and design system documentation
- **Accessibility First** - WCAG 2.1 AA compliance, screen reader support, keyboard navigation
- **Responsive Design** - Mobile-first approach with fluid layouts and adaptive components
- **Dark Mode Support** - System preference detection with manual toggle

### **Backend Services**
- **[Node.js](https://nodejs.org/)** - Runtime environment
- **[NestJS](https://nestjs.com/)/[Fastify](https://fastify.dev/)** - Backend framework with high performance
- **[TypeScript](https://www.typescriptlang.org/)** - Server-side type safety
- **[TypeORM](https://typeorm.io/)** - Database ORM with PostgreSQL
- **[PostgreSQL](https://www.postgresql.org/)** - Primary database
- **[AWS Lambda](https://aws.amazon.com/lambda/)** - Serverless functions with Docker images
- **[Supabase](https://supabase.com/)** - Self-hosted backend-as-a-service
  - Real-time subscriptions
  - Authentication & authorization
  - File storage with CDN
  - Edge functions (Deno runtime)

### **Infrastructure & DevOps**
- **[AWS CDK](https://aws.amazon.com/cdk/)** - Infrastructure as Code
- **[Docker](https://www.docker.com/) & [Docker Compose](https://docs.docker.com/compose/)** - Containerization
- **[AWS Lambda](https://aws.amazon.com/lambda/)** - Serverless compute with container images
- **[AWS EC2](https://aws.amazon.com/ec2/)** - Compute instances for Supabase
- **[Application Load Balancer](https://aws.amazon.com/elasticloadbalancing/application-load-balancer/)** - Traffic routing
- **[Route53](https://aws.amazon.com/route53/)** - DNS management
- **[SES](https://aws.amazon.com/ses/)** - Email delivery
- **[CloudWatch](https://aws.amazon.com/cloudwatch/)** - Monitoring and logging

### **Development Tools**
- **[pnpm](https://pnpm.io/)** - Fast, disk space efficient package manager
- **[Turborepo](https://turbo.build/)** - Monorepo build system
- **[ESLint](https://eslint.org/) & [Prettier](https://prettier.io/)** - Code quality and formatting
- **[Supabase CLI](https://supabase.com/docs/guides/cli)** - Local development environment

### **Architecture Patterns**
- **Monorepo** - Unified codebase with workspace management and atomic deployments
- **Microservices** - Independent, scalable service architecture with clear domain boundaries
- **Infrastructure as Code** - CDK-first approach with reproducible, version-controlled deployments
- **Container-First** - Docker-native development with multi-stage builds and optimized images
- **Self-hosted SaaS** - Complete control with SaaS-like experience and enterprise features
- **Serverless + Containers** - Lambda functions with Docker images for optimal performance
- **API-First Design** - OpenAPI specifications with auto-generated clients and documentation
- **Event-Driven Architecture** - Pub/sub patterns for loose coupling and async processing

### **Platform Accelerator Features**
- **Code Generation** - Automated API endpoints, database schemas, and UI components
- **Template Library** - Pre-built patterns for common CRM workflows and integrations
- **Plugin Architecture** - Extensible framework for custom business logic and third-party integrations
- **Configuration Management** - Feature flags, environment-specific settings, and A/B testing
- **Rapid Prototyping** - Hot reload, mock data generation, and instant preview environments

### **GenAI Integration Ready**
- **Structured Data Models** - Normalized schemas optimized for machine learning workflows
- **API-First Architecture** - RESTful endpoints with consistent data formats for AI consumption
- **Real-time Data Streams** - WebSocket connections for live AI model inference and updates
- **Vector Database Support** - PostgreSQL with pgvector extension for semantic search and embeddings
- **Audit Trail Integration** - Comprehensive logging for AI decision tracking and compliance
- **Scalable Compute** - Lambda and ECS integration for on-demand AI model execution

## 🏗️ Modular Architecture

### **Service-Oriented Design**
The Pravia platform follows a microservices architecture with clear separation of concerns. Each API service handles a specific domain:

- **Platform API** - Core business logic, CRM operations, and data management
- **Auth API** - User authentication, authorization, and session management  
- **Data API** - ETL processes, external integrations, and data synchronization
- **Compliance API** - Regulatory compliance, SAML/OIDC identity providers, audit trails

This modular approach enables independent development, testing, and deployment of each service while maintaining loose coupling through well-defined APIs.

### **Shared Library Ecosystem**
The monorepo includes reusable packages that promote consistency and reduce duplication:

- **UI Package** - Standardized React components built on Material-UI, ensuring consistent user experience
- **SDK Package** - Type-safe API clients and shared TypeScript interfaces for seamless service communication
- **Utils Package** - Common utilities, validation schemas, and helper functions
- **Config Package** - Environment configuration management and feature flags

## 🔒 Security & Compliance

### **Enterprise-Grade Security**
- **Role-Based Access Control (RBAC)** - Granular permissions with hierarchical role inheritance
- **Multi-Factor Authentication** - TOTP, SMS, and hardware key support with backup codes
- **Single Sign-On (SSO)** - SAML 2.0 and OpenID Connect integration with enterprise identity providers
- **Session Management** - JWT tokens with refresh rotation, device tracking, and concurrent session limits
- **API Security** - Rate limiting, request signing, and API key management with scoped permissions
- **Zero-Trust Architecture** - Network segmentation, mutual TLS, and continuous verification

### **Data Protection & Privacy**
- **Encryption Everywhere** - AES-256 encryption at rest, TLS 1.3 in transit, and field-level encryption
- **Data Sovereignty** - Self-hosted deployment with complete data residency control
- **Privacy by Design** - GDPR/CCPA compliance with consent management and right to deletion
- **Audit Logging** - Immutable audit trails with tamper detection and compliance reporting
- **Data Loss Prevention** - Automated PII detection, data classification, and access monitoring
- **Backup Security** - Encrypted backups with point-in-time recovery and cross-region replication

### **Compliance Ready**
- **SOC 2 Type II** - Security controls framework with continuous monitoring and reporting
- **HIPAA Ready** - Healthcare compliance with BAA support and PHI protection (when configured)
- **ISO 27001** - Information security management system with risk assessment frameworks
- **PCI DSS** - Payment card industry compliance for secure payment processing integration
- **GDPR/CCPA** - Privacy regulation compliance with automated data subject request handling

## 🚀 Future-Proof Technology Choices

### **Scalability & Performance**
- **Serverless Architecture** - AWS Lambda with container images for automatic scaling
- **Database Optimization** - PostgreSQL with read replicas, connection pooling
- **CDN Integration** - Global content delivery through CloudFront
- **Caching Strategy** - Redis for session storage, application-level caching

### **Technology Evolution**
- **TypeScript First** - Type safety across the entire stack reduces bugs and improves maintainability
- **Modern React** - Latest patterns (App Router, Server Components) for optimal performance
- **Container Native** - Docker-first approach enables easy migration between cloud providers
- **Infrastructure as Code** - CDK ensures reproducible deployments and easy environment management

### **Extensibility**
- **Plugin Architecture** - Modular design allows easy addition of new features and integrations
- **API-First Design** - RESTful APIs with OpenAPI documentation enable third-party integrations
- **Event-Driven** - Pub/sub patterns through SNS/SQS for loose coupling and async processing
- **Multi-Tenant Ready** - Architecture supports both single and multi-tenant deployments

## 🔄 Reusability & Maintainability

### **Code Reuse Strategy**
- **Monorepo Benefits** - Shared dependencies, unified tooling, and atomic cross-service changes
- **Component Library** - Reusable UI components reduce development time and ensure consistency
- **Shared Business Logic** - Common validation, formatting, and utility functions
- **Template-Based Deployment** - CDK constructs and patterns for rapid environment provisioning

### **Development Experience**
- **Hot Reload** - Fast development cycles with instant feedback
- **Type Safety** - End-to-end TypeScript prevents runtime errors
- **Automated Testing** - Unit, integration, and E2E tests with CI/CD pipelines
- **Documentation** - Auto-generated API docs, Storybook components, and architectural decision records

This architecture balances immediate development needs with long-term scalability, security, and maintainability requirements.

- **pravia-web** - Frontend React/Next.js application
- **pravia-platform-api** - Core backend API service
- **pravia-data-api** - Data synchronization and ETL API
- **pravia-auth-api** - Authentication API service
- **pravia-compliance-api** - Compliance and regulatory API for SAML/OIDC

## Packages (Shared Libraries)

- **ui** - Shared React/MUI component library
- **utils** - Shared TypeScript utilities
- **config** - Shared configuration and environment parsing
- **sdk** - Shared API client and TypeScript types

## Infrastructure Layers

### Local Development
- **Docker Compose** - Local Supabase stack
- **PostgreSQL** - Simple database option
- **pnpm Workspaces** - Monorepo management

### Production (AWS)
- **Foundation Stack** - DNS, SSL, storage (shared)
- **Supabase Stack** - Application infrastructure per environment
- **CDK** - Infrastructure as Code

---
**Navigation**: [← Getting Started](./README.md) | [Next: Commands →](./commands.md)
