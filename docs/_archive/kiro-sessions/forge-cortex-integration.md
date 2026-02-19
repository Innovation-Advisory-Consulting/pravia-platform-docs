# Forge-Cortex Integration Architecture

## Document Upload Flow (with n8n Automation)

```mermaid
sequenceDiagram
    participant Client as Client/Frontend
    participant Cortex as Cortex API<br/>(Python/FastAPI)
    participant Forge as Forge API<br/>(NestJS/TUS)
    participant Storage as Supabase Storage
    participant Helix as Helix API<br/>(n8n Integration)
    participant N8N as n8n Workflow<br/>(Document Processing)

    %% Initiate Upload
    Client->>Cortex: POST /api/v1/knowledge-bases/{kb_id}/documents/initiate
    Note over Client,Cortex: {filename, content_type, metadata}
    
    Cortex->>Cortex: Create document record<br/>(status: PENDING_UPLOAD)
    Cortex->>Forge: POST /api/v1/files/tus/initiate
    Note over Cortex,Forge: {filename, size, content_type}
    
    Forge->>Storage: Reserve storage path
    Forge-->>Cortex: {upload_url, upload_id}
    Cortex-->>Client: {document_id, upload_url, upload_metadata}

    %% Direct Upload via TUS
    Note over Client,Forge: Client uploads directly to Forge using TUS protocol
    Client->>Forge: PATCH {upload_url}<br/>(TUS resumable upload)
    Forge->>Storage: Stream chunks
    Forge-->>Client: Upload progress
    
    Client->>Forge: PATCH {upload_url}<br/>(final chunk)
    Forge->>Storage: Complete upload
    
    %% Trigger n8n Workflow via Helix
    Forge->>Helix: POST /api/n8n/workflows/{workflow_id}/execute
    Note over Forge,Helix: {document_id, file_id, kb_id, storage_path}
    
    Helix->>N8N: Trigger workflow execution
    Helix-->>Forge: 200 Workflow triggered
    Forge-->>Client: 204 Upload Complete

    %% n8n Workflow Processing
    N8N->>Cortex: Update status to PROCESSING
    N8N->>Forge: Download file
    Forge->>Storage: Get file
    Forge-->>N8N: File stream
    
    N8N->>N8N: Extract text<br/>(PDF/DOCX/etc)
    N8N->>N8N: Clean & chunk content
    N8N->>N8N: Generate embeddings<br/>(OpenAI API)
    N8N->>Cortex: Store chunks & embeddings
    N8N->>Cortex: Update status to COMPLETED
    
    N8N-->>Client: WebSocket notification<br/>(optional)
```

## Component Architecture (with n8n)

```mermaid
graph TB
    subgraph "Client Layer"
        WebApp[Web Application]
        MobileApp[Mobile App]
    end

    subgraph "API Layer"
        subgraph "Cortex API (Python)"
            CortexEndpoints[REST Endpoints]
            CortexService[Document Service]
            CortexDB[(PostgreSQL<br/>+ pgvector)]
        end

        subgraph "Forge API (NestJS)"
            ForgeEndpoints[TUS Endpoints]
            ForgeService[Storage Service]
            ForgeTUS[TUS Server]
        end
        
        subgraph "Helix API (NestJS)"
            HelixEndpoints[n8n Integration]
            HelixService[Workflow Service]
        end
    end

    subgraph "Shared Libraries"
        APICore[api-core Package]
        ForgeClientTS[ForgeClient<br/>TypeScript]
        HelixClientTS[HelixClient<br/>TypeScript]
    end

    subgraph "Storage Layer"
        Supabase[(Supabase Storage)]
    end

    subgraph "Automation Layer"
        N8N[n8n Workflows]
        DocProcessing[Document Processing<br/>Workflow]
        Embeddings[OpenAI Embeddings]
    end

    %% Client connections
    WebApp -->|HTTP| CortexEndpoints
    MobileApp -->|HTTP| CortexEndpoints
    WebApp -->|TUS Upload| ForgeEndpoints
    MobileApp -->|TUS Upload| ForgeEndpoints

    %% Cortex internal
    CortexEndpoints --> CortexService
    CortexService --> CortexDB

    %% Forge internal
    ForgeEndpoints --> ForgeService
    ForgeService --> ForgeTUS
    ForgeTUS --> Supabase

    %% Helix internal
    HelixEndpoints --> HelixService
    HelixService --> N8N

    %% Cross-service communication
    ForgeEndpoints -.->|Trigger Workflow| HelixEndpoints
    
    %% n8n workflow interactions
    N8N --> DocProcessing
    DocProcessing -.->|Update Status| CortexEndpoints
    DocProcessing -.->|Download File| ForgeEndpoints
    DocProcessing -.->|Store Chunks| CortexDB
    DocProcessing --> Embeddings

    %% Shared library usage
    APICore --> ForgeClientTS
    APICore --> HelixClientTS
    ForgeClientTS -.->|Used by Forge| ForgeEndpoints
    HelixClientTS -.->|Used by Helix| HelixEndpoints

    style Cortex fill:#e1f5ff
    style Forge fill:#fff4e1
    style Helix fill:#e1ffe1
    style APICore fill:#f0f0f0
    style N8N fill:#ff9999
```

