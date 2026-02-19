# TUS Upload API - Complete Build Guide

> **Reference Architecture:** `/api/nexus` - Configuration Management API  
> **Target:** Build a production-ready TUS resumable upload API following Nexus patterns

---

## Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Project Setup](#project-setup)
4. [Database Design](#database-design)
5. [Entity Layer](#entity-layer)
6. [Repository Layer](#repository-layer)
7. [Service Layer](#service-layer)
8. [Controller Layer](#controller-layer)
9. [TUS Integration](#tus-integration)
10. [Testing](#testing)
11. [Deployment](#deployment)

---

## Overview

### What We're Building

A **resumable file upload API** using the TUS protocol that:
- Handles large file uploads with resume capability
- Stores metadata in PostgreSQL
- Supports multiple storage backends (S3, local filesystem)
- Follows NestJS + TypeORM patterns from Nexus API
- Provides REST endpoints for upload management

### Technology Stack

```typescript
// Core Framework
- NestJS 10.3.8
- Fastify 4.x (instead of Express)
- TypeORM 0.3.17
- PostgreSQL (Supabase)

// TUS Protocol
- @tus/server 2.3.0
- @tus/file-store 2.0.0
- @tus/s3-store 2.0.1

// Validation & Transformation
- class-validator 0.14.0
- class-transformer 0.5.1

// Shared Core
- @asyml8/api-core (workspace package)
```

### Key Features

✅ **Resumable Uploads** - Continue interrupted uploads  
✅ **Multi-Storage** - S3 or local filesystem  
✅ **Metadata Tracking** - Store upload info in PostgreSQL  
✅ **Progress Tracking** - Real-time upload progress  
✅ **Expiration** - Auto-cleanup of abandoned uploads  
✅ **Access Control** - User/tenant-based permissions  
✅ **Swagger Docs** - Auto-generated API documentation

---

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     TUS UPLOAD API                          │
│                   Schema: uploads (Supabase)                │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  CLIENT LAYER                                               │
├─────────────────────────────────────────────────────────────┤
│  Browser/Mobile App                                         │
│  └─ tus-js-client                                          │
│     └─ Handles chunking, retry, resume                     │
└─────────────────────────────────────────────────────────────┘
                          ↓ HTTP
┌─────────────────────────────────────────────────────────────┐
│  API LAYER (NestJS + Fastify)                              │
├─────────────────────────────────────────────────────────────┤
│  Controllers                                                │
│  ├─ UploadController      → /api/uploads (CRUD)           │
│  └─ TusController         → /files/* (TUS protocol)       │
│                                                             │
│  Services                                                   │
│  ├─ UploadService         → Business logic                │
│  ├─ TusService            → TUS lifecycle hooks           │
│  └─ StorageService        → Storage abstraction           │
│                                                             │
│  Repositories                                               │
│  └─ UploadRepository      → Database operations           │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│  STORAGE LAYER                                              │
├─────────────────────────────────────────────────────────────┤
│  @tus/server                                               │
│  ├─ Protocol Handler                                       │
│  ├─ Chunk Management                                       │
│  └─ Resume Logic                                           │
│                                                             │
│  Storage Backends                                           │
│  ├─ @tus/s3-store    → AWS S3 / Supabase Storage         │
│  └─ @tus/file-store  → Local filesystem                   │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│  DATA LAYER                                                 │
├─────────────────────────────────────────────────────────────┤
│  PostgreSQL (Supabase)                                      │
│  └─ uploads.upload                                         │
│     ├─ id, filename, size, status                         │
│     ├─ user_id, tenant_id                                 │
│     ├─ storage_path, storage_backend                      │
│     └─ metadata (JSONB)                                    │
└─────────────────────────────────────────────────────────────┘
```

### Module Structure

```
src/
├── modules/
│   ├── upload/
│   │   ├── entity/
│   │   │   └── upload.entity.ts
│   │   ├── dto/
│   │   │   ├── create-upload.dto.ts
│   │   │   ├── update-upload.dto.ts
│   │   │   └── upload-query.dto.ts
│   │   ├── upload.repository.ts
│   │   ├── upload.service.ts
│   │   ├── upload.controller.ts
│   │   └── upload.module.ts
│   │
│   ├── tus/
│   │   ├── tus.service.ts
│   │   ├── tus.controller.ts
│   │   ├── tus.module.ts
│   │   └── lifecycle/
│   │       ├── on-create.ts
│   │       ├── on-upload-finish.ts
│   │       └── on-error.ts
│   │
│   └── storage/
│       ├── storage.service.ts
│       ├── storage.module.ts
│       └── adapters/
│           ├── s3-adapter.ts
│           └── local-adapter.ts
│
├── database/
│   ├── migrations/
│   │   └── 1700000001000-CreateUploadTables.ts
│   ├── seeds/
│   │   └── upload-seed.ts
│   └── data-source.ts
│
├── config/
│   └── app.config.ts
│
├── app.module.ts
└── main.ts
```

---

## Project Setup

### Step 1: Create Project Structure

```bash
# Navigate to API directory
cd /Users/tonyhenderson/Documents/GitHub/faro/pravia-monorepo/api

# Create new NestJS project
mkdir tus-upload-api
cd tus-upload-api

# Initialize with NestJS CLI (or copy from nexus)
pnpm init
```

### Step 2: Install Dependencies

```bash
# Core dependencies
pnpm add @nestjs/common@10.3.8 \
         @nestjs/core@10.3.8 \
         @nestjs/platform-fastify@10.3.8 \
         @nestjs/typeorm@10.0.1 \
         @nestjs/config@3.2.2 \
         @nestjs/swagger@7.3.1 \
         typeorm@0.3.17 \
         pg@8.11.0 \
         fastify@4.0.0 \
         class-validator@0.14.0 \
         class-transformer@0.5.1 \
         reflect-metadata@0.1.13 \
         rxjs@7.8.1 \
         dotenv@16.4.0

# TUS dependencies
pnpm add @tus/server@2.3.0 \
         @tus/file-store@2.0.0 \
         @tus/s3-store@2.0.1

# Storage dependencies
pnpm add @supabase/supabase-js@2.38.0 \
         @aws-sdk/client-s3@3.654.0 \
         @aws-sdk/lib-storage@3.654.0

# Workspace dependency
pnpm add @asyml8/api-core@workspace:*

# Dev dependencies
pnpm add -D @nestjs/cli@10.3.2 \
            @nestjs/testing@10.3.8 \
            @types/node@20.3.1 \
            typescript@5.1.3 \
            ts-node@10.9.1 \
            tsconfig-paths@4.2.0 \
            prettier@3.0.0 \
            eslint@8.42.0
```

### Step 3: Configuration Files

**tsconfig.json**
```json
{
  "compilerOptions": {
    "module": "commonjs",
    "declaration": true,
    "removeComments": true,
    "emitDecoratorMetadata": true,
    "experimentalDecorators": true,
    "allowSyntheticDefaultImports": true,
    "target": "ES2021",
    "sourceMap": true,
    "outDir": "./dist",
    "baseUrl": "./",
    "incremental": true,
    "skipLibCheck": true,
    "strictNullChecks": false,
    "noImplicitAny": false,
    "strictBindCallApply": false,
    "forceConsistentCasingInFileNames": false,
    "noFallthroughCasesInSwitch": false,
    "paths": {
      "@/*": ["src/*"]
    }
  }
}
```

**nest-cli.json**
```json
{
  "$schema": "https://json.schemastore.org/nest-cli",
  "collection": "@nestjs/schematics",
  "sourceRoot": "src",
  "compilerOptions": {
    "deleteOutDir": true
  }
}
```

**.env.example**
```bash
# Application
NODE_ENV=development
PORT=4004
APP_TITLE=TUS Upload API
APP_DESCRIPTION=Resumable File Upload Service
SERVER_NAME=TUS Upload Server

# Database
DATABASE_ENABLED=true
DATABASE_HOST=aws-1-us-east-2.pooler.supabase.com
DATABASE_PORT=5432
DATABASE_USERNAME=postgres.kcoscwspccqppdoqnsdm
DATABASE_PASSWORD=your_password
DATABASE_DB_NAME=postgres
DATABASE_SCHEMA=uploads

# TUS Configuration
TUS_PATH=/files
TUS_MAX_SIZE=10737418240
TUS_PART_SIZE=5
TUS_EXPIRY_MS=86400000
TUS_STORAGE_BACKEND=s3

# S3/Supabase Storage
STORAGE_S3_BUCKET=uploads
STORAGE_S3_REGION=us-east-1
STORAGE_S3_ENDPOINT=https://your-project.supabase.co/storage/v1/s3
STORAGE_S3_ACCESS_KEY=your_access_key
STORAGE_S3_SECRET_KEY=your_secret_key

# Local Storage (alternative)
STORAGE_LOCAL_PATH=./uploads

# Swagger
SWAGGER_ENABLED=true
SWAGGER_PERSIST_AUTH=true
SWAGGER_GRADIENT_ENABLED=true
SWAGGER_GRADIENT_COLORS=#E67E22,#5DADE2,#2E86AB
```

**package.json scripts**
```json
{
  "scripts": {
    "dev": "nest start --watch",
    "build": "nest build",
    "start": "node dist/main",
    "start:prod": "node dist/main",
    "typeorm": "ts-node --project tsconfig.json -r tsconfig-paths/register ./node_modules/typeorm/cli.js",
    "migration:generate": "pnpm typeorm migration:generate -d src/database/data-source.ts",
    "migration:run": "pnpm typeorm migration:run -d src/database/data-source.ts",
    "migration:revert": "pnpm typeorm migration:revert -d src/database/data-source.ts",
    "seed": "ts-node -r tsconfig-paths/register src/database/seeds/run-seed.ts",
    "lint": "eslint \"{src,apps,libs,test}/**/*.ts\" --fix",
    "test": "jest",
    "test:watch": "jest --watch",
    "test:cov": "jest --coverage"
  }
}
```

---

## Database Design

### Schema: `uploads`

**Table: `upload`**

```sql
CREATE SCHEMA IF NOT EXISTS uploads;

CREATE TABLE uploads.upload (
  -- Base fields (from BaseEntity)
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
  deleted_at TIMESTAMP,
  
  -- Upload identification
  filename VARCHAR(500) NOT NULL,
  original_filename VARCHAR(500) NOT NULL,
  mime_type VARCHAR(100),
  size BIGINT NOT NULL,
  
  -- Upload status
  status VARCHAR(50) NOT NULL DEFAULT 'pending',
  -- pending, uploading, completed, failed, expired
  
  upload_offset BIGINT NOT NULL DEFAULT 0,
  upload_length BIGINT,
  
  -- Storage information
  storage_backend VARCHAR(50) NOT NULL,
  -- s3, local
  
  storage_path TEXT NOT NULL,
  storage_url TEXT,
  
  -- Access control
  user_id UUID,
  tenant_id UUID,
  
  -- TUS metadata
  tus_id VARCHAR(255) UNIQUE NOT NULL,
  upload_metadata JSONB,
  
  -- Expiration
  expires_at TIMESTAMP,
  
  -- Indexes
  CONSTRAINT upload_status_check CHECK (
    status IN ('pending', 'uploading', 'completed', 'failed', 'expired')
  )
);

CREATE INDEX idx_upload_user_id ON uploads.upload(user_id);
CREATE INDEX idx_upload_tenant_id ON uploads.upload(tenant_id);
CREATE INDEX idx_upload_status ON uploads.upload(status);
CREATE INDEX idx_upload_tus_id ON uploads.upload(tus_id);
CREATE INDEX idx_upload_expires_at ON uploads.upload(expires_at);
```

### Entity Relationships

```
User (auth schema)
  ↓ 1:N
Upload
  ↓ 1:1
Storage (S3/Local)
```

---

*Continue to Part 2 for Entity Layer implementation...*
