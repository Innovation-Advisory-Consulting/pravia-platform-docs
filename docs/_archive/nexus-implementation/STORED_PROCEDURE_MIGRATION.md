# Stored Procedure Migration Guide

## SQL Server → PostgreSQL/TypeORM Migration

### Original Stored Procedure: `sp_bx_get_configuration_data`

**Parameters:**
- `@option`: 'GetAllBxConfigurationData' | 'GetAllBxConfigurationAttribData'
- `@regionId`, `@locationId`, `@userId`: Access context filters
- `@configId`: Optional specific configuration
- `@groupId`: Configuration group filter
- `@maxRows`: Result limit (default 2000)

---

## Migration Mapping

### 1. GetAllBxConfigurationData → `getAllConfigurations()`

**Endpoint:** `GET /api/configuration-data/configurations`

**Query Parameters:**
```typescript
{
  groupId: string;
  configId?: string;
  regionId?: string;
  locationId?: string;
  userId?: string;
  maxRows?: number;
}
```

**Response:**
```typescript
{
  configId: string;
  configTemplateId: string;
  groupId: string;
  isEnabled: boolean;
  name: string;
  description: string;
  type: string;
  access: 'true' | 'false';  // Computed based on access priorities
  lastModified: Date;
}[]
```

**Key Changes:**
- Dynamic SQL → TypeORM QueryBuilder
- Access check moved to CASE expression in SELECT
- Automatic parameter sanitization (no SQL injection risk)
- Returns JSON directly (no table variables)

---

### 2. GetAllBxConfigurationAttribData → `getAllConfigurationAttributes()`

**Endpoint:** `GET /api/configuration-data/attributes`

**Query Parameters:**
```typescript
{
  groupId: string;
  configId?: string;
  regionId?: string;
  locationId?: string;
  userId?: string;
}
```

**Response:**
```typescript
{
  configId: string;
  isEnabled: boolean;
  attribTemplateId: string;
  attribValId: string;
  name: string;
  description: string;
  origin: 'temp_attrib' | 'config_attrib' | 'config_attrib_ovr';
  sortIdx: number;
  value: string;
  valueType: string;
  options: string;
  overrideEnabled: boolean;
  overrideStatus: string;
  overrideFilter: string;
  mediaId: string;
  lastModified: Date;
}[]
```

**Key Logic:**

1. **Origin Determination:**
   ```sql
   -- SQL Server
   CASE 
     WHEN attrib_val_id IS NULL THEN 'temp_attrib'
     ELSE CASE 
       WHEN priority_rank IS NULL THEN 'config_attrib'
       ELSE 'config_attrib_ovr' 
     END 
   END
   ```
   
   ```typescript
   // TypeORM
   .addSelect(`
     CASE 
       WHEN cav.id IS NULL THEN 'temp_attrib'
       ELSE CASE 
         WHEN ovr.priorityRank IS NULL THEN 'config_attrib'
         ELSE 'config_attrib_ovr'
       END
     END`, 'origin')
   ```

2. **Priority Resolution:**
   - Subquery finds highest priority override matching context
   - Uses `LIMIT 1` + `ORDER BY rank ASC` (PostgreSQL)
   - Replaces SQL Server's `TOP 1` syntax

3. **Value Coalescing:**
   ```typescript
   COALESCE(cav.value, at.value) AS value
   ```
   Falls back to template value if no configuration value exists

---

## View Migration: `vw_bx_configuration_data`

**TypeORM View Entity:** `ConfigurationDataView`

**Key Differences:**

| SQL Server | PostgreSQL/TypeORM |
|------------|-------------------|
| `TOP 1` subquery | `LATERAL` join with `LIMIT 1` |
| `datetime2(7)` | `timestamp` |
| Table variables | Direct query results |
| `CHAR(39)` for quotes | Parameterized queries |

**Usage:**
```typescript
@InjectRepository(ConfigurationDataView)
private viewRepo: Repository<ConfigurationDataView>;

// Query the view
const data = await this.viewRepo.find({
  where: { config_group_id: groupId }
});
```

---

## Testing Equivalence

### Test Case 1: Basic Configuration Fetch
```bash
# SQL Server
EXEC sp_bx_get_configuration_data 
  @option='GetAllBxConfigurationData',
  @groupId='123e4567-e89b-12d3-a456-426614174000'

# NestJS
GET /api/configuration-data/configurations?groupId=123e4567-e89b-12d3-a456-426614174000
```

### Test Case 2: Attributes with Context
```bash
# SQL Server
EXEC sp_bx_get_configuration_data 
  @option='GetAllBxConfigurationAttribData',
  @groupId='123e4567-e89b-12d3-a456-426614174000',
  @regionId='reg_1',
  @locationId='loc_2',
  @userId='ahhenderson'

# NestJS
GET /api/configuration-data/attributes?groupId=123e4567-e89b-12d3-a456-426614174000&regionId=reg_1&locationId=loc_2&userId=ahhenderson
```

---

## Performance Considerations

### SQL Server Approach
- Dynamic SQL with `sp_executesql`
- Table variables for intermediate results
- String concatenation for WHERE clauses

### TypeORM Approach
- Compiled query with parameters
- Single query execution
- Query plan caching by PostgreSQL
- No intermediate storage

**Expected Performance:** Similar or better due to:
- Parameterized queries (better plan reuse)
- No dynamic SQL compilation overhead
- PostgreSQL's efficient LATERAL joins

---

## Security Improvements

### SQL Injection Prevention

**Before (SQL Server):**
```sql
SET @SqlWhereClause = 'WHERE config_group_id = ' + CHAR(39) + @groupId + CHAR(39)
```
Risk: String concatenation could allow injection if input validation fails

**After (TypeORM):**
```typescript
.where('c.configurationGroupId = :groupId', { groupId })
```
✅ Automatic parameterization - no injection possible

---

## Migration Checklist

- [x] Create `ConfigurationDataService`
- [x] Implement `getAllConfigurations()` method
- [x] Implement `getAllConfigurationAttributes()` method
- [x] Create `ConfigurationDataController`
- [x] Define REST endpoints
- [x] Create `ConfigurationDataView` entity
- [ ] Write unit tests for service methods
- [ ] Write integration tests comparing SQL vs TypeORM results
- [ ] Performance benchmark both approaches
- [ ] Update API documentation
- [ ] Create migration script for view creation

---

## Next Steps

1. **Add to Module:**
```typescript
// configuration.module.ts
@Module({
  imports: [
    TypeOrmModule.forFeature([
      Configuration,
      ConfigurationDataView,
      // ... other entities
    ]),
  ],
  controllers: [ConfigurationDataController],
  providers: [ConfigurationDataService],
})
export class ConfigurationModule {}
```

2. **Create Migration:**
```bash
pnpm migration:generate CreateConfigurationDataView
```

3. **Test:**
```bash
pnpm test configuration-data.service
pnpm test:e2e configuration-data.controller
```
