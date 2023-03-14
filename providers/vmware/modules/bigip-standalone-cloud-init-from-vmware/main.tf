# Basic configuration without variables

#### RETRIEVE DATA INFORMATION ON VCENTER ####

data "vsphere_datacenter" "dc" {
  name = var.vsphere_datacenter
}

data "vsphere_resource_pool" "pool" {
  name          = var.vsphere_resource_pool
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "datastore" {
  name          = var.vsphere_datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  count         = length(var.vsphere_networks)
  name          = var.vsphere_networks[count.index]
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
  type       = "vm-template"
  library_id = data.vsphere_content_library.content_library[0].id
}


#### VM CREATION ####

locals {
  template_uuid = var.vsphere_content_library != null ? data.vsphere_content_library_item.item[0].id : data.vsphere_virtual_machine.template[0].id
}


# Set vm parameters
resource "vsphere_virtual_machine" "this" {
  #depends_on = [ vsphere_file.cloud-init ]
  name             = var.vm_name
  num_cpus         = var.num_cpus
  memory           = var.memory
  datastore_id     = data.vsphere_datastore.datastore.id
  resource_pool_id = data.vsphere_resource_pool.pool.id

  guest_id  = var.vsphere_content_library == null ? data.vsphere_virtual_machine.template[0].guest_id : null
  scsi_type = var.vsphere_content_library == null ? data.vsphere_virtual_machine.template[0].scsi_type : null

  # https://github.com/hashicorp/terraform-provider-vsphere/issues/718
  wait_for_guest_net_timeout = 5
  wait_for_guest_ip_timeout  = 5

  disk {
    label = "${var.vm_name}-disk.vmdk"
    size  = var.disk_size
    # https://github.com/hashicorp/terraform-provider-vsphere/issues/562
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


  # This Template does not have OVF properties to toggle username/password
  # Using Simple Cloud-Init ISO (datasource = Cloud-Drive) to pass startup script  
  cdrom {
    datastore_id = data.vsphere_datastore.datastore.id
    path         = var.bigip_cloud_init_iso
  }

}

# TESTING ONLY: Check Onboard Script Requires Terraform client to be able to reach BIG-IP Management IP, have credentials, etc.
# https://github.com/hashicorp/terraform/issues/4668
# NOTE: Need to sleep for wait_bigip_ready time above for MCPD to finish booting up (if using SSH-Key Auth) due to error below:
# BIG-IP Log: 
# 2022-12-07T17:11:18.198-0800 [ERROR] scp stderr: "Cannot connect to mcpd. Your preferences and aliases will not be available until it comes back up.\nSyntax Error: unexpected argument \"scp\"\n"
# AND/OR if using Password Auth, beggining 16.x, for Runtime-Init and DO to finish setting password before can attempt to log in due to error below:
# Terraform Log: 
# Timeout - last error: SSH authentication failed (admin@XX.XX.XX.XX:22): ssh: handshake failed: ssh: unable to authenticate, attempted methods [none keyboard-interactive publickey], no supported methods remain

resource "time_sleep" "check_bigip_login_delay" {
  count           = var.check_bigip_ready == true ? 1 : 0
  depends_on      = [vsphere_virtual_machine.this]
  create_duration = var.check_bigip_login_delay
}
resource "null_resource" "check_onboard_complete" {
  count      = var.check_bigip_ready == true ? 1 : 0
  depends_on = [vsphere_virtual_machine.this, time_sleep.check_bigip_login_delay]

  connection {
    type        = "ssh"
    user        = var.check_bigip_username
    host        = var.check_bigip_host != null ? var.check_bigip_host : vsphere_virtual_machine.this.default_ip_address
    private_key = var.check_bigip_ssh_private_key_file != null ? file("${var.check_bigip_ssh_private_key_file}") : null
    password    = var.check_bigip_password
    timeout     = var.check_bigip_timeout
    script_path = "/var/tmp/check_onboard_complete.sh"
  }

  provisioner "remote-exec" {
    script = "${path.module}/scripts/check_onboard_complete.sh"
  }
}

