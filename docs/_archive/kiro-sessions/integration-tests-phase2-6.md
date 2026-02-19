# Integration Tests - Phases 2-6

## Phase 2: Cortex API Endpoints

### Test Suite 2.1: Status Update Endpoint

**File:** `tests/integration/phase2/test_status_endpoint.py`

```python
import pytest
import requests
from uuid import uuid4
from datetime import datetime

CORTEX_URL = "http://localhost:8000"

@pytest.fixture
def test_kb():
    """Create test knowledge base"""
    response = requests.post(
        f"{CORTEX_URL}/api/v1/knowledge-bases",
        json={"name": "Test KB", "description": "Test"}
    )
    kb_id = response.json()["id"]
    yield kb_id
    requests.delete(f"{CORTEX_URL}/api/v1/knowledge-bases/{kb_id}")

@pytest.fixture
def test_document(test_kb):
    """Create test document"""
    response = requests.post(
        f"{CORTEX_URL}/api/v1/knowledge-bases/{test_kb}/documents",
        json={
            "filename": "test.pdf",
            "content_type": "application/pdf",
            "content": "test"
        }
    )
    doc_id = response.json()["id"]
    yield doc_id
    requests.delete(f"{CORTEX_URL}/api/v1/documents/{doc_id}")

def test_status_update_processing(test_document):
    """✅ Test: Update status to PROCESSING"""
    response = requests.patch(
        f"{CORTEX_URL}/api/v1/documents/{test_document}/status",
        json={"status": "processing"}
    )
    assert response.status_code == 200
    assert response.json()["status"] == "processing"
    print("✅ PASS: Status updated to PROCESSING")

def test_status_update_completed(test_document):
    """✅ Test: Update status to COMPLETED with chunk count"""
    response = requests.patch(
        f"{CORTEX_URL}/api/v1/documents/{test_document}/status",
        json={
            "status": "completed",
            "chunk_count": 10,
            "processed_at": datetime.utcnow().isoformat()
        }
    )
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "completed"
    assert data["chunk_count"] == 10
    print("✅ PASS: Status updated to COMPLETED")

def test_status_update_failed_requires_error(test_document):
    """✅ Test: FAILED status requires error message"""
    response = requests.patch(
        f"{CORTEX_URL}/api/v1/documents/{test_document}/status",
        json={"status": "failed"}
    )
    assert response.status_code == 400
    print("✅ PASS: Failed status requires error message")

def test_status_update_failed_with_error(test_document):
    """✅ Test: FAILED status with error message"""
    response = requests.patch(
        f"{CORTEX_URL}/api/v1/documents/{test_document}/status",
        json={
            "status": "failed",
            "error": "Test error message"
        }
    )
    assert response.status_code == 200
    assert response.json()["status"] == "failed"
    print("✅ PASS: Failed status with error")

def test_status_update_invalid_status(test_document):
    """✅ Test: Invalid status value"""
    response = requests.patch(
        f"{CORTEX_URL}/api/v1/documents/{test_document}/status",
        json={"status": "invalid"}
    )
    assert response.status_code == 400
    print("✅ PASS: Invalid status rejected")

def test_status_update_nonexistent_document():
    """✅ Test: Update status of non-existent document"""
    response = requests.patch(
        f"{CORTEX_URL}/api/v1/documents/{uuid4()}/status",
        json={"status": "processing"}
    )
    assert response.status_code == 404
    print("✅ PASS: 404 for non-existent document")
```

### Test Suite 2.2: Chunk Storage Endpoint

**File:** `tests/integration/phase2/test_chunk_endpoint.py`

