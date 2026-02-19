# Kiro CLI Configuration

## Overview
This directory contains configuration, instructions, and context for Kiro CLI - AWS's AI-assisted development tool. It provides the AI with project-specific knowledge, verification procedures, and development guidelines to ensure safe and accurate operations.

## Directory Structure

```
.kiro/
├── instructions.md                    # Mandatory AI instructions
├── project-context.md                 # Environment mapping
├── verification-checklist.md          # Operation verification procedures
├── scripts/                           # Utility scripts
│   ├── verify-db-connection.sh       # Database connection verification
│   └── run-db-query.sh               # Database query execution
├── context/                           # Development context
│   └── frontend/                     # Frontend-specific guides
│       ├── GENERATED_CODE_GUIDE.md   # Auto-generated code usage
│       └── ZUSTAND_SLICE_WIRING.md   # State management patterns
└── specs/                            # Project specifications
    └── ai-accelerator-platform/      # AI platform feature specs
        ├── requirements.md           # System requirements
        ├── design.md                 # Technical design
        └── tasks.md                  # Implementation tasks
```

## Core Configuration Files

### 1. instructions.md
**Purpose:** Mandatory rules and procedures for AI operations.

**Key Rules:**

**Database Operations:**
- ALWAYS verify environment before database operations
- NEVER claim success without proof
- Show query results and verification
- Explicitly state which environment (dev/test/uat/prod)
- Confirm with user before destructive operations

**Environment Verification:**
```bash
# Must run FIRST before any DB operation
./.kiro/scripts/verify-db-connection.sh <environment> <api-name>
```

**Critical Behaviors:**
- Show .env file path being used
- Display actual connection details
- Run connection test query
- Say "I'm not certain" instead of guessing
- Don't assume environment variable loading

**Environment Files Mapping:**
- `.env.development` → Dev (ahanrwalkdrbbhlhjxzr)
- `.env.test` → Test (gurgyegmjqbisdhbvoww)
- `.env.uat` → UAT (laorysvmqjaxatyzsgkj)

**TypeScript/Node.js Note:**
- dotenv does NOT auto-load `.env.<NODE_ENV>` files
- Must explicitly specify: `dotenv.config({ path: '.env.development' })`

### 2. project-context.md
**Purpose:** Environment mapping and database schema reference.

**Environment Mapping:**

| API | Environment | .env File | Supabase Project | Schema |
|-----|-------------|-----------|------------------|--------|
| Foundry | development | `.env.development` | ahanrwalkdrbbhlhjxzr | external_authentication |
| Foundry | test | `.env.test` | gurgyegmjqbisdhbvoww | external_authentication |
| Foundry | uat | `.env.uat` | laorysvmqjaxatyzsgkj | external_authentication |
| Flux | development | `.env.development` | ahanrwalkdrbbhlhjxzr | external_dataverse |
| Flux | test | `.env.test` | gurgyegmjqbisdhbvoww | external_dataverse |
| Flux | uat | `.env.uat` | laorysvmqjaxatyzsgkj | external_dataverse |
| Incidents | TBD | TBD | TBD | TBD |

**Database Schemas:**
- **Foundry**: `external_authentication` - User profiles, roles, authentication
- **Flux**: `external_dataverse` - Dataverse integration data
- **Incidents**: TBD

**Critical Rules:**
1. ALWAYS verify which .env file is being loaded
2. ALWAYS show Supabase project ref before operations
3. NEVER assume NODE_ENV maps correctly without verification
4. ALWAYS use schema-qualified table names in queries

### 3. verification-checklist.md
**Purpose:** Step-by-step verification procedures for database operations.

**Pre-Operation Checklist:**

**1. Verify Environment**
- [ ] Show actual .env file being used
- [ ] Display DATABASE_HOST, DATABASE_USERNAME, DATABASE_DB_NAME
- [ ] Confirm Supabase instance (project ref)

**2. Verify Connection**
- [ ] Run query: `SELECT current_database(), current_user, inet_server_addr()`
- [ ] Confirm matches expected environment

**3. Before Destructive Operations**
- [ ] List what will be affected (tables, schemas, data)
- [ ] Show preview query (SELECT instead of DELETE/DROP)
- [ ] Wait for explicit user confirmation

**4. After Operations**
- [ ] Verify operation completed as expected
- [ ] Show proof (query results, not assumptions)

**Never Assume:**
- Environment variables loaded correctly
- Command succeeded without verification
- Something is done without showing proof

## Utility Scripts

### verify-db-connection.sh
**Purpose:** Verify database connection and environment configuration.

**Usage:**
```bash
./.kiro/scripts/verify-db-connection.sh <environment> <api-name>
```

**Parameters:**
- `<environment>`: development, test, uat, production
- `<api-name>`: foundry, flux, incidents

**What It Does:**
1. Loads appropriate .env file
2. Displays connection parameters
3. Shows Supabase project reference
4. Runs test query to verify connection
5. Confirms database, user, and server address

**Example:**
```bash
./.kiro/scripts/verify-db-connection.sh development foundry

# Output:
Environment: development
.env file: api/foundry/.env.development
DATABASE_HOST: aws-0-us-east-1.pooler.supabase.com
DATABASE_USERNAME: postgres.ahanrwalkdrbbhlhjxzr
DATABASE_DB_NAME: postgres
Supabase Project: ahanrwalkdrbbhlhjxzr

Connection Test:
current_database | current_user | inet_server_addr
postgres         | postgres     | 54.123.45.67
✓ Connection verified
```

### run-db-query.sh
**Purpose:** Execute database queries with proper environment configuration.

**Usage:**
```bash
./.kiro/scripts/run-db-query.sh <environment> <api-name> "<query>"
```

