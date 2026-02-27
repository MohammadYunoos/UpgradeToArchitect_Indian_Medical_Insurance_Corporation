# Medical Insurance Platform - Azure App Service Lab

Complete, production-ready deployment of Intranet and Internet sites for Medical Insurance Corporation on Azure App Service.

## 🎯 Project Overview

This lab provides a fully functional, containerized Python FastAPI application with:

- **2 Independent Web Applications**
  - 🏢 **Intranet Site**: Employee claims management and reporting portal
  - 🌐 **Internet Site**: Public customer portal for policies and claims

- **Complete CI/CD Pipeline**
  - GitHub Actions for automated testing and deployment
  - Azure Container Registry for Docker image management
  - Automated deployment to Azure App Service

- **Enterprise-Ready Features**
  - RESTful APIs with comprehensive documentation
  - Health checks and monitoring
  - Docker containerization
  - Azure integration (Key Vault, Storage, Application Insights)
  - Unit tests included

---

## 📁 Project Structure

```
medical-insurance-app/
├── intranet-site/                 # Employee portal
│   ├── app/
│   │   └── main.py               # FastAPI application
│   ├── tests/
│   │   └── test_main.py          # Unit tests
│   ├── requirements.txt           # Python dependencies
│   ├── Dockerfile                 # Container definition
│   ├── .env.example              # Environment variables template
│   └── .github/workflows/
│       └── deploy-intranet.yml   # CI/CD workflow
│
├── internet-site/                 # Customer portal
│   ├── app/
│   │   └── main.py               # FastAPI application
│   ├── tests/
│   │   └── test_main.py          # Unit tests
│   ├── requirements.txt           # Python dependencies
│   ├── Dockerfile                 # Container definition
│   ├── .env.example              # Environment variables template
│   └── .github/workflows/
│       └── deploy-internet.yml   # CI/CD workflow
│
├── shared/                        # Shared utilities (for future use)
├── infra/
│   ├── azure-deployment.md       # Detailed Azure setup guide
│   └── docker-compose.yml        # Local Docker setup
│
├── docs/
│   ├── INTRANET_API.md          # Intranet API documentation
│   └── INTERNET_API.md          # Internet API documentation
│
├── scripts/
│   └── setup.sh                 # Quick setup script
│
├── README.md                     # This file
├── QUICK_START.md               # Fast-track deployment guide
└── .gitignore                   # Git ignore rules
```

---

## 🚀 Quick Start (5 Minutes)

### 1. Clone & Navigate
```bash
cd medical-insurance-app
```

### 2. Login to Azure
```bash
az login
az account set --subscription "Your Subscription ID"
```

### 3. Run Quick Deployment
```bash
# For complete step-by-step guide, see QUICK_START.md
# Or follow the comprehensive guide in infra/azure-deployment.md
```

### 4. Test Your Deployment
```bash
curl https://medical-intranet-site.azurewebsites.net/health
curl https://medical-internet-site.azurewebsites.net/health
```

**See `QUICK_START.md` for complete 5-minute deployment steps.**

---

## 🔧 Local Development

### Option 1: Docker Compose (Recommended)

```bash
# From project root
docker-compose -f infra/docker-compose.yml up

# In another terminal, test
curl http://localhost:8001/health  # Intranet
curl http://localhost:8002/health  # Internet
```

### Option 2: Local Python Environment

```bash
# Intranet Site
cd intranet-site
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python -m uvicorn app.main:app --reload --port 8001

# In another terminal, Internet Site
cd internet-site
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python -m uvicorn app.main:app --reload --port 8002
```

### Option 3: Using Setup Script

```bash
chmod +x scripts/setup.sh
./scripts/setup.sh both
```

---

## 📊 API Documentation

### Intranet Site API
- **Base URL**: `https://medical-intranet-site.azurewebsites.net`
- **Interactive Docs**: `/docs`
- **Health Check**: `/health`
- **Guide**: See `docs/INTRANET_API.md`

**Key Endpoints**:
- `GET /api/v1/dashboard` - Employee dashboard
- `GET /api/v1/claims` - List claims
- `GET /api/v1/claims/{id}` - Claim details
- `POST /api/v1/claims/{id}/approve` - Approve claim
- `GET /api/v1/reports/summary` - Reports
- `GET /api/v1/admin/users` - User management

