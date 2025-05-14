resource "azurerm_resource_group" "ml_rg" {
  name     = "rg-ml-${var.location}-001"
  location = var.location
}

resource "azurerm_application_insights" "ml_app_insights" {
  name                = "appi-ml-${var.location}-001"
  location            = var.location
  resource_group_name = azurerm_resource_group.ml_rg.name
  application_type    = "web"
}

resource "azurerm_user_assigned_identity" "ml_user_identity" {
  name                = "uai-ml-${var.location}-001"
  location            = var.location
  resource_group_name = azurerm_resource_group.ml_rg.name
}

resource "random_string" "random_string" {
  length  = 8
  lower   = true
  upper   = false
  numeric = false
  special = false
}

resource "azurerm_key_vault" "ml_key_vault" {
  name                      = "kvml${var.location}001${random_string.random_string.result}"
  location                  = var.location
  resource_group_name       = azurerm_resource_group.ml_rg.name
  tenant_id                 = var.tenant_id
  sku_name                  = "standard"
  purge_protection_enabled  = true
  enable_rbac_authorization = true
}

resource "azurerm_role_assignment" "key_vault_administrators" {
  for_each             = toset(var.admin_object_ids)
  scope                = azurerm_key_vault.ml_key_vault.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = each.value
}

resource "azurerm_role_assignment" "ml_identity_kv_crypto_user" {
  scope                = azurerm_key_vault.ml_key_vault.id
  role_definition_name = "Key Vault Crypto User"
  principal_id         = azurerm_user_assigned_identity.ml_user_identity.principal_id
}

resource "azurerm_role_assignment" "ml_identity_kv_reader" {
  scope                = azurerm_key_vault.ml_key_vault.id
  role_definition_name = "Key Vault Reader"
  principal_id         = azurerm_user_assigned_identity.ml_user_identity.principal_id
}

resource "azurerm_key_vault_key" "ml_kv_key" {
  name         = "key-ml-${var.location}-001"
  key_vault_id = azurerm_key_vault.ml_key_vault.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
}

resource "azurerm_storage_account" "ml_storage" {
  name                     = "stml${var.location}001${random_string.random_string.result}"
  location                 = var.location
  resource_group_name      = azurerm_resource_group.ml_rg.name
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_role_assignment" "storage_administrators" {
  for_each             = toset(var.admin_object_ids)
  scope                = azurerm_key_vault.ml_key_vault.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = each.value
}

resource "azurerm_machine_learning_workspace" "ml_workspace" {
  name                           = "mlw-ml-${var.location}-001"
  location                       = var.location
  resource_group_name            = azurerm_resource_group.ml_rg.name
  application_insights_id        = azurerm_application_insights.ml_app_insights.id
  key_vault_id                   = azurerm_key_vault.ml_key_vault.id
  storage_account_id             = azurerm_storage_account.ml_storage.id
  primary_user_assigned_identity = azurerm_user_assigned_identity.ml_user_identity.id
  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.ml_user_identity.id,
    ]
  }

  encryption {
    key_vault_id = azurerm_key_vault.ml_key_vault.id
    key_id       = azurerm_key_vault_key.ml_kv_key.id
  }

  depends_on = [ azurerm_role_assignment.ml_identity_kv_crypto_user, azurerm_role_assignment.ml_identity_kv_reader ]
}

resource "azurerm_role_assignment" "ml_administrators" {
  for_each             = toset(var.admin_object_ids)
  scope                = azurerm_key_vault.ml_key_vault.id
  role_definition_name = "Owner"
  principal_id         = each.value
}

