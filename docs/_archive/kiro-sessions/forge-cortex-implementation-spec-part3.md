# Forge-Cortex Integration - Part 3

## Phase 4: Forge Integration

### Priority: MEDIUM
### Estimated Effort: 1 day
### Dependencies: Phase 1 (n8n workflow), Phase 3 (HelixClient)

### Objective
Update Forge API to automatically trigger the n8n workflow via Helix when a file upload completes.

---

### 4.1 Add HelixClient to Forge

#### Update Package Dependencies

**File:** `api/forge/package.json`

```json
{
  "dependencies": {
    "@asyml8/api-core": "workspace:*",
    // ... other dependencies
  }
}
```

#### Import HelixClientModule

**File:** `api/forge/src/app.module.ts`

```typescript
import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { HelixClientModule } from '@asyml8/api-core';
import { TusModule } from './modules/tus/tus.module';
// ... other imports

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    HelixClientModule,  // Add this
    TusModule,
    // ... other modules
  ],
})
export class AppModule {}
```

---

### 4.2 Update TUS Service

#### Inject HelixClient

**File:** `api/forge/src/modules/tus/tus.service.ts`

```typescript
import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { HelixClient } from '@asyml8/api-core';

@Injectable()
export class TusService {
  private readonly logger = new Logger(TusService.name);
  private readonly documentProcessingWorkflowId: string;

  constructor(
    private readonly helixClient: HelixClient,
    private readonly configService: ConfigService,
  ) {
    this.documentProcessingWorkflowId = this.configService.getOrThrow<string>(
      'DOCUMENT_PROCESSING_WORKFLOW_ID',
    );
  }

  // ... existing methods ...

  /**
   * Called when TUS upload completes
   */
  async onUploadComplete(
    uploadId: string,
    metadata: Record<string, any>,
    storagePath: string,
    fileSize: number,
  ): Promise<void> {
    this.logger.log(`Upload complete: ${uploadId}`);

    try {
      // Extract metadata
      const documentId = metadata.document_id;
      const kbId = metadata.kb_id;
      const filename = metadata.filename;
      const contentType = metadata.content_type;

      // Validate required metadata
      if (!documentId || !kbId) {
        this.logger.warn(
          `Missing required metadata for upload ${uploadId}. Skipping workflow trigger.`,
        );
        return;
      }

      // Trigger n8n workflow via Helix
      this.logger.log(
        `Triggering document processing workflow for document ${documentId}`,
      );

      const execution = await this.helixClient.executeWorkflow(
        this.documentProcessingWorkflowId,
        {
          document_id: documentId,
          file_id: uploadId,
          kb_id: kbId,
          storage_path: storagePath,
          filename: filename,
          content_type: contentType,
          file_size: fileSize,
        },
      );

      this.logger.log(
        `Workflow triggered successfully. Execution ID: ${execution.executionId}`,
      );
    } catch (error) {
      this.logger.error(
        `Failed to trigger workflow for upload ${uploadId}`,
        error.stack,
      );
      // Don't throw - upload is complete, workflow trigger is best-effort
    }
  }
}
```

---

### 4.3 Update TUS Controller

#### Hook into Upload Complete Event

**File:** `api/forge/src/modules/tus/tus.controller.ts`

```typescript
import { Controller, Patch, Req, Res, Headers } from '@nestjs/common';
import { Request, Response } from 'express';
import { TusService } from './tus.service';

@Controller('api/v1/files/tus')
export class TusController {
  constructor(private readonly tusService: TusService) {}

  @Patch(':id')
  async uploadChunk(
    @Req() req: Request,
    @Res() res: Response,
    @Headers('upload-offset') uploadOffset: string,
    @Headers('upload-length') uploadLength: string,
  ) {
    // ... existing TUS upload logic ...

    // Check if upload is complete
    const currentOffset = parseInt(uploadOffset, 10);
    const totalLength = parseInt(uploadLength, 10);

    if (currentOffset + chunkSize >= totalLength) {
      // Upload complete
      const uploadId = req.params.id;
      const metadata = await this.getUploadMetadata(uploadId);
      const storagePath = await this.getStoragePath(uploadId);
      const fileSize = totalLength;

      // Trigger workflow (async, don't wait)
      this.tusService
        .onUploadComplete(uploadId, metadata, storagePath, fileSize)
        .catch((error) => {
          // Log but don't fail the upload
          console.error('Workflow trigger failed:', error);
        });
    }

    res.status(204).send();
  }
}
```

---

### 4.4 Environment Configuration

#### Add Environment Variables

**File:** `api/forge/.env.example`

```bash
# Existing variables...

# Helix Integration
HELIX_API_URL=http://localhost:4005
HELIX_API_KEY=your-helix-api-key-here
DOCUMENT_PROCESSING_WORKFLOW_ID=your-n8n-workflow-id-here
```

**File:** `api/forge/.env`

```bash
HELIX_API_URL=http://localhost:4005
HELIX_API_KEY=dev-secret-key
DOCUMENT_PROCESSING_WORKFLOW_ID=5Wba1MKHnLpdc8IB
```

---

### 4.5 Update File Upload Metadata

#### Ensure Metadata is Passed

When initiating upload from Cortex, ensure these metadata fields are included:

```typescript
// In Cortex when calling Forge
const uploadSession = await forgeClient.initiateUpload({
  filename: doc.filename,
  size: doc.file_size,
  contentType: doc.content_type,
  metadata: {
    document_id: document.id,
    kb_id: kb_id,
    filename: doc.filename,
    content_type: doc.content_type,
  },
});
```

---

### 4.6 Testing

#### Unit Tests

**File:** `api/forge/src/modules/tus/tus.service.spec.ts`

