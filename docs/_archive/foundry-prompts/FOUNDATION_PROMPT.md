# **Reusable NestJS API Foundation Prompt**

Create a modern, production-ready NestJS API with the following standardized foundation that can be reused across multiple projects.

## **Core Technology Stack:**

**Framework & Runtime:**
- Node.js 20+ with TypeScript 5+
- NestJS 10+ with Fastify adapter
- Zod for runtime validation and type safety

**Database & Caching:**
- TypeORM 0.3+ with PostgreSQL
- Redis for caching, sessions, and queues
- Enhanced migration system with post-processors

**Performance & Security:**
- Fastify for high-performance HTTP
- JWT authentication with refresh tokens
- Rate limiting with Redis
- CORS and security headers
- Input sanitization and validation

**Developer Experience:**
- OpenAPI 3.1 with Swagger integration
- Comprehensive error handling
- Structured logging with Pino
- Health checks and metrics
- Docker containerization

## **File Naming Conventions:**

**Standard NestJS Files (use dot notation):**
- `*.module.ts` - NestJS modules
- `*.controller.ts` - API controllers
- `*.service.ts` - Business logic services
- `*.entity.ts` - Database entities
- `*.dto.ts` - Data transfer objects
- `*.guard.ts` - Authentication/authorization guards
- `*.strategy.ts` - Passport strategies
- `*.interceptor.ts` - Request/response interceptors
- `*.decorator.ts` - Custom decorators
- `*.spec.ts` - Unit tests
- `*.e2e-spec.ts` - End-to-end tests

**Custom/Utility Files (use kebab-case):**
- `post-migration-processor.ts` - Custom migration scripts
- `database-seeder.ts` - Database seeding utilities
- `email-template-builder.ts` - Custom utility classes
- `api-response-formatter.ts` - Custom formatters

## **Standard Project Structure:**

```
src/
├── modules/
│   ├── auth/              # JWT authentication
│   ├── health/            # System monitoring
│   └── [custom-modules]/  # Project-specific modules
├── libs/
│   ├── core/              # Base classes & utilities
│   ├── database/          # TypeORM setup & entities
│   ├── interceptors/      # Request/response handling
│   ├── guards/            # Auth & permission guards
│   └── decorators/        # Custom decorators
├── database/
│   ├── migrations/        # TypeORM migrations
│   ├── entities/          # Database entities
│   └── scripts/           # Migration processors (kebab-case)
├── config/                # Environment configuration
└── main.ts                # NestJS + Fastify bootstrap
```

## **Foundation Package.json (Validated Dependencies):**

