<!-- BEGIN_TF_DOCS -->



# Example BIG-IP Standalone Deployment using BIG-IP Terraform module.

Deploys VMWare virtual machine(s) from a BIG-IP VM Template using the BIG-IP module contained in this project. The BIG-IP module uses [OVF Properties](https://clouddocs.f5.com/cloud/public/v1/vmware/vmware_setup.html#set-the-big-ip-ve-management-ip-address-and-passwords).

NOTE: this solution uses count at the module level to deploy N number of instances and hence leverages different variables then the modules themselves to facilitate deploying multiple instances (ex. hostname prefixes vs. hostnames, arrays of IPs vs. single IPs, etc).

### Features
  * Ability to deploy Template from a Datastore or VMware Content Library.
  * Ability to add multiple network cards for the VM.
  * Accepts a Static IPv4 and/or IPv6 address for the 1st NIC (Management).
  * Runs external provisioner to confirm successful deployment, onboard and deploy a virtual service.

# Requirements

### General

* SSH Public Key (common cloud standard)
* An F5 Networks BYOL (Bring Your Own License) registration key available.
* CLI/Tools:
  * [Common OVF Tool (COT)](https://cot.readthedocs.io/en/latest/usage_edit_properties.html)
    * *OR* 
  * tar 
  * shasum

### VMware Env:

* 3 Networks ( Port Groups )
    * 1st Network = BIG-IP's Management
       * Access to the Internet
       * DHCP enabled *(optional)* 
    * Uses Static IPs on External and Internal Networks.
    * The example onboarding payload in this plan has 2 dataplane networks hardcoded. If changing the # of networks, you must customize /template/do-w-3-nics.json.
* VM Templates in vSphere (hosted on a Datastore or VMware Content Library).
  * **BIG-IP**: BIGIP-16.1.3-0.0.12.ALL-vmware
  * **Application**: kinetic-server-cloudimg-amd64

## Usage:

1.  **Customize the OVA**
    * Download BIG-IP OVA from [my.f5.com portal](https://my.f5.com/manage/s/downloads). 
    * Add the F5 supported additional OVF properties according to:
      * [Customizing BIG-IP OVF](https://clouddocs.f5.com/cloud/public/v1/vmware/vmware_setup.html#set-the-big-ip-ve-management-ip-address-and-passwords)

      For example, customize BIGIP-16.1.3-0.0.12.ALL-vmware.ova from [my.f5.com portal](https://my.f5.com/manage/s/downloads):


      * *Using COT*: 

        ```
        cot edit-properties BIGIP-16.1.3-0.0.12.ALL-vmware.ova -p net.mgmt.addr=""+string -l "mgmt-addr" -d "F5 BIG-IP VE's management address in the format of IP/prefix"  -p net.mgmt.addr6=""+string -l "mgmt-addr6" -d "F5 BIG-IP VE's management address in the format of IPv6" -p net.mgmt.gw=""+string -l "mgmt-gw" -d "F5 BIG-IP VE's management default gateway" -p net.mgmt.gw6=""+string -l "mgmt-gw6" -d "F5 BIG-IP VE's management default IPv6 gateway" -p user.root.pwd=""+string -l "root-pwd" -d "F5 BIG-IP VE's SHA-512 shadow or plain-text password for root user" -p user.admin.pwd=""+string -l "admin-pwd" -d "F5 BIG-IP VE's SHA-512 shadow or plain-text password for admin user" -u -o BIGIP-16.1.3-0.0.12.ALL-vmware-custom.ova
        ```

        ***OR***

      * *Manually Editing the OVF file*:

        * untar the OVA:
          ```
          tar xf BIGIP-16.1.3-0.0.12.ALL-vmware.ova
          ```

          manually edit the OVF file (ex. BIGIP-16.1.3-0.0.12-vmware.ovf) with text editor of choice.

          * re-calculate the SHA-1 hash the new customized OVF file:
            ```
            shasum BIGIP-16.1.3-0.0.12-vmware.ovf
            ```

          * Update the .mf file (ex. BIGIP-16.1.3-0.0.12-vmware.mf) with the new shasum value:

        * retar the files to create a new custom OVA:

          ```
          COPYFILE_DISABLE=1 tar -cf BIGIP-16.1.3-0.0.12.ALL-vmware-custom.ova BIGIP-16.1.3-0.0.12-vmware.ovf BIGIP-16.1.3-0.0.12-vmware.mf BIGIP-16.1.3-0.0.12-disk1.vmdk
          ```

          *NOTE:*
          * The OVF descriptor file (.ovf) has to be the first file in the OVA package so the OVF file should be the first in list of files provided to tar command.
          * `COPYFILE_DISABLE=1` include on mac os to disable including hidden mac files w/ mac's tar utility.

          *ex.*
          ```
          $ tar tf BIGIP-16.1.3-0.0.12.ALL-vmware-customized-ovf.ova 
          BIGIP-16.1.3-0.0.12-vmware.ovf <- Confirm it's the 1st file
          BIGIP-16.1.3-0.0.12-vmware.mf
          BIGIP-16.1.3-0.0.12-disk1.vmdk
          ```

2. Create a VM Template
    * Create a VM from the **new** customized OVA *(do not boot)*. See VMware docs on [Deploying OVF Template](https://docs.vmware.com/en/VMware-vSphere/7.0/com.vmware.vsphere.vm_admin.doc/GUID-17BEDA21-43F6-41F4-8FB2-E01D275FE9B4.html) for more details.
    * [Clone the VM to a VM Template](https://docs.vmware.com/en/VMware-vSphere/7.0/com.vmware.vsphere.vm_admin.doc/GUID-5B3737CC-28DB-4334-BD18-6E12011CDC9F.html) on Datastore or Content Library. 

3. Create terraform variables file (terraform.tfvars). 

4. Deploy
  - terraform init
  - terraform plan
  - terraform apply

## Providers

| Name | Version |
|------|---------|
| <a name="provider_local"></a> [local](#provider\_local) | 2.4.0 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.1 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_vsphere_user"></a> [vsphere\_user](#input\_vsphere\_user) | vSphere User | `string` | n/a | yes |
| <a name="input_vsphere_password"></a> [vsphere\_password](#input\_vsphere\_password) | vSphere Password | `string` | n/a | yes |
| <a name="input_vsphere_server"></a> [vsphere\_server](#input\_vsphere\_server) | vSphere Server | `string` | n/a | yes |
| <a name="input_allow_unverified_ssl"></a> [allow\_unverified\_ssl](#input\_allow\_unverified\_ssl) | Allow Unverified SSL Cert on vSphere Server | `bool` | `true` | no |
| <a name="input_vsphere_datacenter"></a> [vsphere\_datacenter](#input\_vsphere\_datacenter) | vSphere Datacenter | `string` | n/a | yes |
| <a name="input_vsphere_host"></a> [vsphere\_host](#input\_vsphere\_host) | vSphere Host | `string` | n/a | yes |
| <a name="input_vsphere_resource_pool"></a> [vsphere\_resource\_pool](#input\_vsphere\_resource\_pool) | vSphere Resource Pool. If you don't have any resource pools, put 'Resources' after cluster name. ex. vSAN Cluster/Resources | `string` | n/a | yes |
| <a name="input_vsphere_datastore"></a> [vsphere\_datastore](#input\_vsphere\_datastore) | vSphere Datastore hosting VM template and cloud-init iso | `string` | n/a | yes |
| <a name="input_ssh_public_key"></a> [ssh\_public\_key](#input\_ssh\_public\_key) | SSH public key | `string` | n/a | yes |
| <a name="input_domain"></a> [domain](#input\_domain) | Virtual Machine hostname domain. | `string` | `"example.com"` | no |
| <a name="input_vsphere_content_library"></a> [vsphere\_content\_library](#input\_vsphere\_content\_library) | Name of Content Library. Provide vsphere\_virtual\_machine parameter as well. | `string` | `null` | no |
| <a name="input_vsphere_virtual_machine"></a> [vsphere\_virtual\_machine](#input\_vsphere\_virtual\_machine) | Template Name | `string` | `"BIGIP-16.1.3-0.0.12.ALL-vmware-Template"` | no |
| <a name="input_bigip_vm_name_prefix"></a> [bigip\_vm\_name\_prefix](#input\_bigip\_vm\_name\_prefix) | Virtual Machine Name Prefix. Will add instance count as suffix. | `string` | `"bigip"` | no |
| <a name="input_bigip_networks"></a> [bigip\_networks](#input\_bigip\_networks) | List of Networks (Port groups) to add | `list(string)` | <pre>[<br>  "VM Network"<br>]</pre> | no |
| <a name="input_bigip_networks_ovf_map"></a> [bigip\_networks\_ovf\_map](#input\_bigip\_networks\_ovf\_map) | BUG: List of OVF mappings if deploying from Content Library. Must match count of vSphere networks provided above. | `list(string)` | <pre>[<br>  "eth0"<br>]</pre> | no |
| <a name="input_bigip_admin_username"></a> [bigip\_admin\_username](#input\_bigip\_admin\_username) | BIG-IP admin username. Default is admin | `string` | `"admin"` | no |
| <a name="input_bigip_admin_password"></a> [bigip\_admin\_password](#input\_bigip\_admin\_password) | BIG-IP admin initial password. WARNING: Visible in VMWare console so need to change immediately. | `string` | `null` | no |
| <a name="input_bigip_root_password"></a> [bigip\_root\_password](#input\_bigip\_root\_password) | BIG-IP root initial password. WARNING: Visible in VMWare console so need to change immediately. | `string` | `null` | no |
| <a name="input_bigip_ipv4_network_addresses"></a> [bigip\_ipv4\_network\_addresses](#input\_bigip\_ipv4\_network\_addresses) | List of Management IP addresses in X.X.X.X/X format. One per instance. This determines number of VMs to deploy. ex. use ["10.1.1.11/24"] for 1 instance, ["10.1.1.11/24","10.1.1.12/24"] for 2 instances. Use null for DHCP. ex. or [null] for 1 instance, [null,null] for 2 instances. | `list(string)` | <pre>[<br>  null<br>]</pre> | no |
| <a name="input_bigip_ipv4_gateway"></a> [bigip\_ipv4\_gateway](#input\_bigip\_ipv4\_gateway) | The default IPv4 gateway (Management). | `string` | `null` | no |
| <a name="input_bigip_self_ips_external"></a> [bigip\_self\_ips\_external](#input\_bigip\_self\_ips\_external) | List of BIG-IP External Self-Ips in A.B.C.D/XX format. One per instance. | `list(string)` | <pre>[<br>  "192.168.1.51/24"<br>]</pre> | no |
| <a name="input_bigip_self_ips_internal"></a> [bigip\_self\_ips\_internal](#input\_bigip\_self\_ips\_internal) | List of BIG-IP Internal Self-Ips in A.B.C.D/XX format. One per instance. | `list(string)` | <pre>[<br>  "192.168.2.51/24"<br>]</pre> | no |
| <a name="input_bigip_default_gateway"></a> [bigip\_default\_gateway](#input\_bigip\_default\_gateway) | BIG-IP Default Gateway | `string` | `"192.168.1.1"` | no |
| <a name="input_bigip_license_keys"></a> [bigip\_license\_keys](#input\_bigip\_license\_keys) | REQUIRED: BIG-IP license registration keys. One per instance. | `list(string)` | n/a | yes |
| <a name="input_check_bigip_ready"></a> [check\_bigip\_ready](#input\_check\_bigip\_ready) | Run Check Onboard Complete Script and external Onboarding provisioners. Only enable if BIG-IP addresses are reachable from terraform client. | `bool` | `true` | no |
| <a name="input_check_bigip_login_delay"></a> [check\_bigip\_login\_delay](#input\_check\_bigip\_login\_delay) | The number of seconds/minutes of delay to login. | `string` | `"540s"` | no |
| <a name="input_check_bigip_timeout"></a> [check\_bigip\_timeout](#input\_check\_bigip\_timeout) | The number of seconds/minutes to wait to confirm onboarding was successful. | `string` | `"900s"` | no |
| <a name="input_check_bigip_username"></a> [check\_bigip\_username](#input\_check\_bigip\_username) | BIG-IP username to use to validate initial ssh login and confirm onboarding completed successfully. | `string` | `"root"` | no |
| <a name="input_check_bigip_password"></a> [check\_bigip\_password](#input\_check\_bigip\_password) | BIG-IP password to use to validate initial ssh login. NOTE: Must be in clear text and match decrypted password from bigip\_password param. | `string` | `"default"` | no |
| <a name="input_check_bigip_ssh_private_key_file"></a> [check\_bigip\_ssh\_private\_key\_file](#input\_check\_bigip\_ssh\_private\_key\_file) | RECOMMENDED: Pass local file location of Private Key. ex. /Users/you/.ssh/private-key.pem | `string` | `null` | no |
| <a name="input_check_bigip_hosts"></a> [check\_bigip\_hosts](#input\_check\_bigip\_hosts) | List of specific BIG-IP Host IP Addresses to use to check that is reachable from terraform client. IMPORTANT: If using check\_bigip\_ready, this list entry count must also match the count determined by bigip\_ipv4\_network\_addresses parameter.  Unless there's a NAT, this list should match the list provided in the bigip\_ipv4\_network\_addresses parameter without the prefix  ex. ["192.168.1.11"] for 1 instance with static IP, ["192.168.1.11","192.168.1.12"] for 2 instances, etc.  Null is used for the 1st NIC IP provided by DHCP. Ex. use [null,null] for 2 instances, [null,null,null] for 3 instances, etc. | `list(string)` | <pre>[<br>  null<br>]</pre> | no |
| <a name="input_virtual_server_addresses"></a> [virtual\_server\_addresses](#input\_virtual\_server\_addresses) | List of BIG-IP Virtual Server IPs in A.B.C.D format. One per instance. | `list(string)` | <pre>[<br>  "192.168.1.100"<br>]</pre> | no |
| <a name="input_pool_member_addresses"></a> [pool\_member\_addresses](#input\_pool\_member\_addresses) | List of Pool Member Addresses in A.B.C.D format. One per instance. | `list(string)` | <pre>[<br>  null<br>]</pre> | no |
| <a name="input_vsphere_app_virtual_machine"></a> [vsphere\_app\_virtual\_machine](#input\_vsphere\_app\_virtual\_machine) | VM Template on Datastore or Content Library or OVA/OVF on Content Library. Requires providing datastore OR vsphere\_content\_library as well. NOTE: Do not use with ovf\_remote\_url or local\_ovf\_path. | `string` | `null` | no |
| <a name="input_app_ovf_remote_url"></a> [app\_ovf\_remote\_url](#input\_app\_ovf\_remote\_url) | Remote URL to App OVA file. Set to latest to pull latest release. One of ovf\_remote\_url, local\_ovf\_path or content\_library must be provided. | `string` | `null` | no |
| <a name="input_app_local_ovf_path"></a> [app\_local\_ovf\_path](#input\_app\_local\_ovf\_path) | Local path to App OVA file. One of ovf\_remote\_url, local\_ovf\_path or content\_library must be provided. | `string` | `null` | no |
| <a name="input_app_vm_name_prefix"></a> [app\_vm\_name\_prefix](#input\_app\_vm\_name\_prefix) | App Virtual Machine Name Prefix. Will add instance count as suffix. | `string` | `"app"` | no |
| <a name="input_app_username"></a> [app\_username](#input\_app\_username) | The username to configure via cloud-init for ssh access to the VM. | `string` | `"ubuntu"` | no |
| <a name="input_app_password"></a> [app\_password](#input\_app\_password) | The password to configure via cloud-init for ssh access to the VM. | `string` | n/a | yes |
| <a name="input_app_networks"></a> [app\_networks](#input\_app\_networks) | List of Networks (Port groups) to add | `list(string)` | <pre>[<br>  "VM Network"<br>]</pre> | no |
| <a name="input_app_networks_ovf_map"></a> [app\_networks\_ovf\_map](#input\_app\_networks\_ovf\_map) | BUG: List of OVF mappings if deploying from Content Library. Must match count of vSphere networks provided above. | `list(string)` | <pre>[<br>  "eth0"<br>]</pre> | no |
| <a name="input_app_ipv4_network_addresses"></a> [app\_ipv4\_network\_addresses](#input\_app\_ipv4\_network\_addresses) | List of etwork address to assign during customization of cloned virtual machines, in A.B.C.D/XX format. This determines number of VMs to deploy.  Use one per instance. | `list(string)` | <pre>[<br>  "192.168.1.105/24"<br>]</pre> | no |
| <a name="input_app_ipv4_gateway"></a> [app\_ipv4\_gateway](#input\_app\_ipv4\_gateway) | The default IPv4 gateway | `string` | `"192.168.1.1"` | no |
| <a name="input_app_dns_server"></a> [app\_dns\_server](#input\_app\_dns\_server) | The DNS server to assign to each virtual machine. | `string` | `"8.8.8.8"` | no |
| <a name="input_check_app_ready"></a> [check\_app\_ready](#input\_check\_app\_ready) | Run Check Install Complete Script | `bool` | `false` | no |
| <a name="input_check_app_timeout"></a> [check\_app\_timeout](#input\_check\_app\_timeout) | The number of seconds/minutes of wait to confirm install complate. | `string` | `"180s"` | no |
| <a name="input_check_app_ssh_private_key_file"></a> [check\_app\_ssh\_private\_key\_file](#input\_check\_app\_ssh\_private\_key\_file) | WARNING - TESTING ONLY: Private Key File to use to check if install is complete | `string` | `null` | no |
| <a name="input_check_app_hosts"></a> [check\_app\_hosts](#input\_check\_app\_hosts) | List of specific App Host Addresses to use to check. IMPORTANT: If using check\_app\_ready, this list must match the App instance count determined by app\_ipv4\_network\_address parameter. Null will default to 1st NIC IP. Ex. use [null,null] for 2 instances, [null,null,null] for 3 instances, etc. | `list(string)` | <pre>[<br>  null<br>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bigip_default_ip_addresses"></a> [bigip\_default\_ip\_addresses](#output\_bigip\_default\_ip\_addresses) | The ipv4 address of the BIG-IP Virtual Machine(s) |
| <a name="output_bigip_guest_ip_addresses"></a> [bigip\_guest\_ip\_addresses](#output\_bigip\_guest\_ip\_addresses) | The guest addresses output of the BIG-IP Virtual Machine(s) |
| <a name="output_bigip_vm_ids"></a> [bigip\_vm\_ids](#output\_bigip\_vm\_ids) | The VM IDs of the BIG-IP Virtual Machine(s) |
| <a name="output_bigip_vm_moids"></a> [bigip\_vm\_moids](#output\_bigip\_vm\_moids) | The VM Managed Object IDs of the BIG-IP Virtual Machine(s) |
| <a name="output_bigip_vmx_paths"></a> [bigip\_vmx\_paths](#output\_bigip\_vmx\_paths) | The vmx\_path of the BIG-IP Virtual Machine(s) |

## Resources

| Name | Type |
|------|------|
| [local_file.as3](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.onboard](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [null_resource.declare_as3](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.declare_onboard](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.install_packages](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_utils"></a> [utils](#module\_utils) | ../../modules/utils | n/a |
| <a name="module_application"></a> [application](#module\_application) | ../../modules/application | n/a |
| <a name="module_bigip"></a> [bigip](#module\_bigip) | ../../modules/bigip-standalone-ovf-props-from-vmware | n/a |


<!-- END_TF_DOCS -->