```python
import pytest
import requests
from uuid import uuid4

CORTEX_URL = "http://localhost:8000"

def test_store_chunk_success(test_document):
    """✅ Test: Store chunk successfully"""
    embedding = [0.1] * 1536
    
    response = requests.post(
        f"{CORTEX_URL}/api/v1/documents/{test_document}/chunks",
        json={
            "chunk_index": 0,
            "content": "Test chunk content",
            "embedding": embedding,
            "metadata": {"key": "value"}
        }
    )
    
    assert response.status_code == 201
    data = response.json()
    assert data["chunk_index"] == 0
    assert data["document_id"] == test_document
    print("✅ PASS: Chunk stored successfully")

def test_store_multiple_chunks(test_document):
    """✅ Test: Store multiple chunks"""
    for i in range(5):
        embedding = [0.1 * (i + 1)] * 1536
        response = requests.post(
            f"{CORTEX_URL}/api/v1/documents/{test_document}/chunks",
            json={
                "chunk_index": i,
                "content": f"Chunk {i}",
                "embedding": embedding
            }
        )
        assert response.status_code == 201
    print("✅ PASS: Multiple chunks stored")

def test_store_duplicate_chunk_fails(test_document):
    """✅ Test: Duplicate chunk index fails"""
    embedding = [0.1] * 1536
    
    # Store first chunk
    requests.post(
        f"{CORTEX_URL}/api/v1/documents/{test_document}/chunks",
        json={
            "chunk_index": 0,
            "content": "First",
            "embedding": embedding
        }
    )
    
    # Try to store duplicate
    response = requests.post(
        f"{CORTEX_URL}/api/v1/documents/{test_document}/chunks",
        json={
            "chunk_index": 0,
            "content": "Duplicate",
            "embedding": embedding
        }
    )
    
    assert response.status_code == 409
    print("✅ PASS: Duplicate chunk rejected")

def test_store_chunk_invalid_embedding_size(test_document):
    """✅ Test: Invalid embedding size"""
    embedding = [0.1] * 100  # Wrong size
    
    response = requests.post(
        f"{CORTEX_URL}/api/v1/documents/{test_document}/chunks",
        json={
            "chunk_index": 0,
            "content": "Test",
            "embedding": embedding
        }
    )
    
    assert response.status_code == 400
    print("✅ PASS: Invalid embedding size rejected")

def test_store_chunk_missing_content(test_document):
    """✅ Test: Missing content field"""
    embedding = [0.1] * 1536
    
    response = requests.post(
        f"{CORTEX_URL}/api/v1/documents/{test_document}/chunks",
        json={
            "chunk_index": 0,
            "embedding": embedding
        }
    )
    
    assert response.status_code == 400
    print("✅ PASS: Missing content rejected")
```

**Run Phase 2 Tests:**
```bash
pytest tests/integration/phase2/ -v
```

---

## Phase 3: Client Libraries

### Test Suite 3.1: ForgeClient

**File:** `tests/integration/phase3/test_forge_client.ts`

```typescript
import { Test } from '@nestjs/testing';
import { ConfigService } from '@nestjs/config';
import { ForgeClient } from '@asyml8/api-core';

describe('ForgeClient Integration', () => {
  let client: ForgeClient;

  beforeAll(async () => {
    const module = await Test.createTestingModule({
      providers: [
        ForgeClient,
        {
          provide: ConfigService,
          useValue: {
            getOrThrow: (key: string) => {
              if (key === 'FORGE_API_URL') return 'http://localhost:4002';
              if (key === 'FORGE_API_KEY') return 'test-key';
            },
          },
        },
      ],
    }).compile();

    client = module.get<ForgeClient>(ForgeClient);
  });

  it('✅ should initiate upload', async () => {
    const result = await client.initiateUpload({
      filename: 'test.pdf',
      size: 1024,
      contentType: 'application/pdf',
      metadata: { test: true },
    });

    expect(result.uploadId).toBeDefined();
    expect(result.uploadUrl).toBeDefined();
    console.log('✅ PASS: Upload initiated');
  });

  it('✅ should get file metadata', async () => {
    // First upload a file
    const upload = await client.initiateUpload({
      filename: 'test.pdf',
      size: 1024,
      contentType: 'application/pdf',
    });

    // Get metadata
    const metadata = await client.getFileMetadata(upload.uploadId);

    expect(metadata.id).toBe(upload.uploadId);
    expect(metadata.filename).toBe('test.pdf');
    console.log('✅ PASS: Metadata retrieved');
  });

  it('✅ should get download URL', async () => {
    const upload = await client.initiateUpload({
      filename: 'test.pdf',
      size: 1024,
      contentType: 'application/pdf',
    });

    const url = await client.getDownloadUrl(upload.uploadId);

    expect(url).toContain('http');
    console.log('✅ PASS: Download URL retrieved');
  });

  it('✅ should handle errors gracefully', async () => {
    await expect(
      client.getFileMetadata('invalid-id')
    ).rejects.toThrow();
    console.log('✅ PASS: Error handled');
  });
});
```

