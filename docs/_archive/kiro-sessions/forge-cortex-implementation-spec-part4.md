# Forge-Cortex Integration - Part 4

## Phase 5: Cortex Upload Flow

### Priority: LOW
### Estimated Effort: 1-2 days
### Dependencies: Phase 3 (ForgeClient)

### Objective
Update Cortex API to support the new upload flow:
1. Client calls Cortex to initiate upload
2. Cortex calls Forge to get TUS upload URL
3. Cortex creates document record with PENDING_UPLOAD status
4. Client uploads directly to Forge via TUS
5. Forge triggers n8n workflow
6. n8n updates document status and stores chunks

---

### 5.1 Add ForgeClient to Cortex

#### Install Dependencies

Since Cortex is Python, we need a Python HTTP client instead of the TypeScript ForgeClient.

**File:** `services/cortex/requirements.txt`

```txt
# Existing dependencies...
httpx==0.25.0
```

#### Create Python ForgeClient

**File:** `services/cortex/app/core/forge_client.py`

```python
import httpx
from typing import Optional, Dict, Any
from datetime import datetime
from pydantic import BaseModel

from app.config.settings import settings


class UploadSession(BaseModel):
    upload_id: str
    upload_url: str
    expires_at: datetime


class FileMetadata(BaseModel):
    id: str
    filename: str
    content_type: str
    size: int
    storage_path: str
    uploaded_at: datetime


class ForgeClient:
    """HTTP client for Forge Storage API"""

    def __init__(self):
        self.base_url = settings.FORGE_API_URL
        self.api_key = settings.FORGE_API_KEY
        self.client = httpx.AsyncClient(
            base_url=self.base_url,
            headers={"Authorization": f"Bearer {self.api_key}"},
            timeout=30.0,
        )

    async def initiate_upload(
        self,
        filename: str,
        size: int,
        content_type: str,
        metadata: Optional[Dict[str, Any]] = None,
    ) -> UploadSession:
        """Initiate TUS upload session"""
        response = await self.client.post(
            "/api/v1/files/tus/initiate",
            json={
                "filename": filename,
                "size": size,
                "contentType": content_type,
                "metadata": metadata or {},
            },
        )
        response.raise_for_status()
        data = response.json()
        return UploadSession(
            upload_id=data["uploadId"],
            upload_url=data["uploadUrl"],
            expires_at=datetime.fromisoformat(data["expiresAt"].replace("Z", "+00:00")),
        )

    async def get_file_metadata(self, file_id: str) -> FileMetadata:
        """Get file metadata"""
        response = await self.client.get(f"/api/v1/files/{file_id}/metadata")
        response.raise_for_status()
        data = response.json()
        return FileMetadata(**data)

    async def get_download_url(self, file_id: str) -> str:
        """Get temporary download URL"""
        response = await self.client.get(f"/api/v1/files/{file_id}/download-url")
        response.raise_for_status()
        return response.json()["url"]

    async def delete_file(self, file_id: str) -> None:
        """Delete file"""
        response = await self.client.delete(f"/api/v1/files/{file_id}")
        response.raise_for_status()

    async def close(self):
        """Close HTTP client"""
        await self.client.aclose()


# Singleton instance
forge_client = ForgeClient()
```

---

### 5.2 Update Cortex Settings

**File:** `services/cortex/app/config/settings.py`

```python
class Settings(BaseSettings):
    # ... existing settings ...
    
    # Forge Integration
    FORGE_API_URL: str = "http://localhost:4002"
    FORGE_API_KEY: str = ""
    
    # ... rest of settings ...
```

---

### 5.3 Update Document Model

#### Add forge_file_id Field

**File:** `services/cortex/app/models/db/document.py`

```python
from sqlalchemy import Column, String, Integer, ForeignKey, DateTime, Enum, Text
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.orm import relationship
import uuid
import enum
from datetime import datetime

from app.models.db.base import Base

class DocumentStatus(str, enum.Enum):
    PENDING_UPLOAD = "pending_upload"  # Add this
    PROCESSING = "processing"
    COMPLETED = "completed"
    FAILED = "failed"

class Document(Base):
    __tablename__ = "documents"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    kb_id = Column(UUID(as_uuid=True), ForeignKey("knowledge_bases.id", ondelete="CASCADE"), nullable=False)
    forge_file_id = Column(String, nullable=True)  # Add this
    filename = Column(String, nullable=False)
    content_type = Column(String, nullable=False)
    file_size_bytes = Column(Integer, nullable=True)
    storage_path = Column(String, nullable=True)  # Make nullable
    raw_content = Column(Text, nullable=True)
    cleaned_content = Column(Text, nullable=True)
    meta = Column(JSONB)
    status = Column(Enum(DocumentStatus), default=DocumentStatus.PENDING_UPLOAD, nullable=False)
    processing_error = Column(String, nullable=True)
    uploaded_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    uploaded_by = Column(UUID(as_uuid=True), nullable=False)
    processed_at = Column(DateTime, nullable=True)
    chunk_count = Column(Integer, nullable=True)
    
    # Relationships
    knowledge_base = relationship("KnowledgeBase", back_populates="documents")
    chunks = relationship("Chunk", back_populates="document", cascade="all, delete-orphan")
```

