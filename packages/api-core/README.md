# @asyml8/api-core

Shared NestJS core functionality for Pravia APIs including database configuration, health monitoring, response standardization, and common utilities.

## 📦 Installation

```bash
# Already included in monorepo workspace
pnpm install
```

## 🚀 Quick Start

### Basic Integration

```typescript
// app.module.ts
import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { APP_INTERCEPTOR } from '@nestjs/core';
import { HealthModule, ResponseTransformInterceptor, ValidatorsModule } from '@asyml8/api-core';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    HealthModule,
    ValidatorsModule, // Add validators for database validation
    // Your feature modules...
  ],
  providers: [
    {
      provide: APP_INTERCEPTOR,
      useClass: ResponseTransformInterceptor, // Standardize all responses
    },
  ],
})
export class AppModule {}
```

## 🏗️ Available Modules

### 1. HealthModule

Provides standardized health check endpoints with database connectivity monitoring.

**Usage:**
```typescript
import { HealthModule } from '@asyml8/api-core';

@Module({
  imports: [HealthModule],
})
export class AppModule {}
```

**Endpoints:**
- `GET /health` - Overall system health
- `GET /health/database` - Database connectivity check

**Response Example:**
```json
{
  "statusCode": 200,
  "body": {
    "status": "ok",
    "timestamp": "2025-10-07T22:47:11.486Z",
    "uptime": 54.62,
    "database": {
      "status": "healthy",
      "message": "Database connection successful"
    },
    "memory": {
      "rss": 51429376,
      "heapTotal": 68812800,
      "heapUsed": 63271408
    }
  },
  "message": "Health check completed"
}
```

### 2. Response Standardization

Automatically wraps all API responses in a consistent format with proper CORS headers.

**Usage:**
```typescript
import { ResponseTransformInterceptor, ResponseMessage, ApiOkBaseResponse } from '@asyml8/api-core';

// In app.module.ts
{
  provide: APP_INTERCEPTOR,
  useClass: ResponseTransformInterceptor,
}

// In controllers
@Get('users')
@ResponseMessage('Users retrieved successfully')
@ApiOkBaseResponse(UserDto) // For arrays
async getUsers() {
  return this.userService.findAll(); // Returns User[]
}

@Get('users/:id')
@ResponseMessage('User retrieved successfully')
@ApiOkBaseResponse(UserDto, true) // For single entities
async getUser(@Param('id') id: string) {
  return this.userService.findOne(id); // Returns User
}
```

**Response Format:**
```json
{
  "statusCode": 200,
  "body": [...], // Your actual data
  "message": "Users retrieved successfully"
}
```

### 3. Database Validators

Custom validation decorators for database entity existence checks.

**Usage:**
```typescript
import { IsExist, IsNotExist } from '@asyml8/api-core';
import { Validate } from 'class-validator';

export class CreateUserDto {
  @IsEmail()
  @Validate(IsNotExist, [User, 'email'], {
    message: 'User with this email already exists',
  })
  email: string;

  @IsString()
  @Validate(IsExist, [Department, 'id'], {
    message: 'Department does not exist',
  })
  departmentId: string;
}
```

**Available Validators:**
- `IsExist` - Validates that a record exists in the database
- `IsNotExist` - Validates that a record does NOT exist (for uniqueness)

### 4. BaseEntity

Shared base entity with common fields for all database entities.

**Usage:**
```typescript
import { BaseEntity } from '@asyml8/api-core';
import { Entity, Column } from 'typeorm';

@Entity('user_profile')
export class UserProfile extends BaseEntity {
  @Column()
  name: string;
  
  // BaseEntity provides: id, createdAt, updatedAt, deletedAt, createdBy, updatedBy
}
```

### 5. SwaggerUI

Enhanced Swagger UI with custom theming and branding.

**Usage:**
```typescript
import { SwaggerUI } from '@asyml8/api-core';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';

// main.ts
const config = new DocumentBuilder()
  .setTitle('Your API')
  .setDescription('API Description')
  .setVersion('1.0.0')
  .build();

const document = SwaggerModule.createDocument(app, config);

const swaggerUI = new SwaggerUI('http://localhost:4000', {
  customSiteTitle: 'Your API Documentation',
  topbarIconFilename: 'logo.svg',
  persistAuthorization: true,
  wavyGradient: {
    enabled: true,
    colors: ['#E67E22', '#5DADE2', '#2E86AB'],
    height: '93px',
    waveHeight: '25px',
  },
});

SwaggerModule.setup('docs', app, document, swaggerUI.customOptions);
```