## API Endpoints

### Cortex API (Knowledge Base Management)

```mermaid
graph LR
    subgraph "Cortex Endpoints"
        KB[Knowledge Bases]
        Doc[Documents]
        Search[Search]
        Webhook[Webhooks]
    end

    KB --> KB1[POST /knowledge-bases]
    KB --> KB2[GET /knowledge-bases]
    KB --> KB3[GET /knowledge-bases/:id]
    KB --> KB4[PUT /knowledge-bases/:id]
    KB --> KB5[DELETE /knowledge-bases/:id]

    Doc --> Doc1[POST /knowledge-bases/:kb_id/documents/initiate]
    Doc --> Doc2[POST /knowledge-bases/:kb_id/documents/:doc_id/complete]
    Doc --> Doc3[GET /knowledge-bases/:kb_id/documents]
    Doc --> Doc4[GET /knowledge-bases/:kb_id/documents/:id]
    Doc --> Doc5[DELETE /knowledge-bases/:kb_id/documents/:id]

    Search --> Search1[POST /knowledge-bases/:kb_id/search]

    Webhook --> WH1[POST /webhooks/forge/upload-complete]

    style Doc1 fill:#90EE90
    style Doc2 fill:#90EE90
    style WH1 fill:#FFB6C1
```

### Forge API (Storage & TUS)

```mermaid
graph LR
    subgraph "Forge Endpoints"
        TUS[TUS Protocol]
        Files[File Management]
    end

    TUS --> TUS1[POST /api/v1/files/tus/initiate]
    TUS --> TUS2[HEAD /api/v1/files/tus/:id]
    TUS --> TUS3[PATCH /api/v1/files/tus/:id]
    TUS --> TUS4[GET /api/v1/files/tus/:id]

    Files --> F1[GET /api/v1/files/:id]
    Files --> F2[GET /api/v1/files/:id/download]
    Files --> F3[DELETE /api/v1/files/:id]
    Files --> F4[GET /api/v1/files/:id/metadata]

    style TUS1 fill:#90EE90
    style F2 fill:#87CEEB
```

## Data Flow (with n8n Automation)

