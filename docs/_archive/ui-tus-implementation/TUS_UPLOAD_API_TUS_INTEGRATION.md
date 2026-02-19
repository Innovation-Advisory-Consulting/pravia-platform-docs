# TUS Upload API - TUS Integration & Deployment (Part 3)

## TUS Integration

### TUS Service

**src/modules/tus/tus.service.ts**

```typescript
import { Injectable, Logger } from '@nestjs/common';
import { Server, Upload as TusUpload } from '@tus/server';
import { FileStore } from '@tus/file-store';
import { S3Store } from '@tus/s3-store';
import { ConfigService } from '@nestjs/config';
import { UploadService } from '../upload/upload.service';
import { StorageBackend, UploadStatus } from '../upload/entity/upload.entity';

@Injectable()
export class TusService {
  private readonly logger = new Logger(TusService.name);
  private tusServer: Server;

  constructor(
    private readonly configService: ConfigService,
    private readonly uploadService: UploadService,
  ) {
    this.initializeTusServer();
  }

  private initializeTusServer() {
    const storageBackend = this.configService.get('TUS_STORAGE_BACKEND', 's3');
    const datastore = this.createDatastore(storageBackend);

    this.tusServer = new Server({
      path: this.configService.get('TUS_PATH', '/files'),
      datastore,
      maxSize: parseInt(this.configService.get('TUS_MAX_SIZE', '10737418240')),
      respectForwardedHeaders: true,
      
      // Lifecycle hooks
      onUploadCreate: this.onUploadCreate.bind(this),
      onUploadFinish: this.onUploadFinish.bind(this),
      onIncomingRequest: this.onIncomingRequest.bind(this),
      onResponseError: this.onResponseError.bind(this),
    });

    this.logger.log(`TUS server initialized with ${storageBackend} storage`);
  }

  private createDatastore(backend: string) {
    if (backend === 's3') {
      return new S3Store({
        partSize: parseInt(this.configService.get('TUS_PART_SIZE', '5')) * 1024 * 1024,
        expirationPeriodInMilliseconds: parseInt(
          this.configService.get('TUS_EXPIRY_MS', '86400000')
        ),
        s3ClientConfig: {
          bucket: this.configService.get('STORAGE_S3_BUCKET'),
          region: this.configService.get('STORAGE_S3_REGION'),
          endpoint: this.configService.get('STORAGE_S3_ENDPOINT'),
          credentials: {
            accessKeyId: this.configService.get('STORAGE_S3_ACCESS_KEY'),
            secretAccessKey: this.configService.get('STORAGE_S3_SECRET_KEY'),
          },
        },
      });
    }

    // Default to file store
    return new FileStore({
      directory: this.configService.get('STORAGE_LOCAL_PATH', './uploads'),
    });
  }

  // Lifecycle Hooks

  private async onUploadCreate(
    req: any,
    res: any,
    upload: TusUpload,
  ): Promise<void> {
    this.logger.log(`Upload created: ${upload.id}`);

    try {
      // Extract metadata from TUS upload
      const metadata = upload.metadata || {};
      const filename = metadata.filename || 'unknown';
      const mimeType = metadata.filetype || 'application/octet-stream';

      // Create database record
      await this.uploadService.create({
        filename,
        size: upload.size,
        mimeType,
        storageBackend: this.configService.get('TUS_STORAGE_BACKEND') as StorageBackend,
        userId: metadata.userId,
        tenantId: metadata.tenantId,
        metadata,
      });

      this.logger.log(`Database record created for upload: ${upload.id}`);
    } catch (error) {
      this.logger.error(`Failed to create upload record: ${error.message}`, error.stack);
      throw error;
    }
  }

  private async onUploadFinish(
    req: any,
    res: any,
    upload: TusUpload,
  ): Promise<void> {
    this.logger.log(`Upload finished: ${upload.id}`);

    try {
      await this.uploadService.updateProgress(
        upload.id,
        upload.offset,
        UploadStatus.COMPLETED,
      );

      this.logger.log(`Upload marked as completed: ${upload.id}`);
    } catch (error) {
      this.logger.error(`Failed to mark upload as completed: ${error.message}`, error.stack);
    }
  }

  private async onIncomingRequest(req: any, res: any, id: string): Promise<void> {
    this.logger.debug(`Incoming request for upload: ${id}`);

    // Update progress in database
    try {
      const upload = await this.tusServer.getUpload(id);
      if (upload) {
        await this.uploadService.updateProgress(
          id,
          upload.offset,
          UploadStatus.UPLOADING,
        );
      }
    } catch (error) {
      this.logger.warn(`Failed to update progress: ${error.message}`);
    }
  }

  private async onResponseError(
    req: any,
    res: any,
    error: Error,
  ): Promise<void> {
    this.logger.error(`TUS error: ${error.message}`, error.stack);
  }

  // Public methods

  getServer(): Server {
    return this.tusServer;
  }

  async handleRequest(req: any, res: any): Promise<void> {
    return this.tusServer.handle(req, res);
  }
}
```

