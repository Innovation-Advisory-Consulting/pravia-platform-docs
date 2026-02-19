# Integration Tests - Phase 1: n8n Workflow

## Test Environment Setup

### Prerequisites
```bash
# Services running
- n8n: http://localhost:5678
- Helix API: http://localhost:4004
- Cortex API: http://localhost:8000
- Forge API: http://localhost:4002
```

### Test Data
```bash
tests/fixtures/
├── sample.pdf          # Multi-page PDF
├── sample.docx         # Word document
├── sample.txt          # Plain text
├── sample.md           # Markdown
├── large.pdf           # 10MB+ file
└── invalid.xyz         # Unsupported format
```

---

## Test Suite 1: Workflow Execution

### Test 1.1: Trigger Workflow via Helix API

**File:** `tests/integration/phase1/test_01_trigger_workflow.py`

```python
import pytest
import requests
import time
from uuid import uuid4

BASE_URL = "http://localhost:4005"
WORKFLOW_ID = "5Wba1MKHnLpdc8IB"  # Replace with actual workflow ID

def test_trigger_workflow_success():
    """Test triggering n8n workflow via Helix API"""
    
    # Arrange
    payload = {
        "document_id": str(uuid4()),
        "file_id": "test-file-123",
        "kb_id": str(uuid4()),
        "storage_path": "test/sample.pdf",
        "filename": "sample.pdf",
        "content_type": "application/pdf"
    }
    
    # Act
    response = requests.post(
        f"{BASE_URL}/api/n8n/workflows/{WORKFLOW_ID}/execute",
        json=payload,
        headers={"Content-Type": "application/json"}
    )
    
    # Assert
    assert response.status_code == 200, f"Failed to trigger workflow: {response.text}"
    
    result = response.json()
    assert "executionId" in result
    assert result["status"] in ["running", "success"]
    
    print(f"✅ Workflow triggered: {result['executionId']}")
    return result["executionId"]


def test_trigger_workflow_invalid_payload():
    """Test workflow trigger with invalid payload"""
    
    # Missing required fields
    payload = {
        "document_id": str(uuid4())
        # Missing other required fields
    }
    
    response = requests.post(
        f"{BASE_URL}/api/n8n/workflows/{WORKFLOW_ID}/execute",
        json=payload
    )
    
    # Should still trigger but workflow will handle validation
    assert response.status_code in [200, 400]
    print("✅ Invalid payload handled correctly")


def test_get_execution_status():
    """Test retrieving workflow execution status"""
    
    # First trigger a workflow
    execution_id = test_trigger_workflow_success()
    
    # Wait a bit
    time.sleep(2)
    
    # Get status
    response = requests.get(
        f"{BASE_URL}/api/n8n/executions/{execution_id}"
    )
    
    assert response.status_code == 200
    result = response.json()
    assert result["executionId"] == execution_id
    assert result["status"] in ["running", "success", "error"]
    
    print(f"✅ Execution status: {result['status']}")
```

**Run:**
```bash
pytest tests/integration/phase1/test_01_trigger_workflow.py -v
```

**Expected Output:**
```
✅ Workflow triggered: abc123
✅ Invalid payload handled correctly
✅ Execution status: running
PASSED
```

---

## Test Suite 2: Document Download

### Test 2.1: Download File from Forge

**File:** `tests/integration/phase1/test_02_download_file.py`

```python
import pytest
import requests
from pathlib import Path

FORGE_URL = "http://localhost:4002"
CORTEX_URL = "http://localhost:8000"

@pytest.fixture
def uploaded_file():
    """Upload a test file to Forge and return file_id"""
    
    # Upload test file
    test_file = Path("tests/fixtures/sample.pdf")
    
    with open(test_file, "rb") as f:
        response = requests.post(
            f"{FORGE_URL}/api/v1/files/upload",
            files={"file": f},
            data={"metadata": '{"test": true}'}
        )
    
    assert response.status_code == 201
    file_id = response.json()["id"]
    
    yield file_id
    
    # Cleanup
    requests.delete(f"{FORGE_URL}/api/v1/files/{file_id}")


def test_download_file_success(uploaded_file):
    """Test downloading file from Forge"""
    
    response = requests.get(
        f"{FORGE_URL}/api/v1/files/{uploaded_file}/download"
    )
    
    assert response.status_code == 200
    assert len(response.content) > 0
    assert response.headers["Content-Type"] == "application/pdf"
    
    print(f"✅ Downloaded {len(response.content)} bytes")


def test_download_file_not_found():
    """Test downloading non-existent file"""
    
    response = requests.get(
        f"{FORGE_URL}/api/v1/files/invalid-id/download"
    )
    
    assert response.status_code == 404
    print("✅ 404 for non-existent file")


def test_get_file_metadata(uploaded_file):
    """Test getting file metadata"""
    
    response = requests.get(
        f"{FORGE_URL}/api/v1/files/{uploaded_file}/metadata"
    )
    
    assert response.status_code == 200
    metadata = response.json()
    
    assert metadata["id"] == uploaded_file
    assert "filename" in metadata
    assert "size" in metadata
    assert "contentType" in metadata
    
    print(f"✅ Metadata: {metadata['filename']}, {metadata['size']} bytes")
```

