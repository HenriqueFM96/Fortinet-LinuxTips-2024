#########################################################################################
#                              Spoke A - Route Table Creation                           #
#########################################################################################

resource "azurerm_route_table" "spoke_a-rt00" {
  name                          = "Spoke_A-RouteTable-00"
  location                      = azurerm_resource_group.azure-spoke_A-resource-group.location
  resource_group_name           = azurerm_resource_group.azure-spoke_A-resource-group.name
  disable_bgp_route_propagation = true

  route {
    name           = "default"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "VirtualAppliance"
    next_hop_in_ip_address = "10.0.3.4"
  }
  
  route {
    name           = "to-spoke_A-01"
    address_prefix = "172.16.1.0/24"
    next_hop_type  = "VirtualAppliance"
    next_hop_in_ip_address = "10.0.3.4"
  }

  tags = {
    architecture = "Spoke A"
    environment = "Production"
  }
}

resource "azurerm_subnet_route_table_association" "spoke_a-rt-assoc-00" {
  subnet_id      = azurerm_subnet.azure-spoke_A-subnet01.id
  route_table_id = azurerm_route_table.spoke_a-rt00.id
}

resource "azurerm_route_table" "spoke_a-rt01" {
  name                          = "${var.TAG_Spoke_B}-RouteTable-01"
  location                      = azurerm_resource_group.azure-spoke_A-resource-group.location
  resource_group_name           = azurerm_resource_group.azure-spoke_A-resource-group.name
  disable_bgp_route_propagation = true

  route {
    name           = "default"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "VirtualAppliance"
    next_hop_in_ip_address = "10.0.3.4"
  }
  
  route {
    name           = "to-spoke_A-00"
    address_prefix = "172.16.0.0/24"
    next_hop_type  = "VirtualAppliance"
    next_hop_in_ip_address = "10.0.3.4"
  }

  tags = {
    architecture = "Spoke A"
    environment = "Production"
  }
}

resource "azurerm_subnet_route_table_association" "spoke_a-rt-assoc-01" {
  subnet_id      = azurerm_subnet.azure-spoke_A-subnet02.id
  route_table_id = azurerm_route_table.spoke_a-rt01.id
}

#########################################################################################
#                              Spoke B - Route Table Creation                           #
#########################################################################################

resource "azurerm_route_table" "spoke_b-rt" {
  name                          = "${var.TAG_Spoke_B}-RouteTable"
  location                      = azurerm_resource_group.azure-spoke_B-resource-group.location
  resource_group_name           = azurerm_resource_group.azure-spoke_B-resource-group.name
  disable_bgp_route_propagation = true

  route {
    name           = "default"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "VirtualAppliance"
    next_hop_in_ip_address = "10.0.3.4"
  }
  
  tags = {
    architecture = var.TAG_Spoke_B
    environment = var.StageTAG_PROD
  }
}

resource "azurerm_subnet_route_table_association" "spoke_b-rt-assoc" {
  subnet_id      = azurerm_subnet.azure-spoke_B-subnet01.id
  route_table_id = azurerm_route_table.spoke_b-rt.id
}


#########################################################################################
#                                vNet Peerings Creation                                 #
#########################################################################################

resource "azurerm_virtual_network_peering" "vnet-peering-spoke_A" {
  name                      = "peer-SpokeA-to-HUB"
  resource_group_name       = azurerm_resource_group.azure-spoke_A-resource-group.name
  virtual_network_name      = azurerm_virtual_network.azure-spoke_A-vnet.name
  remote_virtual_network_id = azurerm_virtual_network.azure-hub-vnet.id
}

resource "azurerm_virtual_network_peering" "vnet-HUB-to-SpokeA" {
  name                      = "peer-HUB-to-SpokeA"
  resource_group_name       = azurerm_resource_group.azure-hub-resource-group.name
  virtual_network_name      = azurerm_virtual_network.azure-hub-vnet.name
  remote_virtual_network_id = azurerm_virtual_network.azure-spoke_A-vnet.id
}

//

resource "azurerm_virtual_network_peering" "vnet-peering-spoke_B" {
  name                      = "peer-SpokeB-to-HUB"
  resource_group_name       = azurerm_resource_group.azure-spoke_B-resource-group.name
  virtual_network_name      = azurerm_virtual_network.azure-spoke_B-vnet.name
  remote_virtual_network_id = azurerm_virtual_network.azure-hub-vnet.id
}

resource "azurerm_virtual_network_peering" "vnet-HUB-to-SpokeB" {
  name                      = "peer-HUB-to-SpokeB"
  resource_group_name       = azurerm_resource_group.azure-hub-resource-group.name
  virtual_network_name      = azurerm_virtual_network.azure-hub-vnet.name
  remote_virtual_network_id = azurerm_virtual_network.azure-spoke_B-vnet.id
}