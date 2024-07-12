#Spokes configuration
#########################################################################################
#                                Spoke A Infra Creation                                 #
#########################################################################################

// Resource Group for Spoke A
resource "azurerm_resource_group" "azure-spoke_A-resource-group" {
  name     = "${var.ContentTAG}${var.TAG_Spoke_A}-Resource_Group"
  location = var.location
}

// VNET (network broad segment) for Spoke A
resource "azurerm_virtual_network" "azure-spoke_A-vnet" {
  name                = "${var.TAG_Spoke_A}-vNET"
  location            = azurerm_resource_group.azure-spoke_A-resource-group.location
  resource_group_name = azurerm_resource_group.azure-spoke_A-resource-group.name
  address_space       = [var.spoke_A_VNET]
  
  tags = {
    architecture = var.TAG_Spoke_A
    environment = var.StageTAG_PROD
  }
}

// Subnet 01 for Spoke A
resource "azurerm_subnet" "azure-spoke_A-subnet01" {
  name                 = "${var.TAG_Spoke_A}-Subnet_01"
  resource_group_name  = azurerm_resource_group.azure-spoke_A-resource-group.name
  virtual_network_name = azurerm_virtual_network.azure-spoke_A-vnet.name
  address_prefixes     = [var.spoke_A_subnet01]
}

// Subnet 02 for Spoke A
resource "azurerm_subnet" "azure-spoke_A-subnet02" {
  name                 = "${var.TAG_Spoke_B}-Subnet_02"
  resource_group_name  = azurerm_resource_group.azure-spoke_A-resource-group.name
  virtual_network_name = azurerm_virtual_network.azure-spoke_A-vnet.name
  address_prefixes     = [var.spoke_A_subnet02]
}

// Network Security Group for Spoke A VMs
resource "azurerm_network_security_group" "azure-spoke_A-sg" {
  name                = "${var.TAG_Spoke_A}-security-group"
  location            = azurerm_resource_group.azure-spoke_A-resource-group.location
  resource_group_name = azurerm_resource_group.azure-spoke_A-resource-group.name

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
    architecture = var.TAG_Spoke_A
    environment = var.StageTAG_PROD
  }
}


#########################################################################################
#                                Spoke B Infra Creation                                 #
#########################################################################################

// Resource Group for Spoke B
resource "azurerm_resource_group" "azure-spoke_B-resource-group" {
  name     = "${var.ContentTAG}${var.TAG_Spoke_B}-Resource_Group"
  location = var.location
}

// VNET (network broad segment) for Spoke B
resource "azurerm_virtual_network" "azure-spoke_B-vnet" {
  name                = "${var.TAG_Spoke_B}-vNET"
  location            = azurerm_resource_group.azure-spoke_B-resource-group.location
  resource_group_name = azurerm_resource_group.azure-spoke_B-resource-group.name
  address_space       = [var.spoke_B_VNET]

  tags = {
    architecture = var.TAG_Spoke_B
    environment = var.StageTAG_PROD
  }
}

// Subnet for Spoke B
resource "azurerm_subnet" "azure-spoke_B-subnet01" {
  name                 = "${var.TAG_Spoke_B}-Subnet_01"
  resource_group_name  = azurerm_resource_group.azure-spoke_B-resource-group.name
  virtual_network_name = azurerm_virtual_network.azure-spoke_B-vnet.name
  address_prefixes     = [var.spoke_B_subnet01]
}

resource "azurerm_network_security_group" "azure-spoke_B-sg" {
  name                = "${var.TAG_Spoke_B}-security-group"
  location            = azurerm_resource_group.azure-spoke_B-resource-group.location
  resource_group_name = azurerm_resource_group.azure-spoke_B-resource-group.name

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
    architecture = var.TAG_Spoke_B
    environment = var.StageTAG_PROD
  }
}

#########################################################################################
#                                vNet Peerings Creation                                 #
#########################################################################################

resource "azurerm_virtual_network_peering" "vnet-peering-spoke_A" {
  name                      = "peer-${var.TAG_Spoke_A}-to-${var.TAG_Spoke_B}"
  resource_group_name       = azurerm_resource_group.azure-spoke_A-resource-group.name
  virtual_network_name      = azurerm_virtual_network.azure-spoke_A-vnet.name
  remote_virtual_network_id = azurerm_virtual_network.azure-spoke_B-vnet.id
}

resource "azurerm_virtual_network_peering" "vnet-HUB-to-SpokeA" {
  name                      = "peer-${var.TAG_Spoke_B}-to-${var.TAG_Spoke_A}"
  resource_group_name       = azurerm_resource_group.azure-spoke_B-resource-group.name
  virtual_network_name      = azurerm_virtual_network.azure-spoke_B-vnet.name
  remote_virtual_network_id = azurerm_virtual_network.azure-spoke_A-vnet.id
}

#########################################################################################
#                                VMs Creation Spoke A VM 01                             #
#########################################################################################

