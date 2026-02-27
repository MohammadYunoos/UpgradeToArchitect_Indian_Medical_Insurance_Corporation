// Azure Bicep template for Medical Insurance App
// Creates: Azure Container Registry (with admin enabled for lab), App Service Plan (Linux),
// and two Web Apps (intranet/internet) configured to pull container images from ACR.

@description('Location for all resources')
param location string = resourceGroup().location

@description('Name for the Azure Container Registry')
param acrName string = 'medinsacr${uniqueString(resourceGroup().id)}'

@description('ACR SKU (Basic, Standard, Premium)')
param acrSku string = 'Standard'

@description('Enable ACR admin user (useful in labs; consider disabling in production)')
param enableAcrAdmin bool = true

@description('App Service Plan name')
param appServicePlanName string = 'medins-plan'

@description('App Service Plan SKU name (B1, P1v2, etc.)')
param appServicePlanSkuName string = 'B1'

@description('Name of the intranet web app')
param intranetWebAppName string = 'medins-intranet'

@description('Name of the internet web app')
param internetWebAppName string = 'medins-internet'

@description('Container image name for intranet (repo name in ACR)')
param intranetImageName string = 'intranet-site'

@description('Container tag for intranet image')
param intranetImageTag string = 'latest'

@description('Container image name for internet (repo name in ACR)')
param internetImageName string = 'internet-site'

@description('Container tag for internet image')
param internetImageTag string = 'latest'

// Create ACR
resource acr 'Microsoft.ContainerRegistry/registries@2021-09-01' = {
  name: acrName
  location: location
  sku: {
    name: acrSku
  }
  properties: {
    adminUserEnabled: enableAcrAdmin
  }
}

// App Service Plan (Linux)
resource appPlan 'Microsoft.Web/serverfarms@2021-02-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: appServicePlanSkuName
    tier: (contains([ 'B1', 'B2', 'B3' ], appServicePlanSkuName) ? 'Basic' : (startsWith(appServicePlanSkuName, 'P') ? 'PremiumV2' : 'Standard'))
    capacity: 1
  }
  properties: {
    reserved: true // Linux
  }
}

// Get ACR login server (property available after creation)
var acrLoginServer = acr.properties.loginServer

// Fetch ACR credentials (requires admin user enabled)
// NOTE: listCredentials is used to retrieve username/password for lab usage.
var acrCredentials = listCredentials(acr.id, '2019-05-01')

// Intranet Web App (Linux container)
resource intranetWeb 'Microsoft.Web/sites@2021-02-01' = {
  name: intranetWebAppName
  location: location
  kind: 'app,linux,container'
  properties: {
    serverFarmId: appPlan.id
    siteConfig: {
      linuxFxVersion: 'DOCKER|' + acrLoginServer + '/' + intranetImageName + ':' + intranetImageTag
      appSettings: [
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'false'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: 'https://' + acrLoginServer
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_USERNAME'
          value: acrCredentials.username
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_PASSWORD'
          value: acrCredentials.passwords[0].value
        }
      ]
    }
  }
  dependsOn: [ appPlan, acr ]
}

// Internet Web App (Linux container)
resource internetWeb 'Microsoft.Web/sites@2021-02-01' = {
  name: internetWebAppName
  location: location
  kind: 'app,linux,container'
  properties: {
    serverFarmId: appPlan.id
    siteConfig: {
      linuxFxVersion: 'DOCKER|' + acrLoginServer + '/' + internetImageName + ':' + internetImageTag
      appSettings: [
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'false'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: 'https://' + acrLoginServer
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_USERNAME'
          value: acrCredentials.username
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_PASSWORD'
          value: acrCredentials.passwords[0].value
        }
      ]
    }
  }
  dependsOn: [ appPlan, acr ]
}

// Optional: configure health check path via siteConfig
resource intranetConfig 'Microsoft.Web/sites/config@2021-02-01' = {
  name: '${intranetWeb.name}/web'
  properties: {
    // Health check path used by App Service
    healthCheckPath: '/health'
  }
  dependsOn: [ intranetWeb ]
}

resource internetConfig 'Microsoft.Web/sites/config@2021-02-01' = {
  name: '${internetWeb.name}/web'
  properties: {
    healthCheckPath: '/health'
  }
  dependsOn: [ internetWeb ]
}

// Outputs
output acrLoginServer string = acrLoginServer
output acrAdminUsername string = acrCredentials.username
output acrAdminPassword string = acrCredentials.passwords[0].value
output intranetDefaultHostName string = intranetWeb.properties.defaultHostName
output internetDefaultHostName string = internetWeb.properties.defaultHostName
