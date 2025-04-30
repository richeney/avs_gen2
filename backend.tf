terraform {
  backend "azurerm" {
    subscription_id      = "/subscriptions/d52f9c4a-5468-47ec-9641-da4ef1916bb5"
    resource_group_name  = "rcheney-terraform"
    storage_account_name = "terraformavs2bff9911"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
    use_azuread_auth     = true
  }
}