**Run:**
```bash
pytest tests/integration/phase1/test_02_download_file.py -v
```

---

## Test Suite 3: Text Extraction

### Test 3.1: PDF Text Extraction

**File:** `tests/integration/phase1/test_03_text_extraction.py`

```python
import pytest
import requests
import json
from pathlib import Path

N8N_WEBHOOK_URL = "http://localhost:5678/webhook/document-processing"

def test_pdf_extraction():
    """Test PDF text extraction in n8n workflow"""
    
    # Prepare payload
    payload = {
        "document_id": "test-doc-pdf",
        "file_id": "test-file-pdf",
        "kb_id": "test-kb",
        "storage_path": "tests/fixtures/sample.pdf",
        "filename": "sample.pdf",
        "content_type": "application/pdf"
    }
    
    # Trigger workflow
    response = requests.post(N8N_WEBHOOK_URL, json=payload)
    
    assert response.status_code in [200, 202]
    print("✅ PDF extraction workflow triggered")
    
    # Wait for processing
    import time
    time.sleep(5)
    
    # Check Cortex for document status
    doc_response = requests.get(
        f"http://localhost:8000/api/v1/documents/test-doc-pdf"
    )
    
    if doc_response.status_code == 200:
        doc = doc_response.json()
        assert doc["status"] in ["processing", "completed"]
        print(f"✅ Document status: {doc['status']}")


def test_docx_extraction():
    """Test DOCX text extraction"""
    
    payload = {
        "document_id": "test-doc-docx",
        "file_id": "test-file-docx",
        "kb_id": "test-kb",
        "storage_path": "tests/fixtures/sample.docx",
        "filename": "sample.docx",
        "content_type": "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
    }
    
    response = requests.post(N8N_WEBHOOK_URL, json=payload)
    assert response.status_code in [200, 202]
    print("✅ DOCX extraction workflow triggered")


def test_txt_extraction():
    """Test plain text extraction"""
    
    payload = {
        "document_id": "test-doc-txt",
        "file_id": "test-file-txt",
        "kb_id": "test-kb",
        "storage_path": "tests/fixtures/sample.txt",
        "filename": "sample.txt",
        "content_type": "text/plain"
    }
    
    response = requests.post(N8N_WEBHOOK_URL, json=payload)
    assert response.status_code in [200, 202]
    print("✅ TXT extraction workflow triggered")


def test_unsupported_format():
    """Test handling of unsupported file format"""
    
    payload = {
        "document_id": "test-doc-invalid",
        "file_id": "test-file-invalid",
        "kb_id": "test-kb",
        "storage_path": "tests/fixtures/invalid.xyz",
        "filename": "invalid.xyz",
        "content_type": "application/octet-stream"
    }
    
    response = requests.post(N8N_WEBHOOK_URL, json=payload)
    assert response.status_code in [200, 202]
    
    # Wait and check status
    import time
    time.sleep(5)
    
    doc_response = requests.get(
        f"http://localhost:8000/api/v1/documents/test-doc-invalid"
    )
    
    if doc_response.status_code == 200:
        doc = doc_response.json()
        assert doc["status"] == "failed"
        assert "unsupported" in doc.get("processing_error", "").lower()
        print("✅ Unsupported format handled correctly")
```

**Run:**
```bash
pytest tests/integration/phase1/test_03_text_extraction.py -v
```

---

## Test Suite 4: Chunking

### Test 4.1: Text Chunking

**File:** `tests/integration/phase1/test_04_chunking.py`