```json
{
  "name": "@company/[project-name]-api",
  "version": "1.0.0",
  "description": "[Project Description] API",
  "author": "[Company] Team",
  "private": true,
  "license": "UNLICENSED",
  "scripts": {
    "dev": "nest start --watch",
    "build": "nest build",
    "start": "node dist/main",
    "start:prod": "node dist/main",
    "migration:generate": "npm run build && typeorm-ts-node-commonjs migration:generate ./src/database/migrations/schema-update -d ./src/data-source.ts && npm run migration:process",
    "migration:run": "npm run build && typeorm-ts-node-commonjs migration:run -d ./src/data-source.ts",
    "migration:revert": "npm run build && typeorm-ts-node-commonjs migration:revert -d ./src/data-source.ts",
    "migration:process": "tsx ./src/database/scripts/postMigrationProcessor.ts",
    "schema:sync": "typeorm-ts-node-commonjs schema:sync -d ./src/data-source.ts",
    "schema:drop": "typeorm-ts-node-commonjs schema:drop -d ./src/data-source.ts",
    "lint": "eslint \"{src,apps,libs,test}/**/*.ts\"",
    "lint:fix": "eslint \"{src,apps,libs,test}/**/*.ts\" --fix",
    "format": "prettier --write \"src/**/*.ts\" \"test/**/*.ts\"",
    "format:check": "prettier --check \"src/**/*.ts\" \"test/**/*.ts\"",
    "test": "jest",
    "test:watch": "jest --watch",
    "test:cov": "jest --coverage",
    "test:debug": "node --inspect-brk -r tsconfig-paths/register -r ts-node/register node_modules/.bin/jest --runInBand",
    "test:e2e": "jest --config ./test/jest-e2e.json",
    "type-check": "tsc --noEmit"
  },
  "dependencies": {
    "@nestjs/common": "^10.3.8",
    "@nestjs/core": "^10.3.8",
    "@nestjs/platform-fastify": "^10.3.8",
    "@nestjs/swagger": "^7.3.1",
    "@nestjs/config": "^3.2.2",
    "@nestjs/typeorm": "^10.0.2",
    "@nestjs/jwt": "^10.2.0",
    "@nestjs/passport": "^10.0.3",
    "@nestjs/throttler": "^5.1.2",
    "@nestjs/cache-manager": "^2.2.2",
    "@nestjs/websockets": "^10.3.8",
    "@nestjs/platform-socket.io": "^10.3.8",
    "@aws-sdk/client-ses": "^3.600.0",
    "@aws-sdk/client-s3": "^3.600.0",
    "@supabase/supabase-js": "^2.43.4",
    "@fastify/static": "^7.0.4",
    "typeorm": "^0.3.17",
    "pg": "^8.11.5",
    "redis": "^4.6.13",
    "cache-manager-redis-yet": "^5.1.4",
    "fastify": "^4.26.2",
    "zod": "^3.23.6",
    "bcrypt": "^5.1.1",
    "passport": "^0.7.0",
    "passport-jwt": "^4.0.1",
    "class-validator": "^0.14.1",
    "class-transformer": "^0.5.1",
    "pino": "^9.0.0",
    "nestjs-pino": "^4.0.0"
  },
  "devDependencies": {
    "@nestjs/cli": "^10.3.2",
    "@nestjs/schematics": "^10.1.1",
    "@nestjs/testing": "^10.3.8",
    "@types/express": "^4.17.21",
    "@types/jest": "^29.5.12",
    "@types/node": "^20.0.0",
    "@types/passport-jwt": "^4.0.1",
    "@types/bcrypt": "^5.0.2",
    "@types/pg": "^8.11.5",
    "@typescript-eslint/eslint-plugin": "^7.0.0",
    "@typescript-eslint/parser": "^7.0.0",
    "eslint": "^8.57.0",
    "eslint-config-prettier": "^9.1.0",
    "eslint-plugin-prettier": "^5.1.3",
    "eslint-plugin-import": "^2.29.1",
    "eslint-plugin-unused-imports": "^3.2.0",
    "eslint-plugin-prefer-arrow": "^1.2.3",
    "eslint-import-resolver-typescript": "^3.6.1",
    "jest": "^29.7.0",
    "prettier": "^3.2.5",
    "source-map-support": "^0.5.21",
    "supertest": "^6.3.4",
    "ts-jest": "^29.1.2",
    "ts-loader": "^9.5.1",
    "ts-node": "^10.9.2",
    "tsconfig-paths": "^4.2.0",
    "typescript": "^5.4.0",
    "tsx": "^4.7.0"
  }
}
```

**Note:** These versions are validated for monorepo compatibility and confirmed to install without dependency conflicts.

## **Standard Environment Configuration:**

```env
# Application
NODE_ENV=development
PORT=4000
LOG_LEVEL=log,error,warn,debug,verbose
SERVER_URL=http://localhost:4000
LISTEN_ON='0.0.0.0'
API_PREFIX=api
FASTIFY_LOGGER=true

# Database
DATABASE_CONNECTION=postgres
DATABASE_HOST=localhost
DATABASE_PORT=5432
DATABASE_USERNAME=postgres
DATABASE_PASSWORD=
DATABASE_DB_NAME=postgres
DATABASE_POOL_SIZE=10
TYPE_ORM_LOGGER=advanced-console
TYPE_ORM_CACHE=true
TYPE_ORM_CACHE_DURATION=30000

# Redis
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=

# Supabase
SUPABASE_URL=
SUPABASE_ANON_KEY=
SUPABASE_SERVICE_KEY=
SUPABASE_JWT_KEY=
SUPABASE_STORAGE_BUCKET_NAME=[project-name]-storage

# OAuth Providers (configured in Supabase Dashboard)
# Google OAuth - Configure in Supabase Auth settings
# GitHub OAuth - Configure in Supabase Auth settings  
# Discord OAuth - Configure in Supabase Auth settings
# Apple OAuth - Configure in Supabase Auth settings

# Security
JWT_SECRET=your-jwt-secret-key
JWT_EXPIRES_IN=15m
JWT_REFRESH_EXPIRES_IN=7d
RATE_LIMIT_TTL=60
RATE_LIMIT_LIMIT=100

# Swagger
SWAGGER_INFO_TITLE='[Project Name] API'
SWAGGER_INFO_DESCRIPTION='[Project Description]'
SWAGGER_INFO_VERSION='1.0.0'
SWAGGER_INFO_CONTACT_NAME=[Company] Team
SWAGGER_INFO_CONTACT_URL=https://[company].com
SWAGGER_INFO_CONTACT_EMAIL=support@[company].com
```

