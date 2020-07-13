# When changing the azurerm version pin, change EXPECTED_AZURERM_VERSION in tests.sh
provider "azurerm" {
  version         = "=2.14.0"
  subscription_id = local.SUBSCRIPTION
  features {}
}

locals {
  REGION = "eastasia"

  # Subscriptions used
  SUBSCRIPTION = "xxxxx-xxxxx-xxxxx-xxxxxxx"
}


# Store the TF state file on Azure Blobstorage as a remote backend
terraform {
  backend "azurerm" {
    subscription_id      = "xxxxx-xxxxx-xxxxx-xxxxx"
    resource_group_name  = "rg-name"
    storage_account_name = "statefiles"
    container_name       = "container-name"
    key                  = "remote-state-resource-group.tfstate"
  }
}

variable "resourcegroup_names" {
  description = "List of Resource Groups to create"
  default = [
    "rg-ea-1",
    "rg-ea-public-ips",
    "rg-ea-3"
 
  ]
}

resource "azurerm_resource_group" "resource_groups" {
  for_each = toset(var.resourcegroup_names)
  name     = each.value
  location = local.REGION
}