---

### 5.4 Database Migration

**File:** `services/cortex/alembic/versions/20251127_add_forge_integration.py`

```python
"""add forge integration fields

Revision ID: forge_integration_001
Revises: previous_revision
Create Date: 2025-11-27
"""
from alembic import op
import sqlalchemy as sa

revision = 'forge_integration_001'
down_revision = 'previous_revision'  # Update this
branch_labels = None
depends_on = None


def upgrade() -> None:
    # Add forge_file_id column
    op.add_column('documents', sa.Column('forge_file_id', sa.String(), nullable=True))
    
    # Make storage_path nullable
    op.alter_column('documents', 'storage_path',
                    existing_type=sa.String(),
                    nullable=True)
    
    # Add PENDING_UPLOAD to enum (PostgreSQL specific)
    op.execute("ALTER TYPE documentstatus ADD VALUE IF NOT EXISTS 'pending_upload'")


def downgrade() -> None:
    op.drop_column('documents', 'forge_file_id')
    op.alter_column('documents', 'storage_path',
                    existing_type=sa.String(),
                    nullable=False)
```

---

### 5.5 Update Document Schemas

**File:** `services/cortex/app/models/schemas/document.py`

```python
from pydantic import BaseModel, Field
from typing import Optional, Dict, Any
from uuid import UUID
from datetime import datetime

class DocumentInitiateUpload(BaseModel):
    """Request to initiate document upload"""
    filename: str = Field(..., min_length=1, max_length=500)
    content_type: str = Field(..., max_length=100)
    file_size: int = Field(..., gt=0)
    metadata: Optional[Dict[str, Any]] = None

class DocumentUploadResponse(BaseModel):
    """Response with upload URL from Forge"""
    document_id: UUID
    upload_id: str
    upload_url: str
    expires_at: datetime

# ... existing schemas ...
```

---

### 5.6 Update DocumentService

**File:** `services/cortex/app/services/document_service.py`

```python
from app.core.forge_client import forge_client

class DocumentService:
    def __init__(self, db: Session):
        self.db = db
        self.chunking_service = ChunkingService()
        self.embedding_service = EmbeddingService()
    
    def create_pending(
        self,
        kb_id: UUID,
        filename: str,
        content_type: str,
        file_size: int,
        forge_file_id: str,
        metadata: Optional[Dict[str, Any]],
        uploaded_by: UUID
    ) -> Document:
        """Create document record with PENDING_UPLOAD status"""
        document = Document(
            kb_id=kb_id,
            filename=filename,
            content_type=content_type,
            file_size_bytes=file_size,
            forge_file_id=forge_file_id,
            meta=metadata or {},
            status=DocumentStatus.PENDING_UPLOAD,
            uploaded_by=uploaded_by
        )
        self.db.add(document)
        self.db.commit()
        self.db.refresh(document)
        return document
    
    # ... existing methods ...
```

---

### 5.7 Add Initiate Upload Endpoint

**File:** `services/cortex/app/api/v1/endpoints/documents.py`

```python
from app.core.forge_client import forge_client
from app.models.schemas.document import DocumentInitiateUpload, DocumentUploadResponse

@router.post(
    "/{kb_id}/documents/initiate-upload",
    response_model=DocumentUploadResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Initiate document upload",
    description="""
    Initiate a document upload to a knowledge base.
    
    This endpoint:
    1. Creates a document record with PENDING_UPLOAD status
    2. Requests a TUS upload URL from Forge
    3. Returns the upload URL to the client
    
    The client should then upload the file directly to Forge using the TUS protocol.
    """
)
async def initiate_document_upload(
    kb_id: UUID,
    doc: DocumentInitiateUpload,
    db: Session = Depends(get_db),
    tenant_id: UUID = Depends(get_tenant_id),
    current_user: dict = Depends(get_current_user)
):
    # Verify KB exists and belongs to tenant
    kb_service = KnowledgeBaseService(db)
    kb_service.get(kb_id, tenant_id)
    
    # Get upload URL from Forge
    upload_session = await forge_client.initiate_upload(
        filename=doc.filename,
        size=doc.file_size,
        content_type=doc.content_type,
        metadata={
            "kb_id": str(kb_id),
            "filename": doc.filename,
            "content_type": doc.content_type,
            **(doc.metadata or {})
        }
    )
    
    # Create document record with PENDING_UPLOAD status
    service = DocumentService(db)
    document = service.create_pending(
        kb_id=kb_id,
        filename=doc.filename,
        content_type=doc.content_type,
        file_size=doc.file_size,
        forge_file_id=upload_session.upload_id,
        metadata=doc.metadata,
        uploaded_by=UUID(current_user["user_id"])
    )
    
    return DocumentUploadResponse(
        document_id=document.id,
        upload_id=upload_session.upload_id,
        upload_url=upload_session.upload_url,
        expires_at=upload_session.expires_at
    )
```