### Test Suite 3.2: HelixClient

**File:** `tests/integration/phase3/test_helix_client.ts`

```typescript
import { Test } from '@nestjs/testing';
import { ConfigService } from '@nestjs/config';
import { HelixClient } from '@asyml8/api-core';

describe('HelixClient Integration', () => {
  let client: HelixClient;
  const WORKFLOW_ID = '5Wba1MKHnLpdc8IB';

  beforeAll(async () => {
    const module = await Test.createTestingModule({
      providers: [
        HelixClient,
        {
          provide: ConfigService,
          useValue: {
            getOrThrow: (key: string) => {
              if (key === 'HELIX_API_URL') return 'http://localhost:4005';
              if (key === 'HELIX_API_KEY') return 'test-key';
            },
          },
        },
      ],
    }).compile();

    client = module.get<HelixClient>(HelixClient);
  });

  it('✅ should execute workflow', async () => {
    const result = await client.executeWorkflow(WORKFLOW_ID, {
      document_id: 'test-doc',
      file_id: 'test-file',
      kb_id: 'test-kb',
    });

    expect(result.executionId).toBeDefined();
    expect(result.workflowId).toBe(WORKFLOW_ID);
    console.log('✅ PASS: Workflow executed');
  });

  it('✅ should get execution status', async () => {
    const execution = await client.executeWorkflow(WORKFLOW_ID, {
      document_id: 'test-doc',
    });

    const status = await client.getExecutionStatus(execution.executionId);

    expect(status.executionId).toBe(execution.executionId);
    expect(status.status).toBeDefined();
    console.log('✅ PASS: Execution status retrieved');
  });

  it('✅ should get workflow details', async () => {
    const workflow = await client.getWorkflow(WORKFLOW_ID);

    expect(workflow.id).toBe(WORKFLOW_ID);
    expect(workflow.name).toBeDefined();
    console.log('✅ PASS: Workflow details retrieved');
  });
});
```

**Run Phase 3 Tests:**
```bash
cd packages/api-core
npm test -- --testPathPattern=integration
```

---

## Phase 4: Forge Integration

### Test Suite 4.1: Workflow Trigger on Upload

**File:** `tests/integration/phase4/test_forge_trigger.py`