```mermaid
flowchart TD
    Start([Client initiates upload]) --> CreateDoc[Cortex creates document record]
    CreateDoc --> GetUploadURL[Cortex requests upload URL from Forge]
    GetUploadURL --> ReturnURL[Return upload URL to client]
    
    ReturnURL --> DirectUpload{Client uploads<br/>directly to Forge<br/>via TUS}
    
    DirectUpload -->|Success| TriggerN8N[Forge triggers n8n workflow via Helix]
    DirectUpload -->|Failure| UploadFailed[Mark document as FAILED]
    
    TriggerN8N --> N8NWorkflow[n8n Document Processing Workflow]
    
    N8NWorkflow --> UpdateStatus[Update Cortex: status = PROCESSING]
    UpdateStatus --> DownloadFile[Download file from Forge]
    DownloadFile --> ExtractText[Extract text content<br/>PDF/DOCX/TXT parser]
    ExtractText --> ChunkText[Chunk into segments<br/>Configurable size]
    ChunkText --> GenerateEmbeddings[Generate embeddings<br/>OpenAI API call]
    GenerateEmbeddings --> StoreVectors[Store chunks in Cortex<br/>pgvector]
    StoreVectors --> MarkComplete[Update Cortex: status = COMPLETED]
    
    MarkComplete --> End([Document ready for search])
    UploadFailed --> End

    style DirectUpload fill:#FFD700
    style N8NWorkflow fill:#ff9999
    style GenerateEmbeddings fill:#87CEEB
    style StoreVectors fill:#90EE90
```

## Client Library Structure

```mermaid
classDiagram
    class ForgeClient {
        +baseUrl: string
        +apiKey: string
        +initiateUpload(params) Promise~UploadSession~
        +getFileMetadata(fileId) Promise~FileMetadata~
        +getDownloadUrl(fileId) Promise~string~
        +deleteFile(fileId) Promise~void~
    }

    class UploadSession {
        +uploadId: string
        +uploadUrl: string
        +expiresAt: Date
    }

    class FileMetadata {
        +id: string
        +filename: string
        +contentType: string
        +size: number
        +storagePath: string
        +uploadedAt: Date
    }

    ForgeClient --> UploadSession
    ForgeClient --> FileMetadata

    note for ForgeClient "TypeScript client in api-core\nPython client in Cortex"
```

## Key Design Decisions

| Decision | Rationale |
|----------|-----------|
| **Direct Upload to Forge** | Better performance, leverages TUS resumable uploads, reduces Cortex load |
| **n8n for Processing** | Visual workflow builder, easier to modify processing logic, no custom worker code needed |
| **Helix as n8n Bridge** | Centralized n8n integration, reusable across all APIs, consistent workflow triggering |
| **Separate Client Libraries** | TypeScript for NestJS APIs (Forge + Helix clients), minimal HTTP wrappers |
| **Document Status States** | PENDING_UPLOAD → PROCESSING → COMPLETED/FAILED for clear lifecycle |
| **No Shared Database** | Maintains service boundaries, each service owns its data |
| **n8n Workflow Nodes** | HTTP Request (Cortex/Forge), Code (text extraction), OpenAI (embeddings) |

## Benefits of n8n Approach

✅ **Visual Workflow Management**: Non-developers can modify document processing logic
✅ **No Queue Infrastructure**: n8n handles execution, retries, and error handling
✅ **Flexible Processing**: Easy to add new document types, preprocessing steps
✅ **Monitoring Built-in**: n8n provides execution history and debugging
✅ **Reusable Patterns**: Same workflow approach for other automation needs
✅ **Error Recovery**: n8n's retry logic and error branches handle failures gracefully

## n8n Workflow Example

### Document Processing Workflow

```mermaid
graph LR
    Start[Webhook Trigger] --> UpdateStatus1[HTTP: Update Cortex<br/>status=PROCESSING]
    UpdateStatus1 --> Download[HTTP: Download from Forge]
    Download --> DetectType{Detect<br/>File Type}
    
    DetectType -->|PDF| ExtractPDF[Code: Extract PDF Text]
    DetectType -->|DOCX| ExtractDOCX[Code: Extract DOCX Text]
    DetectType -->|TXT| ExtractTXT[Code: Read Text]
    
    ExtractPDF --> Clean[Code: Clean & Normalize]
    ExtractDOCX --> Clean
    ExtractTXT --> Clean
    
    Clean --> Chunk[Code: Chunk Text<br/>500 tokens, 50 overlap]
    Chunk --> Loop{For Each<br/>Chunk}
    
    Loop --> Embed[OpenAI: Generate Embedding<br/>text-embedding-3-small]
    Embed --> Store[HTTP: Store in Cortex<br/>POST /chunks]
    Store --> Loop
    
    Loop -->|Done| UpdateStatus2[HTTP: Update Cortex<br/>status=COMPLETED]
    UpdateStatus2 --> End[Success]
    
    DetectType -->|Error| ErrorHandler[Error Handler]
    Download -->|Error| ErrorHandler
    Embed -->|Error| ErrorHandler
    ErrorHandler --> UpdateFailed[HTTP: Update Cortex<br/>status=FAILED]
    UpdateFailed --> EndFail[Failed]
    
    style Start fill:#90EE90
    style Embed fill:#87CEEB
    style Store fill:#FFD700
    style ErrorHandler fill:#FF6B6B
```

