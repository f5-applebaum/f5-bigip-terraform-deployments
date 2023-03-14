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


# Retrieve template information

# # Ovf from remote url
# variable "bigip_ovf_remote_url" {
#   description = "BIG-IP OVF Template Remote URL. Set to latest to pull latest release. One of ovf_remote_url, local_ovf_path or content_library must be provided."
#   type        = string
#   default     = null
# }

# # Ovf from local path
# variable "bigip_local_ovf_path" {
#   description = "Local path to OVA file. One of ovf_remote_url, local_ovf_path or content_library must be provided."
#   type        = string
#   default     = null
# }

# Template from Content Lib
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

# Declarative Onboarding Vars

variable "bigip_admin_username" {
  description = "BIG-IP admin username. Default is admin"
  type        = string
  default     = "admin"
}

variable "bigip_admin_password" {
  description = "BIG-IP admin initial password. WARNING: Visible in VMWare console so need to change immediately."
  type        = string
  default     = null
}

variable "bigip_root_password" {
  description = "BIG-IP root initial password. WARNING: Visible in VMWare console so need to change immediately."
  type        = string
  default     = null
}

variable "bigip_ipv4_network_addresses" {
  description = "List of Management IP addresses in X.X.X.X/X format. One per instance. This determines number of VMs to deploy. ex. use [\"10.1.1.11/24\"] for 1 instance, [\"10.1.1.11/24\",\"10.1.1.12/24\"] for 2 instances. Use null for DHCP. ex. or [null] for 1 instance, [null,null] for 2 instances."
  type        = list(string)
  default     = [null]
}

variable "bigip_ipv4_gateway" {
  description = "The default IPv4 gateway (Management)."
  type        = string
  default     = null
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

##### Misc BIG-IP Testing Settings

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

variable "check_bigip_username" {
  description = "BIG-IP username to use to validate initial ssh login and confirm onboarding completed successfully."
  type        = string
  default     = "root"
}

variable "check_bigip_password" {
  description = "BIG-IP password to use to validate initial ssh login. NOTE: Must be in clear text and match decrypted password from bigip_password param."
  type        = string
  default     = "default"
}

# Shouldn't pass really ever password directly though BIG-IP module but allows testing if BIG-IP is ready.
variable "check_bigip_ssh_private_key_file" {
  description = "RECOMMENDED: Pass local file location of Private Key. ex. /Users/you/.ssh/private-key.pem"
  type        = string
  default     = null
  sensitive   = true
}

variable "check_bigip_hosts" {
  description = "List of specific BIG-IP Host IP Addresses to use to check that is reachable from terraform client. IMPORTANT: If using check_bigip_ready, this list entry count must also match the count determined by bigip_ipv4_network_addresses parameter.  Unless there's a NAT, this list should match the list provided in the bigip_ipv4_network_addresses parameter without the prefix  ex. [\"192.168.1.11\"] for 1 instance with static IP, [\"192.168.1.11\",\"192.168.1.12\"] for 2 instances, etc.  Null is used for the 1st NIC IP provided by DHCP. Ex. use [null,null] for 2 instances, [null,null,null] for 3 instances, etc. "
  type        = list(string)
  default     = [null]
}