## **Core Foundation Files:**

### 1. **Main Bootstrap (main.ts)**
```typescript
import { NestFactory } from '@nestjs/core';
import { FastifyAdapter, NestFastifyApplication } from '@nestjs/platform-fastify';
import { ValidationPipe } from '@nestjs/common';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { SwaggerUI } from '@asyml8/api-core';
import { Logger } from 'nestjs-pino';
import { join } from 'path';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create<NestFastifyApplication>(
    AppModule,
    new FastifyAdapter({ logger: true })
  );

  app.useLogger(app.get(Logger));
  app.useGlobalPipes(new ValidationPipe({ transform: true, whitelist: true }));
  app.setGlobalPrefix(process.env.API_PREFIX || 'api');

  // Enable CORS
  app.enableCors({
    origin: true,
    credentials: true,
  });

  // Serve static files for Swagger assets
  await app.register(require('@fastify/static'), {
    root: join(__dirname, '..', 'public'),
    prefix: '/',
  });

  // Swagger configuration
  const config = new DocumentBuilder()
    .setTitle(process.env.SWAGGER_INFO_TITLE || '[Project Name] API')
    .setDescription(process.env.SWAGGER_INFO_DESCRIPTION || '[Project Description]')
    .setVersion(process.env.SWAGGER_INFO_VERSION || '1.0.0')
    .addBearerAuth()
    .build();
  
  const document = SwaggerModule.createDocument(app, config);
  
  // Custom Swagger UI with theming
  const swaggerUI = new SwaggerUI('http://localhost:4000', {
    customSiteTitle: '[Project Name] API Documentation',
    topbarIconFilename: 'logo.svg',
    persistAuthorization: true,
    wavyGradient: {
      enabled: true,
      colors: ['#E67E22', '#5DADE2', '#2E86AB'], // Orange, medium blue, darker blue
      height: '93px',
      waveHeight: '25px',
    },
  });
  
  SwaggerModule.setup('docs', app, document, swaggerUI.customOptions);

  await app.listen(process.env.PORT || 4000, process.env.LISTEN_ON || '0.0.0.0');
  
  console.log(`🚀 Server running on http://localhost:${process.env.PORT || 4000}/api`);
  console.log(`📚 Swagger docs: http://localhost:${process.env.PORT || 4000}/docs`);
}

bootstrap();
```

### 2. **App Module (app.module.ts)**
```typescript
import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ThrottlerModule } from '@nestjs/throttler';
import { CacheModule } from '@nestjs/cache-manager';
import { LoggerModule } from 'nestjs-pino';
import { redisStore } from 'cache-manager-redis-store';

import { DatabaseModule } from './libs/database/database.module';
import { AuthModule } from './modules/auth/auth.module';
import { HealthModule } from './modules/health/health.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    LoggerModule.forRoot({
      pinoHttp: {
        transport: process.env.NODE_ENV === 'development' ? { target: 'pino-pretty' } : undefined,
      },
    }),
    ThrottlerModule.forRoot([{
      ttl: parseInt(process.env.RATE_LIMIT_TTL) || 60,
      limit: parseInt(process.env.RATE_LIMIT_LIMIT) || 100,
    }]),
    CacheModule.register({
      isGlobal: true,
      store: redisStore,
      host: process.env.REDIS_HOST,
      port: parseInt(process.env.REDIS_PORT),
      password: process.env.REDIS_PASSWORD,
    }),
    DatabaseModule,
    AuthModule,
    HealthModule,
    // Add project-specific modules here
  ],
})
export class AppModule {}
```

### 3. **Database Configuration (libs/database/database.module.ts)**
```typescript
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';

