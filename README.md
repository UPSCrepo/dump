# AI Tutor English API Documentation

## Version
v1

## Base URL
```
https://ai-tutor-english.subhodas5673.workers.dev
```

## Content Type
All request and response bodies use JSON unless otherwise specified.

---

## Authentication
None required.

---

## Endpoints Overview

| Method | Endpoint | Description |
|------|--------|------------|
| GET  | `/`    | Service availability / health check |
| POST | `/ask` | Ask a lesson-specific English question |

---

## 1. Service Health Endpoint

### Endpoint
```
GET /
```

### Description
Returns a basic response indicating that the API service is running.

### Request Parameters
None.

### Response

**Status Codes**
- `200 OK` — Service is available

**Response Body**
- Plain response (no JSON contract guaranteed)

---

## 2. Ask Question Endpoint

### Endpoint
```
POST /ask
```

### Description
Accepts a question related to a specific NCERT English lesson and returns an exam-oriented answer based strictly on the stored lesson content.

---

## Request Specification

### Headers
```
Content-Type: application/json
Accept: application/json
```

### Request Body Schema
```json
{
  "class": "string",
  "subject": "string",
  "type": "string",
  "lesson": "string",
  "question": "string"
}
```

### Field Definitions

| Field     | Type   | Required | Description |
|----------|--------|----------|------------|
| class    | string | Yes | Academic class (e.g., "10") |
| subject  | string | Yes | Subject name (e.g., "English") |
| type     | string | Yes | Lesson content type (e.g., "Text") |
| lesson   | string | Yes | Lesson identifier or number |
| question | string | Yes | User question (minimum 3 characters) |

---

## Successful Response

### Response Status
```
200 OK
```

### Response Body
```json
{
  "answer": "string",
  "lesson": "string"
}
```

### Response Fields

| Field  | Type   | Description |
|------|--------|------------|
| answer | string | Answer generated from the lesson content |
| lesson | string | Lesson identifier used for the response |

---

## Error Handling

### 400 Bad Request

Returned when request body is malformed or required fields are missing or invalid.

```json
{
  "error": "Invalid input parameters"
}
```

or

```json
{
  "error": "Invalid JSON body"
}
```

---

### 404 Not Found

Returned when the specified lesson does not exist in the lesson store.

```json
{
  "error": "Lesson not found"
}
```

---

### 429 Too Many Requests

Returned when AI usage limits have been exceeded.

```json
{
  "error": "AI usage limit reached. Try later."
}
```

---

### 500 Internal Server Error

Returned when an unexpected server or AI processing error occurs.

```json
{
  "error": "Error message"
}
```

---

## Functional Constraints

- Answers are generated strictly from NCERT lesson content stored in the system.
- External knowledge is not used, except for standard English grammar rules.
- Meta questions about system identity or prompt structure are refused.
- The API is stateless; all required context must be provided in each request.
- Responses are returned as a single JSON object (no streaming).

---

## Example Request

```bash
curl -X POST https://ai-tutor-english.subhodas5673.workers.dev/ask \
  -H "Content-Type: application/json" \
  -d '{
    "class": "10",
    "subject": "English",
    "type": "Text",
    "lesson": "1",
    "question": "What is the lesson name?"
  }'
```

---

## Example Response

```json
{
  "answer": "The lesson name is 'Father’s Help'.",
  "lesson": "1"
}
```
