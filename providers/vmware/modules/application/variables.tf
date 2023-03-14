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

variable "vsphere_content_library" {
  description = "Name of Content Library. Provide vsphere_virtual_machine as well. One of ovf_remote_url, local_ovf_path or (content_library and vsphere_virtual_machine) must be provided."
  type        = string
  default     = null
}

variable "vsphere_virtual_machine" {
  description = "OVA/OVF file on Content Library. Provide vsphere_content_library as well. One of ovf_remote_url, local_ovf_path or (content_library and vsphere_virtual_machine) must be provided."
  type        = string
  default     = null
}

# Ovf from remote URL
variable "ovf_remote_url" {
  description = "Remote URL to fetch OVA. One of ovf_remote_url, local_ovf_path or (content_library and vsphere_virtual_machine) must be provided."
  type        = string
  default     = null
}

# Ovf from local path
variable "local_ovf_path" {
  description = "Local path to OVA file. One of ovf_remote_url, local_ovf_path or (content_library and vsphere_virtual_machine) must be provided."
  type        = string
  default     = null
}

# App Config

variable "admin_username" {
  description = "The username to configure via cloud-init for ssh access to the VM."
  type        = string
  default     = "ubuntu"
}

variable "admin_password" {
  description = "The password to configure via cloud-init for ssh access to the VM."
  type        = string
  sensitive   = true
}

variable "admin_password_hash" {
  description = "The password hash to configure via cloud-init for ssh access to the VM."
  type        = string
  default     = null
  sensitive   = true
}

variable "ssh_public_key" {
  description = "SSH public key"
  type        = string
}

variable "vm_name" {
  description = "Virtual Machine Name"
  type        = string
  default     = "app-01"
}

variable "vm_hostname" {
  description = "Virtual Machine Hostname"
  type        = string
  default     = "app-01.example.local"
}

variable "app_container_name" {
  description = "The app container name to run"
  type        = string
  default     = "f5devcentral/f5-demo-app:latest"
}

variable "num_cpus" {
  description = "Number of CPUS"
  type        = number
  default     = 2
}
variable "memory" {
  description = "Memory"
  type        = number
  default     = 1024
}

variable "thin_provisioned" {
  description = "Thin Provisioned"
  type        = bool
  default     = false
}

variable "disk_size" {
  description = "Disk Size in Gbps"
  type        = number
  default     = 20
}

variable "cdrom_enabled" {
  description = "Attach cd-rom. Should be true if sending vApp properties and OVF env transport = iso. Set to false if sending extra_config and OVF transport = VMtools."
  type        = bool
  default     = true
}

variable "ipv4_network_address" {
  description = "The network address to assign during customization of cloned virtual machines, in A.B.C.D/XX format."
  type        = string
  default     = null
}

variable "ipv4_gateway" {
  description = "The default IPv4 gateway"
  type        = string
  default     = null
}

variable "dns_server" {
  description = "The DNS server to assign to each virtual machine."
  type        = string
  default     = null
}

variable "custom_meta_data" {
  description = "Provide a custom metadata string"
  type        = string
  default     = null
}

variable "custom_user_data" {
  description = "Provide a custom metadata string"
  type        = string
  default     = null
}

## OPTIONAL TEST

variable "check_vm_ready" {
  description = "Run Install Complete Script"
  type        = bool
  default     = false
}

variable "check_vm_timeout" {
  description = "The number of seconds/minutes of wait to confirm install complate."
  type        = string
  default     = "180s"
}

variable "check_vm_host" {
  description = "Address to use to check. Otherwise, will default to 1st NIC IP address."
  type        = string
  default     = null
}

# Shouldn't pass really ever password directly though BIG-IP module but allows testing if BIG-IP is ready.
variable "check_vm_password" {
  description = "WARNING - TESTING ONLY: Pass Password directly so can check if install completed successfully. Should match password in userdata payload"
  type        = string
  default     = null
  sensitive   = true
}

# Shouldn't pass really ever password directly though BIG-IP module but allows testing if BIG-IP is ready.
variable "check_vm_ssh_private_key_file" {
  description = "WARNING - TESTING ONLY: Private Key File to use to check if install is complete"
  type        = string
  default     = null
  sensitive   = true
}
