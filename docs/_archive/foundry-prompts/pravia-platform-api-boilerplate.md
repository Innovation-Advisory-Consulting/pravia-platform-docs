# Pravia Platform API - Boilerplate Generation Prompt

Generate a complete NestJS Platform API that complements the existing `pravia-auth-api`. This API will handle business logic, organizations, roles, permissions, and contacts while integrating with the auth API for authentication.

## **Project Structure**

```
pravia-platform-api/
├── src/
│   ├── modules/
│   │   ├── health/            # System health monitoring
│   │   └── [platform-modules] # To be added later
│   ├── libs/
│   │   ├── core/              # Base classes & utilities
│   │   ├── database/          # TypeORM setup & entities
│   │   ├── interceptors/      # Request/response handling
│   │   ├── guards/            # Auth & permission guards
│   │   └── decorators/        # Custom decorators
│   ├── database/
│   │   ├── migrations/        # TypeORM migrations
│   │   ├── entities/          # Database entities
│   │   └── scripts/           # Migration processors
│   ├── config/                # Environment configuration
│   ├── app.module.ts          # Root module
│   ├── app.controller.ts      # Root controller
│   ├── app.service.ts         # Root service
│   ├── main.ts                # Application bootstrap
│   └── data-source.ts         # TypeORM data source
├── test/                      # E2E tests
├── public/                    # Static assets
├── docs/                      # Documentation
├── prompts/                   # Generation prompts
├── package.json
├── tsconfig.json
├── nest-cli.json
├── jest.config.js
├── .eslintrc.js
├── .prettierrc
├── .prettierignore
├── .env.example
├── .env
└── README.md
```

## **Package.json Configuration**

```json
{
  "name": "@asyml8/platform-api",
  "version": "1.0.0",
  "description": "Pravia Platform API - Business Logic & Organization Management",
  "author": "Pravia Team",
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
    "migration:process": "tsx ./src/database/scripts/post-migration-processor.ts",
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
    "@aws-sdk/client-s3": "^3.600.0",
    "@aws-sdk/client-ses": "^3.600.0",
    "@fastify/cors": "^9.0.1",
    "@fastify/static": "^7.0.4",
    "@nestjs/cache-manager": "^2.2.2",
    "@nestjs/common": "^10.3.8",
    "@nestjs/config": "^3.2.2",
    "@nestjs/core": "^10.3.8",
    "@nestjs/jwt": "^10.2.0",
    "@nestjs/passport": "^10.0.3",
    "@nestjs/platform-fastify": "^10.3.8",
    "@nestjs/swagger": "^7.3.1",
    "@nestjs/throttler": "^5.1.2",
    "@nestjs/typeorm": "^10.0.2",
    "@asyml8/api-core": "workspace:*",
    "@asyml8/config": "workspace:*",
    "@asyml8/sdk": "workspace:*",
    "@asyml8/utils": "workspace:*",
    "axios": "^1.7.0",
    "bcrypt": "^5.1.1",
    "cache-manager-redis-yet": "^5.1.4",
    "class-transformer": "^0.5.1",
    "class-validator": "^0.14.1",
    "dotenv": "^16.4.0",
    "fastify": "^4.26.2",
    "nestjs-pino": "^4.0.0",
    "pg": "^8.11.5",
    "pino": "^9.0.0",
    "redis": "^4.6.13",
    "typeorm": "^0.3.17",
    "zod": "^4.1.11"
  },
  "devDependencies": {
    "@nestjs/cli": "^10.3.2",
    "@nestjs/schematics": "^10.1.1",
    "@nestjs/testing": "^10.3.8",
    "@types/bcrypt": "^5.0.2",
    "@types/express": "^4.17.21",
    "@types/jest": "^29.5.12",
    "@types/node": "^20.0.0",
    "@types/pg": "^8.11.5",
    "@typescript-eslint/eslint-plugin": "^7.0.0",
    "@typescript-eslint/parser": "^7.0.0",
    "eslint": "^8.57.0",
    "eslint-config-prettier": "^9.1.0",
    "eslint-import-resolver-typescript": "^3.6.1",
    "eslint-plugin-import": "^2.29.1",
    "eslint-plugin-prefer-arrow": "^1.2.3",
    "eslint-plugin-prettier": "^5.1.3",
    "eslint-plugin-unused-imports": "^3.2.0",
    "jest": "^29.7.0",
    "prettier": "^3.2.5",
    "source-map-support": "^0.5.21",
    "supertest": "^6.3.4",
    "ts-jest": "^29.1.2",
    "ts-loader": "^9.5.1",
    "ts-node": "^10.9.2",
    "tsconfig-paths": "^4.2.0",
    "tsx": "^4.7.0",
    "typescript": "^5.4.0"
  }
}
```

