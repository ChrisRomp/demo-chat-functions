targetScope = 'subscription'

param location string = 'westus3'
param rgName string = 'bicep-demo-chat-functions2'

// Network Params
param vnetName string = 'vnet-chat-functions'
param subnet0Name string = 'subnet0-common'
param subnet1Name string = 'subnet1-web'
param addressPrefix string = '10.0.0.0/16'
param subnet0Prefix string = '10.0.0.0/24'
param subnet1Prefix string = '10.0.1.0/24'

// Web App Params
param appServicePlanName string = 'asp-chat-functions'
param webAppName string = 'web-chat-functions'
param funcAppName string = 'func-chat-functions'
param funcStorageName string = 'stfuncchatfunctions'

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: rgName
  location: location
}

// Create vnet
module vnet 'core/networking/virtualnetwork.bicep' = {
  name: 'vnet'
  scope: rg
  params: {
    vnetName: vnetName
    addressPrefix: addressPrefix
    location: location
  }
}

// Create subnets
module subnet0 'core/networking/subnet-existing-vnet.bicep' = {
  name: 'subnet0'
  scope: rg
  params: {
    vnetName: vnetName
    subnetName: subnet0Name
    subnetAddressPrefix: subnet0Prefix
  }
  dependsOn: [ vnet ]
}

module subnet1 'core/networking/subnet-existing-vnet.bicep' = {
  name: 'subnet1'
  scope: rg
  params: {
    vnetName: vnetName
    subnetName: subnet1Name
    subnetAddressPrefix: subnet1Prefix
    delegations: [
      {
        name: 'Microsoft.Web/serverFarms'
        properties: {
          serviceName: 'Microsoft.Web/serverFarms'
        }
      }
    ]
  }
  dependsOn: [ vnet ]
}

// Create app service plan
module appServicePlan 'core/host/appserviceplan.bicep' = {
  name: 'appServicePlan'
  scope: rg
  params: {
    name: appServicePlanName
    location: location
    sku: {
      name: 'P1v3'
    }
  }
}

// Create web app
module webApp 'core/host/appservice.bicep' = {
  name: 'webApp'
  scope: rg
  params: {
    name: webAppName
    location: location
    appServicePlanId: appServicePlan.outputs.id
    virtualNetworkSubnetId: subnet1.outputs.id
    runtimeName: 'python'
    runtimeVersion: '3.9'
    appSettings: {
      FORWARD_EASY_AUTH: 'true'
    }
    managedIdentity: true
  }
  dependsOn: [ appServicePlan, subnet1 ]
}

// Storage account for function app
module storageFunc 'core/storage/storage-account.bicep' = {
  name: 'storageFunc'
  scope: rg
  params: {
    name: funcStorageName
    location: location
  }
}

// Create function app
module functionApp 'core/host/functions.bicep' = {
  name: 'functionApp'
  scope: rg
  params: {
    name: funcAppName
    location: location
    appServicePlanId: appServicePlan.outputs.id
    storageAccountName: storageFunc.outputs.name
    virtualNetworkSubnetId: subnet1.outputs.id
    runtimeName: 'python'
    runtimeVersion: '3.9'
    appSettings: {
      // Required for python v2 programming model:
      AzureWebJobsFeatureFlags: 'EnableWorkerIndexing'
    }
    scmDoBuildDuringDeployment: true
    managedIdentity: true
  }
  dependsOn: [ appServicePlan, subnet1 ]
}
