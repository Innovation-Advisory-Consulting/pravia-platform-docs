# n8n Workflow Setup

## Generate API Key

1. Go to http://localhost:5678
2. Click your profile icon (bottom left)
3. Go to **Settings** → **API**
4. Click **Create API Key**
5. Copy the key

## Create Document Processing Workflow

Run the script with your API key:

```bash
cd external/n8n
./create-workflow.sh YOUR_API_KEY_HERE
```

## View the Workflow

1. Go to http://localhost:5678/workflows
2. Click on "Document Processing Workflow"
3. You'll see the complete flow with 9 nodes

## Workflow Overview

The workflow automates document processing:

```
Webhook (Document Upload)
  ↓
Upload to Storage (Helix API)
  ↓
Process with Azure AI
  ↓
Wait 5 seconds
  ↓
Check Processing Status
  ↓
Switch by Document Type
  ├─ TRP → Store in Dataverse (TRP table)
  └─ SSP → Store in Dataverse (SSP table)
  ↓
Respond to Webhook
```

## Nodes Included

1. **Webhook - Document Upload** - Receives POST requests
2. **Upload to Storage** - Calls Helix API to store document
3. **Process with Azure AI** - Triggers AI processing
4. **Wait for Processing** - 5 second delay
5. **Check Status** - Polls processing status
6. **Document Type Switch** - Routes based on classification
7. **Store in Dataverse - TRP** - Saves TRP documents
8. **Store in Dataverse - SSP** - Saves SSP documents
9. **Respond to Webhook** - Returns success response

## Helix API Endpoints Used

- `POST /api/documents/upload`
- `POST /api/azure-ai/process`
- `GET /api/azure-ai/status/:id`
- `POST /api/dataverse/records`

## Next Steps

1. Build the Helix API endpoints
2. Activate the workflow in n8n
3. Test with sample document upload
4. Monitor execution logs
