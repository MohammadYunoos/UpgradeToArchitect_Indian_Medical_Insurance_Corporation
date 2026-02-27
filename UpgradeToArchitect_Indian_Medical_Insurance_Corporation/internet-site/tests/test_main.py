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
        assert response.json()["service"] == "internet-site"

class TestRoot:
    def test_root_endpoint(self):
        """Test root endpoint"""
        response = client.get("/")
        assert response.status_code == 200
        assert "message" in response.json()

class TestPolicies:
    def test_list_policies(self):
        """Test list policies endpoint"""
        response = client.get("/api/v1/info/policies")
        assert response.status_code == 200
        data = response.json()
        assert "policies" in data
        assert "total_policies" in data

    def test_get_policy_details(self):
        """Test get policy details"""
        response = client.get("/api/v1/info/policies/POL001")
        assert response.status_code == 200
        data = response.json()
        assert data["policy_id"] == "POL001"
        assert "coverage_includes" in data

class TestAuthentication:
    def test_register_customer(self):
        """Test customer registration"""
        response = client.post(
            "/api/v1/auth/register",
            params={
                "email": "test@example.com",
                "password": "securepass123",
                "full_name": "Test User"
            }
        )
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "registered"

    def test_login_customer(self):
        """Test customer login"""
        response = client.post(
            "/api/v1/auth/login",
            params={
                "email": "test@example.com",
                "password": "securepass123"
            }
        )
        assert response.status_code == 200
        data = response.json()
        assert "access_token" in data

class TestCustomerProfile:
    def test_get_profile(self):
        """Test get customer profile"""
        response = client.get("/api/v1/profile")
        assert response.status_code == 200
        data = response.json()
        assert "customer_id" in data
        assert "email" in data

class TestPremiumCalculation:
    def test_calculate_premium(self):
        """Test premium calculation"""
        response = client.post(
            "/api/v1/premium/calculate",
            params={
                "policy_id": "POL001",
                "age": 30,
                "coverage_amount": 50000
            }
        )
        assert response.status_code == 200
        data = response.json()
        assert "monthly_premium" in data
        assert "annual_premium" in data

    def test_calculate_premium_invalid_age(self):
        """Test premium calculation with invalid age"""
        response = client.post(
            "/api/v1/premium/calculate",
            params={
                "policy_id": "POL001",
                "age": 15,
                "coverage_amount": 50000
            }
        )
        assert response.status_code == 400

class TestCustomerPolicies:
    def test_get_my_policies(self):
        """Test get customer policies"""
        response = client.get("/api/v1/my-policies")
        assert response.status_code == 200
        data = response.json()
        assert "policies" in data
        assert "total_policies" in data

class TestClaimsSubmission:
    def test_submit_claim(self):
        """Test claim submission"""
        response = client.post(
            "/api/v1/claims/submit",
            params={
                "policy_id": "POL001",
                "amount": 5000,
                "description": "Medical consultation",
                "service_date": "2026-01-15"
            }
        )
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "submitted"

    def test_submit_claim_invalid_amount(self):
        """Test claim submission with invalid amount"""
        response = client.post(
            "/api/v1/claims/submit",
            params={
                "policy_id": "POL001",
                "amount": -100,
                "description": "Medical consultation",
                "service_date": "2026-01-15"
            }
        )
        assert response.status_code == 400

    def test_get_claim_status(self):
        """Test get claim status"""
        response = client.get("/api/v1/claims/status/CLM-2026-000123")
        assert response.status_code == 200
        data = response.json()
        assert "status" in data
        assert "timeline" in data

class TestContactInfo:
    def test_get_contact_info(self):
        """Test get contact information"""
        response = client.get("/api/v1/contact")
        assert response.status_code == 200
        data = response.json()
        assert "company_name" in data
        assert "phone" in data
