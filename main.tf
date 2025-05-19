# main.tf

# Define the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.75.0"
    }
  }
  
  backend "azurerm" {
    # Backend configuration will be provided during CI/CD pipeline
  }
}

provider "azurerm" {
  features {}
}

# Resource Group for SQL Managed Instance
resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = var.location
}

# Existing SQL MI infrastructure code (from your paste)
# สร้าง Virtual Network และ Subnet สำหรับ SQL Managed Instance
resource "azurerm_virtual_network" "example" {
  name                = "example-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "example" {
  name                 = "example-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
  
  delegation {
    name = "managedinstancedelegation"

    service_delegation {
      name    = "Microsoft.Sql/managedInstances"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action", "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"]
    }
  }
}

# Network Security Group สำหรับ SQL Managed Instance
resource "azurerm_network_security_group" "example" {
  name                = "example-nsg"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  security_rule {
    name                       = "allow_management_inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["9000", "9003", "1438", "1440", "1452"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow_misubnet_inbound"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "10.0.0.0/24"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow_health_probe_inbound"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow_management_outbound"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["80", "443", "12000"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow_misubnet_outbound"
    priority                   = 200
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "10.0.0.0/24"
    destination_address_prefix = "*"
  }
}

# เชื่อม NSG กับ Subnet
resource "azurerm_subnet_network_security_group_association" "example" {
  subnet_id                 = azurerm_subnet.example.id
  network_security_group_id = azurerm_network_security_group.example.id
}

# สร้าง Route Table
resource "azurerm_route_table" "example" {
  name                = "example-route-table"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

# เชื่อม Route Table กับ Subnet
resource "azurerm_subnet_route_table_association" "example" {
  subnet_id      = azurerm_subnet.example.id
  route_table_id = azurerm_route_table.example.id
}

# สร้าง SQL Managed Instance
resource "azurerm_mssql_managed_instance" "example" {
  name                         = var.sql_mi_name
  resource_group_name          = azurerm_resource_group.example.name
  location                     = azurerm_resource_group.example.location
  subnet_id                    = azurerm_subnet.example.id
  administrator_login          = var.sql_admin_username
  administrator_login_password = var.sql_admin_password
  license_type                 = "LicenseIncluded"
  sku_name                     = var.sql_mi_sku
  vcores                       = var.sql_mi_vcores
  storage_size_in_gb           = var.sql_mi_storage_size_gb

  depends_on = [
    azurerm_subnet_network_security_group_association.example,
    azurerm_subnet_route_table_association.example
  ]
}
