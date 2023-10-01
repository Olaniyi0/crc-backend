terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.60.0"
    }
  }
}

provider "azurerm" {
  features {
   resource_group {
     prevent_deletion_if_contains_resources = false
   }
  }
}

resource "azurerm_resource_group" "resume-rg" {
  name     = "crc-backend"
  location = "westeurope"
}