## **TypeScript Configuration (tsconfig.json)**

```json
{
  "compilerOptions": {
    "module": "commonjs",
    "declaration": true,
    "removeComments": true,
    "emitDecoratorMetadata": true,
    "experimentalDecorators": true,
    "allowSyntheticDefaultImports": true,
    "target": "ES2022",
    "sourceMap": true,
    "outDir": "./dist",
    "baseUrl": "./",
    "incremental": true,
    "skipLibCheck": true,
    "strictNullChecks": false,
    "noImplicitAny": false,
    "strictBindCallApply": false,
    "forceConsistentCasingInFileNames": false,
    "noFallthroughCasesInSwitch": false,
    "paths": {
      "@/*": ["src/*"],
      "@/libs/*": ["src/libs/*"],
      "@/modules/*": ["src/modules/*"],
      "@/database/*": ["src/database/*"],
      "@/config/*": ["src/config/*"]
    }
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
```

## **Main Application Bootstrap (src/main.ts)**

```typescript
import { NestFactory } from '@nestjs/core';
import { FastifyAdapter, NestFastifyApplication } from '@nestjs/platform-fastify';
import { ValidationPipe } from '@nestjs/common';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { SwaggerUI } from '@asyml8/api-core';
import { join } from 'path';

import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create<NestFastifyApplication>(
    AppModule,
    new FastifyAdapter({ logger: true }),
  );

  // Global prefix
  app.setGlobalPrefix('api');

  // CORS
  await app.register(require('@fastify/cors'), {
    origin: true,
    credentials: true,
  });

  // Static files
  await app.register(require('@fastify/static'), {
    root: join(__dirname, '..', 'public'),
    prefix: '/public/',
  });

  // Global validation pipe
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
      transformOptions: {
        enableImplicitConversion: true,
      },
    }),
  );

  // Swagger configuration
  const config = new DocumentBuilder()
    .setTitle('Pravia Platform API')
    .setDescription('Business Logic & Organization Management API for Pravia ecosystem')
    .setVersion('1.0.0')
    .addBearerAuth()
    .addTag('Application', 'Basic application information and metadata endpoints')
    .addTag('Health', 'System health monitoring endpoints for database, memory, and network status')
    .build();

  const document = SwaggerModule.createDocument(app, config);
  
  // Custom Swagger UI
  const swaggerUI = new SwaggerUI('http://localhost:5000', {
    customSiteTitle: 'Pravia Platform API Documentation',
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

  const port = 5000;
  await app.listen(port, '0.0.0.0');

  console.log(`🚀 Server running on http://localhost:${port}/api`);
  console.log(`📚 Swagger docs: http://localhost:${port}/docs`);
}

bootstrap();
```

## **App Module (src/app.module.ts)**

```typescript
import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ThrottlerModule } from '@nestjs/throttler';
import { CacheModule } from '@nestjs/cache-manager';
import { LoggerModule } from 'nestjs-pino';

import { AppController } from './app.controller';
import { AppService } from './app.service';
import { HealthModule } from './modules/health/health.module';
import { DatabaseModule } from './libs/database/database.module';

@Module({
  imports: [
    // Configuration
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
    }),

    // Logging
    LoggerModule.forRoot({
      pinoHttp: {
        level: process.env.LOG_LEVEL || 'info',
        transport: {
          target: 'pino-pretty',
          options: {
            colorize: true,
            singleLine: true,
          },
        },
      },
    }),

    // Rate limiting
    ThrottlerModule.forRoot([
      {
        ttl: parseInt(process.env.RATE_LIMIT_TTL || '60') * 1000,
        limit: parseInt(process.env.RATE_LIMIT_LIMIT || '100'),
      },
    ]),

    // Caching
    CacheModule.register({
      isGlobal: true,
      ttl: 300,
    }),

    // Database
    DatabaseModule,

    // Feature modules
    HealthModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
```

## **Environment Configuration (.env.example)**

```env
# Application
NODE_ENV=development
PORT=5000
LOG_LEVEL=log,error,warn,debug,verbose
SERVER_URL=http://localhost:5000
LISTEN_ON=0.0.0.0
API_PREFIX=api
FASTIFY_LOGGER=true

# Database - Shared PostgreSQL from monorepo root
DATABASE_CONNECTION=postgres
DATABASE_HOST=localhost
DATABASE_PORT=5432
DATABASE_USERNAME=postgres
DATABASE_PASSWORD=postgres
DATABASE_DB_NAME=pravia_platform
DATABASE_POOL_SIZE=10
TYPE_ORM_LOGGER=advanced-console
TYPE_ORM_CACHE=false
TYPE_ORM_CACHE_DURATION=30000

# Security
JWT_SECRET=dev-jwt-secret-key-change-this-in-production-32-chars-min
JWT_EXPIRES_IN=15m
JWT_REFRESH_EXPIRES_IN=7d
RATE_LIMIT_TTL=60
RATE_LIMIT_LIMIT=100

# Auth API Integration
AUTH_API_URL=http://localhost:4000/api
AUTH_API_INTERNAL_KEY=internal-service-key-change-in-production

# Redis (optional - for caching)
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=
REDIS_DB=1

# AWS (optional)
AWS_ACCESS_KEY_ID=your-access-key
AWS_SECRET_ACCESS_KEY=your-secret-key
AWS_REGION=us-east-1
S3_STORAGE_BUCKET=pravia-platform-storage

# Email (optional)
AWS_SES_REGION=us-east-1
AWS_SES_FROM_EMAIL=platform@asyml8.com
AWS_SES_FROM_NAME=Pravia Platform
```

## **Database Configuration (src/libs/database/database.module.ts)**

```typescript
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ConfigModule, ConfigService } from '@nestjs/config';

