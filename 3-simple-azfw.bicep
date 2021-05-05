// Azure Firewall with multiple Public IPs from prefix using availability zones

param fwName string = 'contoso-fw'
param subnetId string = '/subscriptions/0e4a9391-6835-4403-b8b0-dcfae6bd9467/resourceGroups/vnet-rg/providers/Microsoft.Network/virtualNetworks/fw-vnet/subnets/AzureFirewallSubnet'
param fwPolicyId string = '/subscriptions/0e4a9391-6835-4403-b8b0-dcfae6bd9467/resourceGroups/vnet-rg/providers/Microsoft.Network/firewallPolicies/child-policy'
param location string = resourceGroup().location

resource ipPrefix 'Microsoft.Network/publicIPPrefixes@2020-08-01' = {
  name: '${fwName}-ipPrefix-1'
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

resource publicIP1 'Microsoft.Network/publicIPAddresses@2020-08-01' = {
  name: '${fwName}-publicip-1'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPPrefix: {
      id: ipPrefix.id
    }
  }
}

resource publicIP2 'Microsoft.Network/publicIPAddresses@2020-08-01' = {
  name: '${fwName}-publicip-2'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPPrefix: {
      id: ipPrefix.id
    }
  }
}

resource firewall 'Microsoft.Network/azureFirewalls@2020-08-01' = {
  name: fwName
  location: location
  zones: [
    '1'
    '2'
    '3'
  ]
  properties: {
    firewallPolicy:{
      id: fwPolicyId
    }
    sku: {
      name: 'AZFW_VNet'
      tier: 'Standard'
    }
    ipConfigurations: [
      {
        name: '${fwName}-vnetIPConf-1'
        properties: {
          publicIPAddress: {
            id: publicIP1.id
          }
          subnet: {
            id: subnetId
          }
        }
      }
      {
        name: '${fwName}-vnetIPConf-2'
        properties: {
          publicIPAddress: {
            id: publicIP2.id
          }
        }
      }
    ]

  }
}
