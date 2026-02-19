# Forge-Cortex Integration - Part 2

## Phase 2: Cortex API Endpoints

### Priority: HIGH
### Estimated Effort: 1-2 days
### Dependencies: Phase 1 (n8n workflow needs these endpoints)

### Objective
Add REST endpoints to Cortex that the n8n workflow can call to:
1. Update document processing status
2. Store document chunks with embeddings
3. Query document details

---

### 2.1 Update Document Status Endpoint

#### Endpoint Specification

**Method:** `PATCH`  
**Path:** `/api/v1/documents/{document_id}/status`  
**Authentication:** Required (API Key or JWT)

**Path Parameters:**
- `document_id` (UUID, required): Document identifier

**Request Body:**
```json
{
  "status": "processing" | "completed" | "failed",
  "error": "string (optional, required if status=failed)",
  "processed_at": "ISO 8601 datetime (optional)",
  "chunk_count": "integer (optional)"
}
```

**Response:**
```json
{
  "id": "uuid",
  "status": "completed",
  "processed_at": "2025-11-27T20:00:00Z",
  "chunk_count": 15
}
```

**Status Codes:**
- `200 OK`: Status updated successfully
- `400 Bad Request`: Invalid status value
- `404 Not Found`: Document not found
- `401 Unauthorized`: Missing or invalid authentication

---

#### Implementation

**File:** `services/cortex/app/api/v1/endpoints/documents.py`

```python
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from uuid import UUID
from datetime import datetime
from pydantic import BaseModel, Field
from typing import Optional, Literal

from app.api.deps import get_db, get_current_user
from app.services.document_service import DocumentService

router = APIRouter()

class UpdateDocumentStatusRequest(BaseModel):
    status: Literal["processing", "completed", "failed"]
    error: Optional[str] = None
    processed_at: Optional[datetime] = None
    chunk_count: Optional[int] = None

class DocumentStatusResponse(BaseModel):
    id: UUID
    status: str
    processed_at: Optional[datetime]
    chunk_count: Optional[int]
    
    class Config:
        from_attributes = True

@router.patch("/{document_id}/status", response_model=DocumentStatusResponse)
async def update_document_status(
    document_id: UUID,
    request: UpdateDocumentStatusRequest,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """
    Update document processing status.
    Called by n8n workflow during document processing.
    """
    service = DocumentService(db)
    
    # Validate status transition
    if request.status == "failed" and not request.error:
        raise HTTPException(
            status_code=400,
            detail="Error message required when status is 'failed'"
        )
    
    # Update document
    document = service.update_status(
        document_id=document_id,
        status=request.status,
        error=request.error,
        processed_at=request.processed_at or (datetime.utcnow() if request.status == "completed" else None),
        chunk_count=request.chunk_count
    )
    
    return document
```

---

#### Service Layer

**File:** `services/cortex/app/services/document_service.py`

```python
def update_status(
    self,
    document_id: UUID,
    status: str,
    error: Optional[str] = None,
    processed_at: Optional[datetime] = None,
    chunk_count: Optional[int] = None
) -> Document:
    """Update document processing status"""
    document = self.db.query(Document).filter(Document.id == document_id).first()
    
    if not document:
        raise NotFoundException(f"Document {document_id} not found")
    
    document.status = DocumentStatus(status)
    
    if error:
        document.processing_error = error
    
    if processed_at:
        document.processed_at = processed_at
    
    if chunk_count is not None:
        document.chunk_count = chunk_count
    
    self.db.commit()
    self.db.refresh(document)
    
    return document
```

---

### 2.2 Store Document Chunks Endpoint

#### Endpoint Specification

**Method:** `POST`  
**Path:** `/api/v1/documents/{document_id}/chunks`  
**Authentication:** Required

**Path Parameters:**
- `document_id` (UUID, required): Document identifier

**Request Body:**
```json
{
  "chunk_index": 0,
  "content": "This is the chunk text content...",
  "embedding": [0.123, -0.456, 0.789, ...],
  "metadata": {
    "filename": "document.pdf",
    "total_chunks": 15
  }
}
```

