@description('Name of the VNET to add a subnet to')
param vnetName string

@description('Name of the subnet to add')
param subnetName string

@description('Address space of the subnet to add')
param subnetAddressPrefix string = '10.0.0.0/24'

param delegations array = []

resource vnet 'Microsoft.Network/virtualNetworks@2021-03-01' existing = {
   name: vnetName
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-03-01' = {
  parent: vnet
  name: subnetName
  properties: {
    addressPrefix: subnetAddressPrefix
    // delegate to app service
    delegations: length(delegations) > 0 ? delegations : []
  }
}

output id string = subnet.id
