output "default_ip_address" {
  description = "The ipv4 address of the Virtual Machine"
  value       = var.vsphere_virtual_machine != null ? vsphere_virtual_machine.vm_from_vmware[0].default_ip_address : vsphere_virtual_machine.vm_from_url[0].default_ip_address
}
output "guest_ip_addresses" {
  description = "The guest addresses output of the Virtual Machine"
  value       = var.vsphere_virtual_machine != null ? vsphere_virtual_machine.vm_from_vmware[0].guest_ip_addresses : vsphere_virtual_machine.vm_from_url[0].guest_ip_addresses
}
