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
  description = "vSphere Datastore"
  type        = string
}

variable "vsphere_content_library" {
  description = "Name of Content Library. Provide vsphere_virtual_machine as well."
  type        = string
  default     = null
}

variable "vsphere_networks" {
  description = "List of Networks (Port groups) to add"
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

variable "cdrom_enabled" {
  description = "Attach cd-rom. Should be true if sending vApp properties."
  type        = bool
  default     = true
}

# BIG-IP Config

# Passed via OVF Properties

variable "admin_password" {
  description = "BIG-IP Admin Password in plain-text or SHA-512 shadow format."
  type        = string
  default     = "admin"
}

variable "root_password" {
  description = "BIG-IP Admin Password in plain-text or SHA-512 shadow format."
  type        = string
  default     = "default"
}

variable "ipv4_network_address" {
  description = "The IPv4 network address to assign during customization of cloned virtual machines, in A.B.C.D/XX format."
  type        = string
  default     = null
}

variable "ipv4_gateway" {
  description = "The default IPv4 gateway."
  type        = string
  default     = null
}

variable "ipv6_network_address" {
  description = "The IPv6 network address to assign during customization of cloned virtual machines, in :: format."
  type        = string
  default     = null
}

variable "ipv6_gateway" {
  description = "The default IPv6 gateway."
  type        = string
  default     = null
}


##### Misc BIG-IP Provisioner and Testing Settings
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
  description = "Pass local file location of Private Key. ex. /Users/you/.ssh/private-key.pem"
  default     = null
}

variable "check_bigip_username" {
  description = "BIG-IP username to use to validate initial ssh login and confirm onboarding completed successfully. NOTE: Defaults to root as the only user that has console access initially."
  type        = string
  default     = "root"
}

variable "check_bigip_password" {
  description = "BIG-IP password to use to validate initial ssh login and confirm onboarding completed successfully. NOTE: Must be in clear text and match decrypted password from root password param."
  type        = string
  default     = "default"
}

variable "check_bigip_host" {
  type        = string
  description = "Address to use to check. Otherwise, will default to 1st NIC IP."
  default     = null
}