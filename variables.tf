variable "location" {
  description = "The region where the resources will be created."
  type        = string
  default     = "uksouth"
}

variable "tenant_id" {
  description = "The tenant ID for the Azure subscription."
  type        = string
}

variable "subscription_id" {
  description = "The subscription ID for the Azure subscription."
  type        = string
}

variable "admin_object_ids" {
  description = "List of object IDs for the administrators."
  type        = list(string)
  default     = []
}