### TUS Controller

**src/modules/tus/tus.controller.ts**

```typescript
import { All, Controller, Req, Res } from '@nestjs/common';
import { ApiTags, ApiExcludeEndpoint } from '@nestjs/swagger';
import { TusService } from './tus.service';

@Controller('files')
@ApiTags('TUS Protocol')
export class TusController {
  constructor(private readonly tusService: TusService) {}

  @All('*')
  @ApiExcludeEndpoint() // Hide from Swagger as it's TUS protocol
  async handleTusRequest(@Req() req: any, @Res() res: any) {
    return this.tusService.handleRequest(req.raw, res.raw);
  }
}
```

### TUS Module

**src/modules/tus/tus.module.ts**

```typescript
import { Module } from '@nestjs/common';
import { TusController } from './tus.controller';
import { TusService } from './tus.service';
import { UploadModule } from '../upload/upload.module';

@Module({
  imports: [UploadModule],
  controllers: [TusController],
  providers: [TusService],
  exports: [TusService],
})
export class TusModule {}
```

---

## Database Migration

**src/database/migrations/1700000001000-CreateUploadTables.ts**

```typescript
import { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateUploadTables1700000001000 implements MigrationInterface {
  name = 'CreateUploadTables1700000001000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    // Create schema
    await queryRunner.query(`CREATE SCHEMA IF NOT EXISTS uploads`);

    // Create upload table
    await queryRunner.query(`
      CREATE TABLE uploads.upload (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        created_at TIMESTAMP NOT NULL DEFAULT NOW(),
        updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
        deleted_at TIMESTAMP,
        
        filename VARCHAR(500) NOT NULL,
        original_filename VARCHAR(500) NOT NULL,
        mime_type VARCHAR(100),
        size BIGINT NOT NULL,
        
        status VARCHAR(50) NOT NULL DEFAULT 'pending',
        upload_offset BIGINT NOT NULL DEFAULT 0,
        upload_length BIGINT,
        
        storage_backend VARCHAR(50) NOT NULL,
        storage_path TEXT NOT NULL,
        storage_url TEXT,
        
        user_id UUID,
        tenant_id UUID,
        
        tus_id VARCHAR(255) UNIQUE NOT NULL,
        upload_metadata JSONB,
        
        expires_at TIMESTAMP,
        
        CONSTRAINT upload_status_check CHECK (
          status IN ('pending', 'uploading', 'completed', 'failed', 'expired')
        )
      )
    `);

    // Create indexes
    await queryRunner.query(`CREATE INDEX idx_upload_user_id ON uploads.upload(user_id)`);
    await queryRunner.query(`CREATE INDEX idx_upload_tenant_id ON uploads.upload(tenant_id)`);
    await queryRunner.query(`CREATE INDEX idx_upload_status ON uploads.upload(status)`);
    await queryRunner.query(`CREATE INDEX idx_upload_tus_id ON uploads.upload(tus_id)`);
    await queryRunner.query(`CREATE INDEX idx_upload_expires_at ON uploads.upload(expires_at)`);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP TABLE uploads.upload`);
    await queryRunner.query(`DROP SCHEMA uploads CASCADE`);
  }
}
```

---

## App Module

**src/app.module.ts**

```typescript
import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { APP_INTERCEPTOR } from '@nestjs/core';
import { ResponseTransformInterceptor } from '@asyml8/api-core';

