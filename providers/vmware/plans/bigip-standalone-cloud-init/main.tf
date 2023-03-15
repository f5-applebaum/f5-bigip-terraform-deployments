locals {
  bigip_instance_count = length(var.bigip_ipv4_network_addresses)
}

#### VM CREATION ####
# Set vm parameters

module "bigip" {
  source                           = "../../modules/bigip-standalone"
  count                            = local.bigip_instance_count
  vsphere_datacenter               = var.vsphere_datacenter
  vsphere_resource_pool            = var.vsphere_resource_pool
  vsphere_datastore                = var.vsphere_datastore
  vsphere_host                     = var.vsphere_host
  vsphere_networks                 = var.bigip_networks
  vsphere_networks_ovf_map         = var.bigip_networks_ovf_map
  vsphere_content_library          = var.vsphere_content_library
  vsphere_virtual_machine          = var.vsphere_virtual_machine
  vm_name                          = "${var.bigip_vm_name_prefix}-${count.index + 1}"
  bigip_cloud_init_iso             = var.bigip_cloud_init_iso
  check_bigip_ready                = var.check_bigip_ready
  check_bigip_login_delay          = var.check_bigip_login_delay
  check_bigip_timeout              = var.check_bigip_timeout
  check_bigip_username             = var.bigip_username
  check_bigip_password             = var.bigip_password
  check_bigip_ssh_private_key_file = var.check_bigip_ssh_private_key_file
}


# Could onboard / do Config Mgmt via Ansible provisioners as well

# Other Options are:
# Terraform: https://registry.terraform.io/providers/F5Networks/bigip/latest/docs/resources/bigip_do
# Ansible: https://clouddocs.f5.com/products/orchestration/ansible/devel/f5_bigip/modules_2_0/bigip_do_deploy_module.html#bigip-do-deploy-module-2
resource "local_file" "onboard" {
  count    = local.bigip_instance_count
  filename = "declarations/do-rendered-${count.index + 1}.json"

  content = templatefile("templates/do-w-3-nics.json", {
    hostname         = "${var.bigip_vm_name_prefix}-${count.index + 1}.${var.domain}"
    self_ip_external = var.bigip_self_ips_external[count.index]
    self_ip_internal = var.bigip_self_ips_internal[count.index]
    default_gw       = var.bigip_default_gateway
    ssh_public_key   = var.ssh_public_key
    admin_username   = var.bigip_username
    admin_password   = var.bigip_password
    license_key      = var.bigip_license_keys[count.index]
  })
}

resource "null_resource" "declare_onboard" {
  count      = local.bigip_instance_count
  depends_on = [module.bigip]

  connection {
    type     = "ssh"
    user     = var.bigip_username
    password = var.bigip_password
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

# https://support.hashicorp.com/hc/en-us/articles/11119084989587-How-to-Terraform-Destroy-time-Provisioners
# "Destroy-time provisioners and their connection configurations may only reference attributes
# of the related resource, via 'self', 'count.index', or 'each.key'.
# │ References to other resources during the destroy phase can cause dependency cycles 
# and interact poorly with create_before_destroy."
# https://stackoverflow.com/questions/64436987/invalid-reference-from-destroy-provisioner

resource "null_resource" "revoke_license" {
  count = local.bigip_instance_count

  triggers = {
    user     = var.check_bigip_username
    password = var.check_bigip_password
    host     = var.check_bigip_hosts[count.index] != null ? var.check_bigip_hosts[count.index] : module.bigip[count.index].*.default_ip_address[0]
  }

  connection {
    type     = "ssh"
    user     = self.triggers.user
    password = self.triggers.password
    host     = self.triggers.host
  }

  provisioner "remote-exec" {
    when       = destroy
    on_failure = continue
    # inline     = ["tmsh revoke sys license"]
    inline = ["curl -v -u admin: -H \"Content-Type: application/json\" -d '{\"command\":\"revoke\"}' -X POST http://localhost:8100/mgmt/tm/sys/license"]
  }

}



