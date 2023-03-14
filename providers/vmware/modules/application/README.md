<!-- BEGIN_TF_DOCS -->



# Terraform vSphere Virtual Machine Module (Example Application)

Deploys a VMWare virtual machine from a Ubuntu Server (kinetic-server-cloudimg-amd64). The virtual machine has docker installed and an example application for testing traffic. 

### Features
  * Ability to deploy from an OVA or VM Template from a VMWare Content Library
  * Ability to deploy from an OVA from a local file or remote URL
  * Ability to add multiple network cards for the VM
  * Accepts a Static IP for 1st NIC
  * Can provide a custom docker container name to run as the example application
  * Can optionally run an external provisioner to confirm successful deployment and assist with measuring deployment times.

# Requirements

### General
* SSH Public Key (common cloud standard)
### VMWare Env:
* 1 VMWare Network ( Port Groups )
* Ubuntu Server (kinetic-server-cloudimg-amd64) OVA hosted on a local file, remote URL or VMware Content Library
  * ***NOTE***:
    * If deploying with ovf_deploy, you must provide either the remote url (**ovf_remote_url** parameter) OR a local file path (**local_ovf_path** parameter).
    * If deploying an OVA or VM Template from a VMWare Content library, you must provide both the Content Library (**vsphere_content_library** parameter) AND the OVA/VM Template name (**vsphere_virtual_machine** parameter).

## Providers

