variable "vsphere_datacenter" {
  description = "vSphere Datacenter"
  type        = string
}

variable "vsphere_host" {
  description = "vSphere Host"
  type        = string
}

variable "vsphere_resource_pool" {
  description = "vSphere Resource Pool. If you don't have any resource pools, put 'Resources' after cluster name. ex. vSAN Cluster/Resources."
  type        = string
}

variable "vsphere_datastore" {
  description = "vSphere Datastore"
  type        = string
}

variable "vsphere_content_library" {
  description = "Name of Content Library. Provide vsphere_virtual_machine as well."
  type        = string
  default     = null
}

variable "vsphere_networks" {
  description = "List of Networks (Port groups) to add."
  type        = list(string)
  default     = ["VM Network"]
}

# https://github.com/hashicorp/terraform-provider-vsphere/issues/1345
variable "vsphere_networks_ovf_map" {
  description = "BUG: List of OVF mappings if deploying from Content Library. Must match count of vSphere networks provided above."
  type        = list(string)
  default     = ["eth0"]
}

# Retrieve template information on vsphere
variable "vsphere_virtual_machine" {
  type    = string
  default = "BIGIP-16.1.3-0.0.12.ALL-vmware"
}

variable "vm_name" {
  description = "Virtual Machine Name"
  type        = string
  default     = "bigip"
}

variable "num_cpus" {
  description = "Number of CPUs"
  type        = number
  default     = 8
}

variable "memory" {
  description = "Memory in MBs"
  type        = number
  default     = 16384
}

variable "thin_provisioned" {
  description = "Thin Provisioned"
  type        = bool
  default     = false
}

variable "disk_size" {
  description = "Disk Size in GBs"
  type        = number
  default     = 120
}

# BIG-IP Config

variable "bigip_cloud_init_iso" {
  description = "Path on datastore to BIG-IP cloud-init iso. ex. /CLOUD-INIT-ISOs/bigip-cloud-init.iso."
  type        = string
  default     = "bigip-cloud-init.iso"
}

##### Misc BIG-IP Testing Settings
variable "check_bigip_ready" {
  type        = bool
  description = "Run Check Onboard Complete Script."
  default     = false
}

variable "check_bigip_login_delay" {
  type        = string
  description = "The number of seconds/minutes of delay to login."
  default     = "180s"
}

variable "check_bigip_timeout" {
  type        = string
  description = "The number of seconds/minutes to wait to confirm onboarding was successful."
  default     = "900s"
}

variable "check_bigip_ssh_private_key_file" {
  type        = string
  description = "Pass local file location of Private Key. ex. /Users/you/.ssh/private-key.pem. One of this or check_bigip_password parameters must be provided."
  default     = null
}

variable "check_bigip_username" {
  description = "BIG-IP username to use to validate initial ssh login and confirm onboarding completed successfully. Needs to match what was passed in initial user-data iso."
  type        = string
  default     = "admin"
}

variable "check_bigip_password" {
  type        = string
  description = "BIG-IP password to use to validate initial ssh login and confirm onboarding completed successfully. Needs to match what was passed in initial user-data iso. If checking, either this or check_bigip_ssh_private_key_file parameters must be provided."
  default     = null
}

variable "check_bigip_host" {
  type        = string
  description = "Host Address to use to check. Otherwise, will default to 1st NIC IP obtained via DHCP. Can be used to override if there's a NAT, FW, etc."
  default     = null
}