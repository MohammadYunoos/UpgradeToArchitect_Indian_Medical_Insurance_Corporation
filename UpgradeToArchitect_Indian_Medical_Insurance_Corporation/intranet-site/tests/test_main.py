import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

class TestHealth:
    def test_health_check(self):
        """Test health check endpoint"""
        response = client.get("/health")
        assert response.status_code == 200
        assert response.json()["status"] == "healthy"
        assert response.json()["service"] == "intranet-site"

class TestRoot:
    def test_root_endpoint(self):
        """Test root endpoint"""
        response = client.get("/")
        assert response.status_code == 200
        assert "message" in response.json()

class TestDashboard:
    def test_get_dashboard(self):
        """Test dashboard endpoint"""
        response = client.get("/api/v1/dashboard")
        assert response.status_code == 200
        data = response.json()
        assert "employee_id" in data
        assert "pending_claims" in data

class TestClaims:
    def test_list_claims(self):
        """Test list claims endpoint"""
        response = client.get("/api/v1/claims")
        assert response.status_code == 200
        data = response.json()
        assert "claims" in data
        assert "total" in data

    def test_list_claims_with_filter(self):
        """Test list claims with status filter"""
        response = client.get("/api/v1/claims?status=pending&limit=5")
        assert response.status_code == 200
        data = response.json()
        assert len(data["claims"]) == 5

    def test_get_claim_details(self):
        """Test get claim details"""
        response = client.get("/api/v1/claims/CLM00001")
        assert response.status_code == 200
        data = response.json()
        assert data["claim_id"] == "CLM00001"

    def test_get_claim_invalid_id(self):
        """Test get claim with invalid ID"""
        response = client.get("/api/v1/claims/")
        assert response.status_code == 404

    def test_approve_claim(self):
        """Test approve claim endpoint"""
        response = client.post("/api/v1/claims/CLM00001/approve")
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "approved"

class TestReports:
    def test_summary_report(self):
        """Test summary report endpoint"""
        response = client.get("/api/v1/reports/summary")
        assert response.status_code == 200
        data = response.json()
        assert "total_claims" in data
        assert "approved" in data

    def test_performance_report(self):
        """Test performance report endpoint"""
        response = client.get("/api/v1/reports/performance")
        assert response.status_code == 200
        data = response.json()
        assert "processing_team" in data

class TestAdminFunctions:
    def test_list_users(self):
        """Test list users endpoint"""
        response = client.get("/api/v1/admin/users")
        assert response.status_code == 200
        data = response.json()
        assert "users" in data
        assert "total_users" in data

    def test_deactivate_user(self):
        """Test deactivate user endpoint"""
        response = client.post("/api/v1/admin/users/USER001/deactivate")
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "deactivated"
