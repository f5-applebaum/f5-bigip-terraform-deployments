variable "vsphere_user" {
  description = "vSphere User"
  type        = string
}

variable "vsphere_password" {
  description = "vSphere Password"
  type        = string
  sensitive   = true
}

variable "vsphere_server" {
  description = "vSphere Server"
  type        = string
}

variable "allow_unverified_ssl" {
  description = "Allow Unverified SSL Cert on vSphere Server"
  type        = bool
  default     = true
}

variable "vsphere_datacenter" {
  description = "vSphere Datacenter"
  type        = string
}

variable "vsphere_host" {
  description = "vSphere Host"
  type        = string
}

variable "vsphere_resource_pool" {
  description = "vSphere Resource Pool. If you don't have any resource pools, put 'Resources' after cluster name. ex. vSAN Cluster/Resources"
  type        = string
}

variable "vsphere_datastore" {
  description = "vSphere Datastore hosting VM template and cloud-init iso"
  type        = string
}

# Common
variable "ssh_public_key" {
  description = "SSH public key"
  type        = string
}

variable "domain" {
  description = "Virtual Machine hostname domain."
  type        = string
  default     = "example.com"
}


# Retrieve template information on vsphere
variable "vsphere_content_library" {
  description = "Name of Content Library. Provide vsphere_virtual_machine parameter as well."
  type        = string
  default     = null
}

# Template Name
variable "vsphere_virtual_machine" {
  type    = string
  default = "BIGIP-16.1.3-0.0.12.ALL-vmware-Template"
}

variable "bigip_vm_name_prefix" {
  description = "Virtual Machine Name Prefix. Will add instance count as suffix."
  type        = string
  default     = "bigip"
}

variable "bigip_networks" {
  description = "List of Networks (Port groups) to add"
  type        = list(string)
  default     = ["VM Network"]
}

# https://github.com/hashicorp/terraform-provider-vsphere/issues/1345
variable "bigip_networks_ovf_map" {
  description = "BUG: List of OVF mappings if deploying from Content Library. Must match count of vSphere networks provided above."
  type        = list(string)
  default     = ["eth0"]
  #default = ["eth0", "eth1", "eth2", "eth3"]
}

# BIG-IP Config
variable "bigip_cloud_init_iso" {
  description = "Path on datastore to bigip cloud init iso. ex. /CLOUD-INIT-ISOs/bigip-cloud-init.iso"
  type        = string
  default     = "bigip-cloud-init.iso"
}

# Declarative Onboarding Vars

# Creds must match what was in cloud-init user-data iso
variable "bigip_username" {
  description = "BIG-IP username. NOTE: Must match what was configured in initial user-data iso. Default is admin"
  type        = string
  default     = "admin"
}

# Creds must match what was in cloud-init user-data iso
variable "bigip_password" {
  description = "BIG-IP password. NOTE: Must match what was configured in initial user-data iso."
  type        = string
  default     = null
}

variable "bigip_ipv4_network_addresses" {
  description = "This determines number of VMs to deploy. Use null for DHCP. ex. use [null] for 1 instance, [null,null] for 2 instances. DISCLAIMER: Static IPs not currently supported. To implement static IPs, you will need to customize the cloud-init user-data iso."
  type        = list(string)
  default     = [null]
}

variable "bigip_self_ips_external" {
  description = "List of BIG-IP External Self-Ips in A.B.C.D/XX format. One per instance."
  type        = list(string)
  default     = ["192.168.1.51/24"]
}

variable "bigip_self_ips_internal" {
  description = "List of BIG-IP Internal Self-Ips in A.B.C.D/XX format. One per instance."
  type        = list(string)
  default     = ["192.168.2.51/24"]
}

variable "bigip_default_gateway" {
  description = "BIG-IP Default Gateway"
  type        = string
  default     = "192.168.1.1"
}

variable "bigip_license_keys" {
  description = "REQUIRED: BIG-IP license registration keys. One per instance."
  type        = list(string)
}

##### Misc BIG-IP  Settings

variable "check_bigip_ready" {
  description = "Run Check Onboard Complete Script and external Onboarding provisioners. BIG-IP addresses must be reachable from terraform client."
  type        = bool
  default     = true
}

variable "check_bigip_login_delay" {
  description = "The number of seconds/minutes of delay to login."
  type        = string
  default     = "540s"
}