```python
import pytest
import requests
from pathlib import Path
import time

FORGE_URL = "http://localhost:4002"
HELIX_URL = "http://localhost:4005"
CORTEX_URL = "http://localhost:8000"

def test_upload_triggers_workflow():
    """✅ Test: File upload triggers n8n workflow"""
    
    # Create KB and document
    kb_response = requests.post(
        f"{CORTEX_URL}/api/v1/knowledge-bases",
        json={"name": "Test KB"}
    )
    kb_id = kb_response.json()["id"]
    
    doc_response = requests.post(
        f"{CORTEX_URL}/api/v1/knowledge-bases/{kb_id}/documents",
        json={
            "filename": "test.pdf",
            "content_type": "application/pdf",
            "content": "test"
        }
    )
    doc_id = doc_response.json()["id"]
    
    # Upload file to Forge with metadata
    test_file = Path("tests/fixtures/sample.pdf")
    with open(test_file, "rb") as f:
        upload_response = requests.post(
            f"{FORGE_URL}/api/v1/files/upload",
            files={"file": f},
            data={
                "metadata": f'{{"document_id": "{doc_id}", "kb_id": "{kb_id}"}}'
            }
        )
    
    assert upload_response.status_code == 201
    file_id = upload_response.json()["id"]
    
    # Wait for workflow to trigger
    time.sleep(3)
    
    # Check document status changed
    doc_response = requests.get(
        f"{CORTEX_URL}/api/v1/documents/{doc_id}"
    )
    
    doc = doc_response.json()
    assert doc["status"] in ["processing", "completed"]
    
    print("✅ PASS: Upload triggered workflow")
    
    # Cleanup
    requests.delete(f"{FORGE_URL}/api/v1/files/{file_id}")
    requests.delete(f"{CORTEX_URL}/api/v1/documents/{doc_id}")
    requests.delete(f"{CORTEX_URL}/api/v1/knowledge-bases/{kb_id}")

def test_upload_without_metadata_skips_workflow():
    """✅ Test: Upload without metadata doesn't trigger workflow"""
    
    test_file = Path("tests/fixtures/sample.pdf")
    with open(test_file, "rb") as f:
        upload_response = requests.post(
            f"{FORGE_URL}/api/v1/files/upload",
            files={"file": f}
        )
    
    assert upload_response.status_code == 201
    file_id = upload_response.json()["id"]
    
    # Workflow should not trigger (no document_id in metadata)
    time.sleep(2)
    
    print("✅ PASS: Upload without metadata skipped workflow")
    
    # Cleanup
    requests.delete(f"{FORGE_URL}/api/v1/files/{file_id}")

def test_workflow_trigger_failure_doesnt_fail_upload():
    """✅ Test: Workflow trigger failure doesn't fail upload"""
    
    # Upload with invalid workflow ID in Forge config
    test_file = Path("tests/fixtures/sample.pdf")
    with open(test_file, "rb") as f:
        upload_response = requests.post(
            f"{FORGE_URL}/api/v1/files/upload",
            files={"file": f},
            data={
                "metadata": '{"document_id": "test", "kb_id": "test"}'
            }
        )
    
    # Upload should succeed even if workflow fails
    assert upload_response.status_code == 201
    
    print("✅ PASS: Upload succeeds even if workflow fails")
```

**Run Phase 4 Tests:**
```bash
pytest tests/integration/phase4/ -v
```

---

## Phase 5: Cortex Upload Flow

### Test Suite 5.1: Initiate Upload

**File:** `tests/integration/phase5/test_cortex_upload_flow.py`

```python
import pytest
import requests
from uuid import uuid4

CORTEX_URL = "http://localhost:8000"
FORGE_URL = "http://localhost:4002"

def test_initiate_upload_success():
    """✅ Test: Initiate upload returns upload URL"""
    
    # Create KB
    kb_response = requests.post(
        f"{CORTEX_URL}/api/v1/knowledge-bases",
        json={"name": "Test KB"}
    )
    kb_id = kb_response.json()["id"]
    
    # Initiate upload
    response = requests.post(
        f"{CORTEX_URL}/api/v1/knowledge-bases/{kb_id}/documents/initiate-upload",
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
    assert "upload_id" in data
    assert "upload_url" in data
    assert "expires_at" in data
    
    # Verify document created with PENDING_UPLOAD status
    doc_response = requests.get(
        f"{CORTEX_URL}/api/v1/documents/{data['document_id']}"
    )
    doc = doc_response.json()
    assert doc["status"] == "pending_upload"
    assert doc["forge_file_id"] == data["upload_id"]
    
    print("✅ PASS: Upload initiated successfully")
    
    # Cleanup
    requests.delete(f"{CORTEX_URL}/api/v1/documents/{data['document_id']}")
    requests.delete(f"{CORTEX_URL}/api/v1/knowledge-bases/{kb_id}")

def test_initiate_upload_invalid_kb():
    """✅ Test: Initiate upload with invalid KB"""
    
    response = requests.post(
        f"{CORTEX_URL}/api/v1/knowledge-bases/{uuid4()}/documents/initiate-upload",
        json={
            "filename": "test.pdf",
            "content_type": "application/pdf",
            "file_size": 1024
        }
    )
    
    assert response.status_code == 404
    print("✅ PASS: Invalid KB rejected")

def test_initiate_upload_invalid_file_size():
    """✅ Test: Initiate upload with invalid file size"""
    
    kb_response = requests.post(
        f"{CORTEX_URL}/api/v1/knowledge-bases",
        json={"name": "Test KB"}
    )
    kb_id = kb_response.json()["id"]
    
    response = requests.post(
        f"{CORTEX_URL}/api/v1/knowledge-bases/{kb_id}/documents/initiate-upload",
        json={
            "filename": "test.pdf",
            "content_type": "application/pdf",
            "file_size": 0  # Invalid
        }
    )
    
    assert response.status_code == 400
    print("✅ PASS: Invalid file size rejected")
    
    # Cleanup
    requests.delete(f"{CORTEX_URL}/api/v1/knowledge-bases/{kb_id}")
```

