Azure Bicep template for Medical Insurance Platform

This folder contains a simple Bicep template to provision the minimal resources required for the lab:
- Azure Container Registry (ACR) with admin user (lab convenience)
- App Service Plan (Linux)
- Two Web Apps (intranet + internet) configured to pull container images from ACR

Files
- `main.bicep` - The Bicep template
- `main.parameters.json` - Example parameters file

Prerequisites
- Azure CLI installed: https://learn.microsoft.com/cli/azure/install-azure-cli
- Logged in: `az login`
- Bicep tooling is available via the Azure CLI (modern `az` includes bicep). If needed: `az bicep install`

Usage (deploy into an existing resource group)
1. Create a resource group (if you don't already have one):

```bash
az group create --name medins-rg --location eastus
```

2. Deploy the template:

```bash
cd infra
az deployment group create \
  --resource-group medins-rg \
  --template-file ./main.bicep \
  --parameters @main.parameters.json
```

Notes & post-deploy steps
- The template enables ACR admin user for lab convenience. In production, prefer Azure AD/GitHub actions identity or a service principal and disable admin user.

- After deployment, the command prints outputs including:
  - `acrLoginServer`
  - `acrAdminUsername`
  - `acrAdminPassword`
  - `intranetDefaultHostName`
  - `internetDefaultHostName`

Use `acrLoginServer` and admin username/password to push images to ACR from your CI or locally (for lab). Example push commands:

```bash
# Example: build & push intranet image
az acr login --name <acrName>
# or docker login <acrLoginServer> -u <username> -p <password>

docker build -t <acrLoginServer>/intranet-site:latest ./intranet-site
docker push <acrLoginServer>/intranet-site:latest

docker build -t <acrLoginServer>/internet-site:latest ./internet-site
docker push <acrLoginServer>/internet-site:latest
```

- Once images are pushed, App Service instances will pull the configured tags. If you update images, use a new tag and update the Web App container setting or trigger a restart.

CI/CD integration notes
- The GitHub Actions workflows in the repo are already configured to build, push and deploy images to App Service. After creating the resources, add these GitHub repository secrets:
  - `REGISTRY_LOGIN_SERVER` -> value: `<acrLoginServer>`
  - `REGISTRY_USERNAME` -> value: `<acrAdminUsername>`
  - `REGISTRY_PASSWORD` -> value: `<acrAdminPassword>`
  - `AZURE_CREDENTIALS` -> service principal json (used by the App Service deploy steps)

Security considerations
- For labs this template uses ACR admin credentials for simplicity. For real deployments:
  - Use a service principal or Managed Identity with proper RBAC to push images
  - Disable ACR admin user
  - Use Key Vault for secrets

Troubleshooting
- If the Web App fails to pull an image, check the App Service logs and container settings and ensure the image exists in ACR with the expected tag.
- To fetch ACR credentials after deployment (if forgot), run:

```bash
az acr credential show --name <acrName>
```

If you want, I can:
- Add an ARM template variant instead of Bicep
- Extend the template to create Log Analytics workspace, Application Insights, or managed identities
- Wire up a Service Principal creation step and produce `AZURE_CREDENTIALS` for GitHub

Which additions would you like next? (I can implement them now.)
