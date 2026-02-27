# Internet Site API Documentation

## Overview

The Internet Site provides public-facing customer portal functionality for policy information, premium calculation, and claims submission.

**Base URL**: `https://medical-internet-site.azurewebsites.net`

**Authentication**: Optional (public API with some protected endpoints)

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
  "service": "internet-site",
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
  "message": "Medical Insurance - Customer Portal API",
  "version": "1.0.0",
  "timestamp": "2026-02-22T10:30:00.000000"
}
```

---

### Public Information

#### List Available Policies
```
GET /api/v1/info/policies
```

Returns list of all available insurance policies.

**Response**:
```json
{
  "total_policies": 5,
  "policies": [
    {
      "policy_id": "POL001",
      "name": "Basic Health Coverage",
      "premium_monthly": "$50",
      "coverage": "$50,000",
      "description": "Basic health insurance for individuals"
    }
  ]
}
```

#### Get Policy Details
```
GET /api/v1/info/policies/{policy_id}
```

Returns detailed information about a specific policy.

**Path Parameters**:
- `policy_id` (required): The policy ID

**Response**:
```json
{
  "policy_id": "POL001",
  "name": "Basic Health Coverage",
  "premium_monthly": "$50",
  "coverage_limit": "$50,000",
  "deductible": "$500",
  "description": "Basic health insurance for individuals",
  "coverage_includes": [
    "Hospitalization",
    "Doctor consultations",
    "Diagnostic tests",
    "Prescription medications"
  ],
  "coverage_excludes": [
    "Cosmetic procedures",
    "Pre-existing conditions (first 12 months)",
    "Experimental treatments"
  ],
  "waiting_period_days": 90
}
```

---

### Authentication

#### Register Customer
```
POST /api/v1/auth/register
```

Registers a new customer account.

**Query Parameters**:
- `email` (required): Customer email
- `password` (required): Customer password
- `full_name` (required): Customer full name

**Response**:
```json
{
  "customer_id": "CUST12345",
  "email": "customer@example.com",
  "name": "John Smith",
  "status": "registered",
  "created_at": "2026-02-22T10:30:00.000000",
  "message": "Registration successful. Please verify your email."
}
```

#### Login Customer
```
POST /api/v1/auth/login
```

Authenticates a customer and returns access token.

**Query Parameters**:
- `email` (required): Customer email
- `password` (required): Customer password

**Response**:
```json
{
  "access_token": "demo_token_12345",
  "token_type": "bearer",
  "expires_in": 86400,
  "customer_id": "CUST12345",
  "email": "customer@example.com"
}
```

---

### Customer Profile

#### Get Customer Profile
```
GET /api/v1/profile
```

Returns the authenticated customer's profile information.

**Query Parameters**:
- `customer_id` (optional): Customer ID (defaults to authenticated user)

**Response**:
```json
{
  "customer_id": "CUST12345",
  "name": "John Smith",
  "email": "john.smith@email.com",
  "phone": "555-1234",
  "dob": "1980-05-15",
  "address": "123 Main Street, City, State 12345",
  "member_since": "2020-01-15",
  "status": "active"
}
```

---

### Premium Calculation

#### Calculate Premium
```
POST /api/v1/premium/calculate
```

Calculates insurance premium based on policy and demographics.

**Query Parameters**:
- `policy_id` (required): Policy ID
- `age` (required): Customer age (must be 18+)
- `coverage_amount` (required): Desired coverage amount

**Response**:
```json
{
  "policy_id": "POL001",
  "age": 30,
  "coverage_amount": 50000,
  "monthly_premium": "$50.00",
  "annual_premium": "$600.00",
  "calculation_date": "2026-02-22T10:30:00.000000"
}
```

---

### Policy Management

#### Get My Policies
```
GET /api/v1/my-policies
```

Returns all policies owned by the customer.

**Query Parameters**:
- `customer_id` (optional): Customer ID

**Response**:
```json
{
  "customer_id": "CUST12345",
  "total_policies": 2,
  "policies": [
    {
      "policy_number": "POL-2020-001234",
      "policy_type": "Basic Health Coverage",
      "status": "active",
      "start_date": "2020-01-15",
      "renewal_date": "2026-01-15",
      "premium_monthly": "$50",
      "coverage_limit": "$50,000",
      "utilization": "30%"
    }
  ]
}
```

---

### Claims Management

#### Submit Claim
```
POST /api/v1/claims/submit
```

Submits a new insurance claim.

**Query Parameters**:
- `policy_id` (required): Policy ID
- `amount` (required): Claim amount (must be > 0)
- `description` (required): Description of claim
- `service_date` (required): Date of service (YYYY-MM-DD)

**Response**:
```json
{
  "claim_id": "CLM-2026-000123",
  "policy_id": "POL001",
  "amount": "$5000",
  "status": "submitted",
  "submission_date": "2026-02-22T10:30:00.000000",
  "service_date": "2026-01-15",
  "description": "Medical consultation",
  "message": "Claim submitted successfully. You will be notified of the status.",
  "estimated_response_time": "5-7 business days"
}
```

#### Get Claim Status
```
GET /api/v1/claims/status/{claim_id}
```

Returns the status and details of a specific claim.

**Path Parameters**:
- `claim_id` (required): The claim ID

**Response**:
```json
{
  "claim_id": "CLM-2026-000123",
  "status": "approved",
  "submitted_date": "2026-01-15",
  "approval_date": "2026-02-01",
  "amount": "$5,000",
  "approved_amount": "$4,500",
  "denial_reason": null,
  "payment_date": "2026-02-05",
  "timeline": [
    {
      "date": "2026-01-15",
      "status": "submitted",
      "note": "Claim received"
    },
    {
      "date": "2026-02-01",
      "status": "approved",
      "note": "Claim approved"
    },
    {
      "date": "2026-02-05",
      "status": "paid",
      "note": "Payment processed"
    }
  ]
}
```

---

### Contact Information

#### Get Contact Info
```
GET /api/v1/contact
```

Returns company contact information.

**Response**:
```json
{
  "company_name": "Medical Insurance Corporation",
  "phone": "1-800-MEDICAL-1",
  "email": "support@medicalinsurance.com",
  "website": "www.medicalinsurance.com",
  "address": "123 Insurance Plaza, Healthcare City, ST 12345",
  "hours": "Mon-Fri: 9AM-6PM, Sat: 10AM-2PM",
  "support_centers": [
    {
      "city": "New Delhi",
      "phone": "011-XXXX-XXXX"
    }
  ]
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
https://medical-internet-site.azurewebsites.net/docs
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
curl https://medical-internet-site.azurewebsites.net/health

# List policies
curl https://medical-internet-site.azurewebsites.net/api/v1/info/policies

# Get policy details
curl https://medical-internet-site.azurewebsites.net/api/v1/info/policies/POL001

# Calculate premium
curl -X POST 'https://medical-internet-site.azurewebsites.net/api/v1/premium/calculate?policy_id=POL001&age=30&coverage_amount=50000'

# Get contact info
curl https://medical-internet-site.azurewebsites.net/api/v1/contact
```

---

## Testing with Python

```python
import requests

# Base URL
BASE_URL = "https://medical-internet-site.azurewebsites.net"

# Health check
response = requests.get(f"{BASE_URL}/health")
print(response.json())

# List policies
response = requests.get(f"{BASE_URL}/api/v1/info/policies")
print(response.json())

# Get policy details
response = requests.get(f"{BASE_URL}/api/v1/info/policies/POL001")
print(response.json())

# Calculate premium
response = requests.post(
    f"{BASE_URL}/api/v1/premium/calculate",
    params={
        "policy_id": "POL001",
        "age": 30,
        "coverage_amount": 50000
    }
)
print(response.json())

# Submit claim
response = requests.post(
    f"{BASE_URL}/api/v1/claims/submit",
    params={
        "policy_id": "POL001",
        "amount": 5000,
        "description": "Medical consultation",
        "service_date": "2026-01-15"
    }
)
print(response.json())
```

---

## Support

For issues or questions about the API, refer to:
- `README.md` - Project overview
- `QUICK_START.md` - Deployment instructions
- `infra/azure-deployment.md` - Azure setup guide
- GitHub Issues in the repository
