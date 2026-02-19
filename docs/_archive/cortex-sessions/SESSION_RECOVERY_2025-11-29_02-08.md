# Session Recovery - E2E Testing Phase

**Date:** 2025-11-29 02:08 AM
**Status:** E2E Test Ready - Troubleshooting n8n Webhook

## Current State

### ✅ Completed & Committed
1. **Complete document ingestion pipeline** - All code implemented
2. **Celery background processing** - Working with memory broker
3. **Token-aware chunking** - Using tiktoken + langchain
4. **OpenAI embeddings** - Integrated and configured
5. **Startup script** - `start_with_worker.sh` runs API + Celery together
6. **E2E test script** - `test_e2e.sh` ready to run
7. **Integration tests** - 5/5 chunking tests passing

### 🔧 Current Issue
**n8n webhook returning empty response**

- Workflow ID: `FOtwVCIi9j4iAVTZ`
- Workflow Name: "Document Ingestion Pipeline"
- Webhook URL: `http://localhost:5678/webhook/document-ingest`
- Status: Active (but not responding)

### Services Running
- ✅ Forge API (port 4002)
- ✅ Cortex API (port 4005)
- ✅ Celery Worker (running with Cortex)
- ✅ n8n (port 5678)
- ✅ PostgreSQL database
- ✅ OpenAI API key configured

## E2E Test Progress

**Test Script:** `services/cortex/test_e2e.sh`

**Steps Completed:**
1. ✅ Service health checks
2. ✅ Get/create knowledge base
3. ✅ Create test file
4. ✅ Upload to Forge (TUS protocol)
5. ❌ Trigger n8n workflow (returns empty)
6. ⏸️ Wait for processing
7. ⏸️ Verify chunks
8. ⏸️ Cleanup

**Last Test Output:**
```
✅ Forge API running
✅ Cortex API running
✅ Using KB: e643199e-a2fb-4fa9-910b-5606eb883483
✅ Created test file: 574 bytes
✅ Upload created: http://localhost:4002/5e87b85beb4ab6f4cdbc526b9f511486
✅ File uploaded successfully
❌ Failed to trigger workflow
Response: (empty)
```

## Troubleshooting Steps

### Check Workflow Status
```bash
curl -s http://localhost:4004/api/n8n/workflows/FOtwVCIi9j4iAVTZ | jq '{id, name, active}'
# Result: active: true
```

### Test Webhook Directly
```bash
curl -s -X POST http://localhost:5678/webhook/document-ingest \
  -H "Content-Type: application/json" \
  -d '{"test": true}'
# Result: (empty response)
```

### Possible Causes
1. **Webhook not registered** - n8n needs restart
2. **Workflow error** - Check n8n logs
3. **Cortex API endpoint mismatch** - Workflow calling wrong URL
4. **Network issue** - Docker networking problem

## Quick Recovery Commands

### Restart Services
```bash
# Kill Cortex
lsof -ti:4005 | xargs kill -9

# Start Cortex + Celery
cd services/cortex
./start_with_worker.sh

# Check n8n
docker ps | grep n8n
docker restart n8n  # If needed
```

### Reactivate Workflow
```bash
# Deactivate
curl -X PATCH http://localhost:4004/api/n8n/workflows/FOtwVCIi9j4iAVTZ/active \
  -H "Content-Type: application/json" \
  -d '{"active": false}'

# Wait 2 seconds
sleep 2

# Reactivate
curl -X PATCH http://localhost:4004/api/n8n/workflows/FOtwVCIi9j4iAVTZ/active \
  -H "Content-Type: application/json" \
  -d '{"active": true}'
```

### Run E2E Test
```bash
cd services/cortex
./test_e2e.sh
```

## Workflow Configuration

**Current Workflow Nodes:**
1. Webhook - Document Ingest (path: `document-ingest`)
2. Ingest Document into Cortex (POST to Cortex API)
3. Respond to Webhook

**Expected Request:**
```json
{
  "document_url": "http://10.0.0.218:4002/api/files/{file_id}",
  "title": "Document Title",
  "knowledgeBaseId": "kb-uuid",
  "originalFilename": "file.txt",
  "mimeType": "text/plain",
  "size": 1024
}
```

**Expected Response:**
```json
{
  "success": true,
  "document_id": "doc-uuid",
  "status": "pending",
  "message": "Document queued for processing"
}
```

## Cortex API Endpoint

**Endpoint:** `POST /api/v1/knowledge-bases/{kb_id}/documents`

