# variables.tf

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
  default     = "eastus"
}

variable "sql_mi_name" {
  description = "Name of the SQL Managed Instance"
  type        = string
  default     = "example-sqlmi"
}

variable "sql_admin_username" {
  description = "SQL Admin username"
  type        = string
  default     = "miadmin"
}

variable "sql_admin_password" {
  description = "SQL Admin password"
  type        = string
  sensitive   = true
}

variable "sql_mi_sku" {
  description = "SKU for SQL Managed Instance"
  type        = string
  default     = "GP_Gen5"
}

variable "sql_mi_vcores" {
  description = "Number of vCores for SQL Managed Instance"
  type        = number
  default     = 4
}

variable "sql_mi_storage_size_gb" {
  description = "Storage size in GB for SQL Managed Instance"
  type        = number
  default     = 32
}