### Internet Site API
- **Base URL**: `https://medical-internet-site.azurewebsites.net`
- **Interactive Docs**: `/docs`
- **Health Check**: `/health`
- **Guide**: See `docs/INTERNET_API.md`

**Key Endpoints**:
- `GET /api/v1/info/policies` - List policies
- `GET /api/v1/info/policies/{id}` - Policy details
- `POST /api/v1/auth/register` - Register customer
- `POST /api/v1/auth/login` - Login
- `POST /api/v1/premium/calculate` - Calculate premium
- `POST /api/v1/claims/submit` - Submit claim
- `GET /api/v1/claims/status/{id}` - Claim status

---

## ☁️ Azure Deployment Architecture

```
┌─────────────────┐
│  GitHub Repo    │
│   (Code Push)   │
└────────┬────────┘
         │
         ▼
┌──────────────────────────────┐
│  GitHub Actions              │
│  (Run Tests & Build)         │
└────────┬─────────────────────┘
         │
         ▼
┌──────────────────────────────┐
│  Azure Container Registry    │
│  (Push Docker Images)        │
└────────┬─────────────────────┘
         │
         ├─────────────────────┐
         ▼                     ▼
    ┌──────────┐           ┌──────────┐
    │ App Svc  │           │ App Svc  │
    │ Intranet │           │ Internet │
    │  Site    │           │  Site    │
    └──────────┘           └──────────┘
         ▲                     ▲
         │                     │
         └─────────────────────┘
              (Auto-Deploy)
```

---

## 📋 Deployment Guides

### Quick Start (5 minutes)
→ See **`QUICK_START.md`**

### Complete Guide (Step-by-Step)
→ See **`infra/azure-deployment.md`**

Includes:
- Creating Azure resources
- Container Registry setup
- GitHub Actions configuration
- Health checks & monitoring
- Troubleshooting

---

## 🧪 Testing

### Run Unit Tests Locally

```bash
# Intranet Site
cd intranet-site
pip install pytest pytest-cov
pytest tests/ -v --cov=app

# Internet Site
cd internet-site
pip install pytest pytest-cov
pytest tests/ -v --cov=app
```

### Test with cURL

```bash
# Health checks
curl https://medical-intranet-site.azurewebsites.net/health
curl https://medical-internet-site.azurewebsites.net/health

# Sample API calls
curl https://medical-intranet-site.azurewebsites.net/api/v1/dashboard
curl https://medical-internet-site.azurewebsites.net/api/v1/info/policies
```

### Interactive Testing

Visit the Swagger UI:
- Intranet: `https://medical-intranet-site.azurewebsites.net/docs`
- Internet: `https://medical-internet-site.azurewebsites.net/docs`

---

## 🔐 Security

### Authentication
- Intranet Site: Azure AD (recommended for production)
- Internet Site: API token-based (demo implementation)

### Data Protection
- HTTPS/TLS encryption
- Secrets stored in Azure Key Vault
- Input validation and sanitization
- Non-root Docker containers
- Health checks for availability

### Environment Variables
- Never commit `.env` files
- Use `.env.example` as template
- Store secrets in Azure Key Vault
- Pass via GitHub Secrets for CI/CD

---

## 📊 Monitoring & Logging

### Azure Portal Monitoring
- Application Insights integration
- App Service diagnostics
- Container logs
- Health check status

### View Logs
```bash
az webapp log tail \
  --resource-group medical-insurance-rg \
  --name medical-intranet-site \
  --provider docker
```

### Health Checks
- Intranet: `https://medical-intranet-site.azurewebsites.net/health`
- Internet: `https://medical-internet-site.azurewebsites.net/health`

---

## 🛠️ Technology Stack

| Component | Technology | Version |
|-----------|-----------|---------|
| Framework | FastAPI | 0.104.1 |
| Runtime | Python | 3.11 |
| Container | Docker | Latest |
| Registry | Azure Container Registry | - |
| Hosting | Azure App Service | Linux |
| CI/CD | GitHub Actions | - |
| Testing | pytest | Latest |

---

## 📦 Dependencies