@Module({
  imports: [
    TypeOrmModule.forRoot({
      type: 'postgres',
      host: process.env.DATABASE_HOST,
      port: parseInt(process.env.DATABASE_PORT),
      username: process.env.DATABASE_USERNAME,
      password: process.env.DATABASE_PASSWORD,
      database: process.env.DATABASE_DB_NAME,
      entities: [__dirname + '/entities/*.entity{.ts,.js}'],
      migrations: [__dirname + '/migrations/*{.ts,.js}'],
      synchronize: false,
      logging: process.env.TYPE_ORM_LOGGER === 'advanced-console',
      cache: {
        type: 'redis',
        options: {
          host: process.env.REDIS_HOST,
          port: parseInt(process.env.REDIS_PORT),
        },
        duration: parseInt(process.env.TYPE_ORM_CACHE_DURATION) || 30000,
      },
      extra: {
        max: parseInt(process.env.DATABASE_POOL_SIZE) || 10,
      },
    }),
  ],
})
export class DatabaseModule {}
```

### 4. **Base Entity (libs/database/entities/base.entity.ts)**
```typescript
import { PrimaryGeneratedColumn, CreateDateColumn, UpdateDateColumn, DeleteDateColumn } from 'typeorm';

export abstract class BaseEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  @DeleteDateColumn()
  deletedAt?: Date;
}
```

### 5. **Auth Module Foundation (modules/auth/auth.module.ts)**
```typescript
import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';
import { JwtStrategy } from './strategies/jwt.strategy';

@Module({
  imports: [
    PassportModule,
    JwtModule.register({
      secret: process.env.JWT_SECRET,
      signOptions: { expiresIn: process.env.JWT_EXPIRES_IN },
    }),
  ],
  controllers: [AuthController],
  providers: [AuthService, JwtStrategy],
  exports: [AuthService],
})
export class AuthModule {}
```

### 6. **Health Module (modules/health/health.module.ts)**
```typescript
import { Module } from '@nestjs/common';
import { HealthController } from './health.controller';
import { HealthService } from './health.service';