**Response:**
```json
{
  "id": "uuid",
  "document_id": "uuid",
  "chunk_index": 0,
  "content": "This is the chunk text content...",
  "created_at": "2025-11-27T20:00:00Z"
}
```

**Status Codes:**
- `201 Created`: Chunk stored successfully
- `400 Bad Request`: Invalid request data
- `404 Not Found`: Document not found
- `409 Conflict`: Chunk with same index already exists

---

#### Implementation

**File:** `services/cortex/app/api/v1/endpoints/documents.py`

```python
from typing import List

class StoreChunkRequest(BaseModel):
    chunk_index: int = Field(..., ge=0)
    content: str = Field(..., min_length=1)
    embedding: List[float] = Field(..., min_items=1536, max_items=1536)
    metadata: Optional[dict] = None

class ChunkResponse(BaseModel):
    id: UUID
    document_id: UUID
    chunk_index: int
    content: str
    created_at: datetime
    
    class Config:
        from_attributes = True

@router.post("/{document_id}/chunks", response_model=ChunkResponse, status_code=status.HTTP_201_CREATED)
async def store_chunk(
    document_id: UUID,
    request: StoreChunkRequest,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """
    Store a document chunk with embedding.
    Called by n8n workflow for each chunk.
    """
    service = DocumentService(db)
    
    # Verify document exists
    document = service.get(document_id)
    
    # Store chunk
    chunk = service.store_chunk(
        document_id=document_id,
        kb_id=document.kb_id,
        chunk_index=request.chunk_index,
        content=request.content,
        embedding=request.embedding,
        metadata=request.metadata or {}
    )
    
    return chunk
```

---

#### Service Layer

**File:** `services/cortex/app/services/document_service.py`

```python
from app.models.db.chunk import Chunk

def store_chunk(
    self,
    document_id: UUID,
    kb_id: UUID,
    chunk_index: int,
    content: str,
    embedding: List[float],
    metadata: dict
) -> Chunk:
    """Store a document chunk with embedding"""
    
    # Check for duplicate
    existing = self.db.query(Chunk).filter(
        Chunk.document_id == document_id,
        Chunk.chunk_index == chunk_index
    ).first()
    
    if existing:
        raise ConflictException(f"Chunk {chunk_index} already exists for document {document_id}")
    
    chunk = Chunk(
        document_id=document_id,
        kb_id=kb_id,
        content=content,
        chunk_index=chunk_index,
        embedding=embedding,
        embedding_model="text-embedding-3-small",
        meta=metadata
    )
    
    self.db.add(chunk)
    self.db.commit()
    self.db.refresh(chunk)
    
    return chunk
```

---

### 2.3 Database Schema Updates

#### Add chunk_count to Document model

**File:** `services/cortex/app/models/db/document.py`

```python
class Document(Base):
    __tablename__ = "documents"
    
    # ... existing fields ...
    
    chunk_count = Column(Integer, nullable=True)  # Add this field
```

#### Migration

**File:** `services/cortex/alembic/versions/YYYYMMDD_add_chunk_count.py`

```python
"""add chunk_count to documents

Revision ID: add_chunk_count_001
"""
from alembic import op
import sqlalchemy as sa

def upgrade() -> None:
    op.add_column('documents', sa.Column('chunk_count', sa.Integer(), nullable=True))

def downgrade() -> None:
    op.drop_column('documents', 'chunk_count')
```

---

### 2.4 Testing

#### Unit Tests

**File:** `services/cortex/tests/test_api/test_documents.py`

