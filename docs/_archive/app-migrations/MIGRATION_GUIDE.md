# Migration Guide: Updating Apps to Use Common Code

This guide explains how to migrate existing NestJS applications in the Pravia monorepo to use the standardized `@asyml8/api-core` common code and environment-driven configuration.

## Overview

The migration involves:
- Replacing custom boilerplate with `createNestApp()` from `@asyml8/api-core`
- Moving hardcoded values to environment variables
- Removing redundant modules that are now provided by the common library

## 🗂️ Files and Folders to Remove

### Custom Modules (replaced by common code)
- `src/modules/health/` - **entire directory**
- `src/auth/` - **entire directory** 
- `src/config/` - **entire directory** (if exists)

These modules are replaced by built-in functionality in `@asyml8/api-core`.

## 📝 Files to Update

### 1. `src/main.ts`
**Before:** ~70 lines of custom NestJS setup
```typescript
// Custom NestFactory.create, Swagger setup, etc.
```

**After:** ~15 lines using common code
```typescript
import { createNestApp } from '@asyml8/api-core';
import { AppModule } from './app.module';

async function bootstrap() {
  const gradientColors = process.env.SWAGGER_GRADIENT_COLORS 
    ? process.env.SWAGGER_GRADIENT_COLORS.split(',').map(color => color.trim())
    : ['#E67E22', '#5DADE2', '#2E86AB'];

  await createNestApp(AppModule, {
    title: process.env.APP_TITLE || 'Default App Title',
    description: process.env.APP_DESCRIPTION || 'Default description',
    serverName: process.env.SERVER_NAME || 'Default Server',
    // autoIncrementVersion: true, // Commented out to test reading existing version
    swagger: {
      topbarIconFilename: process.env.SWAGGER_ICON_FILENAME || 'logo.svg',
      persistAuthorization: process.env.SWAGGER_PERSIST_AUTH === 'true',
      wavyGradient: {
        enabled: process.env.SWAGGER_GRADIENT_ENABLED === 'true',
        colors: gradientColors,
        height: process.env.SWAGGER_GRADIENT_HEIGHT || '60px',
        waveHeight: process.env.SWAGGER_WAVE_HEIGHT || '25px',
      },
    },
  });
}

bootstrap().catch(console.error);
```

### 2. `src/app.service.ts`
Replace hardcoded values with environment variables:
```typescript
import { Injectable } from '@nestjs/common';

@Injectable()
export class AppService {
  getAppInfo() {
    return {
      name: process.env.APP_TITLE || 'Default App Name',
      version: process.env.APP_VERSION || '1.0.0',
      description: process.env.APP_DESCRIPTION || 'Default description',
      timestamp: new Date().toISOString(),
    };
  }
}
```

### 3. `src/app.module.ts`
Remove imports for deleted modules and add common modules:
```typescript
import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AuthModule, SimpleHealthModule } from '@asyml8/api-core';

import { AppController } from './app.controller';
import { AppService } from './app.service';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
    }),
    SimpleHealthModule,  // Provides health endpoints
    AuthModule,          // Provides authentication
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
```

**Remove these imports:**
```typescript
// import { HealthModule } from './modules/health/health.module';
// import { AuthModule } from './auth/auth.module';
// import { ConfigModule } from './config/config.module';
```

## 🔧 Environment Variables to Add

Add these variables to both `.env` and `.env.example`:

### Application Configuration
```env
# Application Configuration
APP_TITLE=Your App Name
APP_DESCRIPTION=Your app description
APP_VERSION=1.0.0
SERVER_NAME=Your Server Name

# Swagger Configuration
SWAGGER_ICON_FILENAME=logo.svg
SWAGGER_PERSIST_AUTH=true
SWAGGER_GRADIENT_ENABLED=true
SWAGGER_GRADIENT_COLORS="#E67E22,#5DADE2,#2E86AB"
SWAGGER_GRADIENT_HEIGHT=60px
SWAGGER_WAVE_HEIGHT=25px
```

**Important Notes:**
- **Colors must be quoted** due to `#` characters being treated as comments
- **Version control**: Use `APP_VERSION` env var or uncomment `autoIncrementVersion: true` for auto-increment

## 🧪 Tests to Update

### E2E Tests (`test/app.e2e-spec.ts`)
Update hardcoded values to match your app:
```typescript
// Update app name expectation
expect(res.body.name).toBe('Your App Name');

// Update service name expectation  
expect(res.body.service).toBe('your-app-service-name');
```

## 📋 Migration Checklist

- [ ] **Backup existing code** before starting migration
- [ ] **Remove custom modules**: `health/`, `auth/`, `config/` directories
- [ ] **Update `main.ts`** to use `createNestApp()`
- [ ] **Update `app.service.ts`** to use environment variables
- [ ] **Update `app.module.ts`** to remove deleted module imports and add `SimpleHealthModule` + `AuthModule`
- [ ] **Add environment variables** to `.env` and `.env.example`
- [ ] **Update test files** with correct app-specific values
- [ ] **Test the application** to ensure all functionality works
- [ ] **Verify Swagger UI** displays correctly with new configuration

## ⚠️ Important Notes

1. **Health endpoints** are automatically provided by `@asyml8/api-core`
2. **Authentication** patterns are standardized in the common library
3. **Configuration** is now fully environment-driven
4. **Swagger customization** is controlled via environment variables
5. **All existing API functionality** remains unchanged
6. **Color values must be quoted** - Use `"#E67E22,#5DADE2,#2E86AB"` not `#E67E22,#5DADE2,#2E86AB`
7. **Version control** - Use `APP_VERSION` env var or enable `autoIncrementVersion: true`
8. **Color parsing** - Extract to variable before passing to `createNestApp` for proper parsing

## 🎯 Benefits After Migration

- **Reduced code**: ~55+ lines removed from `main.ts`
- **Consistency**: All apps use identical patterns
- **Maintainability**: Configuration externalized to environment variables
- **Reusability**: Leverages shared `@asyml8/api-core` functionality
- **Standardization**: Common health, auth, and configuration patterns

## 📚 Example Apps

- **Config API**: Already migrated (reference implementation)
- **IDP API**: Ready for migration using this guide
