output "default_ip_address" {
  description = "The ipv4 address of the Virtual Machine"
  value       = var.ipv4_network_address == null ? vsphere_virtual_machine.this.default_ip_address : local.ipv4_ip_address
}

output "guest_ip_addresses" {
  description = "The guest addresses output of the Virtual Machine"
  value       = var.ipv4_network_address == null ? vsphere_virtual_machine.this.guest_ip_addresses : compact([local.ipv4_ip_address, local.ipv6_ip_address])
}

output "id" {
  description = "The ID of the Virtual Machine"
  value       = vsphere_virtual_machine.this.id
}

output "moid" {
  description = "The Managed Object ID of the Virtual Machine"
  value       = vsphere_virtual_machine.this.moid
}

output "vmx_path" {
  description = "The vmx_path of the Virtual Machine"
  value       = vsphere_virtual_machine.this.vmx_path
}