```python
import pytest
from uuid import uuid4

def test_update_document_status_to_processing(client, test_document):
    response = client.patch(
        f"/api/v1/documents/{test_document.id}/status",
        json={"status": "processing"}
    )
    assert response.status_code == 200
    assert response.json()["status"] == "processing"

def test_update_document_status_to_completed(client, test_document):
    response = client.patch(
        f"/api/v1/documents/{test_document.id}/status",
        json={
            "status": "completed",
            "chunk_count": 10
        }
    )
    assert response.status_code == 200
    assert response.json()["status"] == "completed"
    assert response.json()["chunk_count"] == 10

def test_update_document_status_to_failed_requires_error(client, test_document):
    response = client.patch(
        f"/api/v1/documents/{test_document.id}/status",
        json={"status": "failed"}
    )
    assert response.status_code == 400

def test_store_chunk(client, test_document):
    embedding = [0.1] * 1536
    response = client.post(
        f"/api/v1/documents/{test_document.id}/chunks",
        json={
            "chunk_index": 0,
            "content": "Test chunk content",
            "embedding": embedding,
            "metadata": {"test": "data"}
        }
    )
    assert response.status_code == 201
    assert response.json()["chunk_index"] == 0

def test_store_duplicate_chunk_fails(client, test_document, test_chunk):
    embedding = [0.1] * 1536
    response = client.post(
        f"/api/v1/documents/{test_document.id}/chunks",
        json={
            "chunk_index": test_chunk.chunk_index,
            "content": "Duplicate chunk",
            "embedding": embedding
        }
    )
    assert response.status_code == 409
```

---

### 2.5 API Documentation

Update OpenAPI/Swagger documentation:

**File:** `services/cortex/app/api/v1/endpoints/documents.py`

```python
@router.patch("/{document_id}/status", 
    response_model=DocumentStatusResponse,
    summary="Update document processing status",
    description="""
    Update the processing status of a document.
    
    This endpoint is called by the n8n workflow during document processing:
    - Set to 'processing' when processing starts
    - Set to 'completed' when all chunks are stored
    - Set to 'failed' if an error occurs
    
    **Status Transitions:**
    - pending_upload → processing
    - processing → completed
    - processing → failed
    """,
    responses={
        200: {"description": "Status updated successfully"},
        400: {"description": "Invalid status or missing required fields"},
        404: {"description": "Document not found"}
    }
)
```

---

### 2.6 Success Criteria

- [ ] Status update endpoint works
- [ ] Chunk storage endpoint works
- [ ] Database migrations applied
- [ ] Unit tests pass
- [ ] API documentation updated
- [ ] Postman/curl tests successful
- [ ] n8n workflow can call endpoints

---

### 2.7 Deliverables

1. Working API endpoints
2. Database migrations
3. Unit tests
4. API documentation
5. Postman collection for testing

---

## Phase 3: Client Libraries

### Priority: MEDIUM
### Estimated Effort: 1 day
### Dependencies: None (can be done in parallel)

### Objective
Create reusable TypeScript client libraries in api-core for:
1. ForgeClient - Interact with Forge API
2. HelixClient - Interact with Helix/n8n API

---

### 3.1 ForgeClient Implementation

#### File Structure
```
packages/api-core/src/clients/
├── forge-client.ts
├── forge-client.types.ts
├── forge-client.module.ts
└── index.ts
```

---

#### Types Definition

**File:** `packages/api-core/src/clients/forge-client.types.ts`

```typescript
export interface InitiateUploadParams {
  filename: string;
  size: number;
  contentType: string;
  metadata?: Record<string, any>;
}

export interface UploadSession {
  uploadId: string;
  uploadUrl: string;
  expiresAt: Date;
}

export interface FileMetadata {
  id: string;
  filename: string;
  contentType: string;
  size: number;
  storagePath: string;
  uploadedAt: Date;
  metadata?: Record<string, any>;
}

export interface DownloadUrlResponse {
  url: string;
  expiresAt: Date;
}
```

---

#### Client Implementation

**File:** `packages/api-core/src/clients/forge-client.ts`

