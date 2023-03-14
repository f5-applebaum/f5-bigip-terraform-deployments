<!-- BEGIN_TF_DOCS -->



# Terraform vSphere Virtual Machine Module (BIG-IP)

Deploys a VMware virtual machine from a VM Template on a Datastore or Content Library using [cloud-init](https://canonical-cloud-init.readthedocs-hosted.com/en/latest/index.html). This example cloud-init iso here performs some minimal Day 0 onboarding, ex. initial credential seeding, packaging, etc.

### Features
  * Ability to deploy from VM template on a Datastore or Content Library.
  * Ability to add multiple network cards.
  * Can optionally run an external ssh provisioner to confirm successful deployment and assist with measuring deployment times.

# Requirements

### General

* SSH Public Key (common cloud standard)
* [mkisofs](https://linux.die.net/man/8/mkisofs) - or similar util to make a cloud-init iso for BIG-IP. 
  * See [BIG-IP Cloud-init Support](https://clouddocs.f5.com/cloud/public/v1/shared/cloudinit.html#deploy-with-cloud-init) for more information.

### VMware Env:

* 1 VMware Network ( Port Groups )
* VM Template in vSphere (hosted on a Datastore or VMware Content Library). 
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
| <a name="input_vsphere_resource_pool"></a> [vsphere\_resource\_pool](#input\_vsphere\_resource\_pool) | vSphere Resource Pool. If you don't have any resource pools, put 'Resources' after cluster name. ex. vSAN Cluster/Resources. | `string` | n/a | yes |
| <a name="input_vsphere_datastore"></a> [vsphere\_datastore](#input\_vsphere\_datastore) | vSphere Datastore | `string` | n/a | yes |
| <a name="input_vsphere_content_library"></a> [vsphere\_content\_library](#input\_vsphere\_content\_library) | Name of Content Library. Provide vsphere\_virtual\_machine as well. | `string` | `null` | no |
| <a name="input_vsphere_networks"></a> [vsphere\_networks](#input\_vsphere\_networks) | List of Networks (Port groups) to add. | `list(string)` | <pre>[<br>  "VM Network"<br>]</pre> | no |
| <a name="input_vsphere_networks_ovf_map"></a> [vsphere\_networks\_ovf\_map](#input\_vsphere\_networks\_ovf\_map) | BUG: List of OVF mappings if deploying from Content Library. Must match count of vSphere networks provided above. | `list(string)` | <pre>[<br>  "eth0"<br>]</pre> | no |
| <a name="input_vsphere_virtual_machine"></a> [vsphere\_virtual\_machine](#input\_vsphere\_virtual\_machine) | Retrieve template information on vsphere | `string` | `"BIGIP-16.1.3-0.0.12.ALL-vmware"` | no |
| <a name="input_vm_name"></a> [vm\_name](#input\_vm\_name) | Virtual Machine Name | `string` | `"bigip"` | no |
| <a name="input_num_cpus"></a> [num\_cpus](#input\_num\_cpus) | Number of CPUs | `number` | `8` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | Memory in MBs | `number` | `16384` | no |
| <a name="input_thin_provisioned"></a> [thin\_provisioned](#input\_thin\_provisioned) | Thin Provisioned | `bool` | `false` | no |
| <a name="input_disk_size"></a> [disk\_size](#input\_disk\_size) | Disk Size in GBs | `number` | `120` | no |
| <a name="input_bigip_cloud_init_iso"></a> [bigip\_cloud\_init\_iso](#input\_bigip\_cloud\_init\_iso) | Path on datastore to BIG-IP cloud-init iso. ex. /CLOUD-INIT-ISOs/bigip-cloud-init.iso. | `string` | `"bigip-cloud-init.iso"` | no |
| <a name="input_check_bigip_ready"></a> [check\_bigip\_ready](#input\_check\_bigip\_ready) | Run Check Onboard Complete Script. | `bool` | `false` | no |
| <a name="input_check_bigip_login_delay"></a> [check\_bigip\_login\_delay](#input\_check\_bigip\_login\_delay) | The number of seconds/minutes of delay to login. | `string` | `"180s"` | no |
| <a name="input_check_bigip_timeout"></a> [check\_bigip\_timeout](#input\_check\_bigip\_timeout) | The number of seconds/minutes to wait to confirm onboarding was successful. | `string` | `"900s"` | no |
| <a name="input_check_bigip_ssh_private_key_file"></a> [check\_bigip\_ssh\_private\_key\_file](#input\_check\_bigip\_ssh\_private\_key\_file) | Pass local file location of Private Key. ex. /Users/you/.ssh/private-key.pem. One of this or check\_bigip\_password parameters must be provided. | `string` | `null` | no |
| <a name="input_check_bigip_username"></a> [check\_bigip\_username](#input\_check\_bigip\_username) | BIG-IP username to use to validate initial ssh login and confirm onboarding completed successfully. Needs to match what was passed in initial user-data iso. | `string` | `"admin"` | no |
| <a name="input_check_bigip_password"></a> [check\_bigip\_password](#input\_check\_bigip\_password) | BIG-IP password to use to validate initial ssh login and confirm onboarding completed successfully. Needs to match what was passed in initial user-data iso. If checking, either this or check\_bigip\_ssh\_private\_key\_file parameters must be provided. | `string` | `null` | no |
| <a name="input_check_bigip_host"></a> [check\_bigip\_host](#input\_check\_bigip\_host) | Host Address to use to check. Otherwise, will default to 1st NIC IP obtained via DHCP. Can be used to override if there's a NAT, FW, etc. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_default_ip_address"></a> [default\_ip\_address](#output\_default\_ip\_address) | n/a |
| <a name="output_guest_ip_addresses"></a> [guest\_ip\_addresses](#output\_guest\_ip\_addresses) | n/a |
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