resource "azurerm_network_interface" "spoke_A-vnic1" {
  name                = "${var.TAG_Spoke_A}-vnic-vm01"
  location            = azurerm_resource_group.azure-spoke_A-resource-group.location
  resource_group_name = azurerm_resource_group.azure-spoke_A-resource-group.name

  ip_configuration {
    name                          = "${var.TAG_Spoke_A}-internal-vm01"
    subnet_id                     = azurerm_subnet.azure-spoke_A-subnet01.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.Spoke_A-public_ip.id
  }
}

// Public IP Creation
resource "azurerm_public_ip" "Spoke_A-public_ip" {
  name                = "spokeA-VM01-pip"
  resource_group_name = azurerm_resource_group.azure-spoke_A-resource-group.name
  location            = azurerm_resource_group.azure-spoke_A-resource-group.location
  allocation_method   = "Dynamic"
}

// Network Interface VM01 Association to NSG
resource "azurerm_network_interface_security_group_association" "spokeA-vm1-nsg" {
  network_interface_id      = azurerm_network_interface.spoke_A-vnic1.id
  network_security_group_id = azurerm_network_security_group.azure-spoke_A-sg.id
}

resource "azurerm_linux_virtual_machine" "SpokeA-VM01" {
  name                = "Spoke-A-VM01"
  resource_group_name = azurerm_resource_group.azure-spoke_A-resource-group.name
  location            = azurerm_resource_group.azure-spoke_A-resource-group.location
  size                = var.spoke-vm-size
  admin_username      = var.spoke-vm-username
  boot_diagnostics {
       storage_account_uri = null
   }
  network_interface_ids = [
    azurerm_network_interface.spoke_A-vnic1.id,
  ]

//  admin_ssh_key {
//  username   = "adminuser"
//    public_key = file("~/.ssh/id_rsa.pub")
//  }

    disable_password_authentication = false
    admin_password = var.spoke-vm-password

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

#########################################################################################
#                                VMs Creation Spoke A VM 02                             #
#########################################################################################

resource "azurerm_network_interface" "spoke_A-vnic2" {
  name                = "${var.TAG_Spoke_A}-vnic-vm02"
  location            = azurerm_resource_group.azure-spoke_A-resource-group.location
  resource_group_name = azurerm_resource_group.azure-spoke_A-resource-group.name

  ip_configuration {
    name                          = "${var.TAG_Spoke_A}-internal-vm02"
    subnet_id                     = azurerm_subnet.azure-spoke_A-subnet02.id
    private_ip_address_allocation = "Dynamic"
  }
}

// Network Interface VM02 Association to NSG
resource "azurerm_network_interface_security_group_association" "spokeA-vm2-nsg" {
  network_interface_id      = azurerm_network_interface.spoke_A-vnic2.id
  network_security_group_id = azurerm_network_security_group.azure-spoke_A-sg.id
}

resource "azurerm_linux_virtual_machine" "SpokeA-VM02" {
  name                = "Spoke-A-VM02"
  resource_group_name = azurerm_resource_group.azure-spoke_A-resource-group.name
  location            = azurerm_resource_group.azure-spoke_A-resource-group.location
  size                = var.spoke-vm-size
  admin_username      = var.spoke-vm-username
  boot_diagnostics {
       storage_account_uri = null
   }
  network_interface_ids = [
    azurerm_network_interface.spoke_A-vnic2.id,
  ]

//  admin_ssh_key {
//  username   = "adminuser"
//    public_key = file("~/.ssh/id_rsa.pub")
//  }

    disable_password_authentication = false
    admin_password = var.spoke-vm-password

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

#########################################################################################
#                                VMs Creation Spoke B VM 01                             #
#########################################################################################

resource "azurerm_network_interface" "spoke_B-vnic1" {
  name                = "${var.TAG_Spoke_B}-vnic-vm01"
  location            = azurerm_resource_group.azure-spoke_B-resource-group.location
  resource_group_name = azurerm_resource_group.azure-spoke_B-resource-group.name

  ip_configuration {
    name                          = "${var.TAG_Spoke_B}-internal-vm01"
    subnet_id                     = azurerm_subnet.azure-spoke_B-subnet01.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "SpokeB-VM01" {
  name                = "Spoke-B-VM01"
  resource_group_name = azurerm_resource_group.azure-spoke_B-resource-group.name
  location            = azurerm_resource_group.azure-spoke_B-resource-group.location
  size                = var.spoke-vm-size
  admin_username      = var.spoke-vm-username
  boot_diagnostics {
       storage_account_uri = null
   }
  network_interface_ids = [
    azurerm_network_interface.spoke_B-vnic1.id,
  ]

//  admin_ssh_key {
//  username   = "adminuser"
//    public_key = file("~/.ssh/id_rsa.pub")
//  }

    disable_password_authentication = false
    admin_password = var.spoke-vm-password
    custom_data = base64encode(data.template_file.linux-vm-cloud-init.rendered)

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

# Data template Bash bootstrapping file
data "template_file" "linux-vm-cloud-init" {
  template = file("spokeA-application.sh")
}
