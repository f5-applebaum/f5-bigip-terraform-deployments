<!-- BEGIN_TF_DOCS -->



# Terraform vSphere Virtual Machine Module (BIG-IP)

Deploys a BIG-IP virtual machine from a VMware Template from a Datastore or Content Library using [OVF Properties](https://clouddocs.f5.com/cloud/public/v1/vmware/vmware_setup.html#set-the-big-ip-ve-management-ip-address-and-passwords).

### Features
  * Ability to deploy Template from a Datastore or VMware Content Library.
  * Ability to add multiple network cards for the VM.
  * Accepts a Static IPv4 and/or IPv6 address for the 1st NIC (Management).
  * Can optionally run an external provisioner to confirm successful deployment and assist with measuring deployment times.

# Requirements

### General

* SSH Public Key (common cloud standard)
* CLI/Tools:
  * [Common OVF Tool (COT)](https://cot.readthedocs.io/en/latest/usage_edit_properties.html)
    * *OR* 
  * tar 
  * shasum

### VMware Env:

* 1 VMware Network ( Port Groups ).
* VM Template in vSphere (hosted on a Datastore or VMware Content Library). 
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
| <a name="provider_vsphere"></a> [vsphere](#provider\_vsphere) | n/a |
| <a name="provider_time"></a> [time](#provider\_time) | n/a |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_vsphere_datacenter"></a> [vsphere\_datacenter](#input\_vsphere\_datacenter) | vSphere Datacenter | `string` | n/a | yes |
| <a name="input_vsphere_host"></a> [vsphere\_host](#input\_vsphere\_host) | vSphere Host | `string` | n/a | yes |
| <a name="input_vsphere_resource_pool"></a> [vsphere\_resource\_pool](#input\_vsphere\_resource\_pool) | vSphere Resource Pool. If you don't have any resource pools, put 'Resources' after cluster name. ex. vSAN Cluster/Resources | `string` | n/a | yes |
| <a name="input_vsphere_datastore"></a> [vsphere\_datastore](#input\_vsphere\_datastore) | vSphere Datastore | `string` | n/a | yes |
| <a name="input_vsphere_content_library"></a> [vsphere\_content\_library](#input\_vsphere\_content\_library) | Name of Content Library. Provide vsphere\_virtual\_machine as well. | `string` | `null` | no |
| <a name="input_vsphere_networks"></a> [vsphere\_networks](#input\_vsphere\_networks) | List of Networks (Port groups) to add | `list(string)` | <pre>[<br>  "VM Network"<br>]</pre> | no |
| <a name="input_vsphere_networks_ovf_map"></a> [vsphere\_networks\_ovf\_map](#input\_vsphere\_networks\_ovf\_map) | BUG: List of OVF mappings if deploying from Content Library. Must match count of vSphere networks provided above. | `list(string)` | <pre>[<br>  "eth0"<br>]</pre> | no |
| <a name="input_vsphere_virtual_machine"></a> [vsphere\_virtual\_machine](#input\_vsphere\_virtual\_machine) | Retrieve template information on vsphere | `string` | `"BIGIP-16.1.3-0.0.12.ALL-vmware"` | no |
| <a name="input_vm_name"></a> [vm\_name](#input\_vm\_name) | Virtual Machine Name | `string` | `"bigip"` | no |
| <a name="input_num_cpus"></a> [num\_cpus](#input\_num\_cpus) | Number of CPUs | `number` | `8` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | Memory in MBs | `number` | `16384` | no |
| <a name="input_thin_provisioned"></a> [thin\_provisioned](#input\_thin\_provisioned) | Thin Provisioned | `bool` | `false` | no |
| <a name="input_disk_size"></a> [disk\_size](#input\_disk\_size) | Disk Size in GBs | `number` | `120` | no |
| <a name="input_cdrom_enabled"></a> [cdrom\_enabled](#input\_cdrom\_enabled) | Attach cd-rom. Should be true if sending vApp properties. | `bool` | `true` | no |
| <a name="input_admin_password"></a> [admin\_password](#input\_admin\_password) | BIG-IP Admin Password in plain-text or SHA-512 shadow format. | `string` | `"admin"` | no |
| <a name="input_root_password"></a> [root\_password](#input\_root\_password) | BIG-IP Admin Password in plain-text or SHA-512 shadow format. | `string` | `"default"` | no |
| <a name="input_ipv4_network_address"></a> [ipv4\_network\_address](#input\_ipv4\_network\_address) | The IPv4 network address to assign during customization of cloned virtual machines, in A.B.C.D/XX format. | `string` | `null` | no |
| <a name="input_ipv4_gateway"></a> [ipv4\_gateway](#input\_ipv4\_gateway) | The default IPv4 gateway. | `string` | `null` | no |
| <a name="input_ipv6_network_address"></a> [ipv6\_network\_address](#input\_ipv6\_network\_address) | The IPv6 network address to assign during customization of cloned virtual machines, in :: format. | `string` | `null` | no |
| <a name="input_ipv6_gateway"></a> [ipv6\_gateway](#input\_ipv6\_gateway) | The default IPv6 gateway. | `string` | `null` | no |
| <a name="input_check_bigip_ready"></a> [check\_bigip\_ready](#input\_check\_bigip\_ready) | Run Check Onboard Complete Script. | `bool` | `false` | no |
| <a name="input_check_bigip_login_delay"></a> [check\_bigip\_login\_delay](#input\_check\_bigip\_login\_delay) | The number of seconds/minutes of delay to login. | `string` | `"180s"` | no |
| <a name="input_check_bigip_timeout"></a> [check\_bigip\_timeout](#input\_check\_bigip\_timeout) | The number of seconds/minutes to wait to confirm onboarding was successful. | `string` | `"900s"` | no |
| <a name="input_check_bigip_ssh_private_key_file"></a> [check\_bigip\_ssh\_private\_key\_file](#input\_check\_bigip\_ssh\_private\_key\_file) | Pass local file location of Private Key. ex. /Users/you/.ssh/private-key.pem | `string` | `null` | no |
| <a name="input_check_bigip_username"></a> [check\_bigip\_username](#input\_check\_bigip\_username) | BIG-IP username to use to validate initial ssh login and confirm onboarding completed successfully. NOTE: Defaults to root as the only user that has console access initially. | `string` | `"root"` | no |
| <a name="input_check_bigip_password"></a> [check\_bigip\_password](#input\_check\_bigip\_password) | BIG-IP password to use to validate initial ssh login and confirm onboarding completed successfully. NOTE: Must be in clear text and match decrypted password from root password param. | `string` | `"default"` | no |
| <a name="input_check_bigip_host"></a> [check\_bigip\_host](#input\_check\_bigip\_host) | Address to use to check. Otherwise, will default to 1st NIC IP. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_default_ip_address"></a> [default\_ip\_address](#output\_default\_ip\_address) | The ipv4 address of the Virtual Machine |
| <a name="output_guest_ip_addresses"></a> [guest\_ip\_addresses](#output\_guest\_ip\_addresses) | The guest addresses output of the Virtual Machine |
| <a name="output_id"></a> [id](#output\_id) | The ID of the Virtual Machine |
| <a name="output_moid"></a> [moid](#output\_moid) | The Managed Object ID of the Virtual Machine |
| <a name="output_vmx_path"></a> [vmx\_path](#output\_vmx\_path) | The vmx\_path of the Virtual Machine |

## Resources

| Name | Type |
|------|------|
| [null_resource.check_onboard_complete](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [time_sleep.check_bigip_login_delay](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [vsphere_virtual_machine.this](https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs/resources/virtual_machine) | resource |
| [vsphere_content_library.content_library](https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs/data-sources/content_library) | data source |
| [vsphere_content_library_item.item](https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs/data-sources/content_library_item) | data source |
| [vsphere_datacenter.dc](https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs/data-sources/datacenter) | data source |
| [vsphere_datastore.datastore](https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs/data-sources/datastore) | data source |
| [vsphere_network.network](https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs/data-sources/network) | data source |
| [vsphere_resource_pool.pool](https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs/data-sources/resource_pool) | data source |
| [vsphere_virtual_machine.template](https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs/data-sources/virtual_machine) | data source |

## Modules

No modules.


<!-- END_TF_DOCS -->