### n8n Workflow Configuration

**Nodes:**
1. **Webhook Trigger** - Receives payload from Forge
2. **Update Status (Processing)** - HTTP Request to Cortex
3. **Download File** - HTTP Request to Forge
4. **Detect File Type** - Code node (JavaScript)
5. **Extract Text** - Code nodes for PDF/DOCX/TXT
6. **Clean Text** - Code node (remove special chars, normalize)
7. **Chunk Text** - Code node (split into chunks)
8. **Loop Chunks** - Split In Batches node
9. **Generate Embeddings** - OpenAI node
10. **Store Chunk** - HTTP Request to Cortex
11. **Update Status (Completed)** - HTTP Request to Cortex
12. **Error Handler** - Error Trigger + HTTP Request

**Environment Variables in n8n:**
- `CORTEX_API_URL`
- `FORGE_API_URL`
- `OPENAI_API_KEY`

## Environment Variables

### Cortex (.env)
```bash
# Forge Integration
FORGE_API_URL=http://localhost:4002
FORGE_API_KEY=<secret>

# No webhook secret needed - n8n handles callbacks
```

### Forge (.env)
```bash
# Helix Integration (for triggering n8n workflows)
HELIX_API_URL=http://localhost:4005
HELIX_API_KEY=<secret>
DOCUMENT_PROCESSING_WORKFLOW_ID=<n8n-workflow-id>

# Storage
SUPABASE_URL=<url>
SUPABASE_KEY=<key>
SUPABASE_BUCKET=documents
```

### Helix (.env)
```bash
# n8n Configuration
N8N_API_URL=http://localhost:5678
N8N_API_KEY=<secret>

# Service URLs (for n8n workflows to call back)
CORTEX_API_URL=http://localhost:8000
FORGE_API_URL=http://localhost:4002
```

### n8n Environment Variables
```bash
# Set in n8n workflow or global credentials
CORTEX_API_URL=http://localhost:8000
CORTEX_API_KEY=<secret>
FORGE_API_URL=http://localhost:4002
FORGE_API_KEY=<secret>
OPENAI_API_KEY=<secret>
```

## Development Approach & Sequence

### Recommended Approach: **Workflow-First Development**

Since Helix already exposes n8n endpoints, we should:
1. **Build the n8n workflow first** (using Helix API)
2. **Test it manually** with mock data
3. **Then add minimal API changes** to trigger it

### Why Workflow-First?

✅ **Validate the concept** - Prove document processing works before API changes
✅ **Iterate quickly** - n8n visual editor is faster than code changes
✅ **No deployment needed** - Test workflow without redeploying APIs
✅ **Parallel work** - Frontend/backend teams can work independently
✅ **Minimal risk** - Existing APIs unchanged until workflow is proven

---

## Development Sequence

### **Phase 1: n8n Workflow Development** (Priority: HIGH)
**Goal:** Build and test document processing workflow in n8n

**Steps:**
1. Access n8n instance via Helix
2. Create new workflow: "Document Processing Pipeline"
3. Add nodes:
   - Manual Trigger (for testing)
   - HTTP Request: Download file from Forge
   - Code: Detect file type
   - Code: Extract text (PDF/DOCX/TXT)
   - Code: Clean and chunk text
   - OpenAI: Generate embeddings
   - HTTP Request: Store chunks in Cortex
   - HTTP Request: Update document status
4. Test with sample documents
5. Add error handling branches
6. Configure retries and timeouts