@Module({
  imports: [
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      useFactory: (configService: ConfigService) => ({
        type: 'postgres',
        host: configService.get('DATABASE_HOST'),
        port: configService.get('DATABASE_PORT'),
        username: configService.get('DATABASE_USERNAME'),
        password: configService.get('DATABASE_PASSWORD'),
        database: configService.get('DATABASE_DB_NAME'),
        entities: [__dirname + '/../**/*.entity{.ts,.js}'],
        migrations: [__dirname + '/../../database/migrations/*{.ts,.js}'],
        synchronize: false,
        logging: configService.get('TYPE_ORM_LOGGER') === 'advanced-console',
        cache: configService.get('TYPE_ORM_CACHE') === 'true',
        extra: {
          max: configService.get('DATABASE_POOL_SIZE') || 10,
        },
      }),
      inject: [ConfigService],
    }),
  ],
})
export class DatabaseModule {}
```

## **Base Entity (src/libs/database/entities/base.entity.ts)**

```typescript
import {
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
  DeleteDateColumn,
  Column,
} from 'typeorm';

export abstract class BaseEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  @DeleteDateColumn({ name: 'deleted_at', nullable: true })
  deletedAt?: Date;

  @Column({ name: 'created_by', nullable: true })
  createdBy?: string;

  @Column({ name: 'updated_by', nullable: true })
  updatedBy?: string;
}
```

## **Health Module (src/modules/health/)**

Create a complete health monitoring module with:
- `health.module.ts` - Module configuration
- `health.controller.ts` - Health check endpoints
- `health.service.ts` - Health check logic
- Database, memory, and network health checks
- Swagger documentation

## **Core Libraries Structure**

Create the following library structure:
- `src/libs/core/` - Base classes, utilities, constants
- `src/libs/database/` - TypeORM configuration and base entities
- `src/libs/interceptors/` - Request/response interceptors
- `src/libs/guards/` - Authentication and authorization guards
- `src/libs/decorators/` - Custom decorators

## **Testing Configuration**

Set up Jest configuration with:
- Unit test configuration
- E2E test setup
- Coverage reporting
- Path mapping support
- Test utilities and mocks

## **Linting & Formatting**

Configure ESLint and Prettier with the same rules as pravia-auth-api:
- TypeScript strict rules
- Import organization
- Unused imports removal
- Consistent code formatting

## **Documentation**

Create comprehensive documentation:
- `README.md` - Project overview and setup
- `docs/CONFIGURATION.md` - Environment configuration guide
- `docs/ARCHITECTURE.md` - System architecture overview
- `docs/API.md` - API documentation and examples

## **Key Requirements**

1. **Port Configuration**: Use port 5000 (different from auth API's 4000)
2. **Database**: Separate database `pravia_platform` but same PostgreSQL instance
3. **Integration Ready**: Prepared for auth API integration via HTTP calls
4. **Swagger Branding**: Same FARO | PRAVIA branding as auth API
5. **Modular Structure**: Ready for platform modules to be added
6. **Production Ready**: All production configurations and best practices
7. **Monorepo Compatible**: Works with existing @asyml8 workspace packages

## **Next Steps After Generation**

After generating the boilerplate:
1. Add platform-specific modules (organizations, roles, permissions, contacts)
2. Implement auth API integration middleware
3. Add business logic entities and services
4. Configure inter-service communication
5. Set up deployment configurations

This boilerplate provides a solid foundation that mirrors the pravia-auth-api structure while being optimized for platform business logic and organization management.
