terraform {
  required_version = ">=1.10.0"
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">=2.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "localrg" {
  name = "peru-automation-rg"
  location = "East US"
}

resource "azurerm_virtual_network" "localvnet" {
  name = "peru-automation-vnet"
  resource_group_name = "azurerm_resource_group.localrg.name"
  location = "azurerm_resource_group.localrg.location"
  address_space = [ "10.1.0.0/16" ]
}

resource "azurerm_subnet" "localsubnet" {
  name = "peru-automation-subnet01"
  resource_group_name = "azurerm_resource_group.localrg.name"
  virtual_network_name = "azurerm_virtual_network.localvnet.id"
  address_prefixes = [ "10.1.0.0/24" ]
}

resource "azurerm_network_interface" "localnic" {
    name = "peru-auomation-nic01"
    location = "azurerm_resource_group.localrg.location"
    resource_group_name = "azurerm_resource_group.localrg.name"
    ip_configuration {
      name = "internal-ip"
      subnet_id = azurerm_subnet.localsubnet.id
      private_ip_address_allocation = "Dynamic"
    }
}

resource "azurerm_windows_virtual_machine" "localvmname" {
  name = "peruauto-vm01"
  resource_group_name = "azurerm_resource_group.localrg.name"
  location = "azurerm_resource_group.localrg.location"
  size = "Standard_DS1_v2"
  admin_username = "peruadmin"
  admin_password = "Password@123"
  network_interface_ids = [
    azurerm_network_interface.localnic.id,
  ]
  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer = "WindowsServer"
    sku = "2022-Datacenter"
    version = "latest"
  }
}