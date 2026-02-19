# Forge-Cortex Integration Implementation Spec

## Document Information
- **Version:** 1.0.0
- **Date:** 2025-11-27
- **Status:** Draft
- **Owner:** Development Team

## Table of Contents
1. [Overview](#overview)
2. [Phase 1: n8n Workflow Development](#phase-1-n8n-workflow-development)
3. [Phase 2: Cortex API Endpoints](#phase-2-cortex-api-endpoints)
4. [Phase 3: Client Libraries](#phase-3-client-libraries)
5. [Phase 4: Forge Integration](#phase-4-forge-integration)
6. [Phase 5: Cortex Upload Flow](#phase-5-cortex-upload-flow)
7. [Phase 6: Frontend Integration](#phase-6-frontend-integration)
8. [Testing Strategy](#testing-strategy)
9. [Deployment Plan](#deployment-plan)

---

## Overview

### Goal
Integrate Forge Storage API (TUS uploads) with Cortex Knowledge Base API using n8n workflow automation for document processing.

### Architecture Summary
```
Client → Cortex (initiate) → Forge (TUS upload) → Helix (trigger) → 
n8n (process) → Cortex (store chunks)
```

### Key Components
- **Forge API**: File storage with TUS resumable uploads
- **Cortex API**: Knowledge base management with vector search
- **Helix API**: n8n workflow automation integration
- **n8n**: Visual workflow automation platform

### Success Criteria
- [ ] Documents upload via TUS protocol
- [ ] Automatic processing after upload
- [ ] Text extraction from PDF/DOCX/TXT
- [ ] Chunking and embedding generation
- [ ] Searchable documents in knowledge base
- [ ] Error handling and retry logic
- [ ] Monitoring and logging

---

## Phase 1: n8n Workflow Development

### Priority: HIGH
### Estimated Effort: 2-3 days
### Dependencies: Helix API (already exists)

### Objective
Build and test document processing workflow in n8n that can:
1. Download files from Forge
2. Extract text from various formats
3. Chunk text into segments
4. Generate embeddings via OpenAI
5. Store chunks in Cortex
6. Handle errors gracefully

---

### 1.1 Workflow Setup

#### Access n8n Instance
```bash
# Via Helix API
GET http://localhost:4005/api/n8n/workflows

# Or directly (if exposed)
http://localhost:5678
```

#### Create New Workflow
- **Name:** `Document Processing Pipeline`
- **Description:** `Processes uploaded documents: extract → chunk → embed → store`
- **Tags:** `cortex`, `knowledge-base`, `document-processing`

---

### 1.2 Workflow Nodes Configuration

#### Node 1: Webhook Trigger
**Type:** Webhook  
**Purpose:** Receive trigger from Helix/Forge after upload completes

**Configuration:**
```json
{
  "httpMethod": "POST",
  "path": "document-processing",
  "responseMode": "onReceived",
  "authentication": "headerAuth"
}
```

**Expected Payload:**
```json
{
  "document_id": "uuid",
  "file_id": "uuid",
  "kb_id": "uuid",
  "storage_path": "string",
  "filename": "string",
  "content_type": "string"
}
```

**Output:**
- `document_id`: UUID
- `file_id`: UUID
- `kb_id`: UUID
- `storage_path`: string
- `filename`: string
- `content_type`: string

---

#### Node 2: Update Status - Processing
**Type:** HTTP Request  
**Purpose:** Update document status in Cortex to PROCESSING

**Configuration:**
```json
{
  "method": "PATCH",
  "url": "={{$env.CORTEX_API_URL}}/api/v1/documents/{{$json.document_id}}/status",
  "authentication": "predefinedCredentialType",
  "nodeCredentialType": "cortexApi",
  "sendHeaders": true,
  "headerParameters": {
    "parameters": [
      {
        "name": "Content-Type",
        "value": "application/json"
      }
    ]
  },
  "sendBody": true,
  "bodyParameters": {
    "parameters": [
      {
        "name": "status",
        "value": "processing"
      }
    ]
  }
}
```

**Error Handling:**
- Retry: 3 times
- Retry interval: 5 seconds
- On failure: Go to Error Handler node

---

#### Node 3: Download File from Forge
**Type:** HTTP Request  
**Purpose:** Download file content from Forge API

**Configuration:**
```json
{
  "method": "GET",
  "url": "={{$env.FORGE_API_URL}}/api/v1/files/{{$json.file_id}}/download",
  "authentication": "predefinedCredentialType",
  "nodeCredentialType": "forgeApi",
  "responseFormat": "file"
}
```

**Output:**
- `data`: Binary file data
- `filename`: Original filename
- `mimeType`: Content type

**Error Handling:**
- Retry: 3 times
- On failure: Go to Error Handler node

---

#### Node 4: Detect File Type
**Type:** Code (JavaScript)  
**Purpose:** Determine file type and route to appropriate extractor

**Code:**
```javascript
const mimeType = $input.item.json.mimeType || '';
const filename = $input.item.json.filename || '';

let fileType = 'unknown';

if (mimeType.includes('pdf') || filename.endsWith('.pdf')) {
  fileType = 'pdf';
} else if (mimeType.includes('word') || filename.endsWith('.docx') || filename.endsWith('.doc')) {
  fileType = 'docx';
} else if (mimeType.includes('text') || filename.endsWith('.txt')) {
  fileType = 'txt';
} else if (filename.endsWith('.md')) {
  fileType = 'markdown';
}

return {
  json: {
    ...($input.item.json),
    fileType: fileType
  }
};
```

**Output:**
- All previous data
- `fileType`: 'pdf' | 'docx' | 'txt' | 'markdown' | 'unknown'

---

#### Node 5: Switch - Route by File Type
**Type:** Switch  
**Purpose:** Route to appropriate text extraction node

**Rules:**
1. If `fileType === 'pdf'` → Go to Extract PDF
2. If `fileType === 'docx'` → Go to Extract DOCX
3. If `fileType === 'txt'` → Go to Extract TXT
4. If `fileType === 'markdown'` → Go to Extract Markdown
5. Default → Go to Error Handler (unsupported type)

---

#### Node 6a: Extract PDF Text
**Type:** Code (JavaScript)  
**Purpose:** Extract text from PDF files

**Dependencies:**
```bash
# Install in n8n
npm install pdf-parse
```

**Code:**
```javascript
const pdf = require('pdf-parse');

const items = [];

for (const item of $input.all()) {
  const buffer = Buffer.from(item.binary.data);
  
  try {
    const data = await pdf(buffer);
    
    items.push({
      json: {
        document_id: item.json.document_id,
        file_id: item.json.file_id,
        kb_id: item.json.kb_id,
        filename: item.json.filename,
        rawText: data.text,
        pageCount: data.numpages,
        extractedAt: new Date().toISOString()
      }
    });
  } catch (error) {
    throw new Error(`PDF extraction failed: ${error.message}`);
  }
}

return items;
```

---

#### Node 6b: Extract DOCX Text
**Type:** Code (JavaScript)  
**Purpose:** Extract text from DOCX files

**Dependencies:**
```bash
npm install mammoth
```

**Code:**
```javascript
const mammoth = require('mammoth');

const items = [];

for (const item of $input.all()) {
  const buffer = Buffer.from(item.binary.data);
  
  try {
    const result = await mammoth.extractRawText({ buffer });
    
    items.push({
      json: {
        document_id: item.json.document_id,
        file_id: item.json.file_id,
        kb_id: item.json.kb_id,
        filename: item.json.filename,
        rawText: result.value,
        extractedAt: new Date().toISOString()
      }
    });
  } catch (error) {
    throw new Error(`DOCX extraction failed: ${error.message}`);
  }
}

return items;
```

---

#### Node 6c: Extract TXT/Markdown
**Type:** Code (JavaScript)  
**Purpose:** Read plain text files

**Code:**
```javascript
const items = [];

for (const item of $input.all()) {
  const buffer = Buffer.from(item.binary.data);
  const text = buffer.toString('utf-8');
  
  items.push({
    json: {
      document_id: item.json.document_id,
      file_id: item.json.file_id,
      kb_id: item.json.kb_id,
      filename: item.json.filename,
      rawText: text,
      extractedAt: new Date().toISOString()
    }
  });
}

return items;
```

---

#### Node 7: Clean Text
**Type:** Code (JavaScript)  
**Purpose:** Normalize and clean extracted text

**Code:**
```javascript
function cleanText(text) {
  // Remove excessive whitespace
  text = text.replace(/\s+/g, ' ');
  
  // Remove special characters but keep punctuation
  text = text.replace(/[^\w\s.,!?;:()\-'"]/g, '');
  
  // Normalize line breaks
  text = text.replace(/\n{3,}/g, '\n\n');
  
  // Trim
  text = text.trim();
  
  return text;
}

const items = [];

for (const item of $input.all()) {
  const cleanedText = cleanText(item.json.rawText);
  
  items.push({
    json: {
      ...item.json,
      cleanedText: cleanedText,
      characterCount: cleanedText.length
    }
  });
}

return items;
```

---

#### Node 8: Chunk Text
**Type:** Code (JavaScript)  
**Purpose:** Split text into overlapping chunks

**Configuration:**
- Chunk size: 500 tokens (~2000 characters)
- Overlap: 50 tokens (~200 characters)

**Code:**
```javascript
function chunkText(text, chunkSize = 2000, overlap = 200) {
  const chunks = [];
  let start = 0;
  
  while (start < text.length) {
    const end = Math.min(start + chunkSize, text.length);
    const chunk = text.substring(start, end);
    
    chunks.push(chunk);
    
    // Move start position with overlap
    start = end - overlap;
    
    // Prevent infinite loop
    if (start >= text.length - overlap) break;
  }
  
  return chunks;
}

const items = [];

for (const item of $input.all()) {
  const chunks = chunkText(item.json.cleanedText);
  
  chunks.forEach((chunk, index) => {
    items.push({
      json: {
        document_id: item.json.document_id,
        file_id: item.json.file_id,
        kb_id: item.json.kb_id,
        filename: item.json.filename,
        chunk_index: index,
        chunk_content: chunk,
        total_chunks: chunks.length
      }
    });
  });
}

return items;
```

**Output:** Array of chunk items (one per chunk)

---

#### Node 9: Generate Embeddings
**Type:** OpenAI  
**Purpose:** Generate vector embeddings for each chunk

**Configuration:**
```json
{
  "resource": "embedding",
  "operation": "create",
  "model": "text-embedding-3-small",
  "input": "={{$json.chunk_content}}"
}
```

**Credentials:**
- Use OpenAI API key from environment

**Output:**
- Previous data + `embedding`: number[] (1536 dimensions)

---

#### Node 10: Store Chunk in Cortex
**Type:** HTTP Request  
**Purpose:** Store chunk with embedding in Cortex database

**Configuration:**
```json
{
  "method": "POST",
  "url": "={{$env.CORTEX_API_URL}}/api/v1/documents/{{$json.document_id}}/chunks",
  "authentication": "predefinedCredentialType",
  "nodeCredentialType": "cortexApi",
  "sendBody": true,
  "bodyParameters": {
    "parameters": [
      {
        "name": "chunk_index",
        "value": "={{$json.chunk_index}}"
      },
      {
        "name": "content",
        "value": "={{$json.chunk_content}}"
      },
      {
        "name": "embedding",
        "value": "={{$json.embedding}}"
      },
      {
        "name": "metadata",
        "value": {
          "filename": "={{$json.filename}}",
          "total_chunks": "={{$json.total_chunks}}"
        }
      }
    ]
  }
}
```

**Error Handling:**
- Retry: 3 times
- On failure: Continue (log error but don't fail entire workflow)

---

#### Node 11: Aggregate Results
**Type:** Code (JavaScript)  
**Purpose:** Collect all chunk storage results

**Code:**
```javascript
const allItems = $input.all();
const documentId = allItems[0].json.document_id;

const successCount = allItems.filter(item => item.json.statusCode === 200 || item.json.statusCode === 201).length;
const failureCount = allItems.length - successCount;

return [{
  json: {
    document_id: documentId,
    total_chunks: allItems.length,
    successful_chunks: successCount,
    failed_chunks: failureCount,
    success: failureCount === 0
  }
}];
```

---

#### Node 12: Update Status - Completed
**Type:** HTTP Request  
**Purpose:** Mark document as COMPLETED in Cortex

**Configuration:**
```json
{
  "method": "PATCH",
  "url": "={{$env.CORTEX_API_URL}}/api/v1/documents/{{$json.document_id}}/status",
  "authentication": "predefinedCredentialType",
  "nodeCredentialType": "cortexApi",
  "sendBody": true,
  "bodyParameters": {
    "parameters": [
      {
        "name": "status",
        "value": "completed"
      },
      {
        "name": "processed_at",
        "value": "={{new Date().toISOString()}}"
      },
      {
        "name": "chunk_count",
        "value": "={{$json.total_chunks}}"
      }
    ]
  }
}
```

---

#### Node 13: Error Handler
**Type:** Error Trigger  
**Purpose:** Catch any errors in the workflow

**Connected to:** Update Status - Failed

---

#### Node 14: Update Status - Failed
**Type:** HTTP Request  
**Purpose:** Mark document as FAILED in Cortex

**Configuration:**
```json
{
  "method": "PATCH",
  "url": "={{$env.CORTEX_API_URL}}/api/v1/documents/{{$json.document_id}}/status",
  "authentication": "predefinedCredentialType",
  "nodeCredentialType": "cortexApi",
  "sendBody": true,
  "bodyParameters": {
    "parameters": [
      {
        "name": "status",
        "value": "failed"
      },
      {
        "name": "error",
        "value": "={{$json.error.message}}"
      },
      {
        "name": "failed_at",
        "value": "={{new Date().toISOString()}}"
      }
    ]
  }
}
```

---

### 1.3 Workflow Connections

```
Webhook Trigger
  → Update Status (Processing)
    → Download File
      → Detect File Type
        → Switch
          ├─ PDF → Extract PDF → Clean Text
          ├─ DOCX → Extract DOCX → Clean Text
          ├─ TXT → Extract TXT → Clean Text
          └─ Unknown → Error Handler
        
Clean Text
  → Chunk Text
    → Generate Embeddings (loop over chunks)
      → Store Chunk
        → Aggregate Results
          → Update Status (Completed)

Error Handler (catches all errors)
  → Update Status (Failed)
```

---

### 1.4 Environment Variables

Configure in n8n settings or workflow:

```bash
CORTEX_API_URL=http://localhost:8000
FORGE_API_URL=http://localhost:4002
OPENAI_API_KEY=sk-...
```

---

### 1.5 Testing the Workflow

#### Manual Test via Helix API

```bash
# Get workflow ID
curl http://localhost:4005/api/n8n/workflows

# Execute workflow
curl -X POST http://localhost:4005/api/n8n/workflows/{workflow_id}/execute \
  -H "Content-Type: application/json" \
  -d '{
    "document_id": "123e4567-e89b-12d3-a456-426614174000",
    "file_id": "test-file-123",
    "kb_id": "kb-test-456",
    "storage_path": "test/sample.pdf",
    "filename": "sample.pdf",
    "content_type": "application/pdf"
  }'

# Check execution status
curl http://localhost:4005/api/n8n/executions/{execution_id}
```

#### Test Files
Prepare test documents:
- `test-sample.pdf` - Multi-page PDF
- `test-sample.docx` - Word document
- `test-sample.txt` - Plain text
- `test-sample.md` - Markdown file

---

### 1.6 Success Criteria

- [ ] Workflow executes without errors
- [ ] PDF text extraction works
- [ ] DOCX text extraction works
- [ ] TXT/Markdown extraction works
- [ ] Text is properly chunked
- [ ] Embeddings are generated
- [ ] Chunks are stored in Cortex
- [ ] Document status updates correctly
- [ ] Error handling works (test with invalid file)
- [ ] Execution logs are clear and helpful

---

### 1.7 Deliverables

1. Working n8n workflow (exported JSON)
2. Test results documentation
3. Workflow execution screenshots
4. Performance metrics (processing time per document)

---