### Python Packages
- **fastapi**: Web framework
- **uvicorn**: ASGI server
- **pydantic**: Data validation
- **python-dotenv**: Environment configuration
- **azure-storage-blob**: Azure Storage integration
- **azure-identity**: Azure authentication
- **applicationinsights**: Monitoring

See `requirements.txt` in each site directory for exact versions.

---

## 🐛 Troubleshooting

### Application Won't Start
```bash
# Check logs
az webapp log tail --resource-group medical-insurance-rg --name medical-intranet-site

# Verify health check
curl https://medical-intranet-site.azurewebsites.net/health
```

### Docker Build Fails
```bash
# Build locally first
docker build -t intranet-site:test ./intranet-site

# Test locally
docker run -p 8001:8000 intranet-site:test
```

### GitHub Actions Errors
- Check secrets are configured correctly
- Verify Azure credentials are valid
- Check GitHub workflow logs

**See `infra/azure-deployment.md` for detailed troubleshooting.**

---

## 📝 CI/CD Pipeline

### Automatic Workflows
1. **On Pull Request**: Run tests
2. **On Merge to Main**: Build Docker image
3. **Push to Registry**: Azure Container Registry
4. **Deploy**: Azure App Service (automatic)

### Manual Deployment
```bash
# Build and push manually
az acr build --registry medicalregistry --image intranet-site:latest ./intranet-site

# Deploy
az webapp restart --resource-group medical-insurance-rg --name medical-intranet-site
```

---

## 🧹 Cleanup

Delete all Azure resources:
```bash
az group delete --resource-group medical-insurance-rg --yes
```

---

## 📚 Documentation

| Document | Purpose |
|----------|---------|
| `README.md` | Project overview (this file) |
| `QUICK_START.md` | 5-minute deployment guide |
| `infra/azure-deployment.md` | Complete Azure setup guide |
| `docs/INTRANET_API.md` | Intranet API reference |
| `docs/INTERNET_API.md` | Internet API reference |

---

## ✅ Deployment Checklist

- [ ] Azure CLI installed and authenticated
- [ ] GitHub repository created and cloned
- [ ] Azure resources created (Resource Group, App Service Plan)
- [ ] Container Registry created
- [ ] Docker images built and pushed
- [ ] App Services configured and deployed
- [ ] Health checks passing
- [ ] GitHub Secrets configured (optional for CI/CD)
- [ ] GitHub Actions enabled
- [ ] APIs tested and working

---

## 🎯 Key URLs (After Deployment)

| Service | URL |
|---------|-----|
| Intranet Site | `https://medical-intranet-site.azurewebsites.net` |
| Intranet API Docs | `https://medical-intranet-site.azurewebsites.net/docs` |
| Intranet Health | `https://medical-intranet-site.azurewebsites.net/health` |
| Internet Site | `https://medical-internet-site.azurewebsites.net` |
| Internet API Docs | `https://medical-internet-site.azurewebsites.net/docs` |
| Internet Health | `https://medical-internet-site.azurewebsites.net/health` |

---

## 💡 Next Steps (After Basic Deployment)

1. **Configure Custom Domain**: Add DNS records for custom domains
2. **Set Up SSL Certificates**: Import or auto-manage certificates
3. **Configure Scaling**: Set auto-scale rules based on metrics
4. **Add Monitoring Alerts**: Get notifications for issues
5. **Implement Authentication**: Connect to Azure AD for intranet
6. **Add Database**: Integrate Azure SQL Database
7. **Set Up Backup**: Configure disaster recovery
8. **Configure WAF**: Enable Web Application Firewall

---

## 📞 Support & Resources

- **Azure Documentation**: https://docs.microsoft.com/azure
- **FastAPI Documentation**: https://fastapi.tiangolo.com
- **GitHub Actions**: https://github.com/features/actions
- **Docker Documentation**: https://docs.docker.com

---

## 📄 License

This lab project is provided as-is for educational purposes.

---

## 👥 Contributing

To contribute to this project:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

---

## 🎉 Congratulations!

You've successfully set up the Medical Insurance Platform on Azure App Service. Both sites are now live and ready for use!

**Need help?** Check out:
- `QUICK_START.md` for deployment
- `infra/azure-deployment.md` for detailed setup
- API documentation at `/docs` endpoint on each site

---

**Last Updated**: February 22, 2026
**Status**: ✅ Production Ready for Lab Use