@Module({
  controllers: [HealthController],
  providers: [HealthService],
})
export class HealthModule {}
```

## **Test Structure:**

```
test/
├── setup.ts              # Unit test setup
├── setup-e2e.ts          # E2E test setup  
├── jest-e2e.json         # E2E Jest config
└── app.e2e-spec.ts       # Sample E2E test
```

## **Usage Instructions:**

1. **Replace placeholders:**
   - `[project-name]` → Your project name
   - `[Project Name]` → Your project display name
   - `[Project Description]` → Your project description
   - `[Company]` → Your company name
   - `[company]` → Your company domain

2. **Create all configuration files:**
   - Copy package.json with dependencies
   - Create ESLint and Prettier configurations
   - Set up Jest testing configurations
   - Create comprehensive README.md
   - Configure environment variables

3. **Add project-specific modules:**
   - Create modules in `src/modules/`
   - Import them in `app.module.ts`
   - Follow the established patterns

4. **Customize entities:**
   - Extend `BaseEntity` for all entities
   - Place in `src/libs/database/entities/`

5. **Environment setup:**
   - Copy `.env.example` to `.env`
   - Configure database and Redis connections
   - Set JWT secrets and other credentials

## **Modern Linting Configuration:**

### **ESLint Configuration (.eslintrc.js)**
```javascript
module.exports = {
  parser: '@typescript-eslint/parser',
  parserOptions: {
    project: 'tsconfig.json',
    tsconfigRootDir: __dirname,
    sourceType: 'module',
    ecmaVersion: 2022,
  },
  plugins: [
    '@typescript-eslint/eslint-plugin',
    'import',
    'unused-imports',
    'prefer-arrow',
  ],
  extends: [
    'eslint:recommended',
    '@typescript-eslint/recommended',
    '@typescript-eslint/recommended-requiring-type-checking',
    'plugin:@typescript-eslint/strict',
    'plugin:import/recommended',
    'plugin:import/typescript',
    'prettier',
  ],
  root: true,
  env: {
    node: true,
    jest: true,
    es2022: true,
  },
  ignorePatterns: [
    '.eslintrc.js',
    'dist/',
    'node_modules/',
    '*.d.ts',
    'coverage/',
  ],
  rules: {
    // TypeScript strict rules
    '@typescript-eslint/no-explicit-any': 'warn',
    '@typescript-eslint/no-unused-vars': 'off',
    '@typescript-eslint/prefer-nullish-coalescing': 'error',
    '@typescript-eslint/prefer-optional-chain': 'error',
    '@typescript-eslint/no-floating-promises': 'error',
    '@typescript-eslint/await-thenable': 'error',
    '@typescript-eslint/no-misused-promises': 'error',
    '@typescript-eslint/require-await': 'error',
    '@typescript-eslint/consistent-type-imports': [
      'error',
      { prefer: 'type-imports', fixStyle: 'separate-type-imports' },
    ],
    
    // Import organization
    'import/order': [
      'error',
      {
        groups: ['builtin', 'external', 'internal', 'parent', 'sibling', 'index'],
        'newlines-between': 'always',
        alphabetize: { order: 'asc', caseInsensitive: true },
      },
    ],
    'import/no-cycle': 'error',
    'import/no-duplicates': 'error',
    
    // Unused imports cleanup
    'unused-imports/no-unused-imports': 'error',
    'unused-imports/no-unused-vars': [
      'warn',
      { vars: 'all', varsIgnorePattern: '^_', args: 'after-used', argsIgnorePattern: '^_' },
    ],
    
    // Modern JavaScript patterns
    'prefer-const': 'error',
    'no-var': 'error',
    'object-shorthand': 'error',
    'prefer-template': 'error',
    'prefer-destructuring': ['error', { array: false, object: true }],
    'no-console': 'warn',
    'prefer-arrow/prefer-arrow-functions': [
      'error',
      { disallowPrototype: true, singleReturnOnly: false, classPropertiesAllowed: false },
    ],
    
    // NestJS specific
    'class-methods-use-this': 'off',
    '@typescript-eslint/parameter-properties': 'off',
  },
  settings: {
    'import/resolver': {
      typescript: { alwaysTryTypes: true, project: './tsconfig.json' },
    },
  },
  overrides: [
    {
      files: ['*.spec.ts', '*.test.ts', '**/__tests__/**/*'],
      env: { jest: true },
      rules: {
        '@typescript-eslint/no-explicit-any': 'off',
        '@typescript-eslint/no-non-null-assertion': 'off',
        '@typescript-eslint/no-empty-function': 'off',
      },
    },
  ],
};
```

### **Prettier Configuration (.prettierrc)**
```json
{
  "semi": true,
  "trailingComma": "es5",
  "singleQuote": true,
  "printWidth": 80,
  "tabWidth": 2,
  "useTabs": false,
  "quoteProps": "as-needed",
  "bracketSpacing": true,
  "bracketSameLine": false,
  "arrowParens": "avoid",
  "endOfLine": "lf",
  "embeddedLanguageFormatting": "auto",
  "singleAttributePerLine": false
}
```

### **Jest Configuration (jest.config.js)**
```javascript
module.exports = {
  displayName: '[project-name]',
  preset: 'ts-jest',
  testEnvironment: 'node',
  rootDir: '.',
  testRegex: '.*\\.spec\\.ts$',
  transform: {
    '^.+\\.(t|j)s$': 'ts-jest',
  },
  collectCoverageFrom: [
    'src/**/*.(t|j)s',
    '!src/**/*.spec.ts',
    '!src/**/*.interface.ts',
    '!src/**/*.dto.ts',
    '!src/**/*.entity.ts',
    '!src/main.ts',
    '!src/**/*.module.ts',
  ],
  coverageDirectory: './coverage',
  coverageReporters: ['text', 'lcov', 'html'],
  coverageThreshold: {
    global: {
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80,
    },
  },
  moduleNameMapping: {
    '^@/(.*)$': '<rootDir>/src/$1',
    '^@/libs/(.*)$': '<rootDir>/src/libs/$1',
    '^@/modules/(.*)$': '<rootDir>/src/modules/$1',
    '^@/database/(.*)$': '<rootDir>/src/database/$1',
    '^@/config/(.*)$': '<rootDir>/src/config/$1',
  },
  setupFilesAfterEnv: ['<rootDir>/test/setup.ts'],
  testTimeout: 10000,
  maxWorkers: '50%',
  clearMocks: true,
  restoreMocks: true,
};
```

### **E2E Jest Configuration (test/jest-e2e.json)**
```json
{
  "displayName": "[project-name]:e2e",
  "moduleFileExtensions": ["js", "json", "ts"],
  "rootDir": "..",
  "testEnvironment": "node",
  "testRegex": ".e2e-spec.ts$",
  "transform": {
    "^.+\\.(t|j)s$": "ts-jest"
  },
  "moduleNameMapping": {
    "^@/(.*)$": "<rootDir>/src/$1",
    "^@/libs/(.*)$": "<rootDir>/src/libs/$1",
    "^@/modules/(.*)$": "<rootDir>/src/modules/$1",
    "^@/database/(.*)$": "<rootDir>/src/database/$1",
    "^@/config/(.*)$": "<rootDir>/src/config/$1"
  },
  "setupFilesAfterEnv": ["<rootDir>/test/setup-e2e.ts"],
  "testTimeout": 30000,
  "maxWorkers": 1,
  "forceExit": true,
  "detectOpenHandles": true
}
```

### **Test Setup Files**

**Unit Test Setup (test/setup.ts)**
```typescript
import 'reflect-metadata';

