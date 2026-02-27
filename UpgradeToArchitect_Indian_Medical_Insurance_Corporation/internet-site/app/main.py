from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import logging
from datetime import datetime
import os
from typing import Optional

# Configure logging
logging.basicConfig(level=os.getenv("LOG_LEVEL", "INFO"))
logger = logging.getLogger(__name__)

app = FastAPI(
    title="Medical Insurance - Internet Portal",
    description="Public-facing customer portal for policy and claims",
    version="1.0.0"
)

# CORS Middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=os.getenv("ALLOWED_ORIGINS", "*").split(","),
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Health check endpoint
@app.get("/health")
async def health_check():
    """Health check endpoint for Azure App Service"""
    return {
        "status": "healthy",
        "timestamp": datetime.utcnow().isoformat(),
        "service": "internet-site",
        "version": "1.0.0"
    }

# Root endpoint
@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "message": "Medical Insurance - Customer Portal API",
        "version": "1.0.0",
        "timestamp": datetime.utcnow().isoformat()
    }

# Public Information
@app.get("/api/v1/info/policies")
async def list_policies():
    """List available insurance policies"""
    return {
        "total_policies": 5,
        "policies": [
            {
                "policy_id": "POL001",
                "name": "Basic Health Coverage",
                "premium_monthly": "$50",
                "coverage": "$50,000",
                "description": "Basic health insurance for individuals"
            },
            {
                "policy_id": "POL002",
                "name": "Premium Family Plan",
                "premium_monthly": "$150",
                "coverage": "$200,000",
                "description": "Comprehensive family health insurance"
            },
            {
                "policy_id": "POL003",
                "name": "Senior Citizens Plan",
                "premium_monthly": "$80",
                "coverage": "$100,000",
                "description": "Special plan for senior citizens (60+)"
            },
            {
                "policy_id": "POL004",
                "name": "Maternity Coverage",
                "premium_monthly": "$60",
                "coverage": "$75,000",
                "description": "Maternity and child care coverage"
            },
            {
                "policy_id": "POL005",
                "name": "Critical Illness Plan",
                "premium_monthly": "$100",
                "coverage": "$150,000",
                "description": "Coverage for critical illnesses"
            }
        ]
    }

@app.get("/api/v1/info/policies/{policy_id}")
async def get_policy_details(policy_id: str):
    """Get detailed policy information"""
    if not policy_id:
        raise HTTPException(status_code=400, detail="Invalid policy ID")
    
    return {
        "policy_id": policy_id,
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

# Customer Registration & Authentication
@app.post("/api/v1/auth/register")
async def register_customer(email: str, password: str, full_name: str):
    """Register a new customer"""
    if not all([email, password, full_name]):
        raise HTTPException(status_code=400, detail="Missing required fields")
    
    return {
        "customer_id": "CUST12345",
        "email": email,
        "name": full_name,
        "status": "registered",
        "created_at": datetime.utcnow().isoformat(),
        "message": "Registration successful. Please verify your email."
    }

@app.post("/api/v1/auth/login")
async def login_customer(email: str, password: str):
    """Login customer"""
    # Demo only - in production use proper authentication
    return {
        "access_token": "demo_token_12345",
        "token_type": "bearer",
        "expires_in": 86400,
        "customer_id": "CUST12345",
        "email": email
    }

# Customer Profile
@app.get("/api/v1/profile")
async def get_customer_profile(customer_id: str = "CUST12345"):
    """Get customer profile"""
    return {
        "customer_id": customer_id,
        "name": "John Smith",
        "email": "john.smith@email.com",
        "phone": "555-1234",
        "dob": "1980-05-15",
        "address": "123 Main Street, City, State 12345",
        "member_since": "2020-01-15",
        "status": "active"
    }

# Premium Calculation
@app.post("/api/v1/premium/calculate")
async def calculate_premium(policy_id: str, age: int, coverage_amount: float):
    """Calculate premium based on policy and demographics"""
    if age < 18:
        raise HTTPException(status_code=400, detail="Age must be 18 or above")
    
    base_premium = 50
    age_factor = (age - 18) * 0.5 if age > 30 else 0
    coverage_factor = coverage_amount / 50000
    
    calculated_premium = base_premium * (1 + age_factor/100) * coverage_factor
    
    return {
        "policy_id": policy_id,
        "age": age,
        "coverage_amount": coverage_amount,
        "monthly_premium": f"${calculated_premium:.2f}",
        "annual_premium": f"${calculated_premium * 12:.2f}",
        "calculation_date": datetime.utcnow().isoformat()
    }

# Policy Management
@app.get("/api/v1/my-policies")
async def get_my_policies(customer_id: str = "CUST12345"):
    """Get customer's active policies"""
    return {
        "customer_id": customer_id,
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
            },
            {
                "policy_number": "POL-2022-005678",
                "policy_type": "Critical Illness Plan",
                "status": "active",
                "start_date": "2022-06-01",
                "renewal_date": "2027-06-01",
                "premium_monthly": "$100",
                "coverage_limit": "$150,000",
                "utilization": "5%"
            }
        ]
    }

