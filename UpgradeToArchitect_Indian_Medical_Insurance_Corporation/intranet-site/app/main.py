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
    title="Medical Insurance - Intranet Portal",
    description="Internal employee portal for insurance claims and management",
    version="1.0.0"
)

# CORS Middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=os.getenv("ALLOWED_ORIGINS", "http://localhost").split(","),
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
        "service": "intranet-site",
        "version": "1.0.0"
    }

# Root endpoint
@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "message": "Medical Insurance - Intranet Portal API",
        "version": "1.0.0",
        "timestamp": datetime.utcnow().isoformat()
    }

# Employee Dashboard
@app.get("/api/v1/dashboard")
async def get_dashboard():
    """Get employee dashboard data"""
    return {
        "employee_id": "EMP001",
        "name": "John Doe",
        "department": "Claims",
        "pending_claims": 5,
        "processed_claims": 125,
        "total_cases": 130,
        "last_updated": datetime.utcnow().isoformat()
    }

# Claims Management
@app.get("/api/v1/claims")
async def list_claims(status: Optional[str] = None, limit: int = 10):
    """List all claims - optional status filter"""
    return {
        "total": 130,
        "count": limit,
        "status_filter": status,
        "claims": [
            {
                "claim_id": f"CLM{i:05d}",
                "member_id": f"MEM{i:05d}",
                "status": "pending" if i % 3 == 0 else "approved",
                "amount": f"${i * 100}",
                "submitted_date": datetime.utcnow().isoformat()
            }
            for i in range(1, limit + 1)
        ]
    }

@app.get("/api/v1/claims/{claim_id}")
async def get_claim(claim_id: str):
    """Get specific claim details"""
    if not claim_id:
        raise HTTPException(status_code=400, detail="Invalid claim ID")
    
    return {
        "claim_id": claim_id,
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

@app.post("/api/v1/claims/{claim_id}/approve")
async def approve_claim(claim_id: str):
    """Approve a claim"""
    return {
        "claim_id": claim_id,
        "status": "approved",
        "approved_by": "admin@insurance.com",
        "approved_at": datetime.utcnow().isoformat(),
        "message": "Claim approved successfully"
    }

# Reports
@app.get("/api/v1/reports/summary")
async def get_summary_report(date_range: str = "month"):
    """Get summary report"""
    return {
        "period": date_range,
        "total_claims": 1250,
        "approved": 1000,
        "pending": 150,
        "rejected": 100,
        "total_amount": "$5,000,000",
        "average_processing_time": "5 days",
        "generated_at": datetime.utcnow().isoformat()
    }

@app.get("/api/v1/reports/performance")
async def get_performance_report():
    """Get performance metrics"""
    return {
        "processing_team": [
            {
                "team_id": "TEAM001",
                "team_name": "Claims Processing",
                "claims_processed": 450,
                "average_time": "4.5 days",
                "approval_rate": "85%"
            },
            {
                "team_id": "TEAM002",
                "team_name": "Validation",
                "claims_processed": 500,
                "average_time": "3 days",
                "approval_rate": "92%"
            }
        ],
        "report_date": datetime.utcnow().isoformat()
    }

# Admin Functions
@app.get("/api/v1/admin/users")
async def list_users(role: Optional[str] = None):
    """List all internal users"""
    return {
        "total_users": 50,
        "active_users": 48,
        "role_filter": role,
        "users": [
            {
                "user_id": f"USER{i:03d}",
                "name": f"Employee {i}",
                "email": f"emp{i}@insurance.com",
                "role": ["admin", "claims_officer", "validator"][i % 3],
                "status": "active",
                "last_login": datetime.utcnow().isoformat()
            }
            for i in range(1, 6)
        ]
    }

@app.post("/api/v1/admin/users/{user_id}/deactivate")
async def deactivate_user(user_id: str):
    """Deactivate a user"""
    return {
        "user_id": user_id,
        "status": "deactivated",
        "deactivated_at": datetime.utcnow().isoformat(),
        "message": "User deactivated successfully"
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