```typescript
import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import {
  InitiateUploadParams,
  UploadSession,
  FileMetadata,
  DownloadUrlResponse,
} from './forge-client.types';

@Injectable()
export class ForgeClient {
  private readonly logger = new Logger(ForgeClient.name);
  private readonly baseUrl: string;
  private readonly apiKey: string;

  constructor(private configService: ConfigService) {
    this.baseUrl = this.configService.getOrThrow<string>('FORGE_API_URL');
    this.apiKey = this.configService.getOrThrow<string>('FORGE_API_KEY');
  }

  /**
   * Initiate a TUS upload session
   */
  async initiateUpload(params: InitiateUploadParams): Promise<UploadSession> {
    this.logger.log(`Initiating upload for file: ${params.filename}`);

    const response = await fetch(`${this.baseUrl}/api/v1/files/tus/initiate`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${this.apiKey}`,
      },
      body: JSON.stringify(params),
    });

    if (!response.ok) {
      const error = await response.text();
      throw new Error(`Forge API error: ${response.statusText} - ${error}`);
    }

    const data = await response.json();
    return {
      ...data,
      expiresAt: new Date(data.expiresAt),
    };
  }

  /**
   * Get file metadata
   */
  async getFileMetadata(fileId: string): Promise<FileMetadata> {
    this.logger.log(`Getting metadata for file: ${fileId}`);

    const response = await fetch(
      `${this.baseUrl}/api/v1/files/${fileId}/metadata`,
      {
        headers: {
          Authorization: `Bearer ${this.apiKey}`,
        },
      },
    );

    if (!response.ok) {
      throw new Error(`Forge API error: ${response.statusText}`);
    }

    const data = await response.json();
    return {
      ...data,
      uploadedAt: new Date(data.uploadedAt),
    };
  }

  /**
   * Get temporary download URL
   */
  async getDownloadUrl(fileId: string): Promise<string> {
    this.logger.log(`Getting download URL for file: ${fileId}`);

    const response = await fetch(
      `${this.baseUrl}/api/v1/files/${fileId}/download-url`,
      {
        headers: {
          Authorization: `Bearer ${this.apiKey}`,
        },
      },
    );

    if (!response.ok) {
      throw new Error(`Forge API error: ${response.statusText}`);
    }

    const data: DownloadUrlResponse = await response.json();
    return data.url;
  }

  /**
   * Delete a file
   */
  async deleteFile(fileId: string): Promise<void> {
    this.logger.log(`Deleting file: ${fileId}`);

    const response = await fetch(`${this.baseUrl}/api/v1/files/${fileId}`, {
      method: 'DELETE',
      headers: {
        Authorization: `Bearer ${this.apiKey}`,
      },
    });

    if (!response.ok) {
      throw new Error(`Forge API error: ${response.statusText}`);
    }
  }
}
```

---

#### Module Definition

**File:** `packages/api-core/src/clients/forge-client.module.ts`

```typescript
import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { ForgeClient } from './forge-client';

@Module({
  imports: [ConfigModule],
  providers: [ForgeClient],
  exports: [ForgeClient],
})
export class ForgeClientModule {}
```

---

### 3.2 HelixClient Implementation

#### Types Definition

**File:** `packages/api-core/src/clients/helix-client.types.ts`

```typescript
export interface ExecuteWorkflowParams {
  workflowId: string;
  data: Record<string, any>;
}

export interface WorkflowExecution {
  executionId: string;
  workflowId: string;
  status: 'running' | 'success' | 'error';
  startedAt: Date;
  finishedAt?: Date;
}

export interface WorkflowDetails {
  id: string;
  name: string;
  active: boolean;
  nodes: any[];
  connections: any;
}
```

---

#### Client Implementation

**File:** `packages/api-core/src/clients/helix-client.ts`

```typescript
import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import {
  ExecuteWorkflowParams,
  WorkflowExecution,
  WorkflowDetails,
} from './helix-client.types';

@Injectable()
export class HelixClient {
  private readonly logger = new Logger(HelixClient.name);
  private readonly baseUrl: string;
  private readonly apiKey: string;

  constructor(private configService: ConfigService) {
    this.baseUrl = this.configService.getOrThrow<string>('HELIX_API_URL');
    this.apiKey = this.configService.getOrThrow<string>('HELIX_API_KEY');
  }

