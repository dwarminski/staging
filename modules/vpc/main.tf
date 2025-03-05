variable "vpc_name" {}
variable "location" {}
variable "resource_group_name" {}

variable "address_space" {
  type = list(string)
}

variable "public_subnet_prefix" {
  type = list(string)
}

variable "private_subnet_prefix" {
  type = list(string)
}

variable "create_ddos_protection" {
  description = "Whether to create a DDoS protection plan. Set true only in prod."
  type        = bool
  default     = false
}

resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "vpc" {
  name                = var.vpc_name
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = var.address_space
}

resource "azurerm_subnet" "public_subnet" {
  name                 = "${var.vpc_name}-public-subnet"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.vpc.name
  address_prefixes     = var.public_subnet_prefix
}

resource "azurerm_subnet" "private_subnet" {
  name                 = "${var.vpc_name}-private-subnet"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.vpc.name
  address_prefixes     = var.private_subnet_prefix
}

resource "azurerm_network_security_group" "vpc_nsg" {
  name                = "${var.vpc_name}-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_network_security_rule" "allow_ssh" {
  name                        = "AllowSSH"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.vpc_nsg.name
  resource_group_name         = azurerm_resource_group.this.name
}

resource "azurerm_network_security_rule" "allow_https" {
  name                        = "AllowHTTPS"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.vpc_nsg.name
  resource_group_name         = azurerm_resource_group.this.name
}

resource "azurerm_network_security_rule" "allow_rdp_internal" {
  name                        = "AllowRDPInternal"
  priority                    = 120
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = var.address_space[0]
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.vpc_nsg.name
  resource_group_name         = azurerm_resource_group.this.name
}

resource "azurerm_network_security_rule" "allow_https_internal" {
  name                        = "AllowHTTPSInternal"
  priority                    = 130
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = var.address_space[0]
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.vpc_nsg.name
  resource_group_name         = azurerm_resource_group.this.name
}

resource "azurerm_network_ddos_protection_plan" "ddos_protection" {
  count              = var.create_ddos_protection ? 1 : 0
  name               = "${var.vpc_name}-ddos-protection"
  location           = var.location
  resource_group_name = azurerm_resource_group.this.name
  #Only 1 ddos protection can be created for a region
}

resource "azurerm_subnet_network_security_group_association" "public_nsg_assoc" {
  subnet_id                 = azurerm_subnet.public_subnet.id
  network_security_group_id = azurerm_network_security_group.vpc_nsg.id
}

resource "azurerm_subnet_network_security_group_association" "private_nsg_assoc" {
  subnet_id                 = azurerm_subnet.private_subnet.id
  network_security_group_id = azurerm_network_security_group.vpc_nsg.id
}
