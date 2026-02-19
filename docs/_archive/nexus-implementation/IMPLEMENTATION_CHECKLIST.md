# Configuration API - Complete Implementation Checklist

## ✅ What We Have

### 📋 Documentation Created
- [x] `IMPLEMENTATION_SPEC.md` - Original detailed spec with entities
- [x] `STANDARDIZED_IMPLEMENTATION_PLAN.md` - Follows auth API patterns
- [x] `STORED_PROCEDURE_MIGRATION.md` - SQL to TypeScript migration
- [x] `REAL_WORLD_EXAMPLE.md` - McDonald's delivery app example with JSON
- [x] `ARCHITECTURE_VISUAL.md` - Complete visual architecture (updated, no prefix)
- [x] `ARCHITECTURE_CLEAN.md` - Clean version without prefix
- [x] `ERD.md` - Mermaid ERD diagram

### 🗄️ Database Info
- **Host:** aws-1-us-east-2.pooler.supabase.com
- **Database:** postgres
- **Schema:** external
- **Port:** 4003 (API)
- **Tables:** 11 + 1 view (no prefix)

### 📦 Entities Defined (11 + 1 view)
1. Configuration
2. ConfigurationTemplate
3. ConfigurationType
4. AttribTemplate
5. AttribValType
6. ConfigurationAttribVal
7. ConfigurationAttribValOverride
8. PriorityRank
9. ConfigurationAccessPriority
10. AttribAccessPriority
11. ConfigurationMedia
12. ConfigurationDataView (view)

### 🎮 Controllers Defined (11)
1. ConfigurationController
2. ConfigurationTemplateController
3. ConfigurationTypeController
4. AttribTemplateController
5. AttribValTypeController
6. ConfigurationAttribValController
7. AttribValOverrideController
8. PriorityRankController
9. ConfigAccessPriorityController
10. AttribAccessPriorityController
11. ConfigurationMediaController
12. ConfigurationDataController (special - stored proc replacement)

### 🔧 Services Created
- `configuration-data.service.ts` - Stored procedure replacement
- `configuration-data.controller.ts` - REST endpoints
- `configuration-data.view.ts` - View entity

---

## 🚀 Implementation Steps

### Phase 1: Setup (30 min)
```bash
cd /Users/tonyhenderson/Documents/GitHub/faro/pravia-monorepo/api/config

# Create module structure
mkdir -p src/modules/{configuration,attribute,priority,media,configuration-data}/{entity,dto}
mkdir -p src/database/migrations

# Verify dependencies (already installed)
# @nestjs/typeorm, typeorm, pg, @asyml8/api-core
```

### Phase 2: Base Entity (15 min)
Create common base - already using `@asyml8/api-core` BaseEntity

### Phase 3: Entities (2-3 hours)
Create 11 entity files in respective module `entity/` folders:
- Use BaseEntity from `@asyml8/api-core`
- Schema: `external`
- No prefix on table names
- All columns defined in ERD.md

### Phase 4: DTOs (1-2 hours)
Create DTOs in respective module `dto/` folders:
- CreateDto, UpdateDto for each entity
- Use class-validator decorators
- Follow auth API patterns

### Phase 5: Repositories (1 hour)
Create repository files following auth API pattern:
```typescript
@Injectable()
export class ConfigurationRepository {
  constructor(
    @InjectRepository(Configuration)
    private readonly repo: Repository<Configuration>,
  ) {}
}
```

### Phase 6: Services (2-3 hours)
Create service files with business logic:
- CRUD operations
- ConfigurationMetadataService for stored proc replacement
- Priority resolution logic

### Phase 7: Controllers (2 hours)
Create controller files with REST endpoints:
- Standard CRUD endpoints
- Swagger documentation
- Query parameters for context

### Phase 8: Modules (1 hour)
Create module files:
```typescript
@Module({
  imports: [TypeOrmModule.forFeature([...entities])],
  controllers: [...controllers],
  providers: [...services, ...repositories],
  exports: [...services],
})
```

### Phase 9: Migrations (2 hours)
Create 5 migration files:
1. CreateConfigurationSchema
2. CreateConfigurationTables
3. CreateAttributeTables
4. CreatePriorityTables
5. CreateConfigurationDataView

### Phase 10: Testing (3-4 hours)
- Unit tests for services
- Integration tests for controllers
- E2E tests

---

## 📁 File Structure Reference

