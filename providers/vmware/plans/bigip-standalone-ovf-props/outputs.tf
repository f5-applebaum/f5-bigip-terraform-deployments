output "bigip_default_ip_addresses" {
  description = "The ipv4 address of the BIG-IP Virtual Machine(s)"
  value       = module.bigip[*].default_ip_address
}

output "bigip_guest_ip_addresses" {
  description = "The guest addresses output of the BIG-IP Virtual Machine(s)"
  value       = module.bigip[*].guest_ip_addresses
}

output "bigip_vm_ids" {
  description = "The VM IDs of the BIG-IP Virtual Machine(s)"
  value       = module.bigip[*].id
}

output "bigip_vm_moids" {
  description = "The VM Managed Object IDs of the BIG-IP Virtual Machine(s)"
  value       = module.bigip[*].moid
}

output "bigip_vmx_paths" {
  description = "The vmx_path of the BIG-IP Virtual Machine(s)"
  value       = module.bigip[*].vmx_path
}






