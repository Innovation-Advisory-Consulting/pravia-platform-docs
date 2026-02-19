# BinaryBlox Configuration System - NestJS/TypeORM Implementation Spec

## Overview
Implementation plan for migrating BinaryBlox Configuration architecture to NestJS/Fastify with TypeORM and PostgreSQL.

## Entity Architecture

### Core Entities

#### 1. **Configuration**
```typescript
@Entity('bx_configuration')
export class Configuration extends AuditableEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'configuration_template_id', type: 'uuid' })
  @Index()
  configurationTemplateId: string;

  @Column({ name: 'configuration_group_id', type: 'uuid' })
  @Index()
  configurationGroupId: string;

  @Column({ name: 'is_enabled', default: false })
  isEnabled: boolean;

  // Relations
  @ManyToOne(() => ConfigurationTemplate)
  @JoinColumn({ name: 'configuration_template_id' })
  template: ConfigurationTemplate;

  @OneToMany(() => ConfigurationAttribVal, val => val.configuration)
  attributeValues: ConfigurationAttribVal[];

  @OneToMany(() => ConfigurationMedia, media => media.configuration)
  media: ConfigurationMedia[];

  // Unique constraint
  @Index(['configurationTemplateId', 'configurationGroupId', 'name'], { unique: true })
}
```

#### 2. **ConfigurationTemplate**
```typescript
@Entity('bx_configuration_template')
export class ConfigurationTemplate extends AuditableEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'configuration_type_id', type: 'uuid' })
  configurationTypeId: string;

  @ManyToOne(() => ConfigurationType)
  @JoinColumn({ name: 'configuration_type_id' })
  configurationType: ConfigurationType;

  @OneToMany(() => AttribTemplate, template => template.configurationTemplate)
  attribTemplates: AttribTemplate[];

  @OneToMany(() => Configuration, config => config.template)
  configurations: Configuration[];
}
```

#### 3. **ConfigurationType**
```typescript
@Entity('bx_configuration_type')
export class ConfigurationType extends AuditableEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true })
  name: string;

  @OneToMany(() => ConfigurationTemplate, template => template.configurationType)
  templates: ConfigurationTemplate[];
}
```

#### 4. **AttribTemplate**
```typescript
@Entity('bx_attrib_template')
export class AttribTemplate extends AuditableEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'configuration_template_id', type: 'uuid' })
  configurationTemplateId: string;

  @Column({ name: 'attrib_val_type_id', type: 'uuid' })
  attribValTypeId: string;

  @Column({ name: 'sort_idx', type: 'int' })
  sortIdx: number;

  @Column({ type: 'text', nullable: true })
  options: string;

  @ManyToOne(() => ConfigurationTemplate)
  @JoinColumn({ name: 'configuration_template_id' })
  configurationTemplate: ConfigurationTemplate;

  @ManyToOne(() => AttribValType)
  @JoinColumn({ name: 'attrib_val_type_id' })
  attribValType: AttribValType;

  @OneToMany(() => ConfigurationAttribVal, val => val.attribTemplate)
  attributeValues: ConfigurationAttribVal[];
}
```

#### 5. **AttribValType**
```typescript
@Entity('bx_attrib_val_type')
export class AttribValType extends AuditableEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true })
  name: string;

  @Column({ type: 'text', nullable: true })
  description: string;

  @OneToMany(() => AttribTemplate, template => template.attribValType)
  attribTemplates: AttribTemplate[];
}
```

#### 6. **ConfigurationAttribVal**
```typescript
@Entity('bx_configuration_attrib_val')
export class ConfigurationAttribVal extends AuditableEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'configuration_id', type: 'uuid' })
  @Index()
  configurationId: string;

  @Column({ name: 'attrib_template_id', type: 'uuid' })
  @Index()
  attribTemplateId: string;

  @Column({ type: 'text' })
  value: string;

  @ManyToOne(() => Configuration)
  @JoinColumn({ name: 'configuration_id' })
  configuration: Configuration;

  @ManyToOne(() => AttribTemplate)
  @JoinColumn({ name: 'attrib_template_id' })
  attribTemplate: AttribTemplate;

  @OneToMany(() => ConfigurationAttribValOverride, override => override.attribVal)
  overrides: ConfigurationAttribValOverride[];
}
```

