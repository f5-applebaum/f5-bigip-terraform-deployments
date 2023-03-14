output "bigip_default_ip_addresses" {
  description = "The ipv4 address of the BIG-IP Virtual Machine(s)"
  value       = module.bigip[*].default_ip_address
}

output "bigip_guest_ip_addresses" {
  description = "The guest addresses output of the BIG-IP Virtual Machine(s)"
  value       = module.bigip[*].guest_ip_addresses
}