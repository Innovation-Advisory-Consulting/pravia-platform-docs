# Forge-Cortex Integration - Part 5

## Phase 6: Frontend Integration

### Priority: LOW
### Estimated Effort: 2-3 days
### Dependencies: Phase 5 (Cortex upload flow)

### Objective
Update frontend application to use the new upload flow with TUS protocol.

---

### 6.1 Install TUS Client

**File:** `apps/mule-spa/package.json` or `apps/mule-client/package.json`

```json
{
  "dependencies": {
    "tus-js-client": "^4.0.0"
  }
}
```

---

### 6.2 Create Upload Hook

**File:** `apps/mule-spa/src/hooks/useDocumentUpload.ts`

```typescript
import { useState, useCallback } from 'react';
import * as tus from 'tus-js-client';

interface UploadProgress {
  bytesUploaded: number;
  bytesTotal: number;
  percentage: number;
}

interface UseDocumentUploadResult {
  upload: (file: File, kbId: string) => Promise<string>;
  progress: UploadProgress | null;
  isUploading: boolean;
  error: Error | null;
  cancel: () => void;
}

export function useDocumentUpload(): UseDocumentUploadResult {
  const [progress, setProgress] = useState<UploadProgress | null>(null);
  const [isUploading, setIsUploading] = useState(false);
  const [error, setError] = useState<Error | null>(null);
  const [currentUpload, setCurrentUpload] = useState<tus.Upload | null>(null);

  const upload = useCallback(async (file: File, kbId: string): Promise<string> => {
    setIsUploading(true);
    setError(null);
    setProgress(null);

    try {
      // Step 1: Initiate upload with Cortex
      const initiateResponse = await fetch(
        `/api/v1/knowledge-bases/${kbId}/documents/initiate-upload`,
        {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            filename: file.name,
            content_type: file.type,
            file_size: file.size,
            metadata: {
              original_name: file.name,
              uploaded_from: 'web',
            },
          }),
        }
      );

      if (!initiateResponse.ok) {
        throw new Error('Failed to initiate upload');
      }

      const { document_id, upload_url } = await initiateResponse.json();

      // Step 2: Upload file to Forge using TUS
      return new Promise((resolve, reject) => {
        const upload = new tus.Upload(file, {
          endpoint: upload_url,
          retryDelays: [0, 3000, 5000, 10000],
          metadata: {
            filename: file.name,
            filetype: file.type,
          },
          onError: (error) => {
            setError(error);
            setIsUploading(false);
            reject(error);
          },
          onProgress: (bytesUploaded, bytesTotal) => {
            setProgress({
              bytesUploaded,
              bytesTotal,
              percentage: Math.round((bytesUploaded / bytesTotal) * 100),
            });
          },
          onSuccess: () => {
            setIsUploading(false);
            setProgress({
              bytesUploaded: file.size,
              bytesTotal: file.size,
              percentage: 100,
            });
            resolve(document_id);
          },
        });

        setCurrentUpload(upload);
        upload.start();
      });
    } catch (err) {
      setError(err as Error);
      setIsUploading(false);
      throw err;
    }
  }, []);

  const cancel = useCallback(() => {
    if (currentUpload) {
      currentUpload.abort();
      setIsUploading(false);
      setCurrentUpload(null);
    }
  }, [currentUpload]);

  return { upload, progress, isUploading, error, cancel };
}
```

---

### 6.3 Create Upload Component

**File:** `apps/mule-spa/src/components/DocumentUpload.tsx`

```typescript
import React, { useState } from 'react';
import { useDocumentUpload } from '../hooks/useDocumentUpload';

interface DocumentUploadProps {
  kbId: string;
  onUploadComplete: (documentId: string) => void;
}

export function DocumentUpload({ kbId, onUploadComplete }: DocumentUploadProps) {
  const [selectedFile, setSelectedFile] = useState<File | null>(null);
  const { upload, progress, isUploading, error, cancel } = useDocumentUpload();

  const handleFileSelect = (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (file) {
      setSelectedFile(file);
    }
  };

  const handleUpload = async () => {
    if (!selectedFile) return;

    try {
      const documentId = await upload(selectedFile, kbId);
      onUploadComplete(documentId);
      setSelectedFile(null);
    } catch (err) {
      console.error('Upload failed:', err);
    }
  };

  return (
    <div className="document-upload">
      <input
        type="file"
        onChange={handleFileSelect}
        disabled={isUploading}
        accept=".pdf,.docx,.txt,.md"
      />

      {selectedFile && !isUploading && (
        <button onClick={handleUpload}>
          Upload {selectedFile.name}
        </button>
      )}

      {isUploading && progress && (
        <div className="upload-progress">
          <div className="progress-bar">
            <div
              className="progress-fill"
              style={{ width: `${progress.percentage}%` }}
            />
          </div>
          <p>
            Uploading: {progress.percentage}% ({formatBytes(progress.bytesUploaded)} / {formatBytes(progress.bytesTotal)})
          </p>
          <button onClick={cancel}>Cancel</button>
        </div>
      )}

      {error && (
        <div className="error">
          Upload failed: {error.message}
        </div>
      )}
    </div>
  );
}

function formatBytes(bytes: number): string {
  if (bytes === 0) return '0 Bytes';
  const k = 1024;
  const sizes = ['Bytes', 'KB', 'MB', 'GB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  return Math.round(bytes / Math.pow(k, i) * 100) / 100 + ' ' + sizes[i];
}
```

