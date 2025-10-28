locals {
  region = "canadacentral"

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
    resource_group_name   = "platform-ronak-rg"
    storage_account_name  = "infrastate01"
    container_name        = "tf-state"
    key                   = "infra01.tfstate"
  }
}

provider "azurerm" {
  features {}
}