**Request Body:**
```json
{
  "title": "string",
  "original_filename": "string",
  "mime_type": "string",
  "size": number,
  "storage_url": "string",
  "tag_ids": ["uuid"] (optional)
}
```

**Response:**
```json
{
  "id": "uuid",
  "status": "pending",
  "message": "Document queued for processing"
}
```

## Files Modified (All Committed)

```
services/cortex/
├── start_with_worker.sh (NEW)
├── test_e2e.sh (NEW)
├── app/
│   ├── celery_config.py
│   ├── tasks/
│   │   ├── __init__.py
│   │   └── document_processing.py
│   ├── api/v1/endpoints/
│   │   └── documents.py
│   ├── services/
│   │   └── document_service.py
│   └── models/db/
│       └── document.py
├── tests/integration/
│   └── test_document_ingestion.py
├── docs/
│   ├── DOCUMENT_INGESTION_FLOW_2025-11-29.md
│   ├── SESSION_RECOVERY_2025-11-29_01-35.md
│   └── SESSION_RECOVERY_2025-11-29_02-08.md (THIS FILE)
├── poetry.lock
└── pyproject.toml
```

## Next Steps

1. **Troubleshoot n8n webhook** - Why is it returning empty?
2. **Check n8n logs** - Look for errors
3. **Verify workflow configuration** - Ensure nodes are correct
4. **Test Cortex endpoint directly** - Bypass n8n
5. **Run E2E test** - Once webhook works

## Test Cortex Endpoint Directly

```bash
# Get KB ID
KB_ID=$(curl -s http://localhost:4005/api/v1/knowledge-bases | jq -r '.items[0].id')

# Upload file to Forge
echo "Test content" > /tmp/test.txt
curl -X POST http://localhost:4002/api/files \
  -H "Upload-Length: $(wc -c < /tmp/test.txt)" \
  -H "Tus-Resumable: 1.0.0" \
  -i | grep Location

# Get file ID and upload content
FILE_ID="<from-location>"
curl -X PATCH http://localhost:4002/api/files/$FILE_ID \
  -H "Content-Type: application/offset+octet-stream" \
  -H "Upload-Offset: 0" \
  -H "Tus-Resumable: 1.0.0" \
  --data-binary @/tmp/test.txt

# Call Cortex directly (bypass n8n)
curl -X POST http://localhost:4005/api/v1/knowledge-bases/$KB_ID/documents \
  -H "Content-Type: application/json" \
  -d "{
    \"title\": \"Direct Test\",
    \"original_filename\": \"test.txt\",
    \"mime_type\": \"text/plain\",
    \"size\": 13,
    \"storage_url\": \"http://localhost:4002/api/files/$FILE_ID\"
  }"

# Should return: {"id": "...", "status": "pending", "message": "..."}
```

## Architecture Diagram

```
UI/Test Script
    ↓
Forge API (4002) - File Upload
    ↓
n8n Webhook (5678) - Trigger ❌ FAILING HERE
    ↓
Cortex API (4005) - Create Document
    ↓
Celery Queue (memory://)
    ↓
Celery Worker - Process Document
    ↓
    ├─ Download from Forge
    ├─ Chunk text (tiktoken)
    ├─ Generate embeddings (OpenAI)
    └─ Store in PostgreSQL
```

## Environment Variables

```bash
# Cortex
OPENAI_API_KEY=sk-proj-...  # ✅ Set
CELERY_BROKER_URL=memory://  # ✅ Default
CELERY_RESULT_BACKEND=rpc://  # ✅ Default

# Database
DATABASE_HOST=localhost
DATABASE_PORT=5432
DATABASE_DB_NAME=nexus_db
```

## Logs to Check

```bash
# Cortex logs
tail -f /tmp/cortex.log

# n8n logs
docker logs n8n --tail 50 -f

# Celery worker logs
# (shown in start_with_worker.sh output)
```

## Success Criteria

E2E test passes all steps:
1. ✅ Services running
2. ✅ KB exists
3. ✅ File created
4. ✅ File uploaded to Forge
5. ✅ Workflow triggered
6. ✅ Document processing completed
7. ✅ Chunks created with embeddings
8. ✅ Cleanup successful

## Contact Points

- Workflow ID: `FOtwVCIi9j4iAVTZ`
- KB ID: `e643199e-a2fb-4fa9-910b-5606eb883483`
- Test script: `services/cortex/test_e2e.sh`
- Startup script: `services/cortex/start_with_worker.sh`