---

### 6.4 Poll Document Status

**File:** `apps/mule-spa/src/hooks/useDocumentStatus.ts`

```typescript
import { useState, useEffect } from 'react';

interface DocumentStatus {
  id: string;
  status: 'pending_upload' | 'processing' | 'completed' | 'failed';
  chunk_count?: number;
  processing_error?: string;
}

export function useDocumentStatus(documentId: string | null) {
  const [status, setStatus] = useState<DocumentStatus | null>(null);
  const [isLoading, setIsLoading] = useState(false);

  useEffect(() => {
    if (!documentId) return;

    setIsLoading(true);

    const pollStatus = async () => {
      try {
        const response = await fetch(`/api/v1/documents/${documentId}`);
        const data = await response.json();
        setStatus(data);

        // Stop polling if completed or failed
        if (data.status === 'completed' || data.status === 'failed') {
          setIsLoading(false);
        }
      } catch (error) {
        console.error('Failed to fetch document status:', error);
        setIsLoading(false);
      }
    };

    // Poll every 2 seconds
    const interval = setInterval(pollStatus, 2000);
    pollStatus(); // Initial fetch

    return () => clearInterval(interval);
  }, [documentId]);

  return { status, isLoading };
}
```

---

### 6.5 Complete Upload Flow Component

**File:** `apps/mule-spa/src/components/DocumentUploadFlow.tsx`

```typescript
import React, { useState } from 'react';
import { DocumentUpload } from './DocumentUpload';
import { useDocumentStatus } from '../hooks/useDocumentStatus';

interface DocumentUploadFlowProps {
  kbId: string;
}

export function DocumentUploadFlow({ kbId }: DocumentUploadFlowProps) {
  const [documentId, setDocumentId] = useState<string | null>(null);
  const { status } = useDocumentStatus(documentId);

  const handleUploadComplete = (docId: string) => {
    setDocumentId(docId);
  };

  return (
    <div className="upload-flow">
      <h2>Upload Document</h2>

      {!documentId && (
        <DocumentUpload kbId={kbId} onUploadComplete={handleUploadComplete} />
      )}

      {documentId && status && (
        <div className="processing-status">
          {status.status === 'pending_upload' && (
            <p>⏳ Upload complete. Waiting for processing...</p>
          )}

          {status.status === 'processing' && (
            <div>
              <p>⚙️ Processing document...</p>
              <p className="text-sm">Extracting text, chunking, and generating embeddings</p>
            </div>
          )}

          {status.status === 'completed' && (
            <div className="success">
              <p>✅ Document processed successfully!</p>
              <p>Created {status.chunk_count} searchable chunks</p>
              <button onClick={() => setDocumentId(null)}>
                Upload Another
              </button>
            </div>
          )}

          {status.status === 'failed' && (
            <div className="error">
              <p>❌ Processing failed</p>
              <p>{status.processing_error}</p>
              <button onClick={() => setDocumentId(null)}>
                Try Again
              </button>
            </div>
          )}
        </div>
      )}
    </div>
  );
}
```

---

### 6.6 WebSocket Alternative (Optional)

For real-time updates instead of polling:

**File:** `apps/mule-spa/src/hooks/useDocumentStatusWebSocket.ts`

```typescript
import { useState, useEffect } from 'react';

export function useDocumentStatusWebSocket(documentId: string | null) {
  const [status, setStatus] = useState<any>(null);

  useEffect(() => {
    if (!documentId) return;

    const ws = new WebSocket(`ws://localhost:8000/ws/documents/${documentId}`);

    ws.onmessage = (event) => {
      const data = JSON.parse(event.data);
      setStatus(data);
    };

    ws.onerror = (error) => {
      console.error('WebSocket error:', error);
    };

    return () => {
      ws.close();
    };
  }, [documentId]);

  return { status };
}
```

---

### 6.7 Testing

#### Unit Tests

**File:** `apps/mule-spa/src/hooks/useDocumentUpload.test.ts`

```typescript
import { renderHook, act } from '@testing-library/react-hooks';
import { useDocumentUpload } from './useDocumentUpload';

