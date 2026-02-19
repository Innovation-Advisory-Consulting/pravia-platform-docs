# Step 11: API Implementation - Document Processing with Celery

## Overview

Implement background document processing in Cortex API using Celery with memory broker (dev) and Valkey (production).

## Architecture

```
UI → Forge (upload) → Cortex API (create doc) → Celery Task Queue
                                                        ↓
                                                  Worker Process
                                                        ↓
                                        Download → Extract → Chunk → Embed → Store
```

## Implementation Steps

### Step 11.1: Add Celery Dependencies

**File:** `api/cortex/requirements.txt`

```txt
celery[redis]==5.3.4
```

### Step 11.2: Create Celery Configuration

**File:** `api/cortex/src/celery_config.py`

```python
import os
from celery import Celery

# Use memory broker for dev, Valkey/Redis for production
CELERY_BROKER_URL = os.getenv("CELERY_BROKER_URL", "memory://")
CELERY_RESULT_BACKEND = os.getenv("CELERY_RESULT_BACKEND", "rpc://")

celery_app = Celery(
    "cortex",
    broker=CELERY_BROKER_URL,
    backend=CELERY_RESULT_BACKEND,
)

celery_app.conf.update(
    task_serializer="json",
    accept_content=["json"],
    result_serializer="json",
    timezone="UTC",
    enable_utc=True,
    task_track_started=True,
    task_time_limit=300,  # 5 minutes
    task_soft_time_limit=240,  # 4 minutes
)
```

### Step 11.3: Create Document Processing Task

**File:** `api/cortex/src/tasks/document_processing.py`

```python
import httpx
from celery_config import celery_app
from services.document_service import DocumentService
from services.embedding_service import EmbeddingService

@celery_app.task(bind=True, max_retries=3)
def process_document(self, doc_id: str, file_url: str, kb_id: str):
    """
    Background task to process uploaded document.
    
    Steps:
    1. Download file from Forge
    2. Extract text content
    3. Chunk document
    4. Generate embeddings
    5. Store chunks in database
    6. Update document status
    """
    try:
        # Update status to processing
        DocumentService.update_status(doc_id, "processing")
        
        # Download file
        response = httpx.get(file_url, timeout=30.0)
        response.raise_for_status()
        content = response.text
        
        # Chunk document
        chunks = chunk_text(content, chunk_size=1000, overlap=200)
        
        # Generate embeddings
        embeddings = EmbeddingService.generate_embeddings([c["text"] for c in chunks])
        
        # Store chunks with embeddings
        for chunk, embedding in zip(chunks, embeddings):
            DocumentService.create_chunk(
                doc_id=doc_id,
                text=chunk["text"],
                start_char=chunk["start_char"],
                end_char=chunk["end_char"],
                chunk_index=chunk["index"],
                embedding=embedding,
            )
        
        # Update status to ready
        DocumentService.update_status(doc_id, "ready", chunk_count=len(chunks))
        
        return {"status": "success", "chunk_count": len(chunks)}
        
    except Exception as exc:
        # Update status to failed
        DocumentService.update_status(doc_id, "failed", error=str(exc))
        
        # Retry with exponential backoff
        raise self.retry(exc=exc, countdown=60 * (2 ** self.request.retries))


def chunk_text(text: str, chunk_size: int = 1000, overlap: int = 200):
    """Split text into overlapping chunks."""
    chunks = []
    start = 0
    
    while start < len(text):
        end = min(start + chunk_size, len(text))
        chunks.append({
            "text": text[start:end],
            "start_char": start,
            "end_char": end,
            "index": len(chunks),
        })
        start += chunk_size - overlap
    
    return chunks
```

### Step 11.4: Update Document Creation Endpoint

**File:** `api/cortex/src/routes/documents.py`

```python
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from tasks.document_processing import process_document

router = APIRouter()

class DocumentCreateRequest(BaseModel):
    title: str
    original_filename: str
    mime_type: str
    size: int
    storage_url: str  # URL from Forge
    tag_ids: list[str] = []

@router.post("/knowledge-bases/{kb_id}/documents")
async def create_document(kb_id: str, request: DocumentCreateRequest):
    """
    Create document and queue for background processing.
    """
    # Create document record with "pending" status
    doc = DocumentService.create(
        kb_id=kb_id,
        name=request.title,
        original_filename=request.original_filename,
        mime_type=request.mime_type,
        size=request.size,
        storage_url=request.storage_url,
        status="pending",
    )
    
    # Queue background processing task
    process_document.delay(doc.id, request.storage_url, kb_id)
    
    return {
        "id": doc.id,
        "status": "pending",
        "message": "Document queued for processing"
    }
```

