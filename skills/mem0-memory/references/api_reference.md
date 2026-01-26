# Mem0 REST API Reference

Base URL: `http://localhost:8000`

## Endpoints

### Health Check
```
GET /health
```
Returns 200 if server is running.

---

### Create Memories
```
POST /memories
Content-Type: application/json
```

**Request Body (MemoryCreate)**:
```json
{
  "messages": [
    {"role": "string", "content": "string"}
  ],
  "user_id": "string | null",
  "agent_id": "string | null", 
  "run_id": "string | null",
  "metadata": {"key": "value"} | null
}
```

- `messages` (required): Array of Message objects
  - `role`: Role of message sender ("user" or "assistant")
  - `content`: Message content string
- `user_id`: Optional user identifier
- `agent_id`: Optional agent identifier
- `run_id`: Optional session/run identifier
- `metadata`: Optional key-value metadata

---

### Get All Memories
```
GET /memories
```

**Query Parameters**:
- `user_id` (string, optional): Filter by user
- `agent_id` (string, optional): Filter by agent
- `run_id` (string, optional): Filter by run/session

---

### Get Single Memory
```
GET /memories/{memory_id}
```

**Path Parameters**:
- `memory_id` (string, required): Memory ID

---

### Update Memory
```
PUT /memories/{memory_id}
Content-Type: application/json
```

**Path Parameters**:
- `memory_id` (string, required): Memory ID

**Request Body**: Object with updated fields

---

### Delete Memory
```
DELETE /memories/{memory_id}
```

**Path Parameters**:
- `memory_id` (string, required): Memory ID

---

### Delete All Memories
```
DELETE /memories
```

**Query Parameters**:
- `user_id` (string, optional): Delete for specific user
- `agent_id` (string, optional): Delete for specific agent
- `run_id` (string, optional): Delete for specific run

---

### Search Memories
```
POST /search
Content-Type: application/json
```

**Request Body (SearchRequest)**:
```json
{
  "query": "string",
  "user_id": "string | null",
  "agent_id": "string | null",
  "run_id": "string | null",
  "filters": {"key": "value"} | null
}
```

- `query` (required): Search query string
- `user_id`: Optional user filter
- `agent_id`: Optional agent filter
- `run_id`: Optional run filter
- `filters`: Optional additional filters

---

### Get Memory History
```
GET /memories/{memory_id}/history
```

**Path Parameters**:
- `memory_id` (string, required): Memory ID

Returns version history for a memory.

---

### Configure Mem0
```
POST /configure
Content-Type: application/json
```

**Request Body**: Configuration object (varies by setup)

---

### Reset All Memories
```
POST /reset
```

**Warning**: Completely resets all stored memories.

---

## Error Responses

**422 Validation Error**:
```json
{
  "detail": [
    {
      "loc": ["body", "field_name"],
      "msg": "error message",
      "type": "error_type"
    }
  ]
}
```

## Data Schemas

### Message
```json
{
  "role": "string",
  "content": "string"
}
```

### MemoryCreate
```json
{
  "messages": [Message],
  "user_id": "string | null",
  "agent_id": "string | null",
  "run_id": "string | null",
  "metadata": "object | null"
}
```

### SearchRequest
```json
{
  "query": "string",
  "user_id": "string | null",
  "agent_id": "string | null",
  "run_id": "string | null",
  "filters": "object | null"
}
```
