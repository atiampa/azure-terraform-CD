# outputs.tf

output "sql_mi_id" {
  description = "The ID of the SQL Managed Instance"
  value       = azurerm_mssql_managed_instance.example.id
}

output "sql_mi_fqdn" {
  description = "The fully qualified domain name of the SQL Managed Instance"
  value       = azurerm_mssql_managed_instance.example.fqdn
}

output "subnet_id" {
  description = "The ID of the subnet used by the SQL Managed Instance"
  value       = azurerm_subnet.example.id
}

output "vnet_id" {
  description = "The ID of the virtual network"
  value       = azurerm_virtual_network.example.id
}
