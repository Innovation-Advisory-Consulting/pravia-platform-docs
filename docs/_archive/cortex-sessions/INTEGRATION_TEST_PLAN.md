# Integration Test Plan: Tool Execution Endpoint

## Overview
Comprehensive testing strategy for tool execution endpoint with iterative development approach.

## Test Structure

```
tests/
├── integration/
│   ├── test_tool_execution_endpoint.py
│   ├── test_pdf_extraction.py
│   ├── test_ocr_extraction.py
│   ├── test_provider_fallback.py
│   └── fixtures/
│       ├── sample.pdf
│       ├── sample_scanned.pdf
│       ├── sample_image.png
│       └── sample_complex.pdf
```

## Iterative Testing Approach

### Iteration 1: Basic Endpoint
**Goal**: Verify endpoint exists and handles requests

```python
def test_tool_execution_endpoint_exists():
    """Test that endpoint is accessible"""
    response = client.post("/api/v1/tools/pdf_parser/execute")
    assert response.status_code in [200, 400, 404]

def test_invalid_tool_name():
    """Test 404 for non-existent tool"""
    response = client.post(
        "/api/v1/tools/nonexistent/execute",
        json={"parameters": {}}
    )
    assert response.status_code == 404
    assert response.json()["success"] == False

def test_missing_parameters():
    """Test 400 for missing required parameters"""
    response = client.post(
        "/api/v1/tools/pdf_parser/execute",
        json={"parameters": {}}
    )
    assert response.status_code == 400
```

### Iteration 2: Response Format
**Goal**: Verify standardized response structure

```python
def test_success_response_format():
    """Test success response has correct structure"""
    response = client.post(
        "/api/v1/tools/pdf_parser/execute",
        json={"parameters": {"file_path": "tests/fixtures/sample.pdf"}}
    )
    data = response.json()
    
    assert "success" in data
    assert "data" in data
    assert "metadata" in data
    assert "execution_time_ms" in data["metadata"]
    assert "tool_name" in data["metadata"]

def test_error_response_format():
    """Test error response has correct structure"""
    response = client.post(
        "/api/v1/tools/pdf_parser/execute",
        json={"parameters": {"file_path": "/nonexistent/file.pdf"}}
    )
    data = response.json()
    
    assert data["success"] == False
    assert "error" in data
    assert "code" in data["error"]
    assert "message" in data["error"]
```

### Iteration 3: Local Provider
**Goal**: Implement and test local PDF extraction

```python
def test_pdf_extraction_local_simple():
    """Test local PDF extraction with simple text PDF"""
    response = client.post(
        "/api/v1/tools/pdf_parser/execute",
        json={
            "parameters": {"file_path": "tests/fixtures/sample.pdf"},
            "provider": "local"
        }
    )
    
    assert response.status_code == 200
    data = response.json()
    assert data["success"] == True
    assert len(data["data"]) > 0
    assert "metadata" in data
    assert data["metadata"]["provider"] == "local"

def test_pdf_extraction_local_multipage():
    """Test local PDF extraction with multiple pages"""
    response = client.post(
        "/api/v1/tools/pdf_parser/execute",
        json={
            "parameters": {
                "file_path": "tests/fixtures/multipage.pdf",
                "pages": "1-3"
            }
        }
    )
    
    assert response.status_code == 200
    data = response.json()
    assert data["success"] == True
    assert data["metadata"]["pages_processed"] == 3
```

### Iteration 4: Error Handling
**Goal**: Test various error scenarios

```python
def test_file_not_found():
    """Test handling of non-existent file"""
    response = client.post(
        "/api/v1/tools/pdf_parser/execute",
        json={"parameters": {"file_path": "/nonexistent/file.pdf"}}
    )
    
    assert response.status_code == 200  # Expected error
    data = response.json()
    assert data["success"] == False
    assert data["error"]["code"] == "FILE_NOT_FOUND"

def test_invalid_file_format():
    """Test handling of invalid file format"""
    response = client.post(
        "/api/v1/tools/pdf_parser/execute",
        json={"parameters": {"file_path": "tests/fixtures/sample.txt"}}
    )
    
    assert response.status_code == 200
    data = response.json()
    assert data["success"] == False
    assert data["error"]["code"] == "UNSUPPORTED_FORMAT"

def test_corrupted_pdf():
    """Test handling of corrupted PDF"""
    response = client.post(
        "/api/v1/tools/pdf_parser/execute",
        json={"parameters": {"file_path": "tests/fixtures/corrupted.pdf"}}
    )
    
    assert response.status_code == 200
    data = response.json()
    assert data["success"] == False
    assert data["error"]["code"] == "EXTRACTION_FAILED"
```

