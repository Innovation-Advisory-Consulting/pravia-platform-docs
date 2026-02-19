# API Best Practices Checklist

**Standard checklist for all NestJS/Fastify APIs in the Pravia platform**

## 🔐 Authentication & Authorization

- [ ] **Use opt-out authentication** (protected by default)
  - Apply `ConditionalAuthGuard` globally or at controller level
  - Explicitly mark public endpoints with `@Public()` decorator
  - Never use opt-in authentication (security risk)

- [ ] **Import guards from api-core**
  ```typescript
  import { ConditionalAuthGuard, TestOnlyGuard, Public } from '@asyml8/api-core';
  ```

- [ ] **Mark all public endpoints explicitly**
  ```typescript
  @Public()
  @Post('register')
  async register() {}
  ```

- [ ] **Use `DISABLE_AUTH=true` for local development only**
  - `.env.local`: `DISABLE_AUTH=true`
  - `.env.development`: `DISABLE_AUTH=false`
  - `.env.qa`: `DISABLE_AUTH=false`
  - `.env.prod`: `DISABLE_AUTH=false`

## 🚦 Rate Limiting

- [ ] **Import ApiThrottleModule in app.module.ts**
  ```typescript
  import { ApiThrottleModule } from '@asyml8/api-core';
  
  @Module({
    imports: [
      ApiThrottleModule,  // Global rate limiting
      // ... other modules
    ],
  })
  ```

- [ ] **Configure rate limits via environment variables**
  ```bash
  # .env.local, .env.development, .env.qa
  THROTTLE_PUBLIC=100           # Public endpoints: 100 requests per minute
  THROTTLE_PUBLIC_TTL=60000     # Time window: 60 seconds
  THROTTLE_PROTECTED=1000       # Protected endpoints: 1000 requests per minute
  THROTTLE_PROTECTED_TTL=60000  # Time window: 60 seconds
  ```

- [ ] **Skip throttling on specific endpoints (optional)**
  ```typescript
  import { SkipThrottle } from '@asyml8/api-core';
  
  @SkipThrottle()
  @Get('health')
  async health() {}
  ```

- [ ] **Custom limits for specific endpoints (optional)**
  ```typescript
  import { Throttle } from '@asyml8/api-core';
  
  @Throttle({ default: { limit: 10, ttl: 60000 } })
  @Post('register')
  async register() {}
  ```

- [ ] **Recommended limits per endpoint type**
  - Registration: 10 requests/minute
  - Contact creation: 20 requests/minute
  - Public reads: 100 requests/minute
  - Protected endpoints: 1000 requests/minute
  - Health checks: Skip throttling

## 🏗️ Controller Organization

- [ ] **Separate public/private controllers when appropriate**
  ```
  modules/
  ├── contacts/
  │   ├── contacts.controller.ts          # Protected CRUD
  │   ├── public-contacts.controller.ts   # Public creation
  │   └── contacts.service.ts
  ```

- [ ] **Use clear controller naming**
  - `RegisterController` - All public endpoints
  - `ContactsController` - Mixed public/protected
  - `AdminController` - All protected admin endpoints

- [ ] **Apply guards at controller level when all endpoints share same auth**
  ```typescript
  @UseGuards(ConditionalAuthGuard)
  @Controller('admin')
  export class AdminController {}
  ```

## 🧪 Test Endpoints

- [ ] **Protect test-only endpoints with `TestOnlyGuard`**
  ```typescript
  @UseGuards(TestOnlyGuard)
  @Delete('cleanup')
  async cleanup() {}
  ```

- [ ] **Set `ENABLE_TEST_ENDPOINTS` correctly per environment**
  - `.env.local`: `true`
  - `.env.development`: `false`
  - `.env.qa`: `true`
  - `.env.prod`: `false`

## 📝 DTOs & Validation

- [ ] **Always use DTOs for request bodies**
  ```typescript
  @Post()
  async create(@Body() dto: CreateDto) {}  // ✅
  
  @Post()
  async create(@Body() body: any) {}       // ❌
  ```

- [ ] **Use class-validator decorators**
  ```typescript
  export class CreateDto {
    @IsString()
    @IsNotEmpty()
    name: string;
    
    @IsEmail()
    email: string;
  }
  ```

- [ ] **Export DTOs from index files**
  ```typescript
  // dto/index.ts
  export * from './create.dto';
  export * from './update.dto';
  ```

## 📚 Swagger Documentation

- [ ] **Document all endpoints with Swagger decorators**
  ```typescript
  @ApiTags('Users')
  @ApiBearerAuth()
  @Controller('users')
  export class UsersController {
    @ApiOperation({ summary: 'Get user by ID' })
    @ApiResponse({ status: 200, type: UserDto })
    @ApiResponse({ status: 404, description: 'User not found' })
    @Get(':id')
    async getUser(@Param('id') id: string) {}
  }
  ```

- [ ] **Use `@ApiBearerAuth()` on protected controllers**

- [ ] **Mark public endpoints in Swagger**
  ```typescript
  @Public()
  @ApiOperation({ summary: 'Public endpoint - no auth required' })
  @Post('register')
  ```

## 🎯 Response Handling

- [ ] **Use standardized response format from api-core**
  ```typescript
  import { ApiOkBaseResponse, ResponseMessage } from '@asyml8/api-core';
  
  @ApiOkBaseResponse(UserDto, true)
  @ResponseMessage('User created successfully')
  @Post()
  async create() {}
  ```

- [ ] **Use NestJS exceptions for errors**
  ```typescript
  throw new BadRequestException('Invalid data');
  throw new UnauthorizedException();
  throw new NotFoundException('User not found');
  ```

## 🔧 Environment Configuration

- [ ] **Follow environment standards** (see [ENVIRONMENT_STANDARDS.md](./ENVIRONMENT_STANDARDS.md))
  - Create `.env.local`, `.env.development`, `.env.qa`
  - Use `NODE_ENV=production` for deployed environments
  - Only set `PORT` in `.env.local`

- [ ] **Use environment-specific scripts**
  ```json
  {
    "dev": "nest start --watch",
    "dev:development": "dotenv -e .env.development -- nest start --watch",
    "dev:qa": "dotenv -e .env.qa -- nest start --watch"
  }
  ```

## 🏗️ Code Organization

- [ ] **Use api-core for shared functionality**
  - Guards: `ConditionalAuthGuard`, `TestOnlyGuard`
  - Decorators: `@Public()`, `@ResponseMessage()`
  - Services: `SupabaseService`, `SupabaseAuthGuard`

- [ ] **Don't duplicate code across APIs**
  - Move shared guards to api-core
  - Move shared decorators to api-core
  - Move shared utilities to api-core

- [ ] **Follow NestJS module structure**
  ```
  modules/
  ├── users/
  │   ├── dto/
  │   ├── entities/
  │   ├── users.controller.ts
  │   ├── users.service.ts
  │   ├── users.module.ts
  │   └── users.repository.ts
  ```

## 🧹 Code Quality

- [ ] **Add format-lint script to package.json**
  ```json
  {
    "format": "prettier --write \"src/**/*.ts\" \"test/**/*.ts\"",
    "lint:fix": "eslint \"{src,apps,libs,test}/**/*.ts\" --fix",
    "format-lint": "pnpm format && pnpm lint:fix"
  }
  ```

- [ ] **Integrate with pre-commit hook** (see [ENVIRONMENT_STANDARDS.md](./ENVIRONMENT_STANDARDS.md#pre-commit-hook-configuration))

- [ ] **Fix linting warnings before committing**
  - Avoid `any` types
  - Prefix unused variables with `_`
  - Remove unused imports

## 🚀 Build & Deployment

- [ ] **Auto-increment version on build**
  ```json
  {
    "prebuild": "node scripts/update-build-info.js && pnpm format-lint",
    "build": "nest build",
    "build:ci": "node scripts/update-build-info.js && nest build"
  }
  ```

- [ ] **Use `build:ci` in Docker/CI pipelines**

- [ ] **Add buildDate to package.json**
  ```json
  {
    "version": "1.0.0",
    "buildDate": ""
  }
  ```

## 🔍 Health Checks

- [ ] **Implement health check endpoints**
  ```typescript
  @Get('health')
  async health() {
    return { status: 'ok' };
  }
  ```

- [ ] **Don't require auth for health checks**
  ```typescript
  @Public()
  @Get('health')
  ```

## 🧪 Testing

- [ ] **Write unit tests for services**
- [ ] **Write E2E tests for critical endpoints**
- [ ] **Use test-only endpoints for cleanup**
  ```typescript
  @UseGuards(TestOnlyGuard)
  @Delete('test/cleanup')
  async cleanup() {}
  ```

## 📦 Dependencies

- [ ] **Keep dependencies up to date**
- [ ] **Use workspace dependencies from api-core**
  ```json
  {
    "dependencies": {
      "@asyml8/api-core": "workspace:*"
    }
  }
  ```

## 🔒 Security

- [ ] **Never commit secrets to git**
- [ ] **Use environment variables for sensitive data**
- [ ] **Validate all user input with DTOs**
- [ ] **Use parameterized queries (TypeORM handles this)**
- [ ] **Enable CORS appropriately**
- [ ] **Set secure headers (helmet)**

## 📋 Checklist Summary

When creating a new API or reviewing existing code:

1. ✅ Authentication is opt-out (protected by default)
2. ✅ Public endpoints marked with `@Public()`
3. ✅ ApiThrottleModule imported in app.module
4. ✅ Rate limit env vars configured (THROTTLE_PUBLIC, THROTTLE_PROTECTED)
5. ✅ Guards imported from api-core
6. ✅ All endpoints documented with Swagger
7. ✅ DTOs used for all request bodies
8. ✅ Standardized response format with statusMessage
9. ✅ Environment configuration follows standards
10. ✅ Pre-commit hook configured
11. ✅ Health checks are public
12. ✅ Test endpoints protected with `TestOnlyGuard`
13. ✅ No secrets in code
14. ✅ Version auto-increments on build
15. ✅ Code formatted and linted

---

**Last Updated:** 2025-12-14  
**Version:** 1.0.0

## Related Documentation

- [Environment Standards](./ENVIRONMENT_STANDARDS.md)
- [API Endpoints Guide](../api/foundry/docs/API_ENDPOINTS.md)
- [Testing Guide](../api/foundry/docs/TESTING.md)
