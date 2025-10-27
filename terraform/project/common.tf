locals {
  region = "centralindia"

  common_tags = {
    Environment = "Dev"
    Project     = "PI"
  }
}

terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.37.0"
    }
  }
}

terraform {
  backend "azurerm" {
    resource_group_name   = "platform-rg"
    storage_account_name  = "platformiac"
    container_name        = "tf-state"
    key                   = "infra01.tfstate"
    use_msi               = true
  }
}

provider "azurerm" {
  features {}
}