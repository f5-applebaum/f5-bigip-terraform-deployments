data "vsphere_datacenter" "dc" {
  name = var.vsphere_datacenter
}

data "vsphere_host" "host" {
  name          = var.vsphere_host
  datacenter_id = data.vsphere_datacenter.dc.id
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

data "vsphere_ovf_vm_template" "ovfRemote" {
  count             = var.ovf_remote_url != null ? 1 : 0
  name              = "ovfRemote"
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
  name              = "ovfLocal"
  disk_provisioning = "thin"
  resource_pool_id  = data.vsphere_resource_pool.pool.id
  datastore_id      = data.vsphere_datastore.datastore.id
  host_system_id    = data.vsphere_host.host.id
  local_ovf_path    = var.local_ovf_path
  ovf_network_map = {
    "VM Network" : data.vsphere_network.network[0].id
  }
}

# stringify for outputs
locals {
  ipv4_ip_address = var.ipv4_network_address != null ? regex("(.*)/.*", var.ipv4_network_address)[0] : null
  ipv6_ip_address = var.ipv6_network_address != null ? regex("(.*)/.*", var.ipv6_network_address)[0] : null
}

#### VM CREATION ####

resource "vsphere_virtual_machine" "this" {
  name             = var.vm_name
  datacenter_id    = data.vsphere_datacenter.dc.id
  host_system_id   = data.vsphere_host.host.id
  datastore_id     = data.vsphere_datastore.datastore.id
  resource_pool_id = data.vsphere_resource_pool.pool.id

  wait_for_guest_net_timeout = 10
  wait_for_guest_ip_timeout  = 10

  num_cpus = var.num_cpus
  memory   = var.memory

  scsi_type = "${var.ovf_remote_url}" != null ? data.vsphere_ovf_vm_template.ovfRemote[0].scsi_type : data.vsphere_ovf_vm_template.ovfLocal[0].scsi_type

  dynamic "network_interface" {
    for_each = data.vsphere_network.network
    content {
      network_id = network_interface.value.id
    }
  }

  dynamic "ovf_deploy" {
    for_each = "${var.local_ovf_path}" != null || "${var.ovf_remote_url}" != null ? [0] : []
    content {
      local_ovf_path            = "${var.local_ovf_path}" != null ? "${var.local_ovf_path}" : null
      remote_ovf_url            = "${var.ovf_remote_url}" != null ? "${var.ovf_remote_url}" : null
      allow_unverified_ssl_cert = true

      ip_protocol          = "${var.ovf_remote_url}" != null ? data.vsphere_ovf_vm_template.ovfRemote[0].ip_protocol : data.vsphere_ovf_vm_template.ovfLocal[0].ip_protocol
      ip_allocation_policy = "${var.ovf_remote_url}" != null ? data.vsphere_ovf_vm_template.ovfRemote[0].ip_allocation_policy : data.vsphere_ovf_vm_template.ovfLocal[0].ip_allocation_policy
      disk_provisioning    = "${var.ovf_remote_url}" != null ? data.vsphere_ovf_vm_template.ovfRemote[0].disk_provisioning : data.vsphere_ovf_vm_template.ovfLocal[0].disk_provisioning

      ovf_network_map = "${var.ovf_remote_url}" != null ? data.vsphere_ovf_vm_template.ovfRemote[0].ovf_network_map : data.vsphere_ovf_vm_template.ovfLocal[0].ovf_network_map
    }
  }

  dynamic "cdrom" {
    for_each = var.cdrom_enabled == true ? [1] : []
    content {
      client_device = var.cdrom_enabled
    }
  }

  vapp {
    properties = {
      "net.mgmt.addr"  = var.ipv4_network_address == null ? "" : var.ipv4_network_address,
      "net.mgmt.addr6" = var.ipv6_network_address == null ? "" : var.ipv6_network_address,
      "net.mgmt.gw"    = var.ipv4_gateway == null ? "" : var.ipv4_gateway,
      "net.mgmt.gw6"   = var.ipv6_gateway == null ? "" : var.ipv6_gateway,
      "user.root.pwd"  = var.root_password,
      "user.admin.pwd" = var.admin_password
    }
  }

  lifecycle {
    ignore_changes = [
      annotation,
      vapp[0].properties
    ]
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

