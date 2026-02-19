# Configuration API - Standardized Implementation Plan

## 🎯 Goal
Implement BinaryBlox Configuration system following the **auth API pattern**:
- Module-based structure under `src/modules/`
- Repository pattern with dedicated repository classes
- BaseEntity from `@asyml8/api-core`
- Entities in `entity/` subdirectories
- DTOs in `dto/` subdirectories
- Migrations in `src/database/migrations/`

---

## 📁 Target Structure

```
api/config/src/
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
│   │   ├── configuration.controller.ts
│   │   ├── configuration.service.ts
│   │   ├── configuration.repository.ts
│   │   ├── configuration.module.ts
│   │   └── configuration.service.spec.ts
│   │
│   ├── attribute/
│   │   ├── entity/
│   │   │   ├── attrib-template.entity.ts
│   │   │   ├── attrib-val-type.entity.ts
│   │   │   ├── configuration-attrib-val.entity.ts
│   │   │   └── configuration-attrib-val-override.entity.ts
│   │   ├── dto/
│   │   │   ├── create-attrib-template.dto.ts
│   │   │   └── update-attrib-val.dto.ts
│   │   ├── attribute.controller.ts
│   │   ├── attribute.service.ts
│   │   ├── attribute.repository.ts
│   │   └── attribute.module.ts
│   │
│   ├── priority/
│   │   ├── entity/
│   │   │   ├── priority-rank.entity.ts
│   │   │   ├── configuration-access-priority.entity.ts
│   │   │   └── attrib-access-priority.entity.ts
│   │   ├── dto/
│   │   │   └── create-priority-rank.dto.ts
│   │   ├── priority.controller.ts
│   │   ├── priority.service.ts
│   │   ├── priority.repository.ts
│   │   └── priority.module.ts
│   │
│   ├── media/
│   │   ├── entity/
│   │   │   └── configuration-media.entity.ts
│   │   ├── dto/
│   │   │   └── create-media.dto.ts
│   │   ├── media.controller.ts
│   │   ├── media.service.ts
│   │   ├── media.repository.ts
│   │   └── media.module.ts
│   │
│   └── configuration-data/
│       ├── configuration-data.controller.ts
│       ├── configuration-data.service.ts
│       └── configuration-data.module.ts
│
├── database/
│   ├── migrations/
│   │   ├── 1700000000000-CreateConfigurationSchema.ts
│   │   ├── 1700000001000-CreateConfigurationTables.ts
│   │   ├── 1700000002000-CreateAttributeTables.ts
│   │   ├── 1700000003000-CreatePriorityTables.ts
│   │   └── 1700000004000-CreateConfigurationDataView.ts
│   └── scripts/
│       └── seed-configuration-types.ts
│
├── app.module.ts
├── database.module.ts
└── main.ts
```

---

## 🏗️ Implementation Steps

### Phase 1: Core Setup (Day 1)

#### 1.1 Base Entity Pattern
```typescript
// All entities extend BaseEntity from @asyml8/api-core
import { BaseEntity } from '@asyml8/api-core';

@Entity('bx_configuration', { schema: 'config' })
export class Configuration extends BaseEntity {
  // BaseEntity provides: id, createdAt, updatedAt, deletedAt
  
  @Column({ name: 'configuration_template_id', type: 'uuid' })
  configurationTemplateId: string;
  
  // ... other fields
}
```

#### 1.2 Repository Pattern
```typescript
// configuration.repository.ts
@Injectable()
export class ConfigurationRepository {
  constructor(
    @InjectRepository(Configuration)
    private readonly repo: Repository<Configuration>,
  ) {}

  async findByGroupId(groupId: string): Promise<Configuration[]> {
    return this.repo.find({ where: { configurationGroupId: groupId } });
  }

  // Custom query methods
}
```

#### 1.3 Module Structure
```typescript
// configuration.module.ts
@Module({
  imports: [
    TypeOrmModule.forFeature([
      Configuration,
      ConfigurationTemplate,
      ConfigurationType,
    ]),
  ],
  controllers: [ConfigurationController],
  providers: [ConfigurationService, ConfigurationRepository],
  exports: [ConfigurationService],
})
export class ConfigurationModule {}
```

---

### Phase 2: Entity Implementation (Day 2-3)

#### Module 1: Configuration Module
**Entities:**
- `Configuration` - Main configuration records
- `ConfigurationTemplate` - Configuration blueprints
- `ConfigurationType` - Configuration categories