import { AppController } from './app.controller';
import { AppService } from './app.service';
import { UploadModule } from './modules/upload/upload.module';
import { TusModule } from './modules/tus/tus.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
    }),
    TypeOrmModule.forRoot({
      type: 'postgres',
      host: process.env.DATABASE_HOST,
      port: parseInt(process.env.DATABASE_PORT || '5432'),
      username: process.env.DATABASE_USERNAME,
      password: process.env.DATABASE_PASSWORD,
      database: process.env.DATABASE_DB_NAME,
      entities: ['dist/modules/**/entity/*.entity.js'],
      migrations: ['dist/database/migrations/*.js'],
      synchronize: false,
      logging: process.env.NODE_ENV === 'development',
    }),
    UploadModule,
    TusModule,
  ],
  controllers: [AppController],
  providers: [
    AppService,
    {
      provide: APP_INTERCEPTOR,
      useClass: ResponseTransformInterceptor,
    },
  ],
})
export class AppModule {}
```

---

## Main Bootstrap

**src/main.ts**

```typescript
import { createNestApp } from '@asyml8/api-core';
import { AppModule } from './app.module';

async function bootstrap() {
  await createNestApp(AppModule, {
    title: process.env.APP_TITLE || 'TUS Upload API',
    description: process.env.APP_DESCRIPTION || 'Resumable File Upload Service',
    serverName: process.env.SERVER_NAME || 'TUS Upload Server',
    autoIncrementVersion: true,
    swagger: {
      topbarIconFilename: 'upload-logo.svg',
      persistAuthorization: process.env.SWAGGER_PERSIST_AUTH === 'true',
      wavyGradient: {
        enabled: process.env.SWAGGER_GRADIENT_ENABLED === 'true',
        colors: process.env.SWAGGER_GRADIENT_COLORS?.split(',') || [
          '#E67E22',
          '#5DADE2',
          '#2E86AB',
        ],
        height: '60px',
        waveHeight: '25px',
      },
    },
  });
}

bootstrap().catch(console.error);
```

---

## Client Integration

### Browser Client (tus-js-client)

```typescript
import * as tus from 'tus-js-client';

// Create upload
const file = document.querySelector('input[type=file]').files[0];

const upload = new tus.Upload(file, {
  endpoint: 'http://localhost:4004/files',
  retryDelays: [0, 3000, 5000, 10000, 20000],
  metadata: {
    filename: file.name,
    filetype: file.type,
    userId: 'user-123',
    tenantId: 'tenant-456',
  },
  onError: (error) => {
    console.error('Upload failed:', error);
  },
  onProgress: (bytesUploaded, bytesTotal) => {
    const percentage = ((bytesUploaded / bytesTotal) * 100).toFixed(2);
    console.log(`Progress: ${percentage}%`);
  },
  onSuccess: () => {
    console.log('Upload completed!');
    console.log('Download URL:', upload.url);
  },
});

// Start upload
upload.start();

// Pause/Resume
upload.abort();
upload.start(); // Resume from where it left off
```

### React Hook

```typescript
import { useState, useCallback } from 'react';
import * as tus from 'tus-js-client';

