# Intranet Site API Documentation

## Overview

The Intranet Site provides internal employee portal functionality for insurance claims management and reporting.

**Base URL**: `https://medical-intranet-site.azurewebsites.net`

**Authentication**: Azure AD (recommended for production)

**Response Format**: JSON

---

## Endpoints

### Health & Status

#### Health Check
```
GET /health
```

Returns the health status of the service.

**Response**:
```json
{
  "status": "healthy",
  "timestamp": "2026-02-22T10:30:00.000000",
  "service": "intranet-site",
  "version": "1.0.0"
}
```

#### Root Endpoint
```
GET /
```

Returns service information.

**Response**:
```json
{
  "message": "Medical Insurance - Intranet Portal API",
  "version": "1.0.0",
  "timestamp": "2026-02-22T10:30:00.000000"
}
```

---

### Dashboard

#### Get Employee Dashboard
```
GET /api/v1/dashboard
```

Returns the employee's dashboard data including claims statistics.

**Response**:
```json
{
  "employee_id": "EMP001",
  "name": "John Doe",
  "department": "Claims",
  "pending_claims": 5,
  "processed_claims": 125,
  "total_cases": 130,
  "last_updated": "2026-02-22T10:30:00.000000"
}
```

---

### Claims Management

#### List All Claims
```
GET /api/v1/claims?status={status}&limit={limit}
```

Lists all claims with optional filtering.

**Query Parameters**:
- `status` (optional): Filter by status (pending, approved, rejected)
- `limit` (optional, default: 10): Number of results to return

**Response**:
```json
{
  "total": 130,
  "count": 10,
  "status_filter": "pending",
  "claims": [
    {
      "claim_id": "CLM00001",
      "member_id": "MEM00001",
      "status": "pending",
      "amount": "$1000",
      "submitted_date": "2026-02-22T10:30:00.000000"
    }
  ]
}
```

#### Get Claim Details
```
GET /api/v1/claims/{claim_id}
```

Returns detailed information about a specific claim.

**Path Parameters**:
- `claim_id` (required): The claim ID

**Response**:
```json
{
  "claim_id": "CLM00001",
  "member_id": "MEM00001",
  "member_name": "Jane Smith",
  "claim_amount": "$5,000",
  "status": "approved",
  "submission_date": "2026-01-15",
  "approval_date": "2026-02-01",
  "details": {
    "service_provider": "City Hospital",
    "service_date": "2026-01-10",
    "diagnosis": "Routine Checkup",
    "treatment": "Medical Consultation"
  }
}
```

#### Approve Claim
```
POST /api/v1/claims/{claim_id}/approve
```

Approves a pending claim.

**Path Parameters**:
- `claim_id` (required): The claim ID

**Response**:
```json
{
  "claim_id": "CLM00001",
  "status": "approved",
  "approved_by": "admin@insurance.com",
  "approved_at": "2026-02-22T10:30:00.000000",
  "message": "Claim approved successfully"
}
```

---

### Reports

#### Get Summary Report
```
GET /api/v1/reports/summary?date_range={date_range}
```

Returns summary statistics for claims.

**Query Parameters**:
- `date_range` (optional, default: "month"): month, quarter, or year

**Response**:
```json
{
  "period": "month",
  "total_claims": 1250,
  "approved": 1000,
  "pending": 150,
  "rejected": 100,
  "total_amount": "$5,000,000",
  "average_processing_time": "5 days",
  "generated_at": "2026-02-22T10:30:00.000000"
}
```

#### Get Performance Report
```
GET /api/v1/reports/performance
```

Returns performance metrics by team.

**Response**:
```json
{
  "processing_team": [
    {
      "team_id": "TEAM001",
      "team_name": "Claims Processing",
      "claims_processed": 450,
      "average_time": "4.5 days",
      "approval_rate": "85%"
    }
  ],
  "report_date": "2026-02-22T10:30:00.000000"
}
```

---

### Admin Functions

#### List Users
```
GET /api/v1/admin/users?role={role}
```

Lists all internal users.

**Query Parameters**:
- `role` (optional): Filter by role (admin, claims_officer, validator)

**Response**:
```json
{
  "total_users": 50,
  "active_users": 48,
  "role_filter": null,
  "users": [
    {
      "user_id": "USER001",
      "name": "Employee 1",
      "email": "emp1@insurance.com",
      "role": "admin",
      "status": "active",
      "last_login": "2026-02-22T10:30:00.000000"
    }
  ]
}
```

#### Deactivate User
```
POST /api/v1/admin/users/{user_id}/deactivate
```

Deactivates a user account.

**Path Parameters**:
- `user_id` (required): The user ID

**Response**:
```json
{
  "user_id": "USER001",
  "status": "deactivated",
  "deactivated_at": "2026-02-22T10:30:00.000000",
  "message": "User deactivated successfully"
}
```

---

## Error Responses

All error responses follow this format:

```json
{
  "detail": "Error message",
  "timestamp": "2026-02-22T10:30:00.000000"
}
```

### Common HTTP Status Codes

- `200 OK`: Request successful
- `400 Bad Request`: Invalid request parameters
- `401 Unauthorized`: Authentication required
- `403 Forbidden`: Access denied
- `404 Not Found`: Resource not found
- `500 Internal Server Error`: Server error

---

## Interactive API Documentation

Browse the interactive API documentation at:
```
https://medical-intranet-site.azurewebsites.net/docs
```

---

## Rate Limiting

No rate limiting is currently implemented in this lab environment.

---

## Versioning

Current API version: `v1`

All endpoints use the `/api/v1/` prefix.

---

## Testing with cURL

```bash
# Health check
curl https://medical-intranet-site.azurewebsites.net/health

# Get dashboard
curl https://medical-intranet-site.azurewebsites.net/api/v1/dashboard

# List claims
curl 'https://medical-intranet-site.azurewebsites.net/api/v1/claims?limit=5'

# Get specific claim
curl https://medical-intranet-site.azurewebsites.net/api/v1/claims/CLM00001

# Approve claim
curl -X POST https://medical-intranet-site.azurewebsites.net/api/v1/claims/CLM00001/approve

# Get summary report
curl https://medical-intranet-site.azurewebsites.net/api/v1/reports/summary

# List users
curl https://medical-intranet-site.azurewebsites.net/api/v1/admin/users
```

---

## Testing with Python

```python
import requests

# Base URL
BASE_URL = "https://medical-intranet-site.azurewebsites.net"

# Health check
response = requests.get(f"{BASE_URL}/health")
print(response.json())

# Get claims
response = requests.get(f"{BASE_URL}/api/v1/claims?limit=5")
print(response.json())

# Get claim details
response = requests.get(f"{BASE_URL}/api/v1/claims/CLM00001")
print(response.json())

# Approve claim
response = requests.post(f"{BASE_URL}/api/v1/claims/CLM00001/approve")
print(response.json())
```

---

## Support

For issues or questions about the API, refer to:
- `README.md` - Project overview
- `QUICK_START.md` - Deployment instructions
- `infra/azure-deployment.md` - Azure setup guide
- GitHub Issues in the repository
