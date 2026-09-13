

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

  app_settings = {
    SCM_DO_BUILD_DURING_DEPLOYMENT = "1"
    ENABLE_ORYX_BUILD              = "1"

    APP_VERSION     = "v1.0.0"
    APP_ENVIRONMENT = "production"
  }

  site_config {
    app_command_line = "gunicorn --bind=0.0.0.0:$PORT --timeout 600 app:app"

    application_stack {
      python_version = "3.11"
    }
  }
}

resource "azurerm_linux_web_app_slot" "staging-slot" {
  name           = "${var.prefix}-staging-slot"
  app_service_id = azurerm_linux_web_app.web-app.id

  app_settings = {
    SCM_DO_BUILD_DURING_DEPLOYMENT = "1"
    ENABLE_ORYX_BUILD              = "1"

    APP_VERSION     = "v1.0.0-rc"
    APP_ENVIRONMENT = "staging"
  }

  site_config {
    app_command_line = "gunicorn --bind=0.0.0.0:$PORT --timeout 600 app:app"

    application_stack {
      python_version = "3.11"
    }
  }
}

resource "azurerm_web_app_active_slot" "active-slot" {
  slot_id = azurerm_linux_web_app_slot.staging-slot.id
}