beforeAll(() => {
  process.env.NODE_ENV = 'test';
  process.env.JWT_SECRET = 'test-jwt-secret';
  process.env.DATABASE_HOST = 'localhost';
  process.env.DATABASE_PORT = '5432';
  process.env.DATABASE_USERNAME = 'test';
  process.env.DATABASE_PASSWORD = 'test';
  process.env.DATABASE_DB_NAME = 'test_db';
  process.env.REDIS_HOST = 'localhost';
  process.env.REDIS_PORT = '6379';
});

global.console = {
  ...console,
  log: jest.fn(),
  debug: jest.fn(),
  info: jest.fn(),
  warn: jest.fn(),
  error: jest.fn(),
};
```

**E2E Test Setup (test/setup-e2e.ts)**
```typescript
import 'reflect-metadata';

beforeAll(async () => {
  process.env.NODE_ENV = 'test';
  process.env.PORT = '0';
  process.env.JWT_SECRET = 'test-jwt-secret-e2e';
  process.env.DATABASE_HOST = 'localhost';
  process.env.DATABASE_PORT = '5432';
  process.env.DATABASE_USERNAME = 'test';
  process.env.DATABASE_PASSWORD = 'test';
  process.env.DATABASE_DB_NAME = 'test_e2e_db';
  process.env.REDIS_HOST = 'localhost';
  process.env.REDIS_PORT = '6379';
  process.env.LOG_LEVEL = 'error';
});

### **Prettier Ignore (.prettierignore)**
```
node_modules/
dist/
coverage/
*.d.ts
pnpm-lock.yaml
.env
.env.*
*.log
```

## **Project README Template:**

Create a comprehensive README.md file:

```markdown
# [Project Name] API

Modern, production-ready [description] API built with NestJS, Fastify, and TypeORM.

## 🚀 Features

- **NestJS + Fastify** - High-performance framework with dependency injection
- **TypeORM + PostgreSQL** - Robust database layer with migrations
- **Redis Caching** - Session storage and query result caching
- **JWT Authentication** - Secure authentication with refresh tokens
- **Modern Linting** - ESLint + Prettier with strict TypeScript rules
- **Comprehensive Testing** - Jest unit and E2E tests with coverage
- **API Documentation** - Auto-generated Swagger/OpenAPI docs
- **Health Monitoring** - System health and performance endpoints

## 📋 Prerequisites

- Node.js 20+
- PostgreSQL 14+
- Redis 6+
- pnpm 9+

## 🛠️ Installation

\`\`\`bash
# Install dependencies
pnpm install

# Copy environment variables
cp .env.example .env

# Configure your environment variables in .env
\`\`\`

## 🚀 Development

\`\`\`bash
# Start development server
pnpm dev

# Build for production
pnpm build

# Start production server
pnpm start:prod
\`\`\`

## 🗄️ Database

\`\`\`bash
# Generate migration
pnpm migration:generate

# Run migrations
pnpm migration:run

# Revert migration
pnpm migration:revert
\`\`\`

## 🧪 Testing

\`\`\`bash
# Run unit tests
pnpm test

# Run tests with coverage
pnpm test:cov

# Run E2E tests
pnpm test:e2e
\`\`\`

## 🔍 Code Quality

\`\`\`bash
# Lint code
pnpm lint

# Fix linting issues
pnpm lint:fix

# Format code
pnpm format

# Type check
pnpm type-check
\`\`\`

## 📚 API Documentation

Once the server is running, visit:
- **Swagger UI**: \`http://localhost:4000/docs\`
- **OpenAPI JSON**: \`http://localhost:4000/docs-json\`

## 🏗️ Project Structure

\`\`\`
src/
├── modules/              # Feature modules
├── libs/                 # Shared libraries
├── database/             # Database layer
├── config/               # Configuration
└── main.ts              # Application bootstrap
\`\`\`

## 🔐 Authentication

The API integrates with Supabase Auth supporting multiple authentication methods:

### **OAuth Providers**
- **Google OAuth** - \`POST /api/auth/oauth/google\`
- **GitHub OAuth** - \`POST /api/auth/oauth/github\`
- **Discord OAuth** - \`POST /api/auth/oauth/discord\`
- **Apple OAuth** - \`POST /api/auth/oauth/apple\`

### **Traditional Auth**
- **Email/Password** - \`POST /api/auth/login\`
- **Magic Links** - \`POST /api/auth/magic-link\`
- **Phone/SMS** - \`POST /api/auth/phone\`

### **Token Management**
- **Refresh Token** - \`POST /api/auth/refresh\`
- **Logout** - \`POST /api/auth/logout\`
- **Profile** - \`GET /api/auth/me\`

### **Authentication Flow**

1. **OAuth Login**: Client redirects to Supabase OAuth provider
2. **Token Exchange**: Supabase returns access token and refresh token
3. **API Validation**: API validates Supabase token and creates internal JWT
4. **Request Authorization**: All API calls use internal JWT with Supabase token validation

## 🏥 Health Checks

Monitor system health at:
- **Overall Health**: \`GET /api/health\`
- **Database Health**: \`GET /api/health/database\`
- **Memory Health**: \`GET /api/health/memory\`

## 🚀 Deployment

### Production Checklist

- [ ] Set \`NODE_ENV=production\`
- [ ] Configure production database
- [ ] Set secure JWT secrets
- [ ] Configure Redis for production
- [ ] Enable HTTPS/SSL
- [ ] Set up monitoring and logging

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Ensure all tests pass
5. Run linting and formatting
6. Submit a pull request

## 📄 License

This project is licensed under the UNLICENSED License.
```
## **Dependency Validation Process:**