```
src/
├── modules/
│   ├── configuration/
│   │   ├── entity/
│   │   │   ├── configuration.entity.ts
│   │   │   ├── configuration-template.entity.ts
│   │   │   └── configuration-type.entity.ts
│   │   ├── dto/
│   │   │   ├── create-configuration.dto.ts
│   │   │   ├── update-configuration.dto.ts
│   │   │   └── configuration-metadata.dto.ts
│   │   ├── configuration.repository.ts
│   │   ├── configuration.service.ts
│   │   ├── configuration.controller.ts
│   │   ├── configuration.module.ts
│   │   └── configuration.service.spec.ts
│   │
│   ├── attribute/
│   │   ├── entity/ (4 entities)
│   │   ├── dto/
│   │   ├── *.repository.ts
│   │   ├── *.service.ts
│   │   ├── *.controller.ts
│   │   └── *.module.ts
│   │
│   ├── priority/
│   │   ├── entity/ (3 entities)
│   │   ├── dto/
│   │   ├── *.repository.ts
│   │   ├── *.service.ts
│   │   ├── *.controller.ts
│   │   └── *.module.ts
│   │
│   ├── media/
│   │   ├── entity/ (1 entity)
│   │   ├── dto/
│   │   ├── *.repository.ts
│   │   ├── *.service.ts
│   │   ├── *.controller.ts
│   │   └── *.module.ts
│   │
│   └── configuration-data/
│       ├── configuration-data.service.ts (DONE)
│       ├── configuration-data.controller.ts (DONE)
│       ├── configuration-data.view.ts (DONE)
│       └── configuration-data.module.ts
│
├── database/
│   └── migrations/
│       ├── 1700000000000-CreateConfigurationSchema.ts
│       ├── 1700000001000-CreateConfigurationTables.ts
│       ├── 1700000002000-CreateAttributeTables.ts
│       ├── 1700000003000-CreatePriorityTables.ts
│       └── 1700000004000-CreateConfigurationDataView.ts
│
├── app.module.ts
└── main.ts
```

---

## 🔑 Key Patterns to Follow

### 1. Entity Pattern
```typescript
import { Entity, Column } from 'typeorm';
import { BaseEntity } from '@asyml8/api-core';

@Entity('configuration', { schema: 'external' })
export class Configuration extends BaseEntity {
  @Column({ name: 'configuration_template_id', type: 'uuid' })
  configurationTemplateId: string;
  
  @Column({ name: 'configuration_group_id', type: 'uuid' })
  configurationGroupId: string;
  
  @Column({ name: 'is_enabled', default: false })
  isEnabled: boolean;
}
```

### 2. Repository Pattern
```typescript
@Injectable()
export class ConfigurationRepository {
  constructor(
    @InjectRepository(Configuration)
    private readonly repo: Repository<Configuration>,
  ) {}

  async findByGroupId(groupId: string): Promise<Configuration[]> {
    return this.repo.find({ where: { configurationGroupId: groupId } });
  }
}
```

### 3. Service Pattern
```typescript
@Injectable()
export class ConfigurationService {
  constructor(
    private readonly repository: ConfigurationRepository,
  ) {}

  async findAll(query: FindConfigurationsDto) {
    return this.repository.findByGroupId(query.groupId);
  }
}
```

### 4. Controller Pattern
```typescript
@Controller('api/configurations')
@ApiTags('configurations')
export class ConfigurationController {
  constructor(private readonly service: ConfigurationService) {}

  @Get()
  async findAll(@Query() query: FindConfigurationsDto) {
    return this.service.findAll(query);
  }
}
```

### 5. Module Pattern
```typescript
@Module({
  imports: [TypeOrmModule.forFeature([Configuration])],
  controllers: [ConfigurationController],
  providers: [ConfigurationService, ConfigurationRepository],
  exports: [ConfigurationService],
})
export class ConfigurationModule {}
```

---

## 📊 Quick Reference

### Table Names (external schema)
```
configuration
configuration_template
configuration_type
attrib_template
attrib_val_type
configuration_attrib_val
configuration_attrib_val_override
priority_rank
configuration_access_priority
attrib_access_priority
configuration_media
vw_configuration_data (VIEW)
```

### API Routes
```
/api/configurations
/api/configuration-templates
/api/configuration-types
/api/attrib-templates
/api/attrib-val-types
/api/configuration-attrib-vals
/api/attrib-val-overrides
/api/priority-ranks
/api/config-access-priorities
/api/attrib-access-priorities
/api/configuration-media
/api/configuration-data/configurations
/api/configuration-data/attributes
```

---

## ✅ Ready to Build?

**You have:**
- ✅ Complete ERD diagram
- ✅ All entity definitions
- ✅ All controller endpoints
- ✅ Database connection info
- ✅ Stored procedure replacement code
- ✅ Real-world example with JSON
- ✅ Performance optimization recommendations
- ✅ Auth API patterns to follow
- ✅ File structure
- ✅ Implementation timeline

**Start with:**
```bash
# 1. Create module structure
mkdir -p src/modules/{configuration,attribute,priority,media,configuration-data}/{entity,dto}

# 2. Create first entity
# src/modules/configuration/entity/configuration.entity.ts

# 3. Create migration
pnpm migration:generate CreateConfigurationSchema
```

Everything is documented and ready! 🚀
