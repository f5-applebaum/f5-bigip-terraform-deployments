<!-- BEGIN_TF_DOCS -->




# Example Deployment with BIG-IP Standalone(s) and Application(s) (using modules)

This solution deploys N BIG-IPs and N example Application VMs using the modules contained in this project. The BIG-IP module leverages [cloud-init](https://canonical-cloud-init.readthedocs-hosted.com/en/latest/index.html). 

*NOTE:* This solution also uses count at the module level to deploy N number of instances and hence leverages different variables then the modules themselves to facilitate deploying multiple instances (ex. hostname prefixes vs. hostnames, arrays of IPs vs. single IPs, etc).

This solution deploys Day 0 (VM) and Day 1 (virtual service via AS3) in one plan to facilitate testing deploy times and traffic vs. a more realistic pattern of seperating Day 0 and Day 1-N. See the bigip-standalone plan(s) without the example application VMs and virtual service (AS3) deployments for example of strictly Day 0 deployment.

### Features
  * Ability to deploy from a VM Template on Datastore or Content Library
  * Ability to add multiple network cards for the VM
  * Runs external provisioner to confirm successful deployment, onboard and deploy a virtual service

# Requirements

### General

* SSH Public Key (common cloud standard)
* An F5 Networks BYOL (Bring Your Own License) registration key available.
* [mkisofs](https://linux.die.net/man/8/mkisofs) - or similar util to make a cloud-init iso for BIG-IP. 
  * See [BIG-IP Cloud-init Support](https://clouddocs.f5.com/cloud/public/v1/shared/cloudinit.html#deploy-with-cloud-init) for more information.

### VMware Env:

* 3 Networks ( Port Groups )
    * 1st Network = BIG-IP's Management
       * Access to the Internet
       * DHCP enabled 
    * Uses Static IPs on External and Internal Networks.
    * The example onboarding payload in this plan has 2 dataplane networks hardcoded. If changing the # of networks, you must customize /template/do-w-3-nics.json.
* VM Templates in vSphere (hosted on a Datastore or VMware Content Library).
  * **BIG-IP**: BIGIP-16.1.3-0.0.12.ALL-vmware
  * **Application**: kinetic-server-cloudimg-amd64
* Datastore to host cloud-init ISO

## Usage:
1. Make Cloud Init ISO ([OpenStack Config Drive v2](https://canonical-cloud-init.readthedocs-hosted.com/en/latest/reference/datasources/configdrive.html#version-2) format) from files in **/iso** directory.

   Customize the initial admin username and password in the user_data file as desired. 

   ex. snippet
   ```
      - name: ADMIN_USER
        type: static
        value: admin
      - name: ADMIN_PASS
        type: static
        value: iNitialSTROnGPaZZwrD <- Customize!!!
   ```

   IMPORTANT: You will need to use the same initial credentials for the terraform variables if running the check_bigip external provisioner or subsequent config management tasks (which should include resetting the password)

   
   Create the cloud-init ISO using tool like [mkisofs](https://linux.die.net/man/8/mkisofs):
   ```
   mkisofs -R -V config-2 -o bigip-cloud-init.iso iso
   ```

    NOTE: the meta_data.json file must not be empty. For functional testing, you can use the UUID in the example as is if desired. 


    Finally, upload the cloud-init iso to the Datastore you're deploying the BIG-IP VM on. 
    
    You will provide the path to BIG-IP cloud-init iso on the Datastore to the **bigip_cloud_init_iso** parameter. 
    
    ex. if placed in a folder:

    ```
    /CLOUD-INIT-ISOs/bigip-cloud-init.iso
    ```
2. Create a VM Template
  * Download BIG-IP OVA from [my.f5.com portal](https://my.f5.com/manage/s/downloads). 
  * Create a VM from the OVA (do not boot). See VMware docs on [Deploying OVF Template](https://docs.vmware.com/en/VMware-vSphere/7.0/com.vmware.vsphere.vm_admin.doc/GUID-17BEDA21-43F6-41F4-8FB2-E01D275FE9B4.html) for more details. Optionally edit properties to remove the extra NICs so only leaving the 1st NIC. 
  * [Clone the VM to a VM Template](https://docs.vmware.com/en/VMware-vSphere/7.0/com.vmware.vsphere.vm_admin.doc/GUID-5B3737CC-28DB-4334-BD18-6E12011CDC9F.html) on Datastore or Content Library. 

3. Create/Update terraform.tfvars file. See terraform.tfvars.*.example for example terraform.tfvars files.

4. Deploy
  - terraform init
  - terraform plan
  - terraform apply

## Providers

| Name | Version |
|------|---------|
| <a name="provider_local"></a> [local](#provider\_local) | 2.3.0 |
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
| <a name="input_bigip_cloud_init_iso"></a> [bigip\_cloud\_init\_iso](#input\_bigip\_cloud\_init\_iso) | Path on datastore to bigip cloud init iso. ex. /CLOUD-INIT-ISOs/bigip-cloud-init.iso | `string` | `"bigip-cloud-init.iso"` | no |
| <a name="input_bigip_username"></a> [bigip\_username](#input\_bigip\_username) | BIG-IP username. NOTE: Must match what was configured in initial user-data iso. Default is admin | `string` | `"admin"` | no |
| <a name="input_bigip_password"></a> [bigip\_password](#input\_bigip\_password) | BIG-IP password. NOTE: Must match what was configured in initial user-data iso. | `string` | `null` | no |
| <a name="input_bigip_ipv4_network_addresses"></a> [bigip\_ipv4\_network\_addresses](#input\_bigip\_ipv4\_network\_addresses) | This determines number of VMs to deploy. Use null for DHCP. ex. use [null] for 1 instance, [null,null] for 2 instances. DISCLAIMER: Static IPs not currently supported. To implement static IPs, you will need to customize the cloud-init user-data iso. | `list(string)` | <pre>[<br>  null<br>]</pre> | no |
| <a name="input_bigip_self_ips_external"></a> [bigip\_self\_ips\_external](#input\_bigip\_self\_ips\_external) | List of BIG-IP External Self-Ips in A.B.C.D/XX format. One per instance. | `list(string)` | <pre>[<br>  "192.168.1.51/24"<br>]</pre> | no |
| <a name="input_bigip_self_ips_internal"></a> [bigip\_self\_ips\_internal](#input\_bigip\_self\_ips\_internal) | List of BIG-IP Internal Self-Ips in A.B.C.D/XX format. One per instance. | `list(string)` | <pre>[<br>  "192.168.2.51/24"<br>]</pre> | no |
| <a name="input_bigip_default_gateway"></a> [bigip\_default\_gateway](#input\_bigip\_default\_gateway) | BIG-IP Default Gateway | `string` | `"192.168.1.1"` | no |
| <a name="input_bigip_license_keys"></a> [bigip\_license\_keys](#input\_bigip\_license\_keys) | REQUIRED: BIG-IP license registration keys. One per instance. | `list(string)` | n/a | yes |
| <a name="input_check_bigip_ready"></a> [check\_bigip\_ready](#input\_check\_bigip\_ready) | Run Check Onboard Complete Script and external Onboarding provisioners. BIG-IP addresses must be reachable from terraform client. | `bool` | `true` | no |
| <a name="input_check_bigip_login_delay"></a> [check\_bigip\_login\_delay](#input\_check\_bigip\_login\_delay) | The number of seconds/minutes of delay to login. | `string` | `"540s"` | no |
| <a name="input_check_bigip_timeout"></a> [check\_bigip\_timeout](#input\_check\_bigip\_timeout) | The number of seconds/minutes to wait to confirm onboarding was successful. | `string` | `"900s"` | no |
| <a name="input_check_bigip_ssh_private_key_file"></a> [check\_bigip\_ssh\_private\_key\_file](#input\_check\_bigip\_ssh\_private\_key\_file) | Pass local file location of Private Key. ex. /Users/you/.ssh/private-key.pem | `string` | `null` | no |
| <a name="input_check_bigip_hosts"></a> [check\_bigip\_hosts](#input\_check\_bigip\_hosts) | List of specific BIG-IP Host Addresses to use. Null will default to 1st NIC IP.  IMPORTANT: If using check\_bigip\_ready, this list entry count must match the BIG-IP count determined by bigip\_ipv4\_network\_addresses parameter.  Ex. use [null,null] for 2 instances, [null,null,null] for 3 instances, etc. | `list(string)` | <pre>[<br>  null<br>]</pre> | no |
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
| <a name="output_application_default_ip_address"></a> [application\_default\_ip\_address](#output\_application\_default\_ip\_address) | The ipv4 address of the App Virtual Machine(s) |
| <a name="output_application_guest_ip_addresses"></a> [application\_guest\_ip\_addresses](#output\_application\_guest\_ip\_addresses) | The guest addresses output of the App Virtual Machine(s) |

## Resources

| Name | Type |
|------|------|
| [local_file.as3](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.onboard](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [null_resource.declare_as3](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.declare_onboard](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_utils"></a> [utils](#module\_utils) | ../../modules/utils | n/a |
| <a name="module_application"></a> [application](#module\_application) | ../../modules/application | n/a |
| <a name="module_bigip"></a> [bigip](#module\_bigip) | ../../modules/bigip-standalone | n/a |


<!-- END_TF_DOCS -->