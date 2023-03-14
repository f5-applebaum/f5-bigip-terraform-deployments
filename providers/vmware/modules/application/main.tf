# Example: Deploy VM from Stock Ubuntu Server (Kinetic 22.10) OVA from URL or Content Library
# https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs/resources/virtual_machine#deploying-virtual-machines-from-ovfova



#### RETRIEVE DATA INFORMATION ON VCENTER ####
data "vsphere_datacenter" "dc" {
  name = var.vsphere_datacenter
}

data "vsphere_host" "host" {
  name          = var.vsphere_host
  datacenter_id = data.vsphere_datacenter.dc.id
}

# If you don't have any resource pools, put "Resources" after cluster name
data "vsphere_resource_pool" "pool" {
  name          = var.vsphere_resource_pool
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Retrieve datastore information on vsphere
data "vsphere_datastore" "datastore" {
  name          = var.vsphere_datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  count = length(var.vsphere_networks)
  name  = var.vsphere_networks[count.index]
  #   name          = keys(var.network)[count.index]
  datacenter_id = data.vsphere_datacenter.dc.id
}


data "vsphere_virtual_machine" "template" {
  count         = var.vsphere_content_library == null ? 1 : 0
  name          = var.vsphere_virtual_machine
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_content_library" "content_library" {
  count = var.vsphere_content_library != null ? 1 : 0
  name  = var.vsphere_content_library
}

# Data source for vCenter Content Library Item (OVA)
data "vsphere_content_library_item" "item" {
  count      = var.vsphere_content_library != null ? 1 : 0
  name       = var.vsphere_virtual_machine
  type       = "ovf"
  library_id = data.vsphere_content_library.content_library[0].id
}

data "vsphere_ovf_vm_template" "ovfRemote" {
  count             = var.ovf_remote_url != null ? 1 : 0
  name              = "foo"
  disk_provisioning = "thin"
  resource_pool_id  = data.vsphere_resource_pool.pool.id
  datastore_id      = data.vsphere_datastore.datastore.id
  host_system_id    = data.vsphere_host.host.id
  remote_ovf_url    = var.ovf_remote_url
  ovf_network_map = {
    "VM Network" : data.vsphere_network.network[0].id
  }
}

data "vsphere_ovf_vm_template" "ovfLocal" {
  count             = var.local_ovf_path != null ? 1 : 0
  name              = "foo"
  disk_provisioning = "thin"
  resource_pool_id  = data.vsphere_resource_pool.pool.id
  datastore_id      = data.vsphere_datastore.datastore.id
  host_system_id    = data.vsphere_host.host.id
  local_ovf_path    = var.local_ovf_path
  ovf_network_map = {
    "VM Network" : data.vsphere_network.network[0].id
  }
}


# Templating Cloud-Init 
# Metadata not sent directly with vApp Options. Embed netplan instead
locals {
  admin_password_hash = var.admin_password_hash != null ? var.admin_password_hash : bcrypt(var.admin_password)

  netplan_rendered = templatefile("${path.module}/templates/netplan.tpl", {
    ipv4_network_address = var.ipv4_network_address != null ? var.ipv4_network_address : ""
    ipv4_gateway         = var.ipv4_gateway != null ? var.ipv4_gateway : ""
    dns_server           = var.dns_server != null ? var.dns_server : ""
  })
  user_data_rendered = templatefile("${path.module}/templates/userdata.tpl", {
    netplan            = base64encode(var.ipv4_network_address != null ? local.netplan_rendered : "")
    ssh_public_key     = var.ssh_public_key
    username           = var.admin_username
    password_hash      = local.admin_password_hash
    app_container_name = var.app_container_name
  })

  # Type of deployment. URL or template
  ovf_deploy    = "${var.local_ovf_path}" != null || "${var.ovf_remote_url}" != null ? 1 : 0
  template_uuid = var.vsphere_content_library != null ? data.vsphere_content_library_item.item[0].id : data.vsphere_virtual_machine.template[0].id
}

#### VM CREATION ####

### FROM URL
resource "vsphere_virtual_machine" "vm_from_url" {
  count    = local.ovf_deploy
  name     = var.vm_name
  num_cpus = var.num_cpus
  memory   = var.memory

  datastore_id     = data.vsphere_datastore.datastore.id
  resource_pool_id = data.vsphere_resource_pool.pool.id

  datacenter_id  = data.vsphere_datacenter.dc.id
  host_system_id = data.vsphere_host.host.id

  wait_for_guest_net_timeout = 5
  wait_for_guest_ip_timeout  = 5

  dynamic "network_interface" {
    for_each = data.vsphere_network.network
    content {
      network_id = network_interface.value.id
    }
  }

  dynamic "ovf_deploy" {
    for_each = "${var.local_ovf_path}" != null || "${var.ovf_remote_url}" != null ? [0] : []
    content {
      // Path to local or remote ovf/ova file
      local_ovf_path = "${var.local_ovf_path}" != null ? "${var.local_ovf_path}" : null
      remote_ovf_url = "${var.ovf_remote_url}" != null ? "${var.ovf_remote_url}" : null

      allow_unverified_ssl_cert = true
      disk_provisioning         = "${var.ovf_remote_url}" != null ? data.vsphere_ovf_vm_template.ovfRemote[0].disk_provisioning : data.vsphere_ovf_vm_template.ovfLocal[0].disk_provisioning
      ovf_network_map           = "${var.ovf_remote_url}" != null ? data.vsphere_ovf_vm_template.ovfRemote[0].ovf_network_map : data.vsphere_ovf_vm_template.ovfLocal[0].ovf_network_map
    }
  }

  vapp {
    properties = {
      "hostname"    = var.vm_hostname,
      "instance-id" = var.vm_name,
      "seedfrom"    = "",
      "public-keys" = var.ssh_public_key,
      "password"    = var.admin_password,
      "user-data"   = base64encode(var.custom_user_data != null ? var.custom_user_data : local.user_data_rendered)
    }
  }

  lifecycle {
    ignore_changes = [
      annotation,
      vapp[0].properties
    ]
  }

  dynamic "cdrom" {
    for_each = var.cdrom_enabled == true ? [1] : []
    content {
      client_device = var.cdrom_enabled
    }
  }


}


### FROM CONTENT LIB
resource "vsphere_virtual_machine" "vm_from_vmware" {
  count    = var.vsphere_virtual_machine != null ? 1 : 0
  name     = var.vm_name
  num_cpus = var.num_cpus
  memory   = var.memory

  datastore_id     = data.vsphere_datastore.datastore.id
  resource_pool_id = data.vsphere_resource_pool.pool.id

  guest_id  = var.vsphere_content_library == null ? data.vsphere_virtual_machine.template[0].guest_id : null
  scsi_type = var.vsphere_content_library == null ? data.vsphere_virtual_machine.template[0].scsi_type : null

  wait_for_guest_net_timeout = 5
  wait_for_guest_ip_timeout  = 5

  disk {
    label            = "${var.vm_name}-disk.vmdk"
    size             = var.disk_size
    thin_provisioned = var.thin_provisioned
  }

  # Set network parameters
  # have to set ovf_mapping field due to https://github.com/hashicorp/terraform-provider-vsphere/issues/1345
  dynamic "network_interface" {
    for_each = data.vsphere_network.network
    content {
      network_id  = network_interface.value.id
      ovf_mapping = var.vsphere_networks_ovf_map[network_interface.key]
    }
  }

  clone {
    template_uuid = local.template_uuid
  }

  vapp {
    properties = {
      "hostname"    = var.vm_hostname,
      "instance-id" = var.vm_name,
      "seedfrom"    = "",
      "public-keys" = var.ssh_public_key,
      "password"    = var.admin_password,
      "user-data"   = base64encode(var.custom_user_data != null ? var.custom_user_data : local.user_data_rendered)
    }
  }
  dynamic "cdrom" {
    for_each = var.cdrom_enabled == true ? [1] : []
    content {
      client_device = var.cdrom_enabled
    }
  }

  lifecycle {
    ignore_changes = [
      clone[0].template_uuid,
      annotation,
      vapp[0].properties
    ]
  }

}




resource "null_resource" "check_install_complete_from_url" {
  count      = var.check_vm_ready == true && local.ovf_deploy == 1 ? 1 : 0
  depends_on = [vsphere_virtual_machine.vm_from_url[0]]
  connection {
    type        = "ssh"
    user        = var.admin_username
    password    = var.check_vm_password
    private_key = var.check_vm_ssh_private_key_file != null ? file("${var.check_vm_ssh_private_key_file}") : null
    host        = var.check_vm_host != null ? var.check_vm_host : vsphere_virtual_machine.vm_from_url[0].default_ip_address
    timeout     = var.check_vm_timeout
    script_path = "/var/tmp/check_install_complete.sh"
  }

  provisioner "remote-exec" {
    script = "${path.module}/scripts/check_install_complete.sh"
  }
}


resource "null_resource" "check_install_complete_from_vmware" {
  count      = var.check_vm_ready == true && var.vsphere_virtual_machine != null ? 1 : 0
  depends_on = [vsphere_virtual_machine.vm_from_vmware[0]]
  connection {
    type        = "ssh"
    user        = var.admin_username
    password    = var.check_vm_password
    private_key = var.check_vm_ssh_private_key_file != null ? file("${var.check_vm_ssh_private_key_file}") : null
    host        = var.check_vm_host != null ? var.check_vm_host : vsphere_virtual_machine.vm_from_vmware[0].default_ip_address
    timeout     = var.check_vm_timeout
    script_path = "/var/tmp/check_install_complete.sh"
  }

  provisioner "remote-exec" {
    script = "${path.module}/scripts/check_install_complete.sh"
  }
}