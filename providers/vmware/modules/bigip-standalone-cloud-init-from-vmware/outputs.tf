output "default_ip_address" {
  value = vsphere_virtual_machine.this.default_ip_address
}

output "guest_ip_addresses" {
  value = vsphere_virtual_machine.this.guest_ip_addresses
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