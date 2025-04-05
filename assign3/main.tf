provider "azurerm" {
  features {}
  subscription_id = "0f9d69f5-ad20-4bba-b635-f1f6dc2c1744"
}
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}
resource "azurerm_app_service_plan" "asp" {
  name                = var.app_service_plan_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kind              = "Linux"
  reserved          = true
  sku {
    tier     = "Standard"
    size     = "S1"
  }
}
resource "azurerm_app_service" "app" {
  name                = var.app_service_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.asp.id
  
  site_config {
    always_on = true
    linux_fx_version = "DOCKER|mcr.microsoft.com/azure-app-service/samples/node:13-lts"
  }
}