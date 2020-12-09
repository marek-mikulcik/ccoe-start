terraform {
  required_version = "~>0.13.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.34.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>2.3.0"
    }
    external = {
      source  = "hashicorp/external"
      version = "~>1.2.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~>3.0.0"
    }
  }
  backend "azurerm" {    
    container_name       = "tfstate"
    key                  = "infrabaseline.tfstate"
  }
}

provider "azurerm" {
  use_msi         = tobool(lower(var.useMSI))
  partner_id      =  # Partner customer usage attribution for Swiss Re, do not modify
  features {}
}

resource "azurerm_resource_group" "main_rg" {
  name     = var.resourceGroup
  location = var.location
}

module "law" {
  source = "../../modules/law/terraform"

  resourceName  = var.lawConfig.resourceName
  resourceGroup = azurerm_resource_group.main_rg.name
  tags          = var.tags
}