variable "check_bigip_timeout" {
  description = "The number of seconds/minutes to wait to confirm onboarding was successful."
  type        = string
  default     = "900s"
}

# Shouldn't pass really ever password directly though BIG-IP module but allows testing if BIG-IP is ready.
variable "check_bigip_ssh_private_key_file" {
  description = "Pass local file location of Private Key. ex. /Users/you/.ssh/private-key.pem"
  type        = string
  default     = null
  sensitive   = true
}

variable "check_bigip_hosts" {
  description = "List of specific BIG-IP Host Addresses to use. Null will default to 1st NIC IP.  IMPORTANT: If using check_bigip_ready, this list entry count must match the BIG-IP count determined by bigip_ipv4_network_addresses parameter.  Ex. use [null,null] for 2 instances, [null,null,null] for 3 instances, etc."
  type        = list(string)
  default     = [null]
}


# AS3 Config

variable "virtual_server_addresses" {
  description = "List of BIG-IP Virtual Server IPs in A.B.C.D format. One per instance."
  type        = list(string)
  default     = ["192.168.1.100"]
}

variable "pool_member_addresses" {
  description = "List of Pool Member Addresses in A.B.C.D format. One per instance."
  type        = list(string)
  default     = [null]
}


# APPLICATION VM

# Template Name
variable "vsphere_app_virtual_machine" {
  description = "VM Template on Datastore or Content Library or OVA/OVF on Content Library. Requires providing datastore OR vsphere_content_library as well. NOTE: Do not use with ovf_remote_url or local_ovf_path."
  type        = string
  default     = null
}

# OVF from Remote URL
variable "app_ovf_remote_url" {
  description = "Remote URL to App OVA file. Set to latest to pull latest release. One of ovf_remote_url, local_ovf_path or content_library must be provided."
  type        = string
  default     = null
}

# OVF from Local File
variable "app_local_ovf_path" {
  description = "Local path to App OVA file. One of ovf_remote_url, local_ovf_path or content_library must be provided."
  type        = string
  default     = null
}

variable "app_vm_name_prefix" {
  description = "App Virtual Machine Name Prefix. Will add instance count as suffix."
  type        = string
  default     = "app"
}


variable "app_username" {
  description = "The username to configure via cloud-init for ssh access to the VM."
  type        = string
  default     = "ubuntu"
}

variable "app_password" {
  description = "The password to configure via cloud-init for ssh access to the VM."
  type        = string
  # sensitive   = true
}

variable "app_networks" {
  description = "List of Networks (Port groups) to add"
  type        = list(string)
  default     = ["VM Network"]
}

# https://github.com/hashicorp/terraform-provider-vsphere/issues/1345
variable "app_networks_ovf_map" {
  description = "BUG: List of OVF mappings if deploying from Content Library. Must match count of vSphere networks provided above."
  type        = list(string)
  default     = ["eth0"]
  #default = ["eth0", "eth1", "eth2", "eth3"]
}

variable "app_ipv4_network_addresses" {
  description = "List of etwork address to assign during customization of cloned virtual machines, in A.B.C.D/XX format. This determines number of VMs to deploy.  Use one per instance."
  type        = list(string)
  default     = ["192.168.1.105/24"]
}

variable "app_ipv4_gateway" {
  description = "The default IPv4 gateway"
  type        = string
  default     = "192.168.1.1"
}

variable "app_dns_server" {
  description = "The DNS server to assign to each virtual machine."
  type        = string
  default     = "8.8.8.8"
}

variable "check_app_ready" {
  description = "Run Check Install Complete Script"
  type        = bool
  default     = false
}

variable "check_app_timeout" {
  description = "The number of seconds/minutes of wait to confirm install complate."
  type        = string
  default     = "180s"
}


# Shouldn't pass really pass private key though  but allows testing if app is ready.
variable "check_app_ssh_private_key_file" {
  description = "WARNING - TESTING ONLY: Private Key File to use to check if install is complete"
  type        = string
  default     = null
}

variable "check_app_hosts" {
  description = "List of specific App Host Addresses to use to check. IMPORTANT: If using check_app_ready, this list must match the App instance count determined by app_ipv4_network_address parameter. Null will default to 1st NIC IP. Ex. use [null,null] for 2 instances, [null,null,null] for 3 instances, etc."
  type        = list(string)
  default     = [null]
}
