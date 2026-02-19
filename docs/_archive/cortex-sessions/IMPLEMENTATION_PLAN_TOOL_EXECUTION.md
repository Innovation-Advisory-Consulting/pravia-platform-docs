# Implementation Plan: Tool Execution Endpoint

## Overview
Add HTTP endpoint for tool execution to enable n8n workflows to call Cortex tools, while maintaining CrewAI agent compatibility.

## Phase 1: Testing Infrastructure

### 1.1 Create Integration Test
**File:** `tests/integration/test_tool_execution.py`

**Test Cases:**
- [ ] Test tool execution endpoint with valid parameters
- [ ] Test with invalid tool name (404)
- [ ] Test with invalid parameters (400)
- [ ] Test PDF extraction with local library
- [ ] Test PDF extraction with remote service (if configured)
- [ ] Test OCR with local library
- [ ] Test OCR with remote service (if configured)
- [ ] Test error handling and response format
- [ ] Test execution time tracking

**Approach:**
- Use pytest fixtures for test files
- Mock external services for unit tests
- Use real services for integration tests (optional)
- Test both success and failure paths

### 1.2 Update Existing Tests
- [ ] Verify CrewAI agent tests still pass
- [ ] Ensure tool registry tests are compatible
- [ ] Add test for tool configuration loading

## Phase 2: Tool Configuration System

### 2.1 Configuration Schema
**File:** `app/models/schemas/tool_config.py`

```python
class ToolProviderConfig:
    provider: str  # "local", "azure", "aws", "google"
    enabled: bool
    priority: int  # Lower = higher priority
    config: dict   # Provider-specific settings
```

### 2.2 Environment Variables
**Add to `.env`:**
```
# PDF Extraction
PDF_EXTRACTION_PROVIDER=local  # local, azure, aws
PDF_EXTRACTION_FALLBACK=true

# Azure Form Recognizer (optional)
AZURE_FORM_RECOGNIZER_ENDPOINT=
AZURE_FORM_RECOGNIZER_KEY=

# AWS Textract (optional)
AWS_TEXTRACT_REGION=
AWS_TEXTRACT_ACCESS_KEY=
AWS_TEXTRACT_SECRET_KEY=

# OCR Configuration
OCR_PROVIDER=local  # local, azure, google
TESSERACT_PATH=/usr/bin/tesseract
```

### 2.3 Provider Registry
**File:** `app/tools/providers/registry.py`

- Abstract provider interface
- Local provider implementations
- Remote provider implementations
- Fallback logic
- Provider health checks

## Phase 3: Core Implementation

### 3.1 Response Utilities
**File:** `app/core/responses.py`

```python
def success_response(data, metadata)
def error_response(code, message, details)
def execution_timer() # decorator
```

### 3.2 Tool Execution Schemas
**File:** `app/models/schemas/tool_execution.py`

```python
class ToolExecuteRequest(BaseModel):
    parameters: dict
    provider: Optional[str] = None  # Override default

class ToolExecuteResponse(BaseModel):
    success: bool
    data: Any
    metadata: dict
    error: Optional[dict]
```

### 3.3 PDF Parser Implementation
**File:** `app/tools/document_processing/pdf_parser.py`

**Local Provider (Priority 1):**
- Library: `pypdf` or `pdfplumber`
- Fast, no external dependencies
- Good for text-based PDFs

**Azure Form Recognizer (Priority 2):**
- Better for complex layouts
- Handles scanned documents
- Requires API key

**AWS Textract (Priority 3):**
- Alternative cloud option
- Good OCR capabilities

**Implementation:**
```python
def _run(self, file_path: str, provider: str = None) -> str:
    provider = provider or self._get_default_provider()
    
    if provider == "local":
        return self._extract_local(file_path)
    elif provider == "azure":
        return self._extract_azure(file_path)
    elif provider == "aws":
        return self._extract_aws(file_path)
    
    # Fallback logic if provider fails
```

### 3.4 OCR Implementation
**File:** `app/tools/document_processing/ocr.py`

**Local Provider:**
- Library: `pytesseract`
- Requires tesseract binary installed
- Free, works offline

**Google Cloud Vision:**
- High accuracy
- Multiple language support

**Azure Computer Vision:**
- Good for forms and documents

### 3.5 Tool Execution Endpoint
**File:** `app/api/v1/endpoints/tool_execution.py`

```python
@router.post("/tools/{tool_name}/execute")
async def execute_tool(
    tool_name: str,
    request: ToolExecuteRequest
) -> ToolExecuteResponse:
    # Get tool from registry
    # Validate parameters
    # Execute with timing
    # Return standardized response
```

### 3.6 Register Routes
**File:** `app/api/v1/router.py`

Add tool execution router to API

## Phase 4: n8n Workflow

### 4.1 Create Workflow
**Name:** "Document Ingestion with Text Extraction"

**Nodes:**
1. Webhook - Document Ingest
2. HTTP Request - Detect File Type
3. Switch - Route by File Type
4. HTTP Request - Extract Text (PDF)
5. HTTP Request - Extract Text (Image/OCR)
6. HTTP Request - Ingest to Cortex
7. Respond to Webhook

### 4.2 Error Handling
- Retry logic for transient failures
- Fallback to different providers
- Error notification workflow

## Phase 5: Documentation

### 5.1 API Documentation
- Update OpenAPI/Swagger specs
- Add tool execution examples
- Document error codes
- Provider configuration guide

### 5.2 Developer Guide
- How to add new tools
- How to add new providers
- Testing guidelines
- Configuration best practices

## Dependencies to Add

```txt
# PDF Processing
pypdf>=3.17.0
pdfplumber>=0.10.0

# OCR
pytesseract>=0.3.10
Pillow>=10.0.0

# Azure (optional)
azure-ai-formrecognizer>=3.3.0
azure-cognitiveservices-vision-computervision>=0.9.0

# AWS (optional)
boto3>=1.28.0
```

## Testing Strategy

### Unit Tests
- Test each provider independently
- Mock external API calls
- Test fallback logic

### Integration Tests
- Test full endpoint flow
- Test with real files
- Test provider switching

### E2E Tests
- Test from n8n webhook to completion
- Test error scenarios
- Test with various file types

## Rollout Plan

1. **Phase 1**: Implement local providers only
2. **Phase 2**: Add Azure providers (optional)
3. **Phase 3**: Add AWS providers (optional)
4. **Phase 4**: Deploy and test with n8n
5. **Phase 5**: Monitor and optimize

## Success Criteria

- [ ] All integration tests pass
- [ ] CrewAI agents still work unchanged
- [ ] n8n can call tools via HTTP
- [ ] Local providers work without external dependencies
- [ ] Remote providers work when configured
- [ ] Fallback logic handles failures gracefully
- [ ] Response format is standardized
- [ ] Documentation is complete