### Iteration 5: Provider Configuration
**Goal**: Test provider selection and configuration

```python
def test_provider_override():
    """Test overriding default provider"""
    response = client.post(
        "/api/v1/tools/pdf_parser/execute",
        json={
            "parameters": {"file_path": "tests/fixtures/sample.pdf"},
            "provider": "local"
        }
    )
    
    data = response.json()
    assert data["metadata"]["provider"] == "local"

def test_invalid_provider():
    """Test handling of invalid provider name"""
    response = client.post(
        "/api/v1/tools/pdf_parser/execute",
        json={
            "parameters": {"file_path": "tests/fixtures/sample.pdf"},
            "provider": "nonexistent"
        }
    )
    
    assert response.status_code == 400
    data = response.json()
    assert data["error"]["code"] == "INVALID_PROVIDER"
```

### Iteration 6: Remote Providers (Optional)
**Goal**: Test Azure/AWS providers if configured

```python
@pytest.mark.skipif(not has_azure_config(), reason="Azure not configured")
def test_pdf_extraction_azure():
    """Test Azure Form Recognizer extraction"""
    response = client.post(
        "/api/v1/tools/pdf_parser/execute",
        json={
            "parameters": {"file_path": "tests/fixtures/sample.pdf"},
            "provider": "azure"
        }
    )
    
    assert response.status_code == 200
    data = response.json()
    assert data["success"] == True
    assert data["metadata"]["provider"] == "azure"

@pytest.mark.skipif(not has_aws_config(), reason="AWS not configured")
def test_pdf_extraction_aws():
    """Test AWS Textract extraction"""
    response = client.post(
        "/api/v1/tools/pdf_parser/execute",
        json={
            "parameters": {"file_path": "tests/fixtures/sample.pdf"},
            "provider": "aws"
        }
    )
    
    assert response.status_code == 200
    data = response.json()
    assert data["success"] == True
    assert data["metadata"]["provider"] == "aws"
```

### Iteration 7: Fallback Logic
**Goal**: Test provider fallback behavior

```python
def test_fallback_to_next_provider(monkeypatch):
    """Test fallback when primary provider fails"""
    # Mock first provider to fail
    def mock_local_fail(*args, **kwargs):
        raise Exception("Local provider failed")
    
    monkeypatch.setattr("app.tools.providers.local.extract", mock_local_fail)
    
    response = client.post(
        "/api/v1/tools/pdf_parser/execute",
        json={
            "parameters": {"file_path": "tests/fixtures/sample.pdf"}
        }
    )
    
    data = response.json()
    assert data["success"] == True
    assert data["metadata"]["provider"] != "local"
    assert "fallback_attempted" in data["metadata"]

def test_all_providers_fail(monkeypatch):
    """Test when all providers fail"""
    # Mock all providers to fail
    def mock_fail(*args, **kwargs):
        raise Exception("Provider failed")
    
    monkeypatch.setattr("app.tools.providers.local.extract", mock_fail)
    monkeypatch.setattr("app.tools.providers.azure.extract", mock_fail)
    
    response = client.post(
        "/api/v1/tools/pdf_parser/execute",
        json={"parameters": {"file_path": "tests/fixtures/sample.pdf"}}
    )
    
    assert response.status_code == 500
    data = response.json()
    assert data["success"] == False
    assert data["error"]["code"] == "ALL_PROVIDERS_FAILED"
```

### Iteration 8: OCR Tool
**Goal**: Test OCR extraction

```python
def test_ocr_extraction_local():
    """Test local OCR with tesseract"""
    response = client.post(
        "/api/v1/tools/ocr/execute",
        json={
            "parameters": {"file_path": "tests/fixtures/sample_image.png"}
        }
    )
    
    assert response.status_code == 200
    data = response.json()
    assert data["success"] == True
    assert len(data["data"]) > 0

def test_ocr_with_language():
    """Test OCR with specific language"""
    response = client.post(
        "/api/v1/tools/ocr/execute",
        json={
            "parameters": {
                "file_path": "tests/fixtures/sample_image.png",
                "language": "eng"
            }
        }
    )
    
    assert response.status_code == 200
    data = response.json()
    assert data["metadata"]["language"] == "eng"
```

### Iteration 9: Performance & Timing
**Goal**: Test execution time tracking

