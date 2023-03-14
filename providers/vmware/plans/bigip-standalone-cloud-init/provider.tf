# Define authentification configuration
provider "vsphere" {
  # If you use a domain set your login like this "Domain\\User"
  user           = var.vsphere_user
  password       = var.vsphere_password
  vsphere_server = var.vsphere_server

  # If you have a self-signed cert
  allow_unverified_ssl = var.allow_unverified_ssl
}