**Endpoints:**
- `GET /api/configurations` - List all
- `GET /api/configurations/:id` - Get one
- `POST /api/configurations` - Create
- `PATCH /api/configurations/:id` - Update
- `DELETE /api/configurations/:id` - Soft delete

#### Module 2: Attribute Module
**Entities:**
- `AttribTemplate` - Attribute definitions
- `AttribValType` - Value type definitions (string, number, boolean, etc.)
- `ConfigurationAttribVal` - Attribute values
- `ConfigurationAttribValOverride` - Priority-based overrides

**Endpoints:**
- `GET /api/attributes/templates` - List templates
- `GET /api/attributes/values` - List values
- `POST /api/attributes/values` - Create value
- `PATCH /api/attributes/values/:id` - Update value
- `POST /api/attributes/overrides` - Create override

#### Module 3: Priority Module
**Entities:**
- `PriorityRank` - Priority levels (1=highest)
- `ConfigurationAccessPriority` - Config-level access rules
- `AttribAccessPriority` - Attribute-level access rules

**Endpoints:**
- `GET /api/priorities/ranks` - List ranks
- `POST /api/priorities/ranks` - Create rank
- `GET /api/priorities/access` - List access rules

#### Module 4: Media Module
**Entities:**
- `ConfigurationMedia` - Media attachments

**Endpoints:**
- `GET /api/media` - List media
- `POST /api/media` - Upload media
- `DELETE /api/media/:id` - Remove media

#### Module 5: Configuration Data Module
**Special module for stored procedure replacement**

**Endpoints:**
- `GET /api/configuration-data/configurations` - Replaces sp with GetAllBxConfigurationData
- `GET /api/configuration-data/attributes` - Replaces sp with GetAllBxConfigurationAttribData

---

### Phase 3: Migrations (Day 4)

#### Migration 1: Schema
```typescript
// 1700000000000-CreateConfigurationSchema.ts
export class CreateConfigurationSchema1700000000000 implements MigrationInterface {
  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.createSchema('config', true);
  }
}
```

#### Migration 2: Core Tables
```typescript
// 1700000001000-CreateConfigurationTables.ts
- bx_configuration_type
- bx_configuration_template
- bx_configuration
```

#### Migration 3: Attribute Tables
```typescript
// 1700000002000-CreateAttributeTables.ts
- bx_attrib_val_type
- bx_attrib_template
- bx_configuration_attrib_val
- bx_configuration_attrib_val_override
```

#### Migration 4: Priority Tables
```typescript
// 1700000003000-CreatePriorityTables.ts
- bx_priority_rank
- bx_configuration_access_priority
- bx_attrib_access_priority
```

#### Migration 5: View
```typescript
// 1700000004000-CreateConfigurationDataView.ts
- vw_bx_configuration_data (PostgreSQL view)
```

---

### Phase 4: Testing (Day 5)

#### Unit Tests
```typescript
// configuration.service.spec.ts
describe('ConfigurationService', () => {
  let service: ConfigurationService;
  let repository: ConfigurationRepository;

  beforeEach(async () => {
    const module = await Test.createTestingModule({
      providers: [
        ConfigurationService,
        {
          provide: ConfigurationRepository,
          useValue: mockRepository,
        },
      ],
    }).compile();

    service = module.get(ConfigurationService);
  });

  it('should find by group id', async () => {
    // test implementation
  });
});
```

#### Integration Tests
```typescript
// configuration.controller.spec.ts (e2e)
describe('ConfigurationController (e2e)', () => {
  it('GET /api/configurations', () => {
    return request(app.getHttpServer())
      .get('/api/configurations?groupId=123')
      .expect(200)
      .expect((res) => {
        expect(res.body).toBeInstanceOf(Array);
      });
  });
});
```

---

## 🔑 Key Patterns from Auth API

### 1. BaseEntity Usage
```typescript
// ✅ DO: Extend BaseEntity
export class Configuration extends BaseEntity {
  // Inherits: id, createdAt, updatedAt, deletedAt
}

// ❌ DON'T: Define these manually
```

### 2. Repository Pattern
```typescript
// ✅ DO: Separate repository class
@Injectable()
export class ConfigurationRepository {
  constructor(
    @InjectRepository(Configuration)
    private readonly repo: Repository<Configuration>,
  ) {}
}

// ❌ DON'T: Put queries directly in service
```

### 3. Module Organization
```typescript
// ✅ DO: Feature-based modules
modules/
  configuration/
  attribute/
  priority/

// ❌ DON'T: Flat structure
entities/
services/
controllers/
```