#### 7. **ConfigurationAttribValOverride**
```typescript
@Entity('bx_configuration_attrib_val_override')
export class ConfigurationAttribValOverride extends AuditableEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'attrib_val_id', type: 'uuid' })
  attribValId: string;

  @Column({ name: 'priority_rank_id', type: 'uuid' })
  priorityRankId: string;

  @Column({ type: 'text' })
  value: string;

  @Column({ name: 'is_enabled', default: true })
  isEnabled: boolean;

  @Column({ type: 'text', nullable: true })
  filter: string;

  @ManyToOne(() => ConfigurationAttribVal)
  @JoinColumn({ name: 'attrib_val_id' })
  attribVal: ConfigurationAttribVal;

  @ManyToOne(() => PriorityRank)
  @JoinColumn({ name: 'priority_rank_id' })
  priorityRank: PriorityRank;
}
```

#### 8. **PriorityRank**
```typescript
@Entity('bx_priority_rank')
export class PriorityRank extends AuditableEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true })
  name: string;

  @Column({ type: 'int' })
  rank: number;

  @OneToMany(() => ConfigurationAccessPriority, access => access.priorityRank)
  configurationAccess: ConfigurationAccessPriority[];

  @OneToMany(() => AttribAccessPriority, access => access.priorityRank)
  attribAccess: AttribAccessPriority[];
}
```

#### 9. **ConfigurationAccessPriority**
```typescript
@Entity('bx_configuration_access_priority')
export class ConfigurationAccessPriority extends AuditableEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'configuration_id', type: 'uuid' })
  configurationId: string;

  @Column({ name: 'priority_rank_id', type: 'uuid' })
  priorityRankId: string;

  @Column({ type: 'text', nullable: true })
  filter: string;

  @ManyToOne(() => Configuration)
  @JoinColumn({ name: 'configuration_id' })
  configuration: Configuration;

  @ManyToOne(() => PriorityRank)
  @JoinColumn({ name: 'priority_rank_id' })
  priorityRank: PriorityRank;
}
```

#### 10. **AttribAccessPriority**
```typescript
@Entity('bx_attrib_access_priority')
export class AttribAccessPriority extends AuditableEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'attrib_template_id', type: 'uuid' })
  attribTemplateId: string;

  @Column({ name: 'priority_rank_id', type: 'uuid' })
  priorityRankId: string;

  @Column({ type: 'text', nullable: true })
  filter: string;

  @ManyToOne(() => AttribTemplate)
  @JoinColumn({ name: 'attrib_template_id' })
  attribTemplate: AttribTemplate;

  @ManyToOne(() => PriorityRank)
  @JoinColumn({ name: 'priority_rank_id' })
  priorityRank: PriorityRank;
}
```

#### 11. **ConfigurationMedia**
```typescript
@Entity('bx_configuration_media')
export class ConfigurationMedia extends AuditableEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'configuration_id', type: 'uuid' })
  configurationId: string;

  @Column({ type: 'text' })
  url: string;

  @Column({ type: 'varchar', length: 100 })
  mediaType: string;

  @ManyToOne(() => Configuration)
  @JoinColumn({ name: 'configuration_id' })
  configuration: Configuration;
}
```

### Base Entity Classes

```typescript
// src/common/entities/auditable.entity.ts
export abstract class AuditableEntity {
  @Column({ name: 'name', type: 'varchar', length: 255 })
  name: string;

  @Column({ name: 'description', type: 'text', nullable: true })
  description: string;

  @Column({ name: 'guid_id', type: 'uuid', unique: true })
  @Generated('uuid')
  guidId: string;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  @Column({ name: 'created_by', type: 'uuid', nullable: true })
  createdBy: string;

  @Column({ name: 'updated_by', type: 'uuid', nullable: true })
  updatedBy: string;

  @DeleteDateColumn({ name: 'deleted_at', nullable: true })
  deletedAt: Date;
}
```

