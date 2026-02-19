# End-to-End Workflow Test Results

**Date:** 2025-11-30 17:43 PST  
**Workflow:** Document Ingestion with Text Extraction  
**ID:** eRranIPXytbsdAd3

## Test Summary

✅ **Workflow Structure:** Fixed and validated  
✅ **Network Configuration:** Updated to use Docker gateway (172.17.0.1)  
❌ **End-to-End Test:** Failed - Cortex not accessible from Docker network

## Root Cause

**Cortex is listening on `localhost` only:**
```
TCP localhost:4005 (LISTEN)
```

**Docker containers cannot reach `localhost` of the host machine.**

## Solution

Cortex needs to listen on `0.0.0.0` (all interfaces) instead of `localhost`.

### Current Start Command
```bash
poetry run uvicorn app.main:app --host 0.0.0.0 --port 4005
```

**This should work, but check if it's actually running with `--host 0.0.0.0`**

### Verify Cortex is Accessible

**From host:**
```bash
curl http://localhost:4005/api/v1/tools/pdf_parser/execute \
  -H "Content-Type: application/json" \
  -d '{"parameters": {"file_path": "/tmp/test_workflow.pdf"}}'
```
✅ **Result:** Working

**From Docker network:**
```bash
curl http://172.17.0.1:4005/api/v1/tools/pdf_parser/execute \
  -H "Content-Type: application/json" \
  -d '{"parameters": {"file_path": "/tmp/test_workflow.pdf"}}'
```
❌ **Result:** Connection refused

## Steps to Fix

### 1. Restart Cortex with Correct Host Binding

```bash
cd /Users/tonyhenderson/Documents/GitHub/faro/pravia-monorepo/services/cortex

# Stop current instance
pkill -f "uvicorn app.main:app"

# Start with correct binding
poetry run uvicorn app.main:app --host 0.0.0.0 --port 4005
```

### 2. Verify Cortex is Accessible from Docker

```bash
# Should return success
curl http://172.17.0.1:4005/api/v1/tools/pdf_parser/execute \
  -H "Content-Type: application/json" \
  -d '{"parameters": {"file_path": "/tmp/test_workflow.pdf"}}'
```

### 3. Test Workflow Again

```bash
curl -X POST http://localhost:5678/webhook/document-ingest-extract \
  -H "Content-Type: application/json" \
  -d '{
    "knowledge_base_id": "e2e-test",
    "title": "Test PDF",
    "originalFilename": "test.pdf",
    "mimeType": "application/pdf",
    "size": 1500,
    "document_url": "http://example.com/test.pdf",
    "storage_path": "/tmp/test_workflow.pdf",
    "tag_ids": []
  }'
```

## Expected Flow (Once Fixed)

1. ✅ **Webhook** receives request
2. ✅ **Switch** detects `application/pdf`
3. ✅ **Extract Text from PDF** calls `http://172.17.0.1:4005/api/v1/tools/pdf_parser/execute`
4. ✅ **Ingest PDF Document** calls `http://172.17.0.1:4005/api/v1/knowledge-bases/{kb_id}/documents`
5. ✅ **Respond - PDF** returns success with extracted text length

## Workflow Configuration

**Updated URLs:**
- ✅ Changed from `host.docker.internal:4005` to `172.17.0.1:4005`
- ✅ All HTTP nodes updated
- ✅ Workflow active and ready

## Test Files

**Test PDF:** `/tmp/test_workflow.pdf`
```
Content: "Test Document for n8n Workflow
This PDF contains sample text for extraction testing.
The workflow should extract this text and ingest it into Cortex."
```

## Quick Validation Script

```bash
#!/bin/bash

echo "1. Testing Cortex from host..."
curl -s http://localhost:4005/api/v1/tools/pdf_parser/execute \
  -H "Content-Type: application/json" \
  -d '{"parameters": {"file_path": "/tmp/test_workflow.pdf"}}' | jq '.success'

echo "2. Testing Cortex from Docker network..."
curl -s http://172.17.0.1:4005/api/v1/tools/pdf_parser/execute \
  -H "Content-Type: application/json" \
  -d '{"parameters": {"file_path": "/tmp/test_workflow.pdf"}}' | jq '.success'

echo "3. Testing n8n workflow..."
curl -X POST http://localhost:5678/webhook/document-ingest-extract \
  -H "Content-Type: application/json" \
  -d '{
    "knowledge_base_id": "test",
    "title": "Test",
    "originalFilename": "test.pdf",
    "mimeType": "application/pdf",
    "size": 1500,
    "document_url": "http://example.com/test.pdf",
    "storage_path": "/tmp/test_workflow.pdf",
    "tag_ids": []
  }'

echo "4. Checking execution status..."
sleep 2
curl -s -H "X-N8N-API-KEY: n8n_api_5062da57e48d9aff7119232c98d59e31591da9e9c1378b04015c5a0ea87837ff65a325bd6e3205e1" \
  "http://localhost:5678/api/v1/executions?workflowId=eRranIPXytbsdAd3&limit=1" | \
  jq '.data[0] | {status: .status, finished: .finished}'
```

## Next Actions

1. **Restart Cortex** with `--host 0.0.0.0`
2. **Verify** Cortex is accessible from 172.17.0.1
3. **Test workflow** end-to-end
4. **Validate** all 4 steps complete successfully

## Status

🔴 **Blocked:** Cortex not accessible from Docker network  
✅ **Ready:** Workflow configured and waiting for Cortex fix  
✅ **Validated:** Workflow structure correct, no merge blocking
