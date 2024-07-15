#Attacker Environment - Simulating it
#########################################################################################
#                                  Attacker Environment                                 #
#########################################################################################

// Resource Group for Attacker
resource "azurerm_resource_group" "attacker-resource-group" {
  name     = "${var.TAG-attacker}-Resource_Group"
  location = var.attacker-location
}

// VNET (network broad segment) for Spoke A
resource "azurerm_virtual_network" "attacker-vnet" {
  name                = "${var.TAG-attacker}-vNET"
  location            = azurerm_resource_group.attacker-resource-group.location
  resource_group_name = azurerm_resource_group.attacker-resource-group.name
  address_space       = [var.Attacker_VNET]
  
  tags = {
    architecture = var.TAG-attacker
  }
}

// Attacker's Subnet
resource "azurerm_subnet" "attacker-subnet" {
  name                 = "${var.TAG-attacker}-Subnet"
  resource_group_name  = azurerm_resource_group.attacker-resource-group.name
  virtual_network_name = azurerm_virtual_network.attacker-vnet.name
  address_prefixes     = [var.Attacker_subnet]
}

// Network Security Group for Attacker
resource "azurerm_network_security_group" "attacker-sg" {
  name                = "${var.TAG-attacker}-security-group"
  location            = azurerm_resource_group.attacker-resource-group.location
  resource_group_name = azurerm_resource_group.attacker-resource-group.name

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
    architecture = var.TAG-attacker
  }
}

// attacker vnic
resource "azurerm_network_interface" "attacker-vnic" {
  name                = "${var.TAG-attacker}-vnic"
  location            = azurerm_resource_group.attacker-resource-group.location
  resource_group_name = azurerm_resource_group.attacker-resource-group.name

  ip_configuration {
    name                          = "${var.TAG-attacker}-internal"
    subnet_id                     = azurerm_subnet.attacker-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.attacker-public_ip.id
  }
}

// Public IP Creation
resource "azurerm_public_ip" "attacker-public_ip" {
  name                = "${var.TAG-attacker}-pip"
  resource_group_name = azurerm_resource_group.attacker-resource-group.name
  location            = azurerm_resource_group.attacker-resource-group.location
  allocation_method   = "Dynamic"
}

// Attacker's Network Interface Association to NSG
resource "azurerm_network_interface_security_group_association" "attacker-nsg" {
  network_interface_id      = azurerm_network_interface.attacker-vnic.id
  network_security_group_id = azurerm_network_security_group.attacker-sg.id
}

resource "azurerm_linux_virtual_machine" "attacker-VM" {
  name                = "${var.TAG-attacker}-VM01"
  resource_group_name = azurerm_resource_group.attacker-resource-group.name
  location            = azurerm_resource_group.attacker-resource-group.location
  size                = var.spoke-vm-size
  admin_username      = var.spoke-vm-username
  boot_diagnostics {
       storage_account_uri = null
   }
  network_interface_ids = [
    azurerm_network_interface.attacker-vnic.id,
  ]

    disable_password_authentication = false
    admin_password = var.spoke-vm-password
    custom_data = base64encode(data.template_file.linux-attacker-vm.rendered)

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

# Data template Bash bootstrapping file - Attacker's VM
data "template_file" "linux-attacker-vm" {
  template = file("linux-attacker.sh")
}
