# **Comprehensive NestJS Shared Module Migration Troubleshooting Prompt**

## **Problem Statement**
When migrating NestJS modules (DatabaseModule, HealthModule) from individual applications to a shared `@asyml8/api-core` package, dependency injection fails with errors like:

```
Error: Nest can't resolve dependencies of the [Repository] (?). 
Please make sure that the argument DataSource at index [0] is available in the TypeOrmModule context.
```

## **Root Cause Analysis Framework**

### **1. Verify Module Structure Integrity**
```bash
# Check for duplicate modules
find . -name "*[ModuleName]*" -type f

# Verify all repository injection patterns
find src/ -name "*repository*" -exec grep -l "DataSource\|@InjectDataSource\|@InjectRepository" {} \;

# Check compiled artifacts
rm -rf dist && rm -rf node_modules/.cache
```

### **2. Diagnose TypeORM Configuration Issues**
```typescript
// Common issues in shared DatabaseModule:
// ❌ Wrong: Hardcoded entity paths
entities: [__dirname + '/entities/*.entity{.ts,.js}']

// ✅ Correct: Auto-discovery + flexible paths
autoLoadEntities: true,
entities: [
  __dirname + '/../**/*.entity{.ts,.js}',
  __dirname + '/../../**/*.entity{.ts,.js}',
]
```

### **3. Module Import/Export Verification**
```typescript
// Shared module must be properly structured:
@Global() // Critical for cross-module availability
@Module({
  imports: [
    TypeOrmModule.forRoot(config), // Root connection
  ],
  exports: [TypeOrmModule], // Export for consuming modules
})
export class DatabaseModule {}
```

### **4. Consumer Module Registration Check**
```typescript
// Each feature module must register entities:
@Module({
  imports: [TypeOrmModule.forFeature([Entity])], // Required
  providers: [Repository], // Must inject @InjectRepository(Entity)
})
export class FeatureModule {}
```

## **Systematic Fix Protocol**

### **Phase 1: Isolation Testing**
1. **Create minimal local module first**:
```typescript
// src/database.module.ts - Temporary working version
@Module({
  imports: [
    TypeOrmModule.forRoot({
      type: 'postgres',
      host: process.env.DATABASE_HOST,
      port: parseInt(process.env.DATABASE_PORT),
      username: process.env.DATABASE_USERNAME,
      password: process.env.DATABASE_PASSWORD,
      database: process.env.DATABASE_DB_NAME,
      autoLoadEntities: true, // Critical
      synchronize: false,
      logging: process.env.TYPE_ORM_LOGGER === 'advanced-console',
    }),
  ],
})
export class LocalDatabaseModule {}
```

2. **Test with local module**:
```bash
pnpm build && pnpm dev # Should work
```

### **Phase 2: Shared Module Validation**
1. **Fix shared module structure**:
```typescript
// packages/api-core/src/database/database.module.ts
@Global()
@Module({
  imports: [TypeOrmModule.forRoot(getDatabaseConfig())],
  exports: [TypeOrmModule],
})
export class DatabaseModule {}
```

2. **Ensure proper exports**:
```typescript
// packages/api-core/src/index.ts
export * from './database';
export * from './health';
```

3. **Rebuild shared package**:
```bash
cd packages/api-core && pnpm build
```

### **Phase 3: Gradual Migration**
1. **Replace local with shared**:
```typescript
// app.module.ts
import { DatabaseModule } from '@asyml8/api-core';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    DatabaseModule, // Shared module
    // ... feature modules
  ],
})
export class AppModule {}
```

2. **Remove local modules**:
```bash
rm -rf src/libs/database
rm -rf src/modules/health
rm src/database.module.ts
```

### **Phase 4: Validation & Testing**
1. **Clean rebuild**:
```bash
rm -rf dist
pnpm build
```

2. **Runtime testing**:
```bash
pnpm dev # Check for DI errors
curl http://localhost:4000/api/health # Test endpoints
```

## **Common Pitfalls & Solutions**

### **Issue 1: Module Import Order**
```typescript
// ❌ Wrong: Feature modules before database
imports: [FeatureModule, DatabaseModule]

// ✅ Correct: Database first
imports: [DatabaseModule, FeatureModule]
```

### **Issue 2: Missing @Global() Decorator**
```typescript
// ❌ Wrong: Not global
@Module({...})

// ✅ Correct: Global availability
@Global()
@Module({...})
```

### **Issue 3: Incorrect Entity Registration**
```typescript
// ❌ Wrong: Missing forFeature
@Module({
  providers: [Repository], // DI will fail
})

// ✅ Correct: Proper registration
@Module({
  imports: [TypeOrmModule.forFeature([Entity])],
  providers: [Repository],
})
```

### **Issue 4: Path Resolution Problems**
```typescript
// ❌ Wrong: Hardcoded paths
entities: ['src/**/*.entity.ts']

// ✅ Correct: Runtime resolution + autoLoad
autoLoadEntities: true,
entities: [
  __dirname + '/../**/*.entity{.ts,.js}',
  __dirname + '/../../**/*.entity{.ts,.js}',
]
```

## **Verification Checklist**

- [ ] Shared module has `@Global()` decorator
- [ ] Shared module exports `TypeOrmModule`
- [ ] Database config uses `autoLoadEntities: true`
- [ ] All feature modules use `TypeOrmModule.forFeature([Entity])`
- [ ] All repositories use `@InjectRepository(Entity)`
- [ ] No direct `DataSource` injection in repositories
- [ ] Clean build with no compilation errors
- [ ] Runtime startup without DI errors
- [ ] API endpoints respond correctly

## **Rollback Strategy**

If shared module fails:
1. Revert to local database module
2. Keep only working shared modules (e.g., HealthModule)
3. Gradually migrate one module at a time
4. Test each migration step independently

## **Success Criteria**

- ✅ Application starts without DI errors
- ✅ All repositories can inject their entities
- ✅ Database connections work properly
- ✅ Shared modules are reusable across applications
- ✅ No duplicate code between applications

This prompt provides a systematic approach to diagnose and fix NestJS shared module dependency injection issues, with clear steps for isolation, testing, and gradual migration.
