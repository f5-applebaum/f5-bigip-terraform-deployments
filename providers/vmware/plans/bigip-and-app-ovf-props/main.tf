module "utils" {
  source = "../../modules/utils"

}

locals {
  app_admin_password      = var.app_password != null ? var.app_password : module.utils.admin_password.result
  app_admin_password_hash = var.app_password != null ? bcrypt(var.app_password) : module.utils.admin_password.bcrypt_hash
  bigip_admin_password    = var.bigip_admin_password != null ? var.bigip_admin_password : module.utils.admin_password.result
  bigip_root_password     = var.bigip_root_password != null ? var.bigip_root_password : module.utils.admin_password.result
  check_bigip_password    = local.bigip_root_password

  app_instance_count   = length(var.app_ipv4_network_addresses)
  bigip_instance_count = length(var.bigip_ipv4_network_addresses)
}


# Application

module "application" {
  source                        = "../../modules/application"
  count                         = local.app_instance_count
  vsphere_datacenter            = var.vsphere_datacenter
  vsphere_host                  = var.vsphere_host
  vsphere_resource_pool         = var.vsphere_resource_pool
  vsphere_datastore             = var.vsphere_datastore
  vsphere_content_library       = var.vsphere_content_library
  vsphere_networks              = var.app_networks
  vsphere_networks_ovf_map      = var.app_networks_ovf_map
  vsphere_virtual_machine       = var.vsphere_app_virtual_machine
  ovf_remote_url                = var.app_ovf_remote_url
  vm_name                       = "${var.app_vm_name_prefix}-${count.index + 1}"
  vm_hostname                   = "${var.app_vm_name_prefix}-${count.index + 1}.${var.domain}"
  admin_username                = var.app_username
  admin_password                = local.app_admin_password
  ssh_public_key                = var.ssh_public_key
  dns_server                    = var.app_dns_server
  ipv4_network_address          = var.app_ipv4_network_addresses[count.index]
  ipv4_gateway                  = var.app_ipv4_gateway
  check_vm_ready                = var.check_app_ready
  check_vm_timeout              = var.check_app_timeout
  check_vm_password             = local.app_admin_password
  check_vm_ssh_private_key_file = var.check_app_ssh_private_key_file
  check_vm_host                 = var.check_app_hosts[count.index]
}


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

# Install Packages:

# Other Options are:
# https://clouddocs.f5.com/products/orchestration/ansible/devel/f5_bigip/modules_2_0/bigip_lx_package_module.html#bigip-lx-package-module-2

resource "null_resource" "install_packages" {
  count      = local.bigip_instance_count
  depends_on = [module.bigip]

  connection {
    type     = "ssh"
    user     = var.check_bigip_username
    password = local.check_bigip_password
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
    password = local.check_bigip_password
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


# Day 1-N Should really be seperated out but included here for simple full stack

# Options are: 
# Terraform: https://registry.terraform.io/providers/F5Networks/bigip/latest/docs/resources/bigip_as3
# Ansible: https://clouddocs.f5.com/products/orchestration/ansible/devel/f5_bigip/modules_2_0/bigip_as3_deploy_module.html#bigip-as3-deploy-module-2

resource "local_file" "as3" {
  count    = local.bigip_instance_count
  filename = "declarations/as3-rendered-${count.index + 1}.json"

  content = templatefile("templates/as3.json", {
    virtual_server_address = var.virtual_server_addresses[count.index]
    pool_member_addresses  = element(concat(module.application[*].default_ip_address), count.index)
  })
}


resource "null_resource" "declare_as3" {
  count      = local.bigip_instance_count
  depends_on = [module.bigip, local_file.as3, null_resource.declare_onboard]

  connection {
    type     = "ssh"
    user     = var.check_bigip_username
    password = local.check_bigip_password
    host     = var.check_bigip_hosts[count.index] != null ? var.check_bigip_hosts[count.index] : module.bigip[count.index].*.default_ip_address[0]
    timeout  = var.check_bigip_timeout
  }

  provisioner "remote-exec" {
    inline = ["mkdir -p /tmp/declarations"]
  }

  provisioner "file" {
    source      = "declarations/as3-rendered-${count.index + 1}.json"
    destination = "/tmp/declarations/as3-rendered.json"
  }

  provisioner "file" {
    source      = "declarations/runtime-init-as3.yaml"
    destination = "/tmp/declarations/runtime-init-as3.yaml"
  }
  provisioner "remote-exec" {
    inline = ["f5-bigip-runtime-init -c /tmp/declarations/runtime-init-as3.yaml"]
  }

}