## Service Layer (Replacing Stored Procedures)

### ConfigurationMetadataService

```typescript
@Injectable()
export class ConfigurationMetadataService {
  constructor(
    @InjectRepository(Configuration)
    private configRepo: Repository<Configuration>,
    @InjectRepository(ConfigurationAttribVal)
    private attribValRepo: Repository<ConfigurationAttribVal>,
  ) {}

  /**
   * Replaces stored procedure: GetConfigurationMetadata
   * Retrieves complete configuration with all attributes and overrides
   */
  async getConfigurationMetadata(
    configurationId: string,
    priorityContext?: Record<string, any>
  ): Promise<ConfigurationMetadataDto> {
    const config = await this.configRepo
      .createQueryBuilder('config')
      .leftJoinAndSelect('config.template', 'template')
      .leftJoinAndSelect('template.configurationType', 'type')
      .leftJoinAndSelect('template.attribTemplates', 'attribTemplate')
      .leftJoinAndSelect('attribTemplate.attribValType', 'valType')
      .leftJoinAndSelect('config.attributeValues', 'attribVal')
      .leftJoinAndSelect('attribVal.overrides', 'override')
      .leftJoinAndSelect('override.priorityRank', 'priorityRank')
      .leftJoinAndSelect('config.media', 'media')
      .where('config.id = :configurationId', { configurationId })
      .andWhere('config.isEnabled = :enabled', { enabled: true })
      .getOne();

    if (!config) {
      throw new NotFoundException('Configuration not found');
    }

    return this.buildMetadataDto(config, priorityContext);
  }

  private buildMetadataDto(
    config: Configuration,
    priorityContext?: Record<string, any>
  ): ConfigurationMetadataDto {
    const attributes = config.template.attribTemplates.map(template => {
      const attribVal = config.attributeValues.find(
        val => val.attribTemplateId === template.id
      );

      const effectiveValue = this.resolveAttributeValue(
        attribVal,
        priorityContext
      );

      return {
        attribId: attribVal?.id,
        attribGuidId: attribVal?.guidId,
        attribTemplateId: template.id,
        attribTemplateGuidId: template.guidId,
        attribSortIdx: template.sortIdx,
        attribName: template.name,
        attribOrigin: this.determineOrigin(attribVal, priorityContext),
        attribValue: effectiveValue,
        attribDescription: template.description,
        attribValueType: template.attribValType.name,
        attribOptions: template.options,
        attribOvrEnabled: attribVal?.overrides?.some(o => o.isEnabled) ?? false,
        attribOvrStatus: this.getOverrideStatus(attribVal, priorityContext),
        attribOvrFilter: this.getActiveFilter(attribVal, priorityContext),
        attribMediaId: null, // Link to media if applicable
      };
    });

    return {
      configurationId: config.id,
      configurationName: config.name,
      configurationDescription: config.description,
      configurationType: config.template.configurationType.name,
      configurationEnabled: config.isEnabled,
      configurationGroupId: config.configurationGroupId,
      configurationTemplateId: config.configurationTemplateId,
      configurationTemplateName: config.template.name,
      configurationAccessFilter: null, // Implement access logic
      configurationAccess: null, // Implement access logic
      configurationGuidId: config.guidId,
      configurationLastModified: config.updatedAt,
      attributes,
    };
  }

  /**
   * Resolves attribute value based on priority and overrides
   */
  private resolveAttributeValue(
    attribVal: ConfigurationAttribVal | undefined,
    priorityContext?: Record<string, any>
  ): string {
    if (!attribVal) return null;

    // Get enabled overrides sorted by priority rank
    const applicableOverrides = attribVal.overrides
      ?.filter(override => {
        if (!override.isEnabled) return false;
        if (!override.filter) return true;
        return this.evaluateFilter(override.filter, priorityContext);
      })
      .sort((a, b) => a.priorityRank.rank - b.priorityRank.rank);

    // Return highest priority override or base value
    return applicableOverrides?.[0]?.value ?? attribVal.value;
  }

  /**
   * Evaluates filter expression against context
   */
  private evaluateFilter(
    filter: string,
    context?: Record<string, any>
  ): boolean {
    if (!context) return false;
    
    try {
      // Implement safe filter evaluation
      // Example: "userId === '123' && role === 'admin'"
      const func = new Function(...Object.keys(context), `return ${filter}`);
      return func(...Object.values(context));
    } catch {
      return false;
    }
  }

  private determineOrigin(
    attribVal: ConfigurationAttribVal | undefined,
    priorityContext?: Record<string, any>
  ): string {
    if (!attribVal) return 'template';
    
    const hasActiveOverride = attribVal.overrides?.some(
      o => o.isEnabled && (!o.filter || this.evaluateFilter(o.filter, priorityContext))
    );

    return hasActiveOverride ? 'override' : 'base';
  }

  private getOverrideStatus(
    attribVal: ConfigurationAttribVal | undefined,
    priorityContext?: Record<string, any>
  ): string {
    if (!attribVal?.overrides?.length) return 'none';
    
    const activeOverrides = attribVal.overrides.filter(
      o => o.isEnabled && (!o.filter || this.evaluateFilter(o.filter, priorityContext))
    );

    return activeOverrides.length > 0 ? 'active' : 'inactive';
  }

  private getActiveFilter(
    attribVal: ConfigurationAttribVal | undefined,
    priorityContext?: Record<string, any>
  ): string | null {
    const activeOverride = attribVal?.overrides
      ?.filter(o => o.isEnabled && (!o.filter || this.evaluateFilter(o.filter, priorityContext)))
      .sort((a, b) => a.priorityRank.rank - b.priorityRank.rank)[0];

    return activeOverride?.filter ?? null;
  }
}
```