describe('useDocumentUpload', () => {
  it('should upload file successfully', async () => {
    const { result } = renderHook(() => useDocumentUpload());

    const file = new File(['test content'], 'test.pdf', {
      type: 'application/pdf',
    });

    let documentId: string;
    await act(async () => {
      documentId = await result.current.upload(file, 'kb-123');
    });

    expect(documentId).toBeDefined();
    expect(result.current.isUploading).toBe(false);
  });

  it('should track upload progress', async () => {
    const { result } = renderHook(() => useDocumentUpload());

    const file = new File(['test content'], 'test.pdf', {
      type: 'application/pdf',
    });

    await act(async () => {
      result.current.upload(file, 'kb-123');
    });

    expect(result.current.progress).toBeDefined();
    expect(result.current.progress?.percentage).toBeGreaterThanOrEqual(0);
  });
});
```

---

### 6.8 Success Criteria

- [ ] TUS client installed
- [ ] Upload hook implemented
- [ ] Upload component created
- [ ] Status polling works
- [ ] Progress tracking works
- [ ] Error handling works
- [ ] Cancel upload works
- [ ] UI/UX is intuitive
- [ ] Tests pass

---

### 6.9 Deliverables

1. TUS upload integration
2. React hooks for upload and status
3. Upload UI components
4. Unit tests
5. User documentation

---

## Testing Strategy

### 7.1 Unit Testing

#### Cortex API Tests
```bash
cd services/cortex
pytest tests/test_api/test_documents.py -v
pytest tests/test_services/test_document_service.py -v
```

#### Forge API Tests
```bash
cd api/forge
npm test
```

#### Frontend Tests
```bash
cd apps/mule-spa
npm test
```

---

### 7.2 Integration Testing

#### End-to-End Upload Flow

**Test Script:** `tests/e2e/test_upload_flow.py`

```python
import pytest
import requests
from pathlib import Path

def test_complete_upload_flow():
    """Test complete document upload and processing flow"""
    
    # 1. Create knowledge base
    kb_response = requests.post(
        "http://localhost:8000/api/v1/knowledge-bases",
        json={"name": "Test KB", "description": "Test"}
    )
    kb_id = kb_response.json()["id"]
    
    # 2. Initiate upload
    test_file = Path("test_data/sample.pdf")
    initiate_response = requests.post(
        f"http://localhost:8000/api/v1/knowledge-bases/{kb_id}/documents/initiate-upload",
        json={
            "filename": "sample.pdf",
            "content_type": "application/pdf",
            "file_size": test_file.stat().st_size
        }
    )
    assert initiate_response.status_code == 201
    data = initiate_response.json()
    document_id = data["document_id"]
    upload_url = data["upload_url"]
    
    # 3. Upload file via TUS
    # (Use tus-py-client or similar)
    
    # 4. Wait for processing
    import time
    max_wait = 60
    start = time.time()
    
    while time.time() - start < max_wait:
        status_response = requests.get(
            f"http://localhost:8000/api/v1/documents/{document_id}"
        )
        status = status_response.json()["status"]
        
        if status == "completed":
            break
        elif status == "failed":
            pytest.fail(f"Processing failed: {status_response.json()}")
        
        time.sleep(2)
    
    assert status == "completed"
    
    # 5. Verify chunks created
    doc_response = requests.get(
        f"http://localhost:8000/api/v1/documents/{document_id}"
    )
    assert doc_response.json()["chunk_count"] > 0
    
    # 6. Test search
    search_response = requests.post(
        f"http://localhost:8000/api/v1/knowledge-bases/{kb_id}/search",
        json={"query": "test query", "limit": 5}
    )
    assert search_response.status_code == 200
    assert len(search_response.json()["results"]) > 0
```

---

### 7.3 Performance Testing

#### Load Test Script

```python
import asyncio
import aiohttp
from pathlib import Path

async def upload_document(session, kb_id, file_path):
    """Upload a single document"""
    # Initiate
    async with session.post(
        f"http://localhost:8000/api/v1/knowledge-bases/{kb_id}/documents/initiate-upload",
        json={
            "filename": file_path.name,
            "content_type": "application/pdf",
            "file_size": file_path.stat().st_size
        }
    ) as response:
        data = await response.json()
        return data["document_id"]

async def load_test(num_concurrent=10):
    """Test concurrent uploads"""
    async with aiohttp.ClientSession() as session:
        tasks = []
        for i in range(num_concurrent):
            task = upload_document(session, "kb-id", Path(f"test_{i}.pdf"))
            tasks.append(task)
        
        results = await asyncio.gather(*tasks)
        print(f"Uploaded {len(results)} documents")

