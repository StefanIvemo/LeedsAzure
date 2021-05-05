param location string = resourceGroup().location

//Parent Firewall Policy
resource parentPolicy 'Microsoft.Network/firewallPolicies@2020-08-01' = {
  name: 'parent-policy'
  location: location
  properties: {
    sku: {
      tier: 'Standard'
    }
    threatIntelMode: 'Alert'
  }
}

//Child Firewall Policy 
resource childPolicy 'Microsoft.Network/firewallPolicies@2020-08-01' = {
  name: 'child-policy'
  location: location
  properties: {
    sku: {
      tier: 'Standard'
    }
    threatIntelMode: 'Deny'
    dnsSettings: {
      servers: [
        '10.10.10.10'
        '10.10.10.11'
      ]
      enableProxy: true
    }
    basePolicy: {
      id: parentPolicy.id
    }  
  }
}

//Rule Collection Group
resource ruleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2020-08-01' = {
  name:'${childPolicy.name}/Platform-Network-Rules'
  properties: {
    priority: 1100
    ruleCollections: [
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        name: 'Deny-Https-Private'
        priority: 100
        action: {
          type: 'Deny'
        }
        rules: [
          {
            ruleType: 'NetworkRule'
            name: 'Https'
            description: 'Deny https traffic to private ip ranges'
            sourceAddresses: [
              '*'
            ]
            sourceIpGroups: []
            ipProtocols: [
              'TCP'
            ]
            destinationPorts: [
              '443'
            ]
            destinationIpGroups: []
            destinationAddresses: [
              '10.0.0.0/8'
              '172.16.0.0/12'
              '192.168.0.0/16'
            ]
            destinationFqdns: []
          }
        ]
      }
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        name: 'Allow-Https-Public'
        priority: 200
        action: {
          type: 'Allow'
        }
        rules: [
          {
            ruleType: 'NetworkRule'
            name: 'Https'
            description: 'Allow https traffic to public ip ranges'
            sourceAddresses: [
              '*'
            ]
            sourceIpGroups: []
            ipProtocols: [
              'TCP'
            ]
            destinationPorts: [
              '443'
            ]
            destinationIpGroups: []
            destinationAddresses: [
              '*'
            ]
            destinationFqdns: []
          }
        ]
      }
    ]
  }
}

