# Session Recovery - Document Ingestion Implementation

**Date:** 2025-11-29 01:35 AM
**Status:** In Progress - Testing Phase

## What We've Built

### ✅ Completed Components

1. **Celery Background Processing**
   - File: `app/celery_config.py`
   - Memory broker for dev, Valkey for production
   - Task timeout: 5 minutes

2. **Token-Aware Document Chunking**
   - File: `app/tasks/document_processing.py`
   - Uses tiktoken for accurate token counting
   - Chunk size: 1000 tokens, overlap: 200 tokens
   - Splits on natural boundaries (paragraphs, sentences)

3. **Document Processing Task**
   - File: `app/tasks/document_processing.py`
   - Downloads file from Forge
   - Chunks text
   - Generates embeddings via OpenAI API
   - Stores chunks in PostgreSQL with pgvector
   - Updates document status (PENDING → PROCESSING → COMPLETED/FAILED)
   - Retry logic: 3 attempts with exponential backoff

4. **Document Ingestion Endpoint**
   - File: `app/api/v1/endpoints/documents.py`
   - Accepts storage URL instead of content
   - Creates document with PENDING status
   - Queues Celery task
   - Returns immediately

5. **Integration Tests**
   - File: `tests/integration/test_document_ingestion.py`
   - 5 test cases for chunking logic
   - API endpoint tests (requires DB)

6. **Documentation**
   - File: `docs/DOCUMENT_INGESTION_FLOW_2025-11-29.md`
   - Complete Mermaid diagrams
   - Component details
   - Configuration examples

### 📦 Dependencies Added

```txt
celery[redis]==5.3.4
tiktoken==0.8.0
```

### 🔑 Configuration

**OpenAI API Key:** ✅ Configured in `.env`
```
OPENAI_API_KEY=sk-proj-...
```

**Celery Broker (Dev):**
```
CELERY_BROKER_URL=memory://
CELERY_RESULT_BACKEND=rpc://
```

## Current State

### What's Working
- ✅ File upload to Forge (TUS protocol)
- ✅ n8n workflow triggers Cortex API
- ✅ Document record created with PENDING status
- ✅ Celery task queued

### What's NOT Tested Yet
- ❌ Celery worker not started
- ❌ Integration tests not run (venv broken)
- ❌ End-to-end flow not tested

## Next Steps to Continue

### 1. Fix Virtual Environment

```bash
cd /Users/tonyhenderson/Documents/GitHub/faro/pravia-monorepo/services/cortex

# Recreate venv
rm -rf venv
python3 -m venv venv

# Install dependencies
./venv/bin/pip install --upgrade pip
./venv/bin/pip install -r requirements.txt
./venv/bin/pip install -r requirements-dev.txt
```

### 2. Run Integration Tests

```bash
# Test chunking logic (no DB required)
./venv/bin/pytest tests/integration/test_document_ingestion.py::TestDocumentChunking -v

# Expected output: 5 tests pass
```

### 3. Start Celery Worker

```bash
# Terminal 1: Start Cortex API
cd services/cortex
./venv/bin/uvicorn app.main:app --reload --port 4005

# Terminal 2: Start Celery Worker
cd services/cortex
./venv/bin/celery -A app.celery_config worker --loglevel=info
```

### 4. Test End-to-End

```bash
# 1. Upload file to Forge
curl -X POST http://localhost:4002/api/files \
  -H "Upload-Length: 120" \
  -H "Upload-Metadata: filename $(echo -n 'test.txt' | base64)" \
  -H "Tus-Resumable: 1.0.0"

# Get file ID from Location header
FILE_ID="<from-location-header>"

# 2. Upload content
echo "Test document content" > /tmp/test.txt
curl -X PATCH http://localhost:4002/api/files/$FILE_ID \
  -H "Content-Type: application/offset+octet-stream" \
  -H "Upload-Offset: 0" \
  -H "Tus-Resumable: 1.0.0" \
  --data-binary @/tmp/test.txt

# 3. Trigger ingestion via n8n
curl -X POST http://localhost:5678/webhook/document-ingest \
  -H "Content-Type: application/json" \
  -d '{
    "document_url": "http://10.0.0.218:4002/api/files/'$FILE_ID'",
    "title": "Test Document",
    "knowledgeBaseId": "<kb-id>",
    "originalFilename": "test.txt",
    "mimeType": "text/plain",
    "size": 120
  }'

# 4. Check document status
curl http://localhost:4005/api/v1/knowledge-bases/<kb-id>/documents
```