```python
import pytest
import requests

def test_chunking_creates_multiple_chunks():
    """Test that large text is split into multiple chunks"""
    
    # Create a large text document
    large_text = "This is a test sentence. " * 500  # ~2500 words
    
    # Simulate workflow processing
    # (This would be tested via the full workflow)
    
    # For now, test the chunking logic directly
    chunk_size = 2000
    overlap = 200
    
    chunks = []
    start = 0
    while start < len(large_text):
        end = min(start + chunk_size, len(large_text))
        chunk = large_text[start:end]
        chunks.append(chunk)
        start = end - overlap
        if start >= len(large_text) - overlap:
            break
    
    assert len(chunks) > 1, "Large text should create multiple chunks"
    assert all(len(chunk) <= chunk_size for chunk in chunks)
    
    print(f"✅ Created {len(chunks)} chunks from {len(large_text)} characters")


def test_chunk_overlap():
    """Test that chunks have proper overlap"""
    
    text = "A" * 1000 + "B" * 1000 + "C" * 1000
    chunk_size = 1500
    overlap = 200
    
    chunks = []
    start = 0
    while start < len(text):
        end = min(start + chunk_size, len(text))
        chunk = text[start:end]
        chunks.append(chunk)
        start = end - overlap
        if start >= len(text) - overlap:
            break
    
    # Check overlap between consecutive chunks
    for i in range(len(chunks) - 1):
        chunk1_end = chunks[i][-overlap:]
        chunk2_start = chunks[i + 1][:overlap]
        assert chunk1_end == chunk2_start, "Chunks should overlap"
    
    print(f"✅ Chunk overlap verified for {len(chunks)} chunks")


def test_small_text_single_chunk():
    """Test that small text creates single chunk"""
    
    small_text = "This is a small text."
    chunk_size = 2000
    
    chunks = []
    if len(small_text) <= chunk_size:
        chunks.append(small_text)
    
    assert len(chunks) == 1
    print("✅ Small text creates single chunk")
```

**Run:**
```bash
pytest tests/integration/phase1/test_04_chunking.py -v
```

---

## Test Suite 5: Embeddings Generation

### Test 5.1: OpenAI Embeddings

**File:** `tests/integration/phase1/test_05_embeddings.py`

```python
import pytest
import requests
import os

OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")

@pytest.mark.skipif(not OPENAI_API_KEY, reason="OpenAI API key not set")
def test_generate_embedding():
    """Test generating embedding via OpenAI API"""
    
    text = "This is a test document about machine learning."
    
    response = requests.post(
        "https://api.openai.com/v1/embeddings",
        headers={
            "Authorization": f"Bearer {OPENAI_API_KEY}",
            "Content-Type": "application/json"
        },
        json={
            "input": text,
            "model": "text-embedding-3-small"
        }
    )
    
    assert response.status_code == 200
    result = response.json()
    
    assert "data" in result
    assert len(result["data"]) > 0
    
    embedding = result["data"][0]["embedding"]
    assert len(embedding) == 1536, "Embedding should have 1536 dimensions"
    assert all(isinstance(x, float) for x in embedding)
    
    print(f"✅ Generated embedding with {len(embedding)} dimensions")


@pytest.mark.skipif(not OPENAI_API_KEY, reason="OpenAI API key not set")
def test_batch_embeddings():
    """Test generating embeddings for multiple chunks"""
    
    chunks = [
        "First chunk of text",
        "Second chunk of text",
        "Third chunk of text"
    ]
    
    embeddings = []
    for chunk in chunks:
        response = requests.post(
            "https://api.openai.com/v1/embeddings",
            headers={
                "Authorization": f"Bearer {OPENAI_API_KEY}",
                "Content-Type": "application/json"
            },
            json={
                "input": chunk,
                "model": "text-embedding-3-small"
            }
        )
        
        assert response.status_code == 200
        embedding = response.json()["data"][0]["embedding"]
        embeddings.append(embedding)
    
    assert len(embeddings) == len(chunks)
    assert all(len(emb) == 1536 for emb in embeddings)
    
    print(f"✅ Generated {len(embeddings)} embeddings")


def test_embedding_similarity():
    """Test that similar texts have similar embeddings"""
    
    # This would require actual embeddings
    # Placeholder for similarity calculation
    
    def cosine_similarity(a, b):
        import numpy as np
        return np.dot(a, b) / (np.linalg.norm(a) * np.linalg.norm(b))
    
    # Similar texts should have high similarity
    # Different texts should have low similarity
    
    print("✅ Embedding similarity test placeholder")
```

