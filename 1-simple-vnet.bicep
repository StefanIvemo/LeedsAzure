param location string = resourceGroup().location
param vnetName string = 'fw-vnet'
param addressPrefix string = '10.0.0.0/24'
param azFwRoutes object = {}

var defaultRoutes = {
  routes: [
    {
      name: 'nextHop-Internet'
      properties: {
        addressPrefix: '0.0.0.0/0'
        nextHopType: 'Internet'
      }
    }
  ]
}
var serviceEndpoints = [
    {
      service: 'Microsoft.AzureActiveDirectory'
    }
    {
      service: 'Microsoft.AzureCosmosDB'
    }
    {
      service: 'Microsoft.CognitiveServices'
    }
    {
      service: 'Microsoft.ContainerRegistry'
    }
    {
      service: 'Microsoft.EventHub'
    }
    {
      service: 'Microsoft.KeyVault'
    }
    {
      service: 'Microsoft.ServiceBus'
    }
    {
      service: 'Microsoft.Sql'
    }
    {
      service: 'Microsoft.Storage'
    }
    {
      service: 'Microsoft.Web'
    }
]

resource azFwSubnetRoute 'Microsoft.Network/routeTables@2020-08-01' = {
  location: location
  name: '${vnetName}-azurefirewallsubnet-route'
  properties: {
    disableBgpRoutePropagation: false
    routes: azFwRoutes == {} ? defaultRoutes.routes : union(defaultRoutes.routes, azFwRoutes.routes)
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2020-08-01' = {
  location: location
  name: vnetName
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    subnets:[
      {
        name: 'AzureFirewallSubnet'
        properties:{
          addressPrefix: '10.0.0.0/26'
          serviceEndpoints: serviceEndpoints
          routeTable: {
            id: azFwSubnetRoute.id
          }
        }
      }
    ]
  }
}

output resourceId string = vnet.id
output azfwSubnetId string = vnet.properties.subnets[0].id