**Deliverable:** Working n8n workflow that can process a document end-to-end

**Testing:**
```bash
# Manually trigger workflow via Helix API
curl -X POST http://localhost:4005/api/n8n/workflows/{workflow_id}/execute \
  -H "Content-Type: application/json" \
  -d '{
    "document_id": "test-doc-123",
    "file_id": "test-file-456",
    "kb_id": "test-kb-789",
    "storage_path": "path/to/test.pdf"
  }'
```

---

### **Phase 2: Cortex API Endpoints** (Priority: HIGH)
**Goal:** Add endpoints for n8n workflow to interact with Cortex

**Required Endpoints:**

1. **Update Document Status**
   ```python
   PATCH /api/v1/documents/{doc_id}/status
   Body: { "status": "processing" | "completed" | "failed", "error": "..." }
   ```

2. **Store Document Chunks**
   ```python
   POST /api/v1/documents/{doc_id}/chunks
   Body: {
     "chunks": [
       { "content": "...", "chunk_index": 0, "embedding": [...] }
     ]
   }
   ```

3. **Get Document Details** (may already exist)
   ```python
   GET /api/v1/documents/{doc_id}
   ```

**Deliverable:** Cortex endpoints that n8n can call

**Testing:**
```bash
# Test status update
curl -X PATCH http://localhost:8000/api/v1/documents/{doc_id}/status \
  -H "Content-Type: application/json" \
  -d '{"status": "processing"}'

# Test chunk storage
curl -X POST http://localhost:8000/api/v1/documents/{doc_id}/chunks \
  -H "Content-Type: application/json" \
  -d '{"chunks": [{"content": "test", "chunk_index": 0, "embedding": [...]}]}'
```

---

### **Phase 3: Client Libraries** (Priority: MEDIUM)
**Goal:** Create reusable TypeScript clients in api-core

**Files to Create:**
```
packages/api-core/src/clients/
├── forge-client.ts          # ForgeClient class
├── forge-client.types.ts    # TypeScript interfaces
├── forge-client.module.ts   # NestJS module
├── helix-client.ts          # HelixClient class
├── helix-client.types.ts    # TypeScript interfaces
└── helix-client.module.ts   # NestJS module
```

**ForgeClient Methods:**
- `initiateUpload(params)` → Upload session
- `getFileMetadata(fileId)` → File metadata
- `getDownloadUrl(fileId)` → Download URL
- `deleteFile(fileId)` → void

**HelixClient Methods:**
- `executeWorkflow(workflowId, payload)` → Execution response
- `getWorkflowStatus(executionId)` → Execution status
- `getWorkflow(workflowId)` → Workflow details

**Deliverable:** Reusable clients exported from api-core

---

### **Phase 4: Forge Integration** (Priority: MEDIUM)
**Goal:** Trigger n8n workflow after upload completes

**Changes to Forge:**

1. **Add Helix client dependency**
   ```typescript
   // forge/src/app.module.ts
   import { HelixClientModule } from '@asyml8/api-core';
   
   @Module({
     imports: [HelixClientModule, ...],
   })
   ```

2. **Trigger workflow after upload**
   ```typescript
   // forge/src/modules/tus/tus.service.ts
   async onUploadComplete(uploadId: string, metadata: any) {
     // Existing logic...
     
     // Trigger n8n workflow via Helix
     await this.helixClient.executeWorkflow(
       process.env.DOCUMENT_PROCESSING_WORKFLOW_ID,
       {
         document_id: metadata.document_id,
         file_id: uploadId,
         kb_id: metadata.kb_id,
         storage_path: storagePath,
       }
     );
   }
   ```

**Environment Variables:**
```bash
HELIX_API_URL=http://localhost:4005
HELIX_API_KEY=<secret>
DOCUMENT_PROCESSING_WORKFLOW_ID=<workflow-id-from-n8n>
```

**Deliverable:** Forge automatically triggers workflow on upload

---

### **Phase 5: Cortex Upload Flow** (Priority: LOW)
**Goal:** Update Cortex to support TUS upload initiation