## DTOs

```typescript
// src/configuration/dto/configuration-metadata.dto.ts
export class ConfigurationMetadataDto {
  configurationId: string;
  configurationName: string;
  configurationDescription: string;
  configurationType: string;
  configurationEnabled: boolean;
  configurationGroupId: string;
  configurationTemplateId: string;
  configurationTemplateName: string;
  configurationAccessFilter: string;
  configurationAccess: string;
  configurationGuidId: string;
  configurationLastModified: Date;
  attributes: ConfigurationAttribDataDto[];
}

export class ConfigurationAttribDataDto {
  attribId: string;
  attribGuidId: string;
  attribTemplateId: string;
  attribTemplateGuidId: string;
  attribSortIdx: number;
  attribName: string;
  attribOrigin: string;
  attribValue: string;
  attribDescription: string;
  attribValueType: string;
  attribOptions: string;
  attribOvrEnabled: boolean;
  attribOvrStatus: string;
  attribOvrFilter: string;
  attribMediaId: string;
}
```

## Controllers

```typescript
// src/configuration/controllers/configuration.controller.ts
@Controller('api/configurations')
@ApiTags('configurations')
export class ConfigurationController {
  constructor(
    private readonly configService: ConfigurationService,
    private readonly metadataService: ConfigurationMetadataService,
  ) {}

  @Get(':id/metadata')
  @ApiOperation({ summary: 'Get configuration with resolved attributes' })
  async getMetadata(
    @Param('id') id: string,
    @Query() priorityContext?: Record<string, any>
  ): Promise<ConfigurationMetadataDto> {
    return this.metadataService.getConfigurationMetadata(id, priorityContext);
  }

  @Get()
  async findAll(@Query() query: FindConfigurationsDto) {
    return this.configService.findAll(query);
  }

  @Post()
  async create(@Body() dto: CreateConfigurationDto) {
    return this.configService.create(dto);
  }

  @Patch(':id')
  async update(@Param('id') id: string, @Body() dto: UpdateConfigurationDto) {
    return this.configService.update(id, dto);
  }

  @Delete(':id')
  async remove(@Param('id') id: string) {
    return this.configService.remove(id);
  }
}
```

