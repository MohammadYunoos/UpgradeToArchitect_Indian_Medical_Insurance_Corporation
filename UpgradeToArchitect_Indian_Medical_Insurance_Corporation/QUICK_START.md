# Quick Deployment Guide - Azure App Service Lab

Fast-track guide to deploy both sites to Azure App Service.

## 🚀 5-Minute Quick Start

### Prerequisites
- Azure CLI installed: `brew install azure-cli` (macOS)
- GitHub account with repository access
- Docker Desktop (for local testing)

### Step 1: Login to Azure (1 minute)

```bash
az login
# Select your subscription if prompted
az account set --subscription "Your Subscription ID"
```

### Step 2: Create Azure Resources (2 minutes)

```bash
# Set your resource name (must be globally unique for registry)
export RESOURCE_GROUP="medical-insurance-rg"
export LOCATION="eastus"
export REGISTRY_NAME="medicalreg$(date +%s | tail -c 5)"

# Create resource group
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create Container Registry
az acr create --resource-group $RESOURCE_GROUP --name $REGISTRY_NAME --sku Basic --admin-enabled true

# Create App Service Plan
az appservice plan create \
  --name medical-plan \
  --resource-group $RESOURCE_GROUP \
  --sku B2 \
  --is-linux

# Create Intranet Web App
az webapp create \
  --resource-group $RESOURCE_GROUP \
  --plan medical-plan \
  --name medical-intranet-site \
  --runtime PYTHON:3.11

# Create Internet Web App
az webapp create \
  --resource-group $RESOURCE_GROUP \
  --plan medical-plan \
  --name medical-internet-site \
  --runtime PYTHON:3.11
```

### Step 3: Configure App Services (1 minute)

```bash
# Get registry credentials
ACR_LOGIN_SERVER=$(az acr show --resource-group $RESOURCE_GROUP --name $REGISTRY_NAME --query loginServer -o tsv)
ACR_USERNAME=$(az acr credential show --resource-group $RESOURCE_GROUP --name $REGISTRY_NAME --query username -o tsv)
ACR_PASSWORD=$(az acr credential show --resource-group $RESOURCE_GROUP --name $REGISTRY_NAME --query 'passwords[0].value' -o tsv)

# Configure Intranet Site
az webapp config appsettings set \
  --resource-group $RESOURCE_GROUP \
  --name medical-intranet-site \
  --settings \
    WEBSITES_PORT=8000 \
    DOCKER_REGISTRY_SERVER_URL=https://$ACR_LOGIN_SERVER \
    DOCKER_REGISTRY_SERVER_USERNAME=$ACR_USERNAME \
    DOCKER_REGISTRY_SERVER_PASSWORD=$ACR_PASSWORD \
    LOG_LEVEL=INFO

# Configure Internet Site
az webapp config appsettings set \
  --resource-group $RESOURCE_GROUP \
  --name medical-internet-site \
  --settings \
    WEBSITES_PORT=8000 \
    DOCKER_REGISTRY_SERVER_URL=https://$ACR_LOGIN_SERVER \
    DOCKER_REGISTRY_SERVER_USERNAME=$ACR_USERNAME \
    DOCKER_REGISTRY_SERVER_PASSWORD=$ACR_PASSWORD \
    LOG_LEVEL=INFO

# Configure health checks
az webapp config set \
  --resource-group $RESOURCE_GROUP \
  --name medical-intranet-site \
  --health-check-path /health

az webapp config set \
  --resource-group $RESOURCE_GROUP \
  --name medical-internet-site \
  --health-check-path /health
```

### Step 4: Deploy Images (1 minute)

```bash
# Build and push Intranet image
az acr build --registry $REGISTRY_NAME --image intranet-site:latest ./intranet-site

# Build and push Internet image
az acr build --registry $REGISTRY_NAME --image internet-site:latest ./internet-site

# Deploy to App Services
az webapp config container set \
  --name medical-intranet-site \
  --resource-group $RESOURCE_GROUP \
  --docker-custom-image-name $ACR_LOGIN_SERVER/intranet-site:latest \
  --docker-registry-server-url https://$ACR_LOGIN_SERVER \
  --docker-registry-server-username $ACR_USERNAME \
  --docker-registry-server-password $ACR_PASSWORD

az webapp config container set \
  --name medical-internet-site \
  --resource-group $RESOURCE_GROUP \
  --docker-custom-image-name $ACR_LOGIN_SERVER/internet-site:latest \
  --docker-registry-server-url https://$ACR_LOGIN_SERVER \
  --docker-registry-server-username $ACR_USERNAME \
  --docker-registry-server-password $ACR_PASSWORD
```