# Claims Submission
@app.post("/api/v1/claims/submit")
async def submit_claim(
    policy_id: str,
    amount: float,
    description: str,
    service_date: str
):
    """Submit a new claim"""
    if amount <= 0:
        raise HTTPException(status_code=400, detail="Amount must be greater than 0")
    
    return {
        "claim_id": "CLM-2026-000123",
        "policy_id": policy_id,
        "amount": f"${amount}",
        "status": "submitted",
        "submission_date": datetime.utcnow().isoformat(),
        "service_date": service_date,
        "description": description,
        "message": "Claim submitted successfully. You will be notified of the status.",
        "estimated_response_time": "5-7 business days"
    }

@app.get("/api/v1/claims/status/{claim_id}")
async def get_claim_status(claim_id: str):
    """Get claim status"""
    return {
        "claim_id": claim_id,
        "status": "approved",
        "submitted_date": "2026-01-15",
        "approval_date": "2026-02-01",
        "amount": "$5,000",
        "approved_amount": "$4,500",
        "denial_reason": None,
        "payment_date": "2026-02-05",
        "timeline": [
            {"date": "2026-01-15", "status": "submitted", "note": "Claim received"},
            {"date": "2026-01-20", "status": "under_review", "note": "Being processed"},
            {"date": "2026-02-01", "status": "approved", "note": "Claim approved"},
            {"date": "2026-02-05", "status": "paid", "note": "Payment processed"}
        ]
    }

# Contact Information
@app.get("/api/v1/contact")
async def get_contact_info():
    """Get company contact information"""
    return {
        "company_name": "Medical Insurance Corporation",
        "phone": "1-800-MEDICAL-1",
        "email": "support@medicalinsurance.com",
        "website": "www.medicalinsurance.com",
        "address": "123 Insurance Plaza, Healthcare City, ST 12345",
        "hours": "Mon-Fri: 9AM-6PM, Sat: 10AM-2PM",
        "support_centers": [
            {"city": "New Delhi", "phone": "011-XXXX-XXXX"},
            {"city": "Mumbai", "phone": "022-XXXX-XXXX"},
            {"city": "Bangalore", "phone": "080-XXXX-XXXX"}
        ]
    }

# Error Handlers
@app.exception_handler(HTTPException)
async def http_exception_handler(request, exc):
    return JSONResponse(
        status_code=exc.status_code,
        content={"detail": exc.detail, "timestamp": datetime.utcnow().isoformat()},
    )

@app.exception_handler(Exception)
async def general_exception_handler(request, exc):
    logger.error(f"Unhandled exception: {str(exc)}")
    return JSONResponse(
        status_code=500,
        content={"detail": "Internal server error", "timestamp": datetime.utcnow().isoformat()},
    )

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
