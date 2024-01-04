terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.60.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "spiral-rg"
    storage_account_name = "spiral"
    container_name       = "terraform-state"
    key                  = "resume-backend.tfstate"
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

#####