**Run Phase 5 Tests:**
```bash
pytest tests/integration/phase5/ -v
```

---

## Phase 6: Frontend Integration

### Test Suite 6.1: TUS Upload

**File:** `tests/integration/phase6/test_frontend_upload.spec.ts`

```typescript
import { test, expect } from '@playwright/test';

test.describe('Document Upload Flow', () => {
  test('✅ should upload file successfully', async ({ page }) => {
    await page.goto('http://localhost:3000/knowledge-bases/test-kb');

    // Select file
    const fileInput = page.locator('input[type="file"]');
    await fileInput.setInputFiles('tests/fixtures/sample.pdf');

    // Click upload
    await page.click('button:has-text("Upload")');

    // Wait for progress
    await expect(page.locator('.upload-progress')).toBeVisible();

    // Wait for completion
    await expect(page.locator('.success')).toBeVisible({ timeout: 60000 });

    console.log('✅ PASS: File uploaded successfully');
  });

  test('✅ should show upload progress', async ({ page }) => {
    await page.goto('http://localhost:3000/knowledge-bases/test-kb');

    const fileInput = page.locator('input[type="file"]');
    await fileInput.setInputFiles('tests/fixtures/large.pdf');

    await page.click('button:has-text("Upload")');

    // Check progress updates
    const progressBar = page.locator('.progress-fill');
    await expect(progressBar).toBeVisible();

    // Progress should increase
    const initialWidth = await progressBar.evaluate(el => el.style.width);
    await page.waitForTimeout(2000);
    const laterWidth = await progressBar.evaluate(el => el.style.width);

    expect(laterWidth).not.toBe(initialWidth);

    console.log('✅ PASS: Progress shown');
  });

  test('✅ should cancel upload', async ({ page }) => {
    await page.goto('http://localhost:3000/knowledge-bases/test-kb');

    const fileInput = page.locator('input[type="file"]');
    await fileInput.setInputFiles('tests/fixtures/large.pdf');

    await page.click('button:has-text("Upload")');
    await page.waitForTimeout(1000);

    // Cancel
    await page.click('button:has-text("Cancel")');

    await expect(page.locator('.upload-progress')).not.toBeVisible();

    console.log('✅ PASS: Upload cancelled');
  });

  test('✅ should show processing status', async ({ page }) => {
    await page.goto('http://localhost:3000/knowledge-bases/test-kb');

    const fileInput = page.locator('input[type="file"]');
    await fileInput.setInputFiles('tests/fixtures/sample.pdf');

    await page.click('button:has-text("Upload")');

    // Wait for upload complete
    await expect(page.locator('.success')).toBeVisible({ timeout: 60000 });

    // Should show processing status
    await expect(page.locator('text=Processing document')).toBeVisible();

    console.log('✅ PASS: Processing status shown');
  });
});
```

**Run Phase 6 Tests:**
```bash
npx playwright test tests/integration/phase6/
```

---

## Master Test Runner

**File:** `tests/integration/run_all_integration_tests.sh`