| Name | Version |
|------|---------|
| <a name="provider_vsphere"></a> [vsphere](#provider\_vsphere) | 2.2.0 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.1 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_vsphere_datacenter"></a> [vsphere\_datacenter](#input\_vsphere\_datacenter) | vSphere Datacenter | `string` | n/a | yes |
| <a name="input_vsphere_host"></a> [vsphere\_host](#input\_vsphere\_host) | vSphere Host | `string` | n/a | yes |
| <a name="input_vsphere_resource_pool"></a> [vsphere\_resource\_pool](#input\_vsphere\_resource\_pool) | vSphere Resource Pool. If you don't have any resource pools, put 'Resources' after cluster name. ex. vSAN Cluster/Resources | `string` | n/a | yes |
| <a name="input_vsphere_datastore"></a> [vsphere\_datastore](#input\_vsphere\_datastore) | vSphere Datastore | `string` | n/a | yes |
| <a name="input_vsphere_networks"></a> [vsphere\_networks](#input\_vsphere\_networks) | List of Networks (Port groups) to add | `list(string)` | <pre>[<br>  "VM Network"<br>]</pre> | no |
| <a name="input_vsphere_networks_ovf_map"></a> [vsphere\_networks\_ovf\_map](#input\_vsphere\_networks\_ovf\_map) | BUG: List of OVF mappings if deploying from Content Library. Must match count of vSphere networks provided above. | `list(string)` | <pre>[<br>  "eth0"<br>]</pre> | no |
| <a name="input_vsphere_content_library"></a> [vsphere\_content\_library](#input\_vsphere\_content\_library) | Name of Content Library. Provide vsphere\_virtual\_machine as well. One of ovf\_remote\_url, local\_ovf\_path or (content\_library and vsphere\_virtual\_machine) must be provided. | `string` | `null` | no |
| <a name="input_vsphere_virtual_machine"></a> [vsphere\_virtual\_machine](#input\_vsphere\_virtual\_machine) | OVA/OVF file on Content Library. Provide vsphere\_content\_library as well. One of ovf\_remote\_url, local\_ovf\_path or (content\_library and vsphere\_virtual\_machine) must be provided. | `string` | `null` | no |
| <a name="input_ovf_remote_url"></a> [ovf\_remote\_url](#input\_ovf\_remote\_url) | Remote URL to fetch OVA. One of ovf\_remote\_url, local\_ovf\_path or (content\_library and vsphere\_virtual\_machine) must be provided. | `string` | `null` | no |
| <a name="input_local_ovf_path"></a> [local\_ovf\_path](#input\_local\_ovf\_path) | Local path to OVA file. One of ovf\_remote\_url, local\_ovf\_path or (content\_library and vsphere\_virtual\_machine) must be provided. | `string` | `null` | no |
| <a name="input_admin_username"></a> [admin\_username](#input\_admin\_username) | The username to configure via cloud-init for ssh access to the VM. | `string` | `"ubuntu"` | no |
| <a name="input_admin_password"></a> [admin\_password](#input\_admin\_password) | The password to configure via cloud-init for ssh access to the VM. | `string` | n/a | yes |
| <a name="input_admin_password_hash"></a> [admin\_password\_hash](#input\_admin\_password\_hash) | The password hash to configure via cloud-init for ssh access to the VM. | `string` | `null` | no |
| <a name="input_ssh_public_key"></a> [ssh\_public\_key](#input\_ssh\_public\_key) | SSH public key | `string` | n/a | yes |
| <a name="input_vm_name"></a> [vm\_name](#input\_vm\_name) | Virtual Machine Name | `string` | `"app-01"` | no |
| <a name="input_vm_hostname"></a> [vm\_hostname](#input\_vm\_hostname) | Virtual Machine Hostname | `string` | `"app-01.example.local"` | no |
| <a name="input_app_container_name"></a> [app\_container\_name](#input\_app\_container\_name) | The app container name to run | `string` | `"f5devcentral/f5-demo-app:latest"` | no |
| <a name="input_num_cpus"></a> [num\_cpus](#input\_num\_cpus) | Number of CPUS | `number` | `2` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | Memory | `number` | `1024` | no |
| <a name="input_thin_provisioned"></a> [thin\_provisioned](#input\_thin\_provisioned) | Thin Provisioned | `bool` | `false` | no |
| <a name="input_disk_size"></a> [disk\_size](#input\_disk\_size) | Disk Size in Gbps | `number` | `20` | no |
| <a name="input_cdrom_enabled"></a> [cdrom\_enabled](#input\_cdrom\_enabled) | Attach cd-rom. Should be true if sending vApp properties and OVF env transport = iso. Set to false if sending extra\_config and OVF transport = VMtools. | `bool` | `true` | no |
| <a name="input_ipv4_network_address"></a> [ipv4\_network\_address](#input\_ipv4\_network\_address) | The network address to assign during customization of cloned virtual machines, in A.B.C.D/XX format. | `string` | `null` | no |
| <a name="input_ipv4_gateway"></a> [ipv4\_gateway](#input\_ipv4\_gateway) | The default IPv4 gateway | `string` | `null` | no |
| <a name="input_dns_server"></a> [dns\_server](#input\_dns\_server) | The DNS server to assign to each virtual machine. | `string` | `null` | no |
| <a name="input_custom_meta_data"></a> [custom\_meta\_data](#input\_custom\_meta\_data) | Provide a custom metadata string | `string` | `null` | no |
| <a name="input_custom_user_data"></a> [custom\_user\_data](#input\_custom\_user\_data) | Provide a custom metadata string | `string` | `null` | no |
| <a name="input_check_vm_ready"></a> [check\_vm\_ready](#input\_check\_vm\_ready) | Run Install Complete Script | `bool` | `false` | no |
| <a name="input_check_vm_timeout"></a> [check\_vm\_timeout](#input\_check\_vm\_timeout) | The number of seconds/minutes of wait to confirm install complate. | `string` | `"180s"` | no |
| <a name="input_check_vm_host"></a> [check\_vm\_host](#input\_check\_vm\_host) | Address to use to check. Otherwise, will default to 1st NIC IP address. | `string` | `null` | no |
| <a name="input_check_vm_password"></a> [check\_vm\_password](#input\_check\_vm\_password) | WARNING - TESTING ONLY: Pass Password directly so can check if install completed successfully. Should match password in userdata payload | `string` | `null` | no |
| <a name="input_check_vm_ssh_private_key_file"></a> [check\_vm\_ssh\_private\_key\_file](#input\_check\_vm\_ssh\_private\_key\_file) | WARNING - TESTING ONLY: Private Key File to use to check if install is complete | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_default_ip_address"></a> [default\_ip\_address](#output\_default\_ip\_address) | The ipv4 address of the Virtual Machine |
| <a name="output_guest_ip_addresses"></a> [guest\_ip\_addresses](#output\_guest\_ip\_addresses) | The guest addresses output of the Virtual Machine |

## Resources

| Name | Type |
|------|------|
| [null_resource.check_install_complete_from_content_lib](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.check_install_complete_from_url](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [vsphere_virtual_machine.vm_from_template](https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs/resources/virtual_machine) | resource |
| [vsphere_virtual_machine.vm_from_url](https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs/resources/virtual_machine) | resource |
| [vsphere_content_library.content_library](https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs/data-sources/content_library) | data source |
| [vsphere_content_library_item.item](https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs/data-sources/content_library_item) | data source |
| [vsphere_datacenter.dc](https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs/data-sources/datacenter) | data source |
| [vsphere_datastore.datastore](https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs/data-sources/datastore) | data source |
| [vsphere_host.host](https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs/data-sources/host) | data source |
| [vsphere_network.network](https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs/data-sources/network) | data source |
| [vsphere_ovf_vm_template.ovfLocal](https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs/data-sources/ovf_vm_template) | data source |
| [vsphere_ovf_vm_template.ovfRemote](https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs/data-sources/ovf_vm_template) | data source |
| [vsphere_resource_pool.pool](https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs/data-sources/resource_pool) | data source |
| [vsphere_virtual_machine.template](https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs/data-sources/virtual_machine) | data source |

## Modules

No modules.


<!-- END_TF_DOCS -->