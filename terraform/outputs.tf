
output "vm_name" {
  description = "Nom de la machine virtuelle"
  value       = azurerm_linux_virtual_machine.vm.name
}

output "vm_private_ip" {
  description = "Adresse IP privée de la machine virtuelle"
  value       = azurerm_network_interface.nic.private_ip_address
}

output "vm_public_ip" {
  description = "Adresse IP publique de la machine virtuelle"
  value       = azurerm_public_ip.public_ip.ip_address
}

output "vm_id" {
  description = "Identifiant unique de la machine virtuelle"
  value       = azurerm_linux_virtual_machine.vm.id
}

output "admin_username" {
  description = "Nom d'utilisateur administrateur"
  value       = azurerm_linux_virtual_machine.vm.admin_username
}