## ⚠️ Known Issues & Workarounds

Currently no known issues. All shared modules are working as expected.

## 🛠️ Development

### Building the Package

```bash
cd packages/api-core
pnpm build
```

### Adding New Shared Components

1. Create your component in the appropriate directory:
   ```
   src/
   ├── entities/       # Shared entities
   ├── health/         # Health monitoring
   ├── swagger/        # Swagger utilities
   ├── response/       # Response standardization
   ├── validators/     # Database validators
   └── [new-module]/   # Your new shared module
   ```

2. Export from the main index:
   ```typescript
   // src/index.ts
   export * from './entities';
   export * from './health';
   export * from './swagger';
   export * from './response/dto/entity-response.dto';
   export * from './response/decorators/response.decorator';
   export * from './response/decorators/api-response.decorator';
   export * from './response/interceptors/response-transform.interceptor';
   export * from './validators/is-exist.validator';
   export * from './validators/is-not-exist.validator';
   export * from './new-module'; // Add your export
   ```

3. Rebuild the package:
   ```bash
   pnpm build
   ```

## 📋 Integration Checklist

When integrating api-core into a new API:

- [ ] Install dependencies: `pnpm install`
- [ ] Import `ResponseTransformInterceptor` as global interceptor
- [ ] Import `ValidatorsModule` for database validation
- [ ] Import `HealthModule` in your app module
- [ ] Use `BaseEntity` for your database entities
- [ ] Configure `SwaggerUI` in main.ts
- [ ] Replace `@ApiResponse` with `@ResponseMessage` + `@ApiOkBaseResponse`
- [ ] Test health endpoints: `/health` and `/health/database`
- [ ] Verify Swagger docs are accessible
- [ ] Test response format consistency

## 🔧 Environment Variables

Required environment variables for full functionality:

```env
# Database (for health checks and validators)
DATABASE_HOST=localhost
DATABASE_PORT=5432
DATABASE_USERNAME=postgres
DATABASE_PASSWORD=postgres
DATABASE_DB_NAME=your_database

# Logging
TYPE_ORM_LOGGER=advanced-console
LOG_LEVEL=info
```

## 🤝 Contributing

When adding new shared functionality:

1. Ensure it's truly reusable across multiple APIs
2. Add comprehensive TypeScript types
3. Include proper error handling
4. Add JSDoc documentation
5. Test with at least 2 different consuming applications
6. Update this README with usage examples

## 📚 Related Documentation

- [NestJS Shared Module Troubleshooting](../../prompts/API_NestJS_Shared_Module_Migration_Troubleshooting.md)
- [Pravia Auth API](../../apps/pravia-auth-api/README.md)
- [Pravia Platform API](../../apps/pravia-platform-api/README.md)

## 🐛 Troubleshooting

### Common Issues

**1. Module Import Errors**
```
Error: Nest can't resolve dependencies...
```
**Solution:** Ensure the consuming application has proper TypeORM configuration and entity registration.

**2. Build Failures**
```
Cannot find module '@asyml8/api-core'
```
**Solution:** Run `pnpm build` in the api-core directory first.

**3. Health Check Failures**
```
Database connection failed
```
**Solution:** Verify database environment variables and ensure the database is running.

**4. Validator Not Working**
```
Validation decorator not being called
```
**Solution:** Ensure `ValidatorsModule` is imported and `ValidationPipe` is configured globally.

For detailed troubleshooting, see the [troubleshooting guide](../../prompts/API_NestJS_Shared_Module_Migration_Troubleshooting.md).

## 🎯 What's New

### High Priority Features Implemented

✅ **Response Standardization**
- `EntityResponse<T>` and `EntityListResponse<T>` DTOs
- `ResponseTransformInterceptor` for consistent API responses
- Automatic CORS header management

✅ **Enhanced Decorators**
- `@ResponseMessage()` for consistent response messages
- `@ApiOkBaseResponse()` for improved Swagger documentation
- `@ResponseAsStream()` for streaming responses

✅ **Database Validators**
- `@Validate(IsExist, [...])` for entity existence validation
- `@Validate(IsNotExist, [...])` for uniqueness validation
- Async validation with proper error messages

### Migration Impact

**Breaking Changes:**
- All API responses now wrapped in `{ statusCode, body, message }` format
- Frontend clients must access data via `.body` property

**Benefits:**
- Consistent response structure across all APIs
- Better error handling and CORS support
- Enhanced validation capabilities
- Improved Swagger documentation
