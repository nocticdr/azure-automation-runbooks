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
    subscription_id      = local.SUBSCRIPTION
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "stateaccount"
    container_name       = "region-mainfolder"
    key                  = "remote-automation.tfstate"
  }
}

# Creates the automation account. RunAsAccount has to be added manually from the portal.
# REF: Open Issue https://github.com/terraform-providers/terraform-provider-azurerm/issues/4431
# Make sure to comment out everything else from line 32, then create RunAsAccount.

resource "azurerm_automation_account" "automation_nprod" {
  name                   = "automation-nprod"
  location               = local.REGION
  resource_group_name    = "rg-ea-auto-nprod"

  sku_name               = "Basic"

  tags = {
    environment          = "staging"
  }
}

# Source the powershell script
# Creates the runbook based on script above
# Runbook name needs to be exactly as workflow name in the script
data "local_file" "module_update" {
  filename                       = "../runbooks/Update-AutomationAzureModulesForAccount.ps1"
}
resource "azurerm_automation_runbook" "module_update" {
  name                           = "rb-update-modules"
  location                       = local.REGION
  resource_group_name            = "rg-ea-auto-nprod"
  automation_account_name        = azurerm_automation_account.automation_nprod.name
  log_verbose                    = "true"
  log_progress                   = "true"
  description                    = "This is used to update all automation account modules"
  runbook_type                   = "PowerShell"
  content                        = data.local_file.module_update.content
}

# Source the powershell script
# Creates the runbook based on script above
# Runbook name needs to be exactly as workflow name in the script
data "local_file" "start_vm" {
  filename                       = "../runbooks/start-vm-parallel.ps1"
}
resource "azurerm_automation_runbook" "start_vm" {
  name                           = "rb-start-vm" #TODO: Change to rb-vm-start-stop
  location                       = local.REGION
  resource_group_name            = "rg-ea-auto-nprod"
  automation_account_name        = azurerm_automation_account.automation_nprod.name
  log_verbose                    = "true"
  log_progress                   = "true"
  description                    = "This runbook starts vm in parallel based on a tag value"
  runbook_type                   = "PowerShellWorkflow"
  content                        = data.local_file.start_vm.content
}

# Source the powershell script
# Creates the runbook based on script above
# Runbook name needs to be exactly as workflow name in the script
data "local_file" "stop_vm" {
  filename                       = "../runbooks/stop-vm-parallel.ps1"
}
resource "azurerm_automation_runbook" "stop_vm" {
  name                           = "rb-stop-vm" #TODO: Change to rb-vm-start-stop
  location                       = local.REGION
  resource_group_name            = "rg-ea-auto-nprod"
  automation_account_name        = azurerm_automation_account.automation_nprod.name
  log_verbose                    = "true"
  log_progress                   = "true"
  description                    = "This runbook stops vm in parallel based on a tag value"
  runbook_type                   = "PowerShellWorkflow"
  content                        = data.local_file.stop_vm.content
}

# Creates a schedule
resource "azurerm_automation_schedule" "schedule_0800" {
  name                    = "MON_FRI_0800"
  resource_group_name     = "rg-ea-auto-nprod"
  automation_account_name = azurerm_automation_account.automation_nprod.name
  frequency               = "Week"
  interval                = 1
  week_days               = ["Monday","Tuesday","Wednesday","Thursday","Friday"]
  timezone                = "China Standard Time" # https://support.microsoft.com/en-us/help/973627/microsoft-time-zone-index-values
  start_time              = "2020-07-07T08:00:00+08:00"
  description             = "Schedule which executes on monday to friday at 8:45AM"
}

# Creates a schedule
resource "azurerm_automation_schedule" "schedule_2000" {
  name                    = "MON_SUN_2000" #TODO: Change to lowercase
  resource_group_name     = "rg-ea-auto-nprod"
  automation_account_name = azurerm_automation_account.automation_nprod.name
  frequency               = "Day"
  interval                = 1
  timezone                = "China Standard Time" # https://support.microsoft.com/en-us/help/973627/microsoft-time-zone-index-values
  start_time              = "2020-07-07T20:00:00+08:00"
  description             = "Schedule which executes every day at 8PM"
}

# Create start vm job to run MON to FRI at 8.45AM
resource "azurerm_automation_job_schedule" "start_vm" {
  resource_group_name     = "rg-ea-auto-nprod"
  automation_account_name = azurerm_automation_account.automation_nprod.name
  schedule_name           = "MON_FRI_0800"
  runbook_name            = "rb-start-vm"
  
  parameters = {
    action          = "Start"
    tagvalue        = "MON_FRI_0800"
  }
}

# Create stop vm job to run MON to SUN at 8pm
resource "azurerm_automation_job_schedule" "stop_vm" {
  resource_group_name     = "rg-ea-auto-nprod"
  automation_account_name = azurerm_automation_account.automation_nprod.name
  schedule_name           = "MON_SUN_2000"
  runbook_name            = "rb-stop-vm"
  
  parameters = {
    action          = "Stop"
    tagvalue        = "MON_SUN_2000"
  }
}

# Create start agw job to run MON to FRI at 8.45AM
resource "azurerm_automation_job_schedule" "start_agw" {
  resource_group_name     = "rg-ea-auto-nprod"
  automation_account_name = azurerm_automation_account.automation_nprod.name
  schedule_name           = "MON_FRI_0800"
  runbook_name            = "rb-start-agw"

  parameters = {
    start_schedule_tagvalue = "MON_FRI_0800"
  }
}

# Create stop agw job to run MON to SUN at 8pm
resource "azurerm_automation_job_schedule" "stop_agw" {
  resource_group_name     = "rg-ea-auto-nprod"
  automation_account_name = azurerm_automation_account.automation_nprod.name
  schedule_name           = "MON_SUN_2000"
  runbook_name            = "rb-stop-agw"

  parameters = {
    stop_schedule_tagvalue = "MON_SUN_2000"
  }
}
