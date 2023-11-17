param vnetName string
param location string
param addressPrefix string

resource vnet 'Microsoft.Network/virtualNetworks@2021-08-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    // subnets: [
    //   {
    //     name: subnet1Name
    //     properties: {
    //       addressPrefix: subnet1Prefix
    //     }
    //   }
    //   {
    //     name: subnet2Name
    //     properties: {
    //       addressPrefix: subnet2Prefix
    //     }
    //   }
    // ]
  }
}