### 4. Schema Separation
```typescript
// ✅ DO: Use schema
@Entity('user_profiles', { schema: 'external' })
@Entity('bx_configuration', { schema: 'config' })

// ❌ DON'T: Default public schema
```

### 5. DTO Validation
```typescript
// ✅ DO: Use class-validator
export class CreateConfigurationDto {
  @IsUUID()
  configurationTemplateId: string;

  @IsBoolean()
  @IsOptional()
  isEnabled?: boolean;
}
```

---

## 📊 Entity Mapping from .NET

| .NET ViewModel | TypeScript Entity | Module |
|----------------|-------------------|--------|
| BxConfigurationViewModel | Configuration | configuration |
| BxConfigurationTemplateViewModel | ConfigurationTemplate | configuration |
| BxConfigurationTypeViewModel | ConfigurationType | configuration |
| BxAttribTemplateViewModel | AttribTemplate | attribute |
| BxAttribValTypeViewModel | AttribValType | attribute |
| BxConfigurationAttribValViewModel | ConfigurationAttribVal | attribute |
| BxConfigurationAttribValOverrideViewModel | ConfigurationAttribValOverride | attribute |
| BxPriorityRankViewModel | PriorityRank | priority |
| BxConfigurationAccessPriorityViewModel | ConfigurationAccessPriority | priority |
| BxAttribAccessPriorityViewModel | AttribAccessPriority | priority |
| BxConfigurationMediaViewModel | ConfigurationMedia | media |
| BxConfigurationMetadataViewModel | ConfigurationMetadataDto | configuration-data |
| BxConfigurationAttribDataViewModel | ConfigurationAttribDataDto | configuration-data |

---

## 🚀 Quick Start Commands

```bash
# 1. Create module structure
mkdir -p src/modules/{configuration,attribute,priority,media,configuration-data}/{entity,dto}

# 2. Generate migrations
pnpm migration:generate CreateConfigurationSchema
pnpm migration:generate CreateConfigurationTables

# 3. Run migrations
pnpm migration:run

# 4. Start dev server
pnpm dev

# 5. Run tests
pnpm test
pnpm test:e2e
```

---

## ✅ Checklist

### Setup
- [ ] Create module directories
- [ ] Install dependencies (already done)
- [ ] Configure database.module.ts

### Configuration Module
- [ ] Create entities (Configuration, ConfigurationTemplate, ConfigurationType)
- [ ] Create DTOs
- [ ] Create repository
- [ ] Create service
- [ ] Create controller
- [ ] Create module
- [ ] Write tests

### Attribute Module
- [ ] Create entities (4 entities)
- [ ] Create DTOs
- [ ] Create repository
- [ ] Create service
- [ ] Create controller
- [ ] Create module
- [ ] Write tests

### Priority Module
- [ ] Create entities (3 entities)
- [ ] Create DTOs
- [ ] Create repository
- [ ] Create service
- [ ] Create controller
- [ ] Create module
- [ ] Write tests

### Media Module
- [ ] Create entity
- [ ] Create DTOs
- [ ] Create repository
- [ ] Create service
- [ ] Create controller
- [ ] Create module
- [ ] Write tests

### Configuration Data Module
- [ ] Create service (stored procedure replacement)
- [ ] Create controller
- [ ] Create module
- [ ] Create view entity
- [ ] Write tests

### Database
- [ ] Create schema migration
- [ ] Create table migrations (4 migrations)
- [ ] Create view migration
- [ ] Create seed scripts
- [ ] Test migrations

### Documentation
- [ ] Update README.md
- [ ] Add Swagger documentation
- [ ] Create API examples
- [ ] Document migration from .NET

---

## 🎯 Success Criteria

1. ✅ All entities extend BaseEntity
2. ✅ Repository pattern used consistently
3. ✅ Module-based organization matches auth API
4. ✅ Entities in `entity/` subdirectories
5. ✅ DTOs in `dto/` subdirectories
6. ✅ Migrations in `database/migrations/`
7. ✅ All endpoints have Swagger docs
8. ✅ Unit tests for all services
9. ✅ Integration tests for all controllers
10. ✅ Stored procedures replaced with TypeScript

---

## 📝 Notes

- Use `config` schema for all tables (like `external` in auth API)
- Follow naming: `bx_*` for tables (matches .NET project)
- Use snake_case for database columns
- Use camelCase for TypeScript properties
- All IDs are UUIDs
- Soft deletes via BaseEntity's deletedAt
- Audit fields via BaseEntity (createdAt, updatedAt)
