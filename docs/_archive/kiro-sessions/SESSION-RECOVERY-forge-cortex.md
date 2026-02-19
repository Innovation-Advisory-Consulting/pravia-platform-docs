# Session Recovery: Forge-Cortex Integration

**Date:** 2025-11-28  
**Status:** Phase 1 - Iteration 2 Complete (with workarounds)  
**Current Workflow ID:** MCG6E8QYPQE8I459 (webhook), yMJF6WCc8JzreXiw (manual)

---

## What We've Done

### ✅ Completed

1. **Architecture & Specs Created**
   - Main architecture doc: `.kiro/forge-cortex-integration.md`
   - Implementation specs (5 parts): `.kiro/forge-cortex-implementation-spec*.md`
   - Integration tests: `.kiro/integration-tests-phase*.md`

2. **Phase 1 - Iteration 1: Basic Flow**
   - ✅ Created n8n workflow in n8n (ID: `MCG6E8QYPQE8I459`)
   - ✅ Added Cortex API endpoints:
     - `PATCH /api/v1/documents/{doc_id}/status`
     - `POST /api/v1/documents/{doc_id}/chunks`
   - ✅ Added `DocumentService.get_by_id()` method
   - ✅ Fixed Helix CreateWorkflowDto (added default `settings`)

3. **Files Modified**
   - `services/cortex/app/api/v1/endpoints/documents.py` - Added status & chunk endpoints
   - `services/cortex/app/services/document_service.py` - Added get_by_id method
   - `api/helix/src/modules/n8n/dto/create-workflow.dto.ts` - Added default settings
   - `services/cortex/workflows/document-processing-simple.json` - Workflow JSON
   - `services/cortex/workflows/README.md` - Quick start guide
   - `services/cortex/workflows/test-iteration-1.sh` - Test script

---

## Current n8n Workflow

**ID:** `MCG6E8QYPQE8I459`  
**Name:** Cortex Doc Processing  
**Webhook:** http://localhost:5678/webhook/cortex-doc

**Nodes:**
1. Webhook (receives trigger)
2. Update Status (sets to PROCESSING)

**What it does:**
- Receives document_id
- Updates document status to PROCESSING in Cortex

---

## How to Continue

### Test Current Setup

```bash
# 1. Start Cortex
cd services/cortex
poetry run uvicorn app.main:app --reload

# 2. Create a test document in Cortex
curl -X POST http://localhost:8000/api/v1/knowledge-bases/{kb_id}/documents \
  -H "Content-Type: application/json" \
  -d '{
    "filename": "test.pdf",
    "content_type": "application/pdf",
    "content": "test content"
  }'
# Note the document_id from response

# 3. Test the workflow
curl -X POST http://localhost:5678/webhook/cortex-doc \
  -H "Content-Type: application/json" \
  -d '{"document_id":"<document_id>","text":"Hello world"}'

# 4. Check document status
curl http://localhost:8000/api/v1/documents/<document_id>
# Should show status: "processing"
```

---

## Next Iterations (Phase 1)

### Iteration 2: Add Text Chunking
**Goal:** Split text into chunks and store them

**Add to workflow:**
- Code node: Chunk text (2000 chars, 200 overlap)
- HTTP Request node: Store each chunk

**Test:**
```bash
curl -X POST http://localhost:5678/webhook/cortex-doc \
  -d '{"document_id":"test-123","text":"Long text here..."}'
```

### Iteration 3: Add File Download
**Goal:** Download file from Forge

**Add to workflow:**
- HTTP Request node: GET from Forge
- Update webhook to accept file_id

**Test:**
```bash
# Upload file to Forge first
curl -X POST http://localhost:4002/api/v1/files/upload -F "file=@test.pdf"
# Note file_id

# Trigger workflow
curl -X POST http://localhost:5678/webhook/cortex-doc \
  -d '{"document_id":"test-123","file_id":"<file_id>"}'
```

### Iteration 4: Add PDF Extraction
**Goal:** Extract text from PDF files

**Add to workflow:**
- Code node with pdf-parse library
- Switch node for file type detection

**Install in n8n:**
```bash
# In n8n container
npm install pdf-parse mammoth
```

### Iteration 5: Add OpenAI Embeddings
**Goal:** Generate real embeddings

**Add to workflow:**
- OpenAI node for embeddings
- Update Store Chunk to use real embeddings

**Configure:**
- Add OPENAI_API_KEY to n8n environment

### Iteration 6: Add Error Handling
**Goal:** Handle failures gracefully

**Add to workflow:**
- Error Trigger node
- Update Status - Failed node

---

## Key URLs

- **n8n UI:** http://localhost:5678
- **Workflow:** http://localhost:5678/workflow/MCG6E8QYPQE8I459
- **Cortex API:** http://localhost:8000
- **Cortex Docs:** http://localhost:8000/api/v1/docs
- **Helix API:** http://localhost:4005
- **Forge API:** http://localhost:4002

---

## Environment Variables

### Cortex (.env)
```bash
DATABASE_URL=postgresql://...
SUPABASE_URL=...
SUPABASE_ANON_KEY=...
OPENAI_API_KEY=sk-...
```