  /**
   * Execute an n8n workflow
   */
  async executeWorkflow(
    workflowId: string,
    data: Record<string, any>,
  ): Promise<WorkflowExecution> {
    this.logger.log(`Executing workflow: ${workflowId}`);

    const response = await fetch(
      `${this.baseUrl}/api/n8n/workflows/${workflowId}/execute`,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${this.apiKey}`,
        },
        body: JSON.stringify(data),
      },
    );

    if (!response.ok) {
      const error = await response.text();
      throw new Error(`Helix API error: ${response.statusText} - ${error}`);
    }

    const result = await response.json();
    return {
      ...result,
      startedAt: new Date(result.startedAt),
      finishedAt: result.finishedAt ? new Date(result.finishedAt) : undefined,
    };
  }

  /**
   * Get workflow execution status
   */
  async getExecutionStatus(executionId: string): Promise<WorkflowExecution> {
    this.logger.log(`Getting execution status: ${executionId}`);

    const response = await fetch(
      `${this.baseUrl}/api/n8n/executions/${executionId}`,
      {
        headers: {
          Authorization: `Bearer ${this.apiKey}`,
        },
      },
    );

    if (!response.ok) {
      throw new Error(`Helix API error: ${response.statusText}`);
    }

    const result = await response.json();
    return {
      ...result,
      startedAt: new Date(result.startedAt),
      finishedAt: result.finishedAt ? new Date(result.finishedAt) : undefined,
    };
  }

  /**
   * Get workflow details
   */
  async getWorkflow(workflowId: string): Promise<WorkflowDetails> {
    this.logger.log(`Getting workflow details: ${workflowId}`);

    const response = await fetch(
      `${this.baseUrl}/api/n8n/workflows/${workflowId}`,
      {
        headers: {
          Authorization: `Bearer ${this.apiKey}`,
        },
      },
    );

    if (!response.ok) {
      throw new Error(`Helix API error: ${response.statusText}`);
    }

    return response.json();
  }
}
```

---

#### Module Definition

**File:** `packages/api-core/src/clients/helix-client.module.ts`

```typescript
import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { HelixClient } from './helix-client';

@Module({
  imports: [ConfigModule],
  providers: [HelixClient],
  exports: [HelixClient],
})
export class HelixClientModule {}
```

---

### 3.3 Export from api-core

**File:** `packages/api-core/src/clients/index.ts`

```typescript
export * from './forge-client';
export * from './forge-client.types';
export * from './forge-client.module';
export * from './helix-client';
export * from './helix-client.types';
export * from './helix-client.module';
```

**File:** `packages/api-core/src/index.ts`

```typescript
// ... existing exports ...

// Client libraries
export * from './clients';
```

---

### 3.4 Testing

#### Unit Tests

**File:** `packages/api-core/src/clients/forge-client.spec.ts`

```typescript
import { Test } from '@nestjs/testing';
import { ConfigService } from '@nestjs/config';
import { ForgeClient } from './forge-client';

describe('ForgeClient', () => {
  let client: ForgeClient;
  let configService: ConfigService;

  beforeEach(async () => {
    const module = await Test.createTestingModule({
      providers: [
        ForgeClient,
        {
          provide: ConfigService,
          useValue: {
            getOrThrow: jest.fn((key: string) => {
              if (key === 'FORGE_API_URL') return 'http://localhost:4002';
              if (key === 'FORGE_API_KEY') return 'test-key';
            }),
          },
        },
      ],
    }).compile();

    client = module.get<ForgeClient>(ForgeClient);
    configService = module.get<ConfigService>(ConfigService);
  });

  it('should be defined', () => {
    expect(client).toBeDefined();
  });

  // Add more tests...
});
```

---

### 3.5 Success Criteria

- [ ] ForgeClient implemented
- [ ] HelixClient implemented
- [ ] TypeScript types defined
- [ ] NestJS modules created
- [ ] Exported from api-core
- [ ] Unit tests written
- [ ] Build succeeds
- [ ] Can be imported by other APIs

---

### 3.6 Deliverables

1. ForgeClient and HelixClient classes
2. TypeScript type definitions
3. NestJS modules
4. Unit tests
5. Updated api-core exports

---

