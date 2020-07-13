# Store the TF state file on Azure Blobstorage as a remote backend
terraform {
  backend "azurerm" {
    subscription_id      = "xxxxx-xxxxx-xxxxx-xxxxx"
    resource_group_name  = "rg-name"
    storage_account_name = "statefiles"
    container_name       = "container-name"
    key                  = "remote-state-public-ip.tfstate"
  }
}

locals {
  REGION = "eastasia"

  # Subscriptions used
  SUBSCRIPTION = "xxxxx-xxxxx-xxxxx-xxxxxxx"

  # IP Addresses
  FIREWALL_IP_1_NAME     = "firewall_pip-1"
  FIREWALL_IP_2_NAME     = "firewall_pip-2"

  # Resource Groups
  RG_IPADDRESS = "rg-ea-public-ips"
}


# Create a public IP
resource "azurerm_public_ip" "pip_azure_1" {
  name                = local.FIREWALL_IP_1_NAME
  location            = local.REGION
  resource_group_name = local.RG_IPADDRESS_NAME
  allocation_method   = "Static"
  sku                 = "Standard"
  tags = {
    environment = "development"
  }
}
# Lock it to prevent accidental deletion
resource "azurerm_management_lock" "resource_lock_fw" {
  name       = "resource-level"
  scope      = azurerm_public_ip.pip_azure_1.id
  lock_level = "CanNotDelete"
  notes      = "This IP is locked to prevent accidental deletion"
}

# Create a second public IP for Azure Firewall
resource "azurerm_public_ip" "pip_azure_2" {
  name                = local.FIREWALL_IP_2_NAME
  location            = local.REGION
  resource_group_name = local.RG_IPADDRESS_NAME
  allocation_method   = "Static"
  sku                 = "Standard"
  tags = {
    environment = "Production"
  }
}
# Lock it to prevent accidental deletion
resource "azurerm_management_lock" "resource_lock_nprod_fw_ip" {
  name       = "resource-level"
  scope      = azurerm_public_ip.pip_azure_2.id
  lock_level = "CanNotDelete"
  notes      = "This IP is locked to prevent accidental deletion"
}
