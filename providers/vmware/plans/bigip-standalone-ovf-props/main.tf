locals {
  bigip_instance_count = length(var.bigip_ipv4_network_addresses)
}

#### VM CREATION ####
# Set vm parameters

module "bigip" {
  source                   = "../../modules/bigip-standalone-ovf-props-from-vmware"
  count                    = local.bigip_instance_count
  vsphere_datacenter       = var.vsphere_datacenter
  vsphere_resource_pool    = var.vsphere_resource_pool
  vsphere_datastore        = var.vsphere_datastore
  vsphere_host             = var.vsphere_host
  vsphere_networks         = var.bigip_networks
  vsphere_networks_ovf_map = var.bigip_networks_ovf_map
  vsphere_content_library  = var.vsphere_content_library
  vsphere_virtual_machine  = var.vsphere_virtual_machine
  # ovf_remote_url                   = var.bigip_ovf_remote_url
  # local_ovf_path                   = var.bigip_local_ovf_path
  vm_name                          = "${var.bigip_vm_name_prefix}-${count.index + 1}"
  admin_username                   = var.bigip_admin_username
  admin_password                   = var.bigip_admin_password
  root_password                    = var.bigip_root_password
  ipv4_network_address             = var.bigip_ipv4_network_addresses[count.index]
  ipv4_gateway                     = var.bigip_ipv4_gateway
  check_bigip_ready                = var.check_bigip_ready
  check_bigip_login_delay          = var.check_bigip_login_delay
  check_bigip_timeout              = var.check_bigip_timeout
  check_bigip_username             = var.check_bigip_username
  check_bigip_password             = var.check_bigip_password
  check_bigip_host                 = var.check_bigip_hosts[count.index]
  check_bigip_ssh_private_key_file = var.check_bigip_ssh_private_key_file
}



# Could onboard / do Config Mgmt via Ansible provisioners as well

# Install Packages
resource "null_resource" "install_packages" {
  count      = local.bigip_instance_count
  depends_on = [module.bigip]

  connection {
    type     = "ssh"
    user     = var.check_bigip_username
    password = var.check_bigip_password
    host     = var.check_bigip_hosts[count.index] != null ? var.check_bigip_hosts[count.index] : module.bigip[count.index].*.default_ip_address[0]
    timeout  = var.check_bigip_timeout
  }

  provisioner "remote-exec" {
    inline = ["mkdir -p /config/cloud"]
  }

  provisioner "file" {
    source      = "scripts/install-packages.sh"
    destination = "/config/cloud/install-packages.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /config/cloud/install-packages.sh",
      "/config/cloud/install-packages.sh"
    ]
  }

}

# Another option is could use https://registry.terraform.io/providers/F5Networks/bigip/latest/docs/resources/bigip_do
resource "local_file" "onboard" {
  count    = local.bigip_instance_count
  filename = "declarations/do-rendered-${count.index + 1}.json"

  content = templatefile("templates/do-w-3-nics.json", {
    hostname         = "${var.bigip_vm_name_prefix}-${count.index + 1}.${var.domain}"
    self_ip_external = var.bigip_self_ips_external[count.index]
    self_ip_internal = var.bigip_self_ips_internal[count.index]
    default_gw       = var.bigip_default_gateway
    ssh_public_key   = var.ssh_public_key
    admin_username   = var.bigip_admin_username
    admin_password   = var.bigip_admin_password
    license_key      = var.bigip_license_keys[count.index]
  })
}

resource "null_resource" "declare_onboard" {
  count      = local.bigip_instance_count
  depends_on = [module.bigip, null_resource.install_packages]

  connection {
    type     = "ssh"
    user     = var.check_bigip_username
    password = var.check_bigip_password
    host     = var.check_bigip_hosts[count.index] != null ? var.check_bigip_hosts[count.index] : module.bigip[count.index].*.default_ip_address[0]
    timeout  = var.check_bigip_timeout
  }

  provisioner "remote-exec" {
    inline = ["mkdir -p /tmp/declarations"]
  }

  provisioner "file" {
    source      = "declarations/do-rendered-${count.index + 1}.json"
    destination = "/tmp/declarations/do-rendered.json"
  }

  provisioner "file" {
    source      = "declarations/runtime-init-do.yaml"
    destination = "/tmp/declarations/runtime-init-do.yaml"
  }
  provisioner "remote-exec" {
    inline = ["f5-bigip-runtime-init -c /tmp/declarations/runtime-init-do.yaml"]
  }

}