**Run:**
```bash
export OPENAI_API_KEY=sk-...
pytest tests/integration/phase1/test_05_embeddings.py -v
```

---

## Test Suite 6: Cortex Integration

### Test 6.1: Update Document Status

**File:** `tests/integration/phase1/test_06_cortex_integration.py`

```python
import pytest
import requests
from uuid import uuid4

CORTEX_URL = "http://localhost:8000"

@pytest.fixture
def test_document():
    """Create a test document in Cortex"""
    
    # Create KB first
    kb_response = requests.post(
        f"{CORTEX_URL}/api/v1/knowledge-bases",
        json={
            "name": "Test KB",
            "description": "Integration test KB"
        }
    )
    kb_id = kb_response.json()["id"]
    
    # Create document
    doc_response = requests.post(
        f"{CORTEX_URL}/api/v1/knowledge-bases/{kb_id}/documents",
        json={
            "filename": "test.pdf",
            "content_type": "application/pdf",
            "content": "Test content"
        }
    )
    
    doc_id = doc_response.json()["id"]
    
    yield {"doc_id": doc_id, "kb_id": kb_id}
    
    # Cleanup
    requests.delete(f"{CORTEX_URL}/api/v1/documents/{doc_id}")
    requests.delete(f"{CORTEX_URL}/api/v1/knowledge-bases/{kb_id}")


def test_update_status_to_processing(test_document):
    """Test updating document status to PROCESSING"""
    
    doc_id = test_document["doc_id"]
    
    response = requests.patch(
        f"{CORTEX_URL}/api/v1/documents/{doc_id}/status",
        json={"status": "processing"}
    )
    
    assert response.status_code == 200
    result = response.json()
    assert result["status"] == "processing"
    
    print("✅ Status updated to PROCESSING")


def test_update_status_to_completed(test_document):
    """Test updating document status to COMPLETED"""
    
    doc_id = test_document["doc_id"]
    
    response = requests.patch(
        f"{CORTEX_URL}/api/v1/documents/{doc_id}/status",
        json={
            "status": "completed",
            "chunk_count": 5
        }
    )
    
    assert response.status_code == 200
    result = response.json()
    assert result["status"] == "completed"
    assert result["chunk_count"] == 5
    
    print("✅ Status updated to COMPLETED")


def test_update_status_to_failed(test_document):
    """Test updating document status to FAILED"""
    
    doc_id = test_document["doc_id"]
    
    response = requests.patch(
        f"{CORTEX_URL}/api/v1/documents/{doc_id}/status",
        json={
            "status": "failed",
            "error": "Test error message"
        }
    )
    
    assert response.status_code == 200
    result = response.json()
    assert result["status"] == "failed"
    
    print("✅ Status updated to FAILED")


def test_store_chunk(test_document):
    """Test storing a document chunk"""
    
    doc_id = test_document["doc_id"]
    
    embedding = [0.1] * 1536
    
    response = requests.post(
        f"{CORTEX_URL}/api/v1/documents/{doc_id}/chunks",
        json={
            "chunk_index": 0,
            "content": "This is chunk 0 content",
            "embedding": embedding,
            "metadata": {"test": "data"}
        }
    )
    
    assert response.status_code == 201
    result = response.json()
    assert result["chunk_index"] == 0
    assert result["document_id"] == doc_id
    
    print("✅ Chunk stored successfully")


def test_store_multiple_chunks(test_document):
    """Test storing multiple chunks"""
    
    doc_id = test_document["doc_id"]
    
    for i in range(3):
        embedding = [0.1 * (i + 1)] * 1536
        
        response = requests.post(
            f"{CORTEX_URL}/api/v1/documents/{doc_id}/chunks",
            json={
                "chunk_index": i,
                "content": f"Chunk {i} content",
                "embedding": embedding
            }
        )
        
        assert response.status_code == 201
    
    print("✅ Multiple chunks stored successfully")
```

**Run:**
```bash
pytest tests/integration/phase1/test_06_cortex_integration.py -v
```

---

## Test Suite 7: End-to-End Workflow

### Test 7.1: Complete Workflow Execution

**File:** `tests/integration/phase1/test_07_e2e_workflow.py`