## Migrations

```typescript
// src/database/migrations/1234567890-CreateConfigurationTables.ts
export class CreateConfigurationTables1234567890 implements MigrationInterface {
  public async up(queryRunner: QueryRunner): Promise<void> {
    // Create configuration_type table
    await queryRunner.createTable(
      new Table({
        name: 'bx_configuration_type',
        columns: [
          { name: 'id', type: 'uuid', isPrimary: true, default: 'uuid_generate_v4()' },
          { name: 'name', type: 'varchar', length: '255', isUnique: true },
          { name: 'description', type: 'text', isNullable: true },
          { name: 'guid_id', type: 'uuid', isUnique: true, default: 'uuid_generate_v4()' },
          { name: 'created_at', type: 'timestamp', default: 'now()' },
          { name: 'updated_at', type: 'timestamp', default: 'now()' },
          { name: 'created_by', type: 'uuid', isNullable: true },
          { name: 'updated_by', type: 'uuid', isNullable: true },
          { name: 'deleted_at', type: 'timestamp', isNullable: true },
        ],
      })
    );

    // Create indexes
    await queryRunner.createIndex(
      'bx_configuration_type',
      new TableIndex({ columnNames: ['name'] })
    );

    // Continue with other tables...
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.dropTable('bx_configuration_type');
    // Drop other tables...
  }
}
```

## Module Structure

```
src/
├── configuration/
│   ├── entities/
│   │   ├── configuration.entity.ts
│   │   ├── configuration-template.entity.ts
│   │   ├── configuration-type.entity.ts
│   │   ├── attrib-template.entity.ts
│   │   ├── attrib-val-type.entity.ts
│   │   ├── configuration-attrib-val.entity.ts
│   │   ├── configuration-attrib-val-override.entity.ts
│   │   ├── priority-rank.entity.ts
│   │   ├── configuration-access-priority.entity.ts
│   │   ├── attrib-access-priority.entity.ts
│   │   └── configuration-media.entity.ts
│   ├── dto/
│   │   ├── configuration-metadata.dto.ts
│   │   ├── create-configuration.dto.ts
│   │   ├── update-configuration.dto.ts
│   │   └── find-configurations.dto.ts
│   ├── services/
│   │   ├── configuration.service.ts
│   │   ├── configuration-metadata.service.ts
│   │   ├── configuration-template.service.ts
│   │   └── attrib-template.service.ts
│   ├── controllers/
│   │   ├── configuration.controller.ts
│   │   ├── configuration-template.controller.ts
│   │   └── attrib-template.controller.ts
│   └── configuration.module.ts
├── common/
│   └── entities/
│       └── auditable.entity.ts
└── database/
    └── migrations/
        └── 1234567890-CreateConfigurationTables.ts
```

## Implementation Steps

1. **Phase 1: Core Entities** (Week 1)
   - Create base AuditableEntity
   - Implement all 11 entity classes
   - Create initial migrations

2. **Phase 2: Basic CRUD** (Week 1-2)
   - Implement services for each entity
   - Create DTOs
   - Build controllers with basic operations

3. **Phase 3: Metadata Service** (Week 2)
   - Implement ConfigurationMetadataService
   - Add priority resolution logic
   - Implement filter evaluation

4. **Phase 4: Testing** (Week 3)
   - Unit tests for services
   - Integration tests for metadata resolution
   - E2E tests for API endpoints

5. **Phase 5: Documentation & Optimization** (Week 3-4)
   - API documentation
   - Query optimization
   - Caching strategy

## Key Differences from SQL Server

1. **No Stored Procedures**: All logic in TypeScript services
2. **UUID Primary Keys**: Using PostgreSQL uuid type
3. **Soft Deletes**: Using TypeORM's @DeleteDateColumn
4. **JSON Columns**: For flexible attribute options
5. **Query Builder**: TypeORM QueryBuilder replaces complex SQL

## Next Steps

Please share the stored procedure code so I can provide specific TypeScript implementations for that business logic.
