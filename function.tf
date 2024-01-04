resource "azurerm_service_plan" "myresumes-plan" {
  depends_on          = [azurerm_resource_group.resume-rg]
  name                = "myresumes-service-plan"
  location            = azurerm_resource_group.resume-rg.location
  resource_group_name = azurerm_resource_group.resume-rg.name
  os_type             = "Linux"
  sku_name            = "Y1"
}

resource "azurerm_application_insights" "myresumes-app-insight" {
  name                = "myresumes-app-insight"
  location            = azurerm_resource_group.resume-rg.location
  resource_group_name = azurerm_resource_group.resume-rg.name
  application_type    = "other"
}

resource "azurerm_linux_function_app" "myresumes-linux-funcapp" {
  depends_on                 = [azurerm_service_plan.myresumes-plan]
  name                       = "myresumes-funcapp"
  resource_group_name        = azurerm_resource_group.resume-rg.name
  location                   = azurerm_resource_group.resume-rg.location
  storage_account_name       = azurerm_storage_account.function-storage.name
  storage_account_access_key = azurerm_storage_account.function-storage.primary_access_key
  service_plan_id            = azurerm_service_plan.myresumes-plan.id

  site_config {
    application_insights_connection_string = azurerm_application_insights.myresumes-app-insight.connection_string
    application_insights_key               = azurerm_application_insights.myresumes-app-insight.instrumentation_key
    cors {
      allowed_origins = ["https://portal.azure.com", "https://www.cloudresume.me"]
    }
    application_stack {
      python_version = "3.10"
    }
  }
  app_settings = {
    "RESUMEDB_CONNECTION_STRING" : "${azurerm_cosmosdb_account.resumedb-account.connection_strings[4]}",
    "WEBSITE_RUN_FROM_PACKAGE" : "${azurerm_storage_blob.myresumes-funcapp-blob.url}${data.azurerm_storage_account_sas.myresumes-funcapp-sas.sas}",
    "DATABASE_TABLE_NAME" : azurerm_cosmosdb_table.resumes-db.name,
    "FUNCTIONS_WORKER_RUNTIME" : "python"
  }

}
