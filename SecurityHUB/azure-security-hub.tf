/*
#########################################################################################
#                               Security HUB Infra Creation                             #
#########################################################################################

resource "azurerm_resource_group" "azure-hub-resource-group" {
  name     = "${var.ContentTAG}Security_HUB_Resource_Group"
  location = "Central US"
}

resource "azurerm_network_security_group" "azure-hub-sg" {
  name                = "vnet-hub-security-group"
  location            = azurerm_resource_group.azure-hub-resource-group.location
  resource_group_name = azurerm_resource_group.azure-hub-resource-group.name

  security_rule {
    name                       = "allow-all"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    architecture = "HUB"
    environment = "Production"
  }

}

resource "azurerm_virtual_network" "azure-hub-vnet" {
  name                = "Security_HUB_vNET"
  location            = azurerm_resource_group.azure-hub-resource-group.location
  resource_group_name = azurerm_resource_group.azure-hub-resource-group.name
  address_space       = ["10.0.0.0/16"]

  tags = {
    architecture = "HUB"
    environment = "Production"
  }
}

resource "azurerm_subnet" "azure-hub-management" {
  name                 = "Management_Public_Subnet"
  resource_group_name  = azurerm_resource_group.azure-hub-resource-group.name
  virtual_network_name = azurerm_virtual_network.azure-hub-vnet.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "azure-hub-untrusted" {
  name                 = "Untrusted_Public_Subnet"
  resource_group_name  = azurerm_resource_group.azure-hub-resource-group.name
  virtual_network_name = azurerm_virtual_network.azure-hub-vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "azure-hub-sync" {
  name                 = "Sync_Private_Subnet"
  resource_group_name  = azurerm_resource_group.azure-hub-resource-group.name
  virtual_network_name = azurerm_virtual_network.azure-hub-vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "azure-hub-trusted" {
  name                 = "Trusted_Private_Subnet"
  resource_group_name  = azurerm_resource_group.azure-hub-resource-group.name
  virtual_network_name = azurerm_virtual_network.azure-hub-vnet.name
  address_prefixes     = ["10.0.3.0/24"]
}

#########################################################################################
#                                FortiGate-VM Interfaces                                #
#########################################################################################

// Allocated Public IP
resource "azurerm_public_ip" "FGTPublicIp" {
  name                = "FGTPublicIP"
  location            = var.location
  resource_group_name = azurerm_resource_group.azure-hub-resource-group.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    environment = "Terraform Single FortiGate PIP"
  }
}

// FGT Network Interface port1
resource "azurerm_network_interface" "fgtport1" {
  name                = "fgtport1"
  location            = var.location
  resource_group_name = azurerm_resource_group.azure-hub-resource-group.name
  
  timeouts {
    delete = "5m"
  }

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.azure-hub-untrusted.id
    private_ip_address_allocation = "Dynamic"
    primary                       = true
    public_ip_address_id          = azurerm_public_ip.FGTPublicIp.id
  }

  tags = {
    environment = "Terraform Single FortiGate"
  }
}

resource "azurerm_network_interface_security_group_association" "fgt-port1-nsg" {
  network_interface_id      = azurerm_network_interface.fgtport1.id
  network_security_group_id = azurerm_network_security_group.azure-hub-sg.id
}

resource "azurerm_network_interface" "fgtport2" {
  name                 = "fgtport2"
  location             = var.location
  resource_group_name  = azurerm_resource_group.azure-hub-resource-group.name
  ip_forwarding_enabled = true

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.azure-hub-trusted.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    environment = "Terraform Single FortiGate"
  }
}

resource "azurerm_network_interface_security_group_association" "fgt-port2-nsg" {
  network_interface_id      = azurerm_network_interface.fgtport2.id
  network_security_group_id = azurerm_network_security_group.azure-hub-sg.id
}
*/