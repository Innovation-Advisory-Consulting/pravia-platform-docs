# Integrating Database Materialized Views with API Endpoints

## Problem
API endpoints are returning mock/fake data instead of real data from database materialized views that combine multiple tables.

## Solution Steps

### 1. Identify the Database Schema
- Check migration files to understand the actual materialized view structure
- Look in `src/database/migrations/` for view creation scripts
- Identify column names, data types, and relationships

### 2. Verify Database Objects Exist
```bash
# Check if materialized view exists
docker exec <db_container> psql -U <user> -d <db> -c "SELECT schemaname, matviewname FROM pg_matviews WHERE schemaname = '<schema>';"

# Check function exists (if using stored procedures)
docker exec <db_container> psql -U <user> -d <db> -c "SELECT proname FROM pg_proc WHERE proname = '<function_name>';"

# Refresh materialized view
docker exec <db_container> psql -U <user> -d <db> -c "REFRESH MATERIALIZED VIEW <schema>.<view_name>;"
```

### 3. Test Database Queries Directly
```bash
# Test the view has data
docker exec <db_container> psql -U <user> -d <db> -c "SELECT COUNT(*) FROM <schema>.<view_name>;"

# Test actual query structure
docker exec <db_container> psql -U <user> -d <db> -c "SELECT * FROM <schema>.<view_name> LIMIT 3;"
```

### 4. Update Service Layer
Replace mock data generation with real database queries:

```typescript
// BEFORE: Mock data
const data = profiles.map(profile => ({
  user: {
    id: profile.userId,
    email: `${profile.firstName}@example.com`, // FAKE
    created_at: new Date().toISOString(), // FAKE
  },
  profile
}));

// AFTER: Real data from materialized view
const result = await this.repository.query(`
  SELECT 
    id,
    email,
    auth_created_at,
    profile_id,
    "firstName",
    "lastName"
  FROM <schema>.<materialized_view>
  ORDER BY auth_created_at DESC 
  LIMIT $1 OFFSET $2
`, [limit, offset]);

const data = result.map(row => ({
  user: {
    id: row.id,
    email: row.email, // REAL
    created_at: row.auth_created_at, // REAL
  },
  profile: row.profile_id ? {
    id: row.profile_id,
    firstName: row.firstName,
    lastName: row.lastName
  } : null
}));
```

### 5. Handle Type Mismatches
If you get "structure of query does not match function result type":
- Query the materialized view directly instead of using stored functions
- Check column data types match function return types
- Use explicit column selection instead of `SELECT *`

### 6. Test API Endpoint
```bash
# Temporarily disable auth guards for testing
# @UseGuards(AuthGuard('jwt')) -> // @UseGuards(AuthGuard('jwt'))

# Test endpoint
curl -s "http://localhost:<port>/api/<endpoint>?page=1&perPage=5" | jq '.'
```

### 7. Verify Real Data
Ensure the API returns:
- Real email addresses (not @example.com)
- Real timestamps from database
- Real user metadata
- Proper relationships between tables

## Common Pitfalls
- Using mock data generators instead of database queries
- Not refreshing materialized views after data changes
- Type mismatches between database and function definitions
- Forgetting to run migrations that create views/functions
- Testing with auth enabled when debugging data issues

## Verification Checklist
- [ ] Materialized view exists and has data
- [ ] Migration files show correct column names
- [ ] Database query works directly in psql
- [ ] Service uses real database query (no mock data)
- [ ] API returns real emails and timestamps
- [ ] Pagination works correctly
- [ ] Error handling preserves real data structure
