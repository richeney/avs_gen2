terraform {
  required_version = ">= 1.8, < 2.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.25"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.3"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id = var.subscription_id

  # tenant_id        = <guid> # ARM_TENANT_ID
  # client_id        = <guid> # ARM_CLIENT_ID

  # tenant_id           = "27eda52d-06a5-4e9f-bd76-1a062e47aba0" # ARM_TENANT_ID
  # client_id           = "867d18df-e80f-439f-b6b6-554910f3b3f3" # ARM_CLIENT_ID
  # use_oidc            = true # ARM_USE_OIDC
  storage_use_azuread = true

  resource_provider_registrations = "core"
  resource_providers_to_register = [
    "Microsoft.AVS",
    "Microsoft.Quota"
  ]
}

provider "azapi" {}