---

### 5.8 Testing

#### Unit Tests

**File:** `services/cortex/tests/test_api/test_documents.py`

```python
import pytest
from uuid import uuid4
from unittest.mock import AsyncMock, patch

@pytest.mark.asyncio
async def test_initiate_document_upload(client, test_kb, test_user):
    with patch('app.core.forge_client.forge_client.initiate_upload') as mock_initiate:
        mock_initiate.return_value = AsyncMock(
            upload_id="test-upload-123",
            upload_url="https://forge.example.com/upload/test-upload-123",
            expires_at="2025-11-27T20:00:00Z"
        )
        
        response = client.post(
            f"/api/v1/knowledge-bases/{test_kb.id}/documents/initiate-upload",
            json={
                "filename": "test.pdf",
                "content_type": "application/pdf",
                "file_size": 1024,
                "metadata": {"key": "value"}
            }
        )
        
        assert response.status_code == 201
        data = response.json()
        assert "document_id" in data
        assert data["upload_id"] == "test-upload-123"
        assert "upload_url" in data
        
        # Verify document created with PENDING_UPLOAD status
        doc_response = client.get(f"/api/v1/documents/{data['document_id']}")
        assert doc_response.json()["status"] == "pending_upload"
```

---

#### Integration Tests

**File:** `services/cortex/tests/integration/test_upload_flow.py`

```python
import pytest
from uuid import uuid4

@pytest.mark.integration
@pytest.mark.asyncio
async def test_full_upload_flow(client, test_kb, forge_client_mock):
    """Test complete upload flow from initiate to completion"""
    
    # 1. Initiate upload
    response = client.post(
        f"/api/v1/knowledge-bases/{test_kb.id}/documents/initiate-upload",
        json={
            "filename": "test.pdf",
            "content_type": "application/pdf",
            "file_size": 1024
        }
    )
    assert response.status_code == 201
    document_id = response.json()["document_id"]
    
    # 2. Simulate upload completion (would be done by client + Forge)
    # ... TUS upload happens here ...
    
    # 3. Simulate n8n workflow updating status
    response = client.patch(
        f"/api/v1/documents/{document_id}/status",
        json={"status": "processing"}
    )
    assert response.status_code == 200
    
    # 4. Simulate n8n storing chunks
    for i in range(3):
        response = client.post(
            f"/api/v1/documents/{document_id}/chunks",
            json={
                "chunk_index": i,
                "content": f"Chunk {i} content",
                "embedding": [0.1] * 1536
            }
        )
        assert response.status_code == 201
    
    # 5. Simulate n8n marking complete
    response = client.patch(
        f"/api/v1/documents/{document_id}/status",
        json={"status": "completed", "chunk_count": 3}
    )
    assert response.status_code == 200
    
    # 6. Verify final state
    response = client.get(f"/api/v1/documents/{document_id}")
    doc = response.json()
    assert doc["status"] == "completed"
    assert doc["chunk_count"] == 3
```

---

### 5.9 API Documentation

Update OpenAPI documentation:

```python
@router.post(
    "/{kb_id}/documents/initiate-upload",
    response_model=DocumentUploadResponse,
    status_code=status.HTTP_201_CREATED,
    tags=["Documents"],
    summary="Initiate document upload",
    description="""
    ## Upload Flow
    
    1. **Client calls this endpoint** to initiate upload
    2. **Cortex creates document** with `PENDING_UPLOAD` status
    3. **Cortex requests upload URL** from Forge API
    4. **Client receives upload URL** and uploads directly to Forge using TUS
    5. **Forge triggers n8n workflow** when upload completes
    6. **n8n processes document** (extract, chunk, embed)
    7. **n8n updates document status** to `COMPLETED`
    
    ## TUS Protocol
    
    The upload URL uses the TUS resumable upload protocol:
    - Supports large files
    - Handles network interruptions
    - Allows resume after failure
    
    See: https://tus.io/protocols/resumable-upload.html
    """,
    responses={
        201: {
            "description": "Upload initiated successfully",
            "content": {
                "application/json": {
                    "example": {
                        "document_id": "123e4567-e89b-12d3-a456-426614174000",
                        "upload_id": "abc123",
                        "upload_url": "https://forge.example.com/upload/abc123",
                        "expires_at": "2025-11-27T20:00:00Z"
                    }
                }
            }
        },
        404: {"description": "Knowledge base not found"},
        400: {"description": "Invalid request data"}
    }
)
```

---

### 5.10 Success Criteria

- [ ] ForgeClient implemented in Python
- [ ] Document model updated with forge_file_id
- [ ] Database migration created and applied
- [ ] Initiate upload endpoint works
- [ ] Document created with PENDING_UPLOAD status
- [ ] Upload URL returned to client
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] API documentation updated

---

### 5.11 Deliverables

1. Python ForgeClient
2. Updated Document model and migration
3. Initiate upload endpoint
4. Unit and integration tests
5. API documentation
6. Environment configuration

---

