resource "azurerm_storage_account" "function-storage" {
  name                     = "monster2storage"
  location                 = azurerm_resource_group.resume-rg.location
  resource_group_name      = azurerm_resource_group.resume-rg.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "function-container" {
  depends_on            = [azurerm_storage_account.function-storage]
  name                  = "function-app-container"
  storage_account_name  = azurerm_storage_account.function-storage.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "myresumes-funcapp-blob" {
  depends_on             = [azurerm_storage_container.function-container]
  name                   = "function_app.zip"
  storage_account_name   = azurerm_storage_account.function-storage.name
  storage_container_name = azurerm_storage_container.function-container.name
  type                   = "Block"
  source                 = "./httpTrigger/function_app.zip"
}

data "azurerm_storage_account_sas" "myresumes-funcapp-sas" {
  depends_on        = [azurerm_storage_blob.myresumes-funcapp-blob]
  connection_string = azurerm_storage_account.function-storage.primary_connection_string
  https_only        = true
  signed_version    = "2017-07-29"

  resource_types {
    service   = false
    container = false
    object    = true
  }

  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }

  start  = timestamp()
  expiry = timeadd(timestamp(), "3000h")

  permissions {
    read    = true
    write   = false
    delete  = false
    list    = false
    add     = false
    create  = false
    update  = false
    process = false
    tag     = false
    filter  = false
  }
}

#################### DATABASE ####################

resource "azurerm_cosmosdb_account" "resumedb-account" {
  # depends_on                = [azurerm_resource_group.cloud_resume_rg]
  name                      = "resumedb-account"
  location                  = azurerm_resource_group.resume-rg.location
  resource_group_name       = azurerm_resource_group.resume-rg.name
  offer_type                = "Standard"
  kind                      = "GlobalDocumentDB"
  enable_automatic_failover = false
  enable_free_tier          = true


  capabilities {
    name = "EnableTable"
  }

  capabilities {
    name = "EnableServerless"
  }

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = "uksouth"
    failover_priority = 0
  }

  backup {
    type                = "Periodic"
    interval_in_minutes = 240
    retention_in_hours  = 8
    storage_redundancy  = "Local"
  }
}

resource "azurerm_cosmosdb_table" "resumes-db" {
  depends_on          = [azurerm_cosmosdb_account.resumedb-account]
  name                = "visitors"
  resource_group_name = azurerm_resource_group.resume-rg.name
  account_name        = azurerm_cosmosdb_account.resumedb-account.name
}