### Helix (.env)
```bash
N8N_URL=http://localhost:5678
N8N_API_KEY=n8n_api_5062da57e48d9aff7119232c98d59e31591da9e9c1378b04015c5a0ea87837ff65a325bd6e3205e1
```

### n8n (Environment Variables in UI)
```bash
CORTEX_API_URL=http://host.docker.internal:8000
FORGE_API_URL=http://host.docker.internal:4002
OPENAI_API_KEY=sk-...
```

---

## Troubleshooting

### Workflow not triggering
```bash
# Check workflow is active
curl http://localhost:4005/api/n8n/workflows/MCG6E8QYPQE8I459

# Check webhook URL
curl http://localhost:5678/webhook/cortex-doc
```

### Cortex endpoints not working
```bash
# Check Cortex is running
curl http://localhost:8000/api/v1/health

# Check document exists
curl http://localhost:8000/api/v1/documents/<doc_id>
```

### n8n API errors
```bash
# Check Helix can reach n8n
curl http://localhost:4005/api/n8n/workflows

# Check n8n API key
echo $N8N_API_KEY
```

---

## Quick Commands

```bash
# View workflow in n8n
open http://localhost:5678/workflow/MCG6E8QYPQE8I459

# Test Cortex endpoints
cd services/cortex/workflows
chmod +x test-iteration-1.sh
./test-iteration-1.sh

# Create new workflow via Helix
curl -X POST http://localhost:4005/api/n8n/workflows \
  -H "Content-Type: application/json" \
  -d '{"name":"New Workflow","nodes":[],"connections":{}}'

# Update workflow
curl -X PUT http://localhost:4005/api/n8n/workflows/MCG6E8QYPQE8I459 \
  -H "Content-Type: application/json" \
  -d @services/cortex/workflows/document-processing-simple.json

# Execute workflow
curl -X POST http://localhost:4005/api/n8n/workflows/MCG6E8QYPQE8I459/execute \
  -d '{"document_id":"test"}'

# Check execution
curl http://localhost:4005/api/n8n/executions/<execution_id>
```

---

## Code Locations

### Cortex Endpoints
- File: `services/cortex/app/api/v1/endpoints/documents.py`
- Lines: ~140-200 (new endpoints at end)

### Cortex Service
- File: `services/cortex/app/services/document_service.py`
- Method: `get_by_id(doc_id)` added

### Helix DTO
- File: `api/helix/src/modules/n8n/dto/create-workflow.dto.ts`
- Change: Added default values for settings, nodes, connections

### n8n Workflow
- File: `services/cortex/workflows/document-processing-simple.json`
- Current ID: `MCG6E8QYPQE8I459`

---

## Database Schema (Future)

### Documents Table
```sql
ALTER TABLE documents ADD COLUMN forge_file_id VARCHAR;
ALTER TABLE documents ADD COLUMN chunk_count INTEGER;
ALTER TABLE documents ALTER COLUMN storage_path DROP NOT NULL;
```

### Document Status Enum
```sql
ALTER TYPE documentstatus ADD VALUE 'pending_upload';
```

---

## Webhook Test Story

**Created Testing Tools:**

1. **Storybook Component** (Recommended)
   - File: `packages/ui/src/views/workflow-builder/WebhookTest.stories.tsx`
   - Component: `packages/ui/src/views/workflow-builder/components/webhook-tester.tsx`
   - URL: http://localhost:6006/?path=/story/views-workflow-builder-webhook-test--cortex-document
   - Features:
     - Visual webhook testing
     - Pre-filled with test document ID
     - Shows response in real-time
     - Reusable component for any webhook

2. **Testing Guide**
   - File: `services/cortex/workflows/TESTING.md`
   - Contains 3 testing methods:
     - Storybook UI (easiest)
     - Manual n8n workflow
     - Direct API calls

**How to Test:**
```bash
# Open Storybook
open http://localhost:6006/?path=/story/views-workflow-builder-webhook-test--cortex-document

# Or use manual workflow
open http://localhost:5678/workflow/yMJF6WCc8JzreXiw
```

## Next Session Checklist

- [x] Add chunking node to workflow
- [x] Create webhook test UI
- [ ] Fix webhook registration issue OR use manual trigger
- [ ] Test current workflow works end-to-end
- [ ] Add file download from Forge
- [ ] Add PDF extraction
- [ ] Add OpenAI embeddings
- [ ] Add error handling
- [ ] Run integration tests

---

## Important Notes

1. **Workflow ID:** Always use `MCG6E8QYPQE8I459` for current workflow
2. **Helix DTO Fix:** The CreateWorkflowDto now has default `settings: {}` - this was the blocker
3. **n8n URLs:** Use `host.docker.internal` instead of `localhost` in workflow nodes
4. **Iteration Approach:** Build incrementally, test each addition before moving on
5. **No Auth Yet:** Cortex endpoints don't require auth for testing (add later)

---

## Resources

- Architecture: `.kiro/forge-cortex-integration.md`
- Specs: `.kiro/forge-cortex-implementation-spec-part*.md`
- Tests: `.kiro/integration-tests-phase*.md`
- This doc: `.kiro/SESSION-RECOVERY-forge-cortex.md`
