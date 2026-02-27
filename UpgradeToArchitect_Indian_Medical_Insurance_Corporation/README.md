# Medical Insurance Platform - Azure App Service Deployment

This project contains two independent applications:
1. **Intranet Site** - Employee and internal staff portal
2. **Internet Site** - Public-facing customer portal

Both applications are built with Python FastAPI and deployed to Azure App Service.

## Project Structure

```
medical-insurance-app/
├── intranet-site/          # Internal employee portal
│   ├── app/
│   ├── tests/
│   ├── requirements.txt
│   ├── Dockerfile
│   └── .github/workflows/
│
├── internet-site/          # Public customer portal
│   ├── app/
│   ├── tests/
│   ├── requirements.txt
│   ├── Dockerfile
│   └── .github/workflows/
│
├── shared/                 # Shared utilities and configs
│   ├── models.py
│   ├── config.py
│   └── utils.py
│
└── infra/                  # Infrastructure and deployment
    ├── azure-deployment.md
    └── docker-compose.yml
```

## Prerequisites

- Python 3.9+
- Docker Desktop
- Azure CLI
- Azure subscription with App Service plan
- GitHub repository

## Deployment Architecture

```
GitHub Repository
       ↓
GitHub Actions CI/CD Pipeline
       ↓
Docker Build & Registry
       ↓
Azure App Service Deployment
       ↓
Production (Intranet + Internet Sites)
```

## Quick Start

### Local Development

1. **Intranet Site:**
```bash
cd intranet-site
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python -m uvicorn app.main:app --reload
```

2. **Internet Site:**
```bash
cd internet-site
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python -m uvicorn app.main:app --reload
```

### Docker Deployment

```bash
# Build and run Intranet
docker build -t intranet-site:latest ./intranet-site
docker run -p 8001:8000 intranet-site:latest

# Build and run Internet
docker build -t internet-site:latest ./internet-site
docker run -p 8002:8000 internet-site:latest
```

## Azure App Service Deployment

See `infra/azure-deployment.md` for detailed Azure deployment instructions.

## CI/CD Pipeline

- Automated tests on every pull request
- Automated Docker build and push on merge to main
- Automated deployment to Azure App Service

## Features

### Intranet Site
- Employee authentication (Azure AD)
- Internal claims management
- Employee dashboard
- Reports and analytics
- Admin portal

### Internet Site
- Policy information
- Customer registration
- Premium calculation
- Claim submission
- Policy status tracking

## Environment Variables

Both sites require:
```
APP_NAME=intranet-site (or internet-site)
ENVIRONMENT=production
LOG_LEVEL=INFO
```

## Security

- All sensitive data stored in Azure Key Vault
- HTTPS/TLS encryption
- Role-based access control (RBAC)
- Secure API endpoints
- Input validation and sanitization

## Monitoring

- Azure Application Insights integration
- Centralized logging
- Performance monitoring
- Alert configuration

## Support

For deployment issues, refer to:
- `infra/azure-deployment.md` - Step-by-step Azure setup
- GitHub Actions logs in repository
- Azure App Service diagnostic logs
