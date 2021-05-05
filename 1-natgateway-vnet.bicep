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

resource ipPrefix 'Microsoft.Network/publicIPPrefixes@2020-08-01' = {
  name: '${vnetName}-natGW-ipPrefix-1'
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    prefixLength: 30
    publicIPAddressVersion: 'IPv4'
  }
}

resource natGateway 'Microsoft.Network/natGateways@2020-11-01' = {
  name: '${vnetName}-natGW-publicIp-1'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIpPrefixes:[
      {
        id: ipPrefix.id
      }
    ]
    idleTimeoutInMinutes: 4
  }
}

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
          natGateway:{
            id:natGateway.id
          }
        }
      }
    ]
  }
}

output resourceId string = vnet.id
output azfwSubnetId string = vnet.properties.subnets[0].id