### Step 11.5: Start Celery Worker

**Development:**
```bash
# Terminal 1: Start API
uvicorn main:app --reload

# Terminal 2: Start Celery worker
celery -A celery_config worker --loglevel=info
```

**Production (docker-compose.yml):**
```yaml
services:
  valkey:
    image: valkey/valkey:latest
    ports:
      - "6379:6379"
  
  cortex-api:
    build: ./api/cortex
    command: uvicorn main:app --host 0.0.0.0
    environment:
      CELERY_BROKER_URL: redis://valkey:6379/0
    depends_on:
      - valkey
  
  cortex-worker:
    build: ./api/cortex
    command: celery -A celery_config worker --loglevel=info
    environment:
      CELERY_BROKER_URL: redis://valkey:6379/0
    depends_on:
      - valkey
```

## Integration Tests

### Test 11.1: Document Creation

**File:** `api/cortex/tests/test_document_processing.py`

```python
import pytest
from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

def test_create_document_queues_processing():
    """Test that document creation queues background task."""
    response = client.post(
        "/api/v1/knowledge-bases/test-kb-id/documents",
        json={
            "title": "Test Document",
            "original_filename": "test.txt",
            "mime_type": "text/plain",
            "size": 1024,
            "storage_url": "http://localhost:4002/api/files/test-file-id",
        }
    )
    
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "pending"
    assert "id" in data
```

### Test 11.2: Document Processing Task

```python
from tasks.document_processing import process_document, chunk_text
from unittest.mock import patch, MagicMock

def test_chunk_text():
    """Test text chunking with overlap."""
    text = "A" * 1000 + "B" * 1000
    chunks = chunk_text(text, chunk_size=500, overlap=100)
    
    assert len(chunks) == 5
    assert chunks[0]["start_char"] == 0
    assert chunks[0]["end_char"] == 500
    assert chunks[1]["start_char"] == 400  # 500 - 100 overlap

@patch("tasks.document_processing.httpx.get")
@patch("tasks.document_processing.DocumentService")
def test_process_document_success(mock_service, mock_get):
    """Test successful document processing."""
    # Mock file download
    mock_response = MagicMock()
    mock_response.text = "Test document content"
    mock_get.return_value = mock_response
    
    # Run task
    result = process_document("doc-123", "http://test.com/file", "kb-123")
    
    assert result["status"] == "success"
    mock_service.update_status.assert_called_with("doc-123", "ready", chunk_count=1)
```

### Test 11.3: End-to-End Integration

```python
import time

def test_document_processing_e2e():
    """Test complete document processing flow."""
    # 1. Upload file to Forge
    with open("test.txt", "rb") as f:
        forge_response = client.post(
            "http://localhost:4002/api/files",
            files={"file": f}
        )
    file_url = forge_response.json()["url"]
    
    # 2. Create document in Cortex
    response = client.post(
        "/api/v1/knowledge-bases/test-kb/documents",
        json={
            "title": "E2E Test",
            "original_filename": "test.txt",
            "mime_type": "text/plain",
            "size": 100,
            "storage_url": file_url,
        }
    )
    doc_id = response.json()["id"]
    
    # 3. Wait for processing (with timeout)
    for _ in range(30):
        doc = client.get(f"/api/v1/documents/{doc_id}").json()
        if doc["status"] == "ready":
            break
        time.sleep(1)
    
    # 4. Verify document is ready
    assert doc["status"] == "ready"
    assert doc["chunk_count"] > 0
    
    # 5. Verify chunks exist
    chunks = client.get(f"/api/v1/documents/{doc_id}/chunks").json()
    assert len(chunks) > 0
```

## Testing Checklist

- [ ] Celery worker starts successfully
- [ ] Document creation returns pending status
- [ ] Background task processes document
- [ ] Chunks are created with embeddings
- [ ] Document status updates to "ready"
- [ ] Failed processing updates status to "failed"
- [ ] Task retries on transient failures
- [ ] Integration test passes end-to-end

## Migration to Production

**Step 1:** Add Valkey to docker-compose
**Step 2:** Update environment variable: `CELERY_BROKER_URL=redis://valkey:6379/0`
**Step 3:** Start worker container
**Step 4:** Monitor with Flower: `celery -A celery_config flower`

## Next Steps

Proceed to Step 12: Testing & Deployment