**Example:**
```bash
./.kiro/scripts/run-db-query.sh development foundry \
  "SELECT * FROM external_authentication.profiles LIMIT 5"
```

## Development Context

### context/frontend/

#### GENERATED_CODE_GUIDE.md
**Purpose:** Guide for using auto-generated code from backend APIs.

**Content:**
- Generated services from Swagger/OpenAPI specs
- Auto-generated Zustand slices
- Shared TypeScript types
- Integration patterns
- Best practices for generated code

**Key Concepts:**

**1. Generated Services (API Layer)**
- Location: `packages/api-types/src/api/flux/services/`
- Auto-generated from backend Swagger
- Factory pattern for HTTP client injection
- All CRUD operations included

**2. Generated Zustand Slices**
- Location: `apps/mule-vite/src/store/slices/`
- State management for each entity
- TanStack Query integration
- Optimistic updates

**3. Shared Types**
- Location: `packages/api-types/src/api/flux/types/`
- TypeScript interfaces from backend DTOs
- Request/response types
- Validation schemas

#### ZUSTAND_SLICE_WIRING.md
**Purpose:** Patterns for connecting Zustand stores to components.

**Content:**
- Store creation patterns
- Slice composition
- Selector optimization
- DevTools integration
- Testing strategies

## Project Specifications

### specs/ai-accelerator-platform/

**Purpose:** Complete technical specifications for AI Accelerator Platform feature.

#### requirements.md (16KB)
**Content:**
- System introduction and glossary
- User stories and requirements
- Multi-agent workflow orchestration
- CrewAI integration
- Multi-tenant architecture
- Event-driven design

**Key Features:**
- Workflow definition and management
- Agent configuration
- Tool integration
- Knowledge base management
- Job execution and monitoring
- Version control
- Observability

#### design.md (111KB)
**Content:**
- Detailed technical design
- Architecture diagrams
- Database schema
- API specifications
- Integration patterns
- Security model
- Performance considerations

**Scope:**
- REST API layer
- Workflow orchestration
- Agent management
- Tool framework
- Knowledge base system
- Job execution engine
- Event publishing

#### tasks.md (12KB)
**Content:**
- Implementation task breakdown
- Development phases
- Dependencies
- Acceptance criteria
- Testing requirements
- Deployment steps

## Usage Guidelines

### For AI Assistants (Kiro)

**Session Start Procedure:**
1. Read `.kiro/project-context.md` for environment mapping
2. Read `.kiro/verification-checklist.md` for procedures
3. When user mentions environment, verify immediately

**Before Database Operations:**
1. Run verification script
2. Show environment details
3. Display connection info
4. Confirm with user
5. Execute operation
6. Verify results

**When Uncertain:**
- Say "I'm not certain" instead of guessing
- Show what was found
- Ask for clarification
- Don't make assumptions

### For Developers

**Adding New Environments:**
1. Update `project-context.md` with new mapping
2. Add environment to verification script
3. Document Supabase project reference
4. Update checklist if needed

**Adding New APIs:**
1. Add schema mapping to `project-context.md`
2. Update verification scripts
3. Document environment files
4. Add to instructions if special handling needed

**Adding Context:**
1. Create markdown files in `context/`
2. Organize by domain (frontend, backend, infra)
3. Keep guides focused and actionable
4. Update this overview

**Adding Specifications:**
1. Create directory in `specs/`
2. Include requirements, design, tasks
3. Keep specifications up to date
4. Link to related documentation

## Best Practices

### 1. Environment Safety
- Always verify before operations
- Never assume environment loading
- Show proof of operations
- Confirm destructive actions

### 2. Documentation
- Keep instructions current
- Document environment changes
- Update mappings immediately
- Include examples

### 3. Script Maintenance
- Test scripts regularly
- Handle errors gracefully
- Provide clear output
- Document parameters

### 4. Context Organization
- Group by domain
- Keep files focused
- Use clear naming
- Cross-reference related docs

### 5. Specification Management
- Version control specs
- Keep design synchronized with code
- Update tasks as work progresses
- Archive completed features

## Troubleshooting

### Issue 1: Wrong Environment Connected
**Symptom:** Operations affecting wrong database

**Solution:**
```bash
# Verify environment
./.kiro/scripts/verify-db-connection.sh <env> <api>

# Check .env file
cat api/<api-name>/.env.<environment>

# Verify Supabase project ref matches
```

### Issue 2: Environment Variables Not Loading
**Symptom:** Connection fails or uses wrong values

**Solution:**
```typescript
// Explicitly load .env file
import dotenv from 'dotenv';
dotenv.config({ path: `.env.${process.env.NODE_ENV}` });

// Verify loaded
console.log('DB Host:', process.env.DATABASE_HOST);
```

### Issue 3: Script Permission Denied
**Symptom:** Cannot execute verification scripts

**Solution:**
```bash
chmod +x .kiro/scripts/*.sh
```

### Issue 4: Outdated Context
**Symptom:** Instructions don't match current setup

**Solution:**
- Review recent changes
- Update affected documentation
- Test verification procedures
- Notify team of changes

## Related Documentation
- Kiro CLI: AWS Documentation
- Supabase: https://supabase.com/docs
- Environment Configuration: `docs/development/ENVIRONMENT_STANDARDS.md`
- Database Options: `docs/development/database-options.md`

## Maintenance

**Regular Updates:**
- Review instructions quarterly
- Update environment mappings when changed
- Verify scripts work with current setup
- Archive obsolete specifications

**When Adding Features:**
- Document in appropriate context file
- Update verification procedures if needed
- Add to specifications if major feature
- Update this overview

**Version Control:**
- Commit .kiro changes with related code
- Document breaking changes
- Tag specification versions
- Maintain change history
