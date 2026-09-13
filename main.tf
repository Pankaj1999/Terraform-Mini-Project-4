

resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-resource-group"
  location = "West Europe"
}

resource "azurerm_service_plan" "service-plan" {
  name                = "${var.prefix}-service-plan"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "S1"
}

resource "azurerm_linux_web_app" "web-app" {
  name                = "${var.prefix}-web-app"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_service_plan.service-plan.location
  service_plan_id     = azurerm_service_plan.service-plan.id

  site_config {}
}

resource "azurerm_linux_web_app_slot" "staging-slot" {
  name           = "${var.prefix}-staging-slot"
  app_service_id = azurerm_linux_web_app.web-app.id

  site_config {}
}