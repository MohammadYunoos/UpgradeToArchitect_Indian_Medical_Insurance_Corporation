# Azure App Service Deployment Guide

Complete step-by-step guide for deploying both the Intranet and Internet sites to Azure App Service.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Azure Resource Setup](#azure-resource-setup)
3. [Container Registry Setup](#container-registry-setup)
4. [GitHub Actions Configuration](#github-actions-configuration)
5. [App Service Configuration](#app-service-configuration)
6. [Deployment](#deployment)
7. [Monitoring and Troubleshooting](#monitoring-and-troubleshooting)

---

## Prerequisites

- Azure Subscription (with App Service plan capability)
- Azure CLI installed locally
- GitHub account and repository
- Docker Desktop (for local testing)
- Python 3.9+ (for local development)

### Install Azure CLI

```bash
# macOS
brew install azure-cli

# Windows (PowerShell)
choco install azure-cli

# Linux
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

---

## Azure Resource Setup

### Step 1: Login to Azure

```bash
az login
```

This opens your browser. Sign in with your Azure credentials.

### Step 2: Create Resource Group

```bash
# Set variables
RESOURCE_GROUP="medical-insurance-rg"
LOCATION="eastus"  # Change as needed

# Create resource group
az group create \
  --name $RESOURCE_GROUP \
  --location $LOCATION
```

### Step 3: Create App Service Plan

```bash
APP_SERVICE_PLAN="medical-insurance-plan"
SKU="B2"  # Basic tier with 2 cores (suitable for lab)

# Create App Service Plan
az appservice plan create \
  --name $APP_SERVICE_PLAN \
  --resource-group $RESOURCE_GROUP \
  --sku $SKU \
  --is-linux
```

### Step 4: Create Web Apps

#### Intranet Site

```bash
INTRANET_WEBAPP="medical-intranet-site"

az webapp create \
  --resource-group $RESOURCE_GROUP \
  --plan $APP_SERVICE_PLAN \
  --name $INTRANET_WEBAPP \
  --deployment-container-image-name-user medicalregistry \
  --deployment-container-image-name medicalregistry.azurecr.io/intranet-site:latest
```

#### Internet Site

```bash
INTERNET_WEBAPP="medical-internet-site"

az webapp create \
  --resource-group $RESOURCE_GROUP \
  --plan $APP_SERVICE_PLAN \
  --name $INTERNET_WEBAPP \
  --deployment-container-image-name-user medicalregistry \
  --deployment-container-image-name medicalregistry.azurecr.io/internet-site:latest
```

### Step 5: Configure App Settings

#### Intranet Site

```bash
az webapp config appsettings set \
  --resource-group $RESOURCE_GROUP \
  --name $INTRANET_WEBAPP \
  --settings \
    WEBSITES_PORT=8000 \
    DOCKER_REGISTRY_SERVER_URL=https://medicalregistry.azurecr.io \
    DOCKER_REGISTRY_SERVER_USERNAME=$ACR_USERNAME \
    DOCKER_REGISTRY_SERVER_PASSWORD=$ACR_PASSWORD \
    LOG_LEVEL=INFO \
    ENVIRONMENT=production \
    ALLOWED_ORIGINS=https://$INTRANET_WEBAPP.azurewebsites.net
```

#### Internet Site

```bash
az webapp config appsettings set \
  --resource-group $RESOURCE_GROUP \
  --name $INTERNET_WEBAPP \
  --settings \
    WEBSITES_PORT=8000 \
    DOCKER_REGISTRY_SERVER_URL=https://medicalregistry.azurecr.io \
    DOCKER_REGISTRY_SERVER_USERNAME=$ACR_USERNAME \
    DOCKER_REGISTRY_SERVER_PASSWORD=$ACR_PASSWORD \
    LOG_LEVEL=INFO \
    ENVIRONMENT=production \
    ALLOWED_ORIGINS=https://$INTERNET_WEBAPP.azurewebsites.net
```

---

## Container Registry Setup

### Step 1: Create Azure Container Registry

```bash
REGISTRY_NAME="medicalregistry"  # Must be globally unique

az acr create \
  --resource-group $RESOURCE_GROUP \
  --name $REGISTRY_NAME \
  --sku Basic \
  --admin-enabled true
```

### Step 2: Get Registry Credentials

```bash
# Get login server
REGISTRY_LOGIN_SERVER=$(az acr show \
  --resource-group $RESOURCE_GROUP \
  --name $REGISTRY_NAME \
  --query loginServer -o tsv)

# Get credentials
az acr credential show \
  --resource-group $RESOURCE_GROUP \
  --name $REGISTRY_NAME
```

### Step 3: Link Registry to App Service

```bash
# For Intranet Site
az webapp identity assign \
  --resource-group $RESOURCE_GROUP \
  --name $INTRANET_WEBAPP

# For Internet Site
az webapp identity assign \
  --resource-group $RESOURCE_GROUP \
  --name $INTERNET_WEBAPP

# Grant pull permissions to registry
ACR_REGISTRY_ID=$(az acr show \
  --resource-group $RESOURCE_GROUP \
  --name $REGISTRY_NAME \
  --query id --output tsv)

# For each app service, get its principal ID and assign role
az role assignment create \
  --assignee-object-id $(az webapp identity show \
    --resource-group $RESOURCE_GROUP \
    --name $INTRANET_WEBAPP \
    --query principalId --output tsv) \
  --role acrpull \
  --scope $ACR_REGISTRY_ID
```

---

## GitHub Actions Configuration

### Step 1: Create Service Principal

```bash
# Create a service principal for GitHub
SERVICE_PRINCIPAL_NAME="github-deployer"

CREDENTIALS=$(az ad sp create-for-rbac \
  --name $SERVICE_PRINCIPAL_NAME \
  --role Contributor \
  --scopes /subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP \
  --sdk-auth true)

echo "$CREDENTIALS"
```

### Step 2: Add GitHub Secrets

In your GitHub repository:

1. Go to **Settings** → **Secrets and variables** → **Actions**

2. Add the following secrets:

   - **AZURE_CREDENTIALS**: Paste the JSON output from the service principal creation
   - **REGISTRY_USERNAME**: Azure Container Registry username
   - **REGISTRY_PASSWORD**: Azure Container Registry password

```bash
# Get registry credentials
REGISTRY_USERNAME=$(az acr credential show \
  --resource-group $RESOURCE_GROUP \
  --name $REGISTRY_NAME \
  --query username -o tsv)

REGISTRY_PASSWORD=$(az acr credential show \
  --resource-group $RESOURCE_GROUP \
  --name $REGISTRY_NAME \
  --query 'passwords[0].value' -o tsv)

echo "Registry Username: $REGISTRY_USERNAME"
echo "Registry Password: $REGISTRY_PASSWORD"
```

---

## App Service Configuration

### Step 1: Enable Continuous Deployment

```bash
# For Intranet Site
az webapp deployment container config \
  --resource-group $RESOURCE_GROUP \
  --name $INTRANET_WEBAPP \
  --enable-cd true

# For Internet Site
az webapp deployment container config \
  --resource-group $RESOURCE_GROUP \
  --name $INTERNET_WEBAPP \
  --enable-cd true
```

### Step 2: Configure Health Check

```bash
# For Intranet Site
az webapp config set \
  --resource-group $RESOURCE_GROUP \
  --name $INTRANET_WEBAPP \
  --health-check-path /health

# For Internet Site
az webapp config set \
  --resource-group $RESOURCE_GROUP \
  --name $INTERNET_WEBAPP \
  --health-check-path /health
```

### Step 3: Configure HTTPS

```bash
# Enable HTTPS only for Intranet Site (Recommended)
az webapp update \
  --resource-group $RESOURCE_GROUP \
  --name $INTRANET_WEBAPP \
  --https-only true

# For Internet Site (optional)
az webapp update \
  --resource-group $RESOURCE_GROUP \
  --name $INTERNET_WEBAPP \
  --https-only false  # Allow HTTP for public access, or set to true
```

---

## Deployment

### Local Testing with Docker

```bash
# Build image locally
docker build -t intranet-site:local ./intranet-site

# Run locally
docker run -p 8001:8000 intranet-site:local

# Test the app
curl http://localhost:8001/health
```

### Deploy to Azure Container Registry

```bash
# Build and push to registry (manual)
az acr build \
  --resource-group $RESOURCE_GROUP \
  --registry $REGISTRY_NAME \
  --image intranet-site:latest \
  ./intranet-site

az acr build \
  --resource-group $RESOURCE_GROUP \
  --registry $REGISTRY_NAME \
  --image internet-site:latest \
  ./internet-site
```

### Trigger App Service Deployment

```bash
# Restart the app service (triggers redeployment from registry)
az webapp restart \
  --resource-group $RESOURCE_GROUP \
  --name $INTRANET_WEBAPP

az webapp restart \
  --resource-group $RESOURCE_GROUP \
  --name $INTERNET_WEBAPP
```

### Check Deployment Status

```bash
# View logs
az webapp log tail \
  --resource-group $RESOURCE_GROUP \
  --name $INTRANET_WEBAPP \
  --provider docker

# Check app health
curl https://medical-intranet-site.azurewebsites.net/health
curl https://medical-internet-site.azurewebsites.net/health
```

---

## Monitoring and Troubleshooting

### Enable Application Insights

```bash
INSIGHTS_NAME="medical-insights"

az monitor app-insights component create \
  --app $INSIGHTS_NAME \
  --location $LOCATION \
  --resource-group $RESOURCE_GROUP

# Get instrumentation key
INSIGHTS_KEY=$(az monitor app-insights component show \
  --app $INSIGHTS_NAME \
  --resource-group $RESOURCE_GROUP \
  --query instrumentationKey -o tsv)

# Add to app settings
az webapp config appsettings set \
  --resource-group $RESOURCE_GROUP \
  --name $INTRANET_WEBAPP \
  --settings APPINSIGHTS_INSTRUMENTATIONKEY=$INSIGHTS_KEY

az webapp config appsettings set \
  --resource-group $RESOURCE_GROUP \
  --name $INTERNET_WEBAPP \
  --settings APPINSIGHTS_INSTRUMENTATIONKEY=$INSIGHTS_KEY
```

### View Logs

```bash
# Enable logging
az webapp log config \
  --resource-group $RESOURCE_GROUP \
  --name $INTRANET_WEBAPP \
  --docker-container-logging filesystem \
  --level information

# Stream logs
az webapp log tail \
  --resource-group $RESOURCE_GROUP \
  --name $INTRANET_WEBAPP
```

### Common Issues

#### App Service not starting
```bash
# Check logs
az webapp log tail --resource-group $RESOURCE_GROUP --name $INTRANET_WEBAPP

# Check configuration
az webapp config show --resource-group $RESOURCE_GROUP --name $INTRANET_WEBAPP
```

#### Image pull failures
```bash
# Verify registry credentials
az acr credential show --resource-group $RESOURCE_GROUP --name $REGISTRY_NAME

# Check container logs
az container logs --resource-group $RESOURCE_GROUP --name $INTRANET_WEBAPP
```

#### Connection issues
```bash
# Test connectivity
curl https://medical-intranet-site.azurewebsites.net/

# Check app service status
az webapp show --resource-group $RESOURCE_GROUP --name $INTRANET_WEBAPP --query state
```

---

## Cleanup (Optional)

```bash
# Delete resource group (this deletes all resources)
az group delete --resource-group $RESOURCE_GROUP --yes
```

---

## Summary of URLs

- **Intranet Site**: `https://medical-intranet-site.azurewebsites.net`
- **Internet Site**: `https://medical-internet-site.azurewebsites.net`
- **Health Checks**:
  - Intranet: `https://medical-intranet-site.azurewebsites.net/health`
  - Internet: `https://medical-internet-site.azurewebsites.net/health`

---

## Next Steps

1. Configure custom domain names (if available)
2. Set up SSL certificates
3. Configure WAF rules (optional)
4. Set up auto-scaling policies
5. Configure backup and disaster recovery
6. Implement monitoring alerts