### Step 5: Verify Deployment (Done!)

```bash
# Check if apps are running
curl https://medical-intranet-site.azurewebsites.net/health
curl https://medical-internet-site.azurewebsites.net/health

# View logs
az webapp log tail --resource-group $RESOURCE_GROUP --name medical-intranet-site
```

---

## 🔧 Local Testing (Optional)

### Docker Compose Local Test

```bash
# Navigate to project root
cd medical-insurance-app

# Copy environment files
cp intranet-site/.env.example intranet-site/.env
cp internet-site/.env.example internet-site/.env

# Run with Docker Compose
docker-compose -f infra/docker-compose.yml up

# In another terminal, test the APIs
curl http://localhost:8001/health  # Intranet
curl http://localhost:8002/health  # Internet
```

### Local Python Development

#### Intranet Site
```bash
cd intranet-site
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python -m uvicorn app.main:app --reload --port 8001
```

#### Internet Site
```bash
cd internet-site
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python -m uvicorn app.main:app --reload --port 8002
```

---

## 🔑 GitHub Actions Setup (For CI/CD)

### Add GitHub Secrets

1. Go to your GitHub repository
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Add these secrets:

```
AZURE_CREDENTIALS: <paste the JSON from az ad sp create-for-rbac>
REGISTRY_USERNAME: <your-acr-username>
REGISTRY_PASSWORD: <your-acr-password>
```

### Create Service Principal for GitHub

```bash
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
RESOURCE_GROUP="medical-insurance-rg"

az ad sp create-for-rbac \
  --name github-deployer \
  --role Contributor \
  --scopes /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP \
  --sdk-auth
```

Copy the JSON output to GitHub Secrets as `AZURE_CREDENTIALS`.

---

## 📊 Monitoring URLs

After deployment, your applications will be available at:

| Service | URL | Health Check |
|---------|-----|--------------|
| Intranet | `https://medical-intranet-site.azurewebsites.net` | `/health` |
| Internet | `https://medical-internet-site.azurewebsites.net` | `/health` |

### API Documentation

Both sites have auto-generated API documentation available at:
- Intranet: `https://medical-intranet-site.azurewebsites.net/docs`
- Internet: `https://medical-internet-site.azurewebsites.net/docs`

---

## 🐛 Troubleshooting

### Apps not starting?

```bash
# Check logs
az webapp log tail \
  --resource-group $RESOURCE_GROUP \
  --name medical-intranet-site \
  --provider docker

# Check configuration
az webapp show \
  --resource-group $RESOURCE_GROUP \
  --name medical-intranet-site
```

### Image pull errors?

```bash
# Verify registry credentials
az acr credential show \
  --resource-group $RESOURCE_GROUP \
  --name $REGISTRY_NAME

# Check if image exists
az acr repository list \
  --name $REGISTRY_NAME
```

### Connection timeout?

```bash
# Restart the app service
az webapp restart \
  --resource-group $RESOURCE_GROUP \
  --name medical-intranet-site
```

---

## 🧹 Cleanup (Delete All Resources)

```bash
# Delete the entire resource group
az group delete --name $RESOURCE_GROUP --yes

# This will delete:
# - App Services
# - App Service Plan
# - Container Registry
# - All related resources
```

---

## 📚 Additional Resources

- **Full Azure Deployment Guide**: See `infra/azure-deployment.md`
- **API Endpoints**: Check the FastAPI auto-generated docs at `/docs`
- **GitHub Actions Workflows**: Check `.github/workflows/`
- **Docker Setup**: See `infra/docker-compose.yml`

---

## ✅ Checklist

- [ ] Azure CLI installed and logged in
- [ ] GitHub repository created
- [ ] Azure resources created
- [ ] Docker images built and pushed
- [ ] App Services deployed
- [ ] Health checks passing
- [ ] GitHub Actions configured (optional)
- [ ] Monitoring alerts set up (optional)

---

**Congratulations!** Your Medical Insurance Platform is now live on Azure App Service! 🎉