export function useFileUpload() {
  const [progress, setProgress] = useState(0);
  const [isUploading, setIsUploading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [uploadUrl, setUploadUrl] = useState<string | null>(null);

  const upload = useCallback((file: File, metadata?: Record<string, string>) => {
    setIsUploading(true);
    setError(null);
    setProgress(0);

    const tusUpload = new tus.Upload(file, {
      endpoint: '/files',
      metadata: {
        filename: file.name,
        filetype: file.type,
        ...metadata,
      },
      onError: (err) => {
        setError(err.message);
        setIsUploading(false);
      },
      onProgress: (bytesUploaded, bytesTotal) => {
        setProgress((bytesUploaded / bytesTotal) * 100);
      },
      onSuccess: () => {
        setUploadUrl(tusUpload.url);
        setIsUploading(false);
        setProgress(100);
      },
    });

    tusUpload.start();

    return {
      abort: () => tusUpload.abort(),
      resume: () => tusUpload.start(),
    };
  }, []);

  return { upload, progress, isUploading, error, uploadUrl };
}
```

---

## Deployment

### Docker Setup

**Dockerfile**

```dockerfile
FROM node:20-alpine AS builder

WORKDIR /app

COPY package*.json ./
COPY pnpm-lock.yaml ./

RUN npm install -g pnpm
RUN pnpm install --frozen-lockfile

COPY . .

RUN pnpm build

FROM node:20-alpine

WORKDIR /app

COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./

EXPOSE 4004

CMD ["node", "dist/main"]
```

**docker-compose.yml**

```yaml
version: '3.8'

services:
  tus-api:
    build: .
    ports:
      - '4004:4004'
    environment:
      - NODE_ENV=production
      - DATABASE_HOST=${DATABASE_HOST}
      - DATABASE_PORT=${DATABASE_PORT}
      - DATABASE_USERNAME=${DATABASE_USERNAME}
      - DATABASE_PASSWORD=${DATABASE_PASSWORD}
      - DATABASE_DB_NAME=${DATABASE_DB_NAME}
      - TUS_STORAGE_BACKEND=s3
      - STORAGE_S3_BUCKET=${STORAGE_S3_BUCKET}
      - STORAGE_S3_REGION=${STORAGE_S3_REGION}
      - STORAGE_S3_ENDPOINT=${STORAGE_S3_ENDPOINT}
      - STORAGE_S3_ACCESS_KEY=${STORAGE_S3_ACCESS_KEY}
      - STORAGE_S3_SECRET_KEY=${STORAGE_S3_SECRET_KEY}
    volumes:
      - ./uploads:/app/uploads
    restart: unless-stopped
```

### Build & Run

```bash
# Development
pnpm dev

# Build
pnpm build

# Run migrations
pnpm migration:run

# Production
pnpm start:prod

# Docker
docker-compose up -d
```

---

## Testing

### Unit Test Example

**src/modules/upload/upload.service.spec.ts**

```typescript
import { Test, TestingModule } from '@nestjs/testing';
import { UploadService } from './upload.service';
import { UploadRepository } from './upload.repository';
import { UploadStatus } from './entity/upload.entity';

describe('UploadService', () => {
  let service: UploadService;
  let repository: UploadRepository;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        UploadService,
        {
          provide: UploadRepository,
          useValue: {
            create: jest.fn(),
            findById: jest.fn(),
            update: jest.fn(),
          },
        },
      ],
    }).compile();

    service = module.get<UploadService>(UploadService);
    repository = module.get<UploadRepository>(UploadRepository);
  });

  it('should create upload', async () => {
    const dto = {
      filename: 'test.pdf',
      size: 1024,
      storageBackend: 's3' as any,
    };

    jest.spyOn(repository, 'create').mockResolvedValue({
      id: '123',
      ...dto,
      status: UploadStatus.PENDING,
    } as any);

    const result = await service.create(dto);
    expect(result.status).toBe(UploadStatus.PENDING);
  });
});
```

---

## Summary

### What You Built

✅ **Complete TUS Upload API** with:
- NestJS + TypeORM architecture
- PostgreSQL metadata storage
- S3/Local file storage
- Resumable upload support
- Progress tracking
- Expiration handling
- Swagger documentation

### Key Files Created

```
src/
├── modules/
│   ├── upload/          (7 files)
│   └── tus/             (3 files)
├── database/
│   └── migrations/      (1 file)
├── app.module.ts
└── main.ts

Total: ~15 files, ~1,200 lines of code
```

### Estimated Build Time

- **Setup:** 30 minutes
- **Entity/DTO:** 1 hour
- **Repository/Service:** 2 hours
- **Controller:** 1 hour
- **TUS Integration:** 2 hours
- **Testing:** 2 hours

**Total: 8-9 hours**

### Next Steps

1. Run migrations: `pnpm migration:run`
2. Start server: `pnpm dev`
3. Test with Swagger: `http://localhost:4004/api`
4. Integrate client: Use tus-js-client
5. Deploy: Docker or cloud platform

---

**Reference:** Based on `/api/nexus` architecture patterns