# Run: asyncio.run(load_test(10))
```

---

### 7.4 Manual Testing Checklist

- [ ] Upload PDF file
- [ ] Upload DOCX file
- [ ] Upload TXT file
- [ ] Upload large file (>10MB)
- [ ] Cancel upload mid-way
- [ ] Resume interrupted upload
- [ ] Upload with network interruption
- [ ] Upload invalid file type
- [ ] Upload to non-existent KB
- [ ] Verify chunks created
- [ ] Search uploaded document
- [ ] Delete document
- [ ] Check n8n execution logs
- [ ] Verify error handling

---

## Deployment Plan

### 8.1 Pre-Deployment Checklist

- [ ] All tests passing
- [ ] Database migrations ready
- [ ] Environment variables documented
- [ ] n8n workflow exported
- [ ] API documentation updated
- [ ] Monitoring configured
- [ ] Rollback plan prepared

---

### 8.2 Deployment Sequence

#### Step 1: Deploy n8n Workflow
```bash
# Export workflow from dev
curl http://localhost:5678/api/v1/workflows/{id} > workflow.json

# Import to production n8n
curl -X POST http://prod-n8n:5678/api/v1/workflows \
  -H "Content-Type: application/json" \
  -d @workflow.json

# Get production workflow ID
PROD_WORKFLOW_ID=<new-id>
```

#### Step 2: Deploy Cortex API
```bash
cd services/cortex

# Run migrations
alembic upgrade head

# Deploy service
docker build -t cortex:latest .
docker push cortex:latest

# Update environment
kubectl set env deployment/cortex \
  FORGE_API_URL=https://forge.prod.example.com \
  FORGE_API_KEY=$FORGE_API_KEY
```

#### Step 3: Deploy Forge API
```bash
cd api/forge

# Build and deploy
docker build -t forge:latest .
docker push forge:latest

# Update environment
kubectl set env deployment/forge \
  HELIX_API_URL=https://helix.prod.example.com \
  HELIX_API_KEY=$HELIX_API_KEY \
  DOCUMENT_PROCESSING_WORKFLOW_ID=$PROD_WORKFLOW_ID
```

#### Step 4: Deploy Frontend
```bash
cd apps/mule-spa

# Build
npm run build

# Deploy
aws s3 sync dist/ s3://app-bucket/
aws cloudfront create-invalidation --distribution-id $DIST_ID --paths "/*"
```

---

### 8.3 Post-Deployment Verification

```bash
# Test upload flow
curl -X POST https://api.prod.example.com/api/v1/knowledge-bases/{kb_id}/documents/initiate-upload \
  -H "Content-Type: application/json" \
  -d '{"filename": "test.pdf", "content_type": "application/pdf", "file_size": 1024}'

# Check n8n workflow
curl https://helix.prod.example.com/api/n8n/workflows/$PROD_WORKFLOW_ID

# Monitor logs
kubectl logs -f deployment/cortex
kubectl logs -f deployment/forge
```

---

### 8.4 Monitoring

#### Metrics to Track
- Upload success rate
- Processing time per document
- n8n workflow execution time
- Error rate by stage
- Storage usage
- API response times

#### Alerts
- Upload failure rate > 5%
- Processing time > 5 minutes
- n8n workflow failures
- Storage quota exceeded

---

### 8.5 Rollback Plan

If issues occur:

1. **Disable new upload flow**
   ```bash
   # Feature flag in Cortex
   kubectl set env deployment/cortex ENABLE_TUS_UPLOAD=false
   ```

2. **Revert to previous version**
   ```bash
   kubectl rollout undo deployment/cortex
   kubectl rollout undo deployment/forge
   ```

3. **Rollback database**
   ```bash
   cd services/cortex
   alembic downgrade -1
   ```

---

## Summary

### Implementation Timeline

| Phase | Duration | Dependencies |
|-------|----------|--------------|
| Phase 1: n8n Workflow | 2-3 days | None |
| Phase 2: Cortex Endpoints | 1-2 days | Phase 1 |
| Phase 3: Client Libraries | 1 day | None |
| Phase 4: Forge Integration | 1 day | Phase 1, 3 |
| Phase 5: Cortex Upload Flow | 1-2 days | Phase 3 |
| Phase 6: Frontend | 2-3 days | Phase 5 |
| Testing & QA | 2-3 days | All phases |
| **Total** | **10-15 days** | |

### Key Milestones

1. ✅ n8n workflow processes documents
2. ✅ Cortex endpoints work
3. ✅ Forge triggers workflow
4. ✅ End-to-end upload works
5. ✅ Frontend integrated
6. ✅ Production deployed

---

