output "bigip_default_ip_addresses" {
  description = "The ipv4 address of the BIG-IP Virtual Machine(s)"
  value       = module.bigip[*].default_ip_address
}

output "bigip_guest_ip_addresses" {
  description = "The guest addresses output of the BIG-IP Virtual Machine(s)"
  value       = module.bigip[*].guest_ip_addresses
}

output "application_default_ip_address" {
  description = "The ipv4 address of the App Virtual Machine(s)"
  value       = module.application[*].default_ip_address
}

output "application_guest_ip_addresses" {
  description = "The guest addresses output of the App Virtual Machine(s)"
  value       = module.application[*].guest_ip_addresses
}