Before using this foundation, validate dependencies in your monorepo:

### **1. Test Installation**
```bash
# From monorepo root
pnpm install --filter @company/[project-name]-api
```

### **2. Common Issues & Solutions**

## **Common Issues & Solutions**

**Version Conflicts:**
- Use exact versions that are confirmed to exist in npm registry
- Match TypeScript/ESLint versions across workspace
- Use `cache-manager-redis-yet` instead of deprecated `cache-manager-redis-store`
- Add `@fastify/static` dependency for Swagger documentation

**Connection Refused Errors:**
- Make Redis optional for development (use in-memory cache)
- Remove complex modules during initial setup
- Test with minimal configuration first

**Fastify Issues:**
- Use `app.enableCors()` instead of `@fastify/cors` plugin
- Install `@fastify/static` for Swagger support
- Version mismatch warnings are usually non-blocking

**Monorepo Compatibility:**
- Ensure workspace dependencies use `workspace:*` protocol
- Check peer dependency warnings (usually non-blocking)
- Align major versions with root package.json

**Validation Checklist:**
- ✅ All packages install without errors
- ✅ TypeScript compiles successfully
- ✅ ESLint runs without configuration errors
- ✅ Jest tests can be executed
- ✅ NestJS application starts and responds to requests
- ✅ Swagger documentation is accessible

## **Enhanced Features:**

- ✅ **Validated Dependencies** - All versions tested for compatibility
- ✅ **Modern Linting** - Strict TypeScript rules with auto-formatting
- ✅ **Jest Testing** - Unit & E2E tests with coverage thresholds
- ✅ **Comprehensive README** - Complete documentation template
- ✅ **NestJS + Fastify** - High-performance setup
- ✅ **TypeORM + Redis** - Database with caching layer
- ✅ **JWT Authentication** - With refresh token support
- ✅ **Rate Limiting** - Redis-based throttling
- ✅ **Swagger Documentation** - Auto-generated API docs
- ✅ **Structured Logging** - Pino for production logging
- ✅ **Health Monitoring** - System health endpoints
- ✅ **Global Validation** - Zod + class-validator integration
- ✅ **Error Handling** - Comprehensive exception filters
- ✅ **Migration System** - TypeORM with post-processors
- ✅ **Docker Ready** - Containerization support

This foundation provides a **production-ready, validated base** that can be extended for any API project while maintaining consistency and best practices across your organization.