**Changes to Cortex:**

1. **Add document status: PENDING_UPLOAD**
   ```python
   class DocumentStatus(str, enum.Enum):
       PENDING_UPLOAD = "pending_upload"
       PROCESSING = "processing"
       COMPLETED = "completed"
       FAILED = "failed"
   ```

2. **Add initiate-upload endpoint**
   ```python
   @router.post("/{kb_id}/documents/initiate-upload")
   async def initiate_upload(kb_id: UUID, doc: DocumentInitiateUpload):
       # Get upload URL from Forge
       upload_session = await forge_client.initiate_upload(...)
       
       # Create document record
       document = service.create_pending(...)
       
       return {
           "document_id": document.id,
           "upload_url": upload_session.upload_url,
           "upload_id": upload_session.upload_id
       }
   ```

**Deliverable:** Cortex can initiate uploads via Forge

---

### **Phase 6: Frontend Integration** (Priority: LOW)
**Goal:** Update frontend to use new upload flow

**Changes:**
1. Call Cortex initiate-upload endpoint
2. Use TUS client to upload directly to Forge
3. Poll document status or use WebSocket for updates

---

## Priority Summary

| Phase | Priority | Effort | Dependencies | Can Start Now? |
|-------|----------|--------|--------------|----------------|
| 1. n8n Workflow | **HIGH** | 2-3 days | Helix API (exists) | ✅ **YES** |
| 2. Cortex Endpoints | **HIGH** | 1-2 days | Phase 1 complete | ✅ **YES** (parallel) |
| 3. Client Libraries | MEDIUM | 1 day | None | ✅ **YES** (parallel) |
| 4. Forge Integration | MEDIUM | 1 day | Phase 1, 3 | ⏳ After Phase 1 |
| 5. Cortex Upload Flow | LOW | 1-2 days | Phase 3 | ⏳ After Phase 3 |
| 6. Frontend | LOW | 2-3 days | Phase 5 | ⏳ After Phase 5 |

---

## Recommended Start

### **Week 1: Prove the Concept**
- **Day 1-2:** Build n8n workflow (Phase 1)
- **Day 3:** Add Cortex endpoints (Phase 2)
- **Day 4:** Test end-to-end manually
- **Day 5:** Create client libraries (Phase 3)

### **Week 2: Integration**
- **Day 1:** Integrate Forge with Helix (Phase 4)
- **Day 2-3:** Update Cortex upload flow (Phase 5)
- **Day 4-5:** Frontend integration (Phase 6)

---

## Testing Strategy

### Manual Testing (Phase 1-2)
```bash
# 1. Upload a file to Forge manually
curl -X POST http://localhost:4002/api/v1/files/upload ...

# 2. Trigger n8n workflow via Helix
curl -X POST http://localhost:4005/api/n8n/workflows/{id}/execute \
  -d '{"file_id": "...", "document_id": "..."}'

# 3. Check n8n execution logs
curl http://localhost:4005/api/n8n/executions/{execution_id}

# 4. Verify chunks in Cortex
curl http://localhost:8000/api/v1/documents/{doc_id}
```

### Automated Testing (Phase 4+)
- Integration tests for Forge → Helix → n8n flow
- E2E tests for full upload → process → search flow

---

## Implementation Phases

### Phase 1: Client Libraries (api-core)
- Create `ForgeClient` in TypeScript
- Create `HelixClient` in TypeScript
- Export from api-core package

### Phase 2: Forge Integration
- Add endpoint to trigger Helix workflows after upload
- Pass document metadata to Helix

### Phase 3: Helix Integration
- Implement n8n workflow execution endpoints
- Add workflow status monitoring

### Phase 4: n8n Workflow
- Create document processing workflow in n8n
- Configure nodes for download, extract, chunk, embed
- Set up error handling and retries

### Phase 5: Cortex Endpoints
- Add endpoints for n8n to update document status
- Add endpoints for n8n to store chunks
- Update document schemas

### Phase 6: Testing & Monitoring
- End-to-end upload testing
- Monitor n8n execution logs
- Performance optimization