```typescript
import { Test } from '@nestjs/testing';
import { ConfigService } from '@nestjs/config';
import { HelixClient } from '@asyml8/api-core';
import { TusService } from './tus.service';

describe('TusService', () => {
  let service: TusService;
  let helixClient: HelixClient;

  beforeEach(async () => {
    const module = await Test.createTestingModule({
      providers: [
        TusService,
        {
          provide: HelixClient,
          useValue: {
            executeWorkflow: jest.fn(),
          },
        },
        {
          provide: ConfigService,
          useValue: {
            getOrThrow: jest.fn(() => 'test-workflow-id'),
          },
        },
      ],
    }).compile();

    service = module.get<TusService>(TusService);
    helixClient = module.get<HelixClient>(HelixClient);
  });

  describe('onUploadComplete', () => {
    it('should trigger workflow with correct payload', async () => {
      const metadata = {
        document_id: 'doc-123',
        kb_id: 'kb-456',
        filename: 'test.pdf',
        content_type: 'application/pdf',
      };

      await service.onUploadComplete(
        'upload-789',
        metadata,
        'path/to/file',
        1024,
      );

      expect(helixClient.executeWorkflow).toHaveBeenCalledWith(
        'test-workflow-id',
        {
          document_id: 'doc-123',
          file_id: 'upload-789',
          kb_id: 'kb-456',
          storage_path: 'path/to/file',
          filename: 'test.pdf',
          content_type: 'application/pdf',
          file_size: 1024,
        },
      );
    });

    it('should not throw if workflow trigger fails', async () => {
      jest
        .spyOn(helixClient, 'executeWorkflow')
        .mockRejectedValue(new Error('Network error'));

      await expect(
        service.onUploadComplete('upload-789', {}, 'path', 1024),
      ).resolves.not.toThrow();
    });

    it('should skip workflow if document_id missing', async () => {
      await service.onUploadComplete(
        'upload-789',
        { kb_id: 'kb-456' },
        'path',
        1024,
      );

      expect(helixClient.executeWorkflow).not.toHaveBeenCalled();
    });
  });
});
```

---

#### Integration Tests

**File:** `api/forge/test/tus-workflow-integration.e2e.spec.ts`

```typescript
import { Test } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import * as request from 'supertest';
import { AppModule } from '../src/app.module';

describe('TUS Workflow Integration (e2e)', () => {
  let app: INestApplication;

  beforeAll(async () => {
    const moduleFixture = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    await app.init();
  });

  it('should trigger workflow after upload completes', async () => {
    // 1. Initiate upload
    const initiateResponse = await request(app.getHttpServer())
      .post('/api/v1/files/tus/initiate')
      .send({
        filename: 'test.pdf',
        size: 1024,
        contentType: 'application/pdf',
        metadata: {
          document_id: 'test-doc-123',
          kb_id: 'test-kb-456',
        },
      })
      .expect(201);

    const { uploadId, uploadUrl } = initiateResponse.body;

    // 2. Upload file chunks
    const fileContent = Buffer.from('test content');
    await request(app.getHttpServer())
      .patch(`/api/v1/files/tus/${uploadId}`)
      .set('Upload-Offset', '0')
      .set('Upload-Length', fileContent.length.toString())
      .set('Content-Type', 'application/offset+octet-stream')
      .send(fileContent)
      .expect(204);

    // 3. Verify workflow was triggered (check logs or mock)
    // This would require mocking HelixClient in test environment
  });

  afterAll(async () => {
    await app.close();
  });
});
```

---

### 4.7 Monitoring and Logging

#### Add Structured Logging

**File:** `api/forge/src/modules/tus/tus.service.ts`

```typescript
async onUploadComplete(
  uploadId: string,
  metadata: Record<string, any>,
  storagePath: string,
  fileSize: number,
): Promise<void> {
  const logContext = {
    uploadId,
    documentId: metadata.document_id,
    kbId: metadata.kb_id,
    filename: metadata.filename,
    fileSize,
  };

  this.logger.log('Upload complete', logContext);

  try {
    const execution = await this.helixClient.executeWorkflow(
      this.documentProcessingWorkflowId,
      {
        document_id: metadata.document_id,
        file_id: uploadId,
        kb_id: metadata.kb_id,
        storage_path: storagePath,
        filename: metadata.filename,
        content_type: metadata.content_type,
        file_size: fileSize,
      },
    );

    this.logger.log('Workflow triggered successfully', {
      ...logContext,
      executionId: execution.executionId,
      workflowId: this.documentProcessingWorkflowId,
    });
  } catch (error) {
    this.logger.error('Failed to trigger workflow', {
      ...logContext,
      error: error.message,
      stack: error.stack,
    });
  }
}
```

---

### 4.8 Error Handling

#### Retry Logic (Optional)

If workflow trigger is critical, add retry logic:

```typescript
import { retry } from 'rxjs/operators';
import { from } from 'rxjs';

async onUploadComplete(...): Promise<void> {
  try {
    await from(
      this.helixClient.executeWorkflow(this.documentProcessingWorkflowId, payload)
    )
      .pipe(
        retry({
          count: 3,
          delay: 1000,
        })
      )
      .toPromise();
  } catch (error) {
    // Log and continue
  }
}
```

---

### 4.9 Success Criteria

- [ ] HelixClient integrated into Forge
- [ ] Workflow triggered on upload complete
- [ ] Metadata passed correctly
- [ ] Environment variables configured
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Logging implemented
- [ ] Error handling works
- [ ] Upload succeeds even if workflow fails

---

### 4.10 Deliverables

1. Updated Forge service with Helix integration
2. Environment configuration
3. Unit and integration tests
4. Logging and monitoring
5. Documentation

---