```python
def test_execution_time_tracking():
    """Test that execution time is tracked"""
    response = client.post(
        "/api/v1/tools/pdf_parser/execute",
        json={"parameters": {"file_path": "tests/fixtures/sample.pdf"}}
    )
    
    data = response.json()
    assert "execution_time_ms" in data["metadata"]
    assert data["metadata"]["execution_time_ms"] > 0

def test_timeout_handling():
    """Test handling of provider timeout"""
    response = client.post(
        "/api/v1/tools/pdf_parser/execute",
        json={
            "parameters": {"file_path": "tests/fixtures/large.pdf"},
            "timeout": 1  # 1 second timeout
        }
    )
    
    data = response.json()
    if not data["success"]:
        assert data["error"]["code"] == "TIMEOUT"
```

### Iteration 10: CrewAI Compatibility
**Goal**: Ensure CrewAI agents still work

```python
def test_crewai_agent_tool_usage():
    """Test that CrewAI agents can still use tools"""
    from app.tools.registry import get_tool
    
    tool = get_tool("pdf_parser")
    assert tool is not None
    
    result = tool._run(file_path="tests/fixtures/sample.pdf")
    assert isinstance(result, str)
    assert len(result) > 0

def test_crewai_agent_execution_unchanged():
    """Test full agent execution with tools"""
    response = client.post(
        "/api/v1/agents/test-agent/execute",
        json={
            "task": "Extract text from document",
            "tools": ["pdf_parser"]
        }
    )
    
    assert response.status_code == 200
    # Agent execution should work as before
```

## Test Fixtures

### Sample Files Needed
```bash
tests/fixtures/
├── sample.pdf              # Simple text PDF
├── multipage.pdf           # Multiple pages
├── sample_scanned.pdf      # Scanned document (needs OCR)
├── sample_complex.pdf      # Complex layout with tables
├── corrupted.pdf           # Corrupted file
├── sample_image.png        # Image for OCR
├── sample_image.jpg        # JPEG image
└── sample.txt              # Wrong format
```

### Creating Test Fixtures
```python
# conftest.py
import pytest
from pathlib import Path

@pytest.fixture
def test_files_dir():
    return Path(__file__).parent / "fixtures"

@pytest.fixture
def simple_pdf(test_files_dir):
    return test_files_dir / "sample.pdf"

@pytest.fixture
def client():
    from app.main import app
    from fastapi.testclient import TestClient
    return TestClient(app)
```

## Running Tests

### Run All Tests
```bash
pytest tests/integration/test_tool_execution_endpoint.py -v
```

### Run Specific Iteration
```bash
pytest tests/integration/test_tool_execution_endpoint.py::test_tool_execution_endpoint_exists -v
```

### Run with Coverage
```bash
pytest tests/integration/ --cov=app.api.v1.endpoints.tool_execution --cov-report=html
```

### Run Only Local Provider Tests
```bash
pytest tests/integration/ -k "local" -v
```

### Skip Remote Provider Tests
```bash
pytest tests/integration/ -m "not remote" -v
```

## Test Markers

```python
# Mark tests that require external services
@pytest.mark.remote
def test_azure_extraction():
    pass

# Mark slow tests
@pytest.mark.slow
def test_large_file_extraction():
    pass

# Mark tests that require specific config
@pytest.mark.requires_azure
def test_azure_specific_feature():
    pass
```

## CI/CD Integration

### GitHub Actions Workflow
```yaml
name: Integration Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Install dependencies
        run: |
          pip install -r requirements.txt
          pip install -r requirements-dev.txt
      - name: Run integration tests
        run: pytest tests/integration/ -v --cov
      - name: Upload coverage
        uses: codecov/codecov-action@v2
```

## Success Criteria

- [ ] All iteration 1-5 tests pass (local provider)
- [ ] All iteration 6-7 tests pass if remote providers configured
- [ ] All iteration 8 tests pass (OCR)
- [ ] All iteration 9 tests pass (performance)
- [ ] All iteration 10 tests pass (CrewAI compatibility)
- [ ] Code coverage > 80%
- [ ] No regression in existing tests
- [ ] Documentation updated

## Troubleshooting

### Common Issues

**Tesseract not found**
```bash
# Ubuntu/Debian
sudo apt-get install tesseract-ocr

# macOS
brew install tesseract
```

**PDF library issues**
```bash
pip install pypdf pdfplumber --upgrade
```

**Test fixtures missing**
```bash
# Generate test fixtures
python scripts/generate_test_fixtures.py
```