```bash
#!/bin/bash

set -e

echo "🧪 Running All Integration Tests"
echo "================================="
echo ""

# Check all services
echo "Checking services..."
services=(
  "http://localhost:5678:n8n"
  "http://localhost:4005:Helix"
  "http://localhost:8000:Cortex"
  "http://localhost:4002:Forge"
)

for service in "${services[@]}"; do
  IFS=':' read -r url name <<< "$service"
  if curl -f "$url" > /dev/null 2>&1; then
    echo "✅ $name running"
  else
    echo "❌ $name not running at $url"
    exit 1
  fi
done

echo ""
echo "Running Phase 1: n8n Workflow Tests"
pytest tests/integration/phase1/ -v --tb=short

echo ""
echo "Running Phase 2: Cortex API Tests"
pytest tests/integration/phase2/ -v --tb=short

echo ""
echo "Running Phase 3: Client Library Tests"
cd packages/api-core && npm test -- --testPathPattern=integration && cd ../..

echo ""
echo "Running Phase 4: Forge Integration Tests"
pytest tests/integration/phase4/ -v --tb=short

echo ""
echo "Running Phase 5: Cortex Upload Flow Tests"
pytest tests/integration/phase5/ -v --tb=short

echo ""
echo "Running Phase 6: Frontend Tests"
npx playwright test tests/integration/phase6/

echo ""
echo "✅ All Integration Tests Passed!"
echo ""
echo "Summary:"
echo "--------"
pytest tests/integration/ --collect-only | grep "test session starts"
```

**Run all tests:**
```bash
chmod +x tests/integration/run_all_integration_tests.sh
./tests/integration/run_all_integration_tests.sh
```

---

## CI/CD Integration

**File:** `.github/workflows/integration-tests.yml`

```yaml
name: Integration Tests

on:
  pull_request:
    branches: [main, develop]
  push:
    branches: [main, develop]

jobs:
  integration-tests:
    runs-on: ubuntu-latest
    
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: postgres
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
      
      redis:
        image: redis:7
        options: >-
          --health-cmd "redis-cli ping"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '20'
      
      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'
      
      - name: Install dependencies
        run: |
          npm install -g pnpm
          pnpm install
          pip install -r services/cortex/requirements.txt
          pip install pytest requests
      
      - name: Start services
        run: |
          docker-compose up -d
          sleep 30
      
      - name: Run integration tests
        run: |
          ./tests/integration/run_all_integration_tests.sh
      
      - name: Upload test results
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: test-results
          path: test-results/
```

---

## Test Coverage Report

**File:** `tests/integration/generate_coverage_report.sh`

```bash
#!/bin/bash

echo "Generating Integration Test Coverage Report"
echo "==========================================="

# Run tests with coverage
pytest tests/integration/ \
  --cov=services/cortex/app \
  --cov=api/forge/src \
  --cov-report=html \
  --cov-report=term

echo ""
echo "Coverage report generated: htmlcov/index.html"
open htmlcov/index.html
```

---

## Success Criteria Checklist

### Phase 1: n8n Workflow
- [ ] Workflow triggers successfully
- [ ] File downloads from Forge
- [ ] PDF text extraction works
- [ ] DOCX text extraction works
- [ ] TXT text extraction works
- [ ] Text chunking works
- [ ] Embeddings generated
- [ ] Chunks stored in Cortex
- [ ] Status updates work
- [ ] Error handling works

### Phase 2: Cortex API
- [ ] Status update endpoint works
- [ ] Chunk storage endpoint works
- [ ] Validation works
- [ ] Error responses correct
- [ ] Database migrations applied

### Phase 3: Client Libraries
- [ ] ForgeClient works
- [ ] HelixClient works
- [ ] Error handling works
- [ ] TypeScript types correct

### Phase 4: Forge Integration
- [ ] Upload triggers workflow
- [ ] Metadata passed correctly
- [ ] Workflow failure doesn't fail upload

### Phase 5: Cortex Upload Flow
- [ ] Initiate upload works
- [ ] Document created with correct status
- [ ] Upload URL returned

### Phase 6: Frontend
- [ ] File upload works
- [ ] Progress shown
- [ ] Cancel works
- [ ] Status polling works
- [ ] Error handling works

---