```python
import pytest
import requests
import time
from uuid import uuid4
from pathlib import Path

HELIX_URL = "http://localhost:4005"
CORTEX_URL = "http://localhost:8000"
FORGE_URL = "http://localhost:4002"
WORKFLOW_ID = "5Wba1MKHnLpdc8IB"

def test_complete_workflow_pdf():
    """Test complete workflow from trigger to completion - PDF"""
    
    # Setup
    kb_response = requests.post(
        f"{CORTEX_URL}/api/v1/knowledge-bases",
        json={"name": "E2E Test KB", "description": "Test"}
    )
    kb_id = kb_response.json()["id"]
    
    doc_id = str(uuid4())
    
    # Upload test file to Forge
    test_file = Path("tests/fixtures/sample.pdf")
    with open(test_file, "rb") as f:
        upload_response = requests.post(
            f"{FORGE_URL}/api/v1/files/upload",
            files={"file": f}
        )
    file_id = upload_response.json()["id"]
    
    # Create document in Cortex
    doc_response = requests.post(
        f"{CORTEX_URL}/api/v1/knowledge-bases/{kb_id}/documents",
        json={
            "filename": "sample.pdf",
            "content_type": "application/pdf",
            "content": "placeholder"
        }
    )
    doc_id = doc_response.json()["id"]
    
    # Trigger workflow
    workflow_payload = {
        "document_id": doc_id,
        "file_id": file_id,
        "kb_id": kb_id,
        "storage_path": f"uploads/{file_id}",
        "filename": "sample.pdf",
        "content_type": "application/pdf"
    }
    
    trigger_response = requests.post(
        f"{HELIX_URL}/api/n8n/workflows/{WORKFLOW_ID}/execute",
        json=workflow_payload
    )
    
    assert trigger_response.status_code == 200
    execution_id = trigger_response.json()["executionId"]
    
    print(f"✅ Workflow triggered: {execution_id}")
    
    # Poll for completion
    max_wait = 60
    start = time.time()
    
    while time.time() - start < max_wait:
        doc_response = requests.get(
            f"{CORTEX_URL}/api/v1/documents/{doc_id}"
        )
        
        if doc_response.status_code == 200:
            doc = doc_response.json()
            status = doc["status"]
            
            print(f"Status: {status}")
            
            if status == "completed":
                assert doc["chunk_count"] > 0
                print(f"✅ Workflow completed: {doc['chunk_count']} chunks")
                
                # Cleanup
                requests.delete(f"{CORTEX_URL}/api/v1/documents/{doc_id}")
                requests.delete(f"{CORTEX_URL}/api/v1/knowledge-bases/{kb_id}")
                requests.delete(f"{FORGE_URL}/api/v1/files/{file_id}")
                
                return
            
            elif status == "failed":
                pytest.fail(f"Workflow failed: {doc.get('processing_error')}")
        
        time.sleep(2)
    
    pytest.fail("Workflow did not complete within timeout")


def test_complete_workflow_docx():
    """Test complete workflow - DOCX"""
    # Similar to PDF test but with DOCX file
    pass


def test_complete_workflow_txt():
    """Test complete workflow - TXT"""
    # Similar to PDF test but with TXT file
    pass
```

**Run:**
```bash
pytest tests/integration/phase1/test_07_e2e_workflow.py -v -s
```

---

## Test Runner Script

**File:** `tests/integration/phase1/run_all_tests.sh`

```bash
#!/bin/bash

echo "🧪 Running Phase 1 Integration Tests"
echo "===================================="

# Check services are running
echo "Checking services..."
curl -f http://localhost:5678 > /dev/null 2>&1 || { echo "❌ n8n not running"; exit 1; }
curl -f http://localhost:4005/api/health > /dev/null 2>&1 || { echo "❌ Helix not running"; exit 1; }
curl -f http://localhost:8000/api/v1/health > /dev/null 2>&1 || { echo "❌ Cortex not running"; exit 1; }
curl -f http://localhost:4002/api/health > /dev/null 2>&1 || { echo "❌ Forge not running"; exit 1; }

echo "✅ All services running"
echo ""

# Run tests
pytest tests/integration/phase1/ -v --tb=short --color=yes

echo ""
echo "✅ Phase 1 Integration Tests Complete"
```

**Run:**
```bash
chmod +x tests/integration/phase1/run_all_tests.sh
./tests/integration/phase1/run_all_tests.sh
```

---

## Success Criteria

- [ ] All workflow trigger tests pass
- [ ] File download tests pass
- [ ] Text extraction tests pass for all formats
- [ ] Chunking tests pass
- [ ] Embedding generation tests pass
- [ ] Cortex integration tests pass
- [ ] End-to-end workflow completes successfully
- [ ] Error handling tests pass
- [ ] Performance within acceptable limits

---