## Files Modified (Not Yet Committed)

```
services/cortex/
├── requirements.txt (added celery, tiktoken)
├── app/
│   ├── celery_config.py (NEW)
│   ├── tasks/
│   │   ├── __init__.py (NEW)
│   │   └── document_processing.py (NEW - FULLY IMPLEMENTED)
│   ├── api/v1/endpoints/
│   │   └── documents.py (MODIFIED - added DocumentIngestRequest)
│   ├── services/
│   │   └── document_service.py (MODIFIED - added create_pending)
│   └── models/db/
│       └── document.py (MODIFIED - added PENDING status)
├── tests/integration/
│   └── test_document_ingestion.py (NEW)
├── docs/
│   ├── DOCUMENT_INGESTION_FLOW_2025-11-29.md (NEW)
│   └── SESSION_RECOVERY_2025-11-29_01-35.md (THIS FILE)
└── run_integration_tests.sh (NEW)
```

## Commit Message (When Ready)

```
feat(cortex): implement complete document ingestion with embeddings

- Add Celery for background processing with memory broker
- Implement token-aware chunking with tiktoken
- Generate embeddings via OpenAI API (text-embedding-3-small)
- Store chunks with embeddings in PostgreSQL/pgvector
- Add PENDING status to document lifecycle
- Update document endpoint to accept storage_url
- Add integration tests for chunking logic
- Add comprehensive documentation with Mermaid diagrams

Completes KB_STEP_11 - Document ingestion now fully functional
```

## Known Issues

1. **Virtual Environment:** Broken symlink, needs recreation
2. **Integration Tests:** Not run yet due to venv issue
3. **Celery Worker:** Not started yet
4. **End-to-End:** Not tested yet

## Architecture Summary

```
UI → Forge (upload) → n8n (trigger) → Cortex API (queue) → Celery Worker
                                                                  ↓
                                                    Download → Chunk → Embed → Store
```

## Key Files to Review

1. `app/tasks/document_processing.py` - Main processing logic
2. `app/api/v1/endpoints/documents.py` - API endpoint
3. `docs/DOCUMENT_INGESTION_FLOW_2025-11-29.md` - Complete flow diagram
4. `tests/integration/test_document_ingestion.py` - Tests

## Environment Variables Required

```bash
# Cortex API
OPENAI_API_KEY=sk-proj-...  # ✅ Already set
CELERY_BROKER_URL=memory://  # Default for dev
CELERY_RESULT_BACKEND=rpc://  # Default for dev

# For production
CELERY_BROKER_URL=redis://valkey:6379/0
```

## Production Deployment (Future)

1. Add Valkey to docker-compose
2. Update CELERY_BROKER_URL env var
3. Start Celery worker container
4. Add monitoring with Flower
5. Configure retry policies
6. Add dead letter queue

## Questions to Answer

- [ ] Do integration tests pass?
- [ ] Does Celery worker start successfully?
- [ ] Does end-to-end flow work?
- [ ] Are embeddings generated correctly?
- [ ] Are chunks stored in database?
- [ ] Does status update to COMPLETED?

## Recovery Commands

```bash
# If session crashes, run these to continue:

# 1. Check what's staged
cd /Users/tonyhenderson/Documents/GitHub/faro/pravia-monorepo
git status

# 2. Review changes
git diff services/cortex/app/tasks/document_processing.py

# 3. Fix venv and test
cd services/cortex
rm -rf venv && python3 -m venv venv
./venv/bin/pip install -r requirements.txt
./venv/bin/pytest tests/integration/test_document_ingestion.py::TestDocumentChunking -v

# 4. If tests pass, commit
git add services/cortex
git commit -m "feat(cortex): implement complete document ingestion with embeddings"
```
