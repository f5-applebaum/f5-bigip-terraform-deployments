# VMware


## Notes

The modules/plans here provide two approaches depending on amount of upfront pre-req work, automation or security requirements desired. 

1) Using Cloud-Init. See [BIG-IP Cloud-init Support](https://clouddocs.f5.com/cloud/public/v1/shared/cloudinit.html#deploy-with-cloud-init) for more information.
    * *Benefits:*
      * Can Endlessly Customize Onboarding from Org Specific to Deployment Specific using traditional Cloud-Init UX.
    * *Drawbacks:*
      * Veers away from traditional VMWare UX.
      * Static Management IP requires Deployment Specific customization.


2) Using OVF Properties. See updating the BIG-IP OVA's [OVF Properties](https://clouddocs.f5.com/cloud/public/v1/vmware/vmware_setup.html#set-the-big-ip-ve-management-ip-address-and-passwords) for more information.
      * *Benefits:*
        * Traditional Day 0 Approach
        * Can Provide Credential and Static Management IP via traditional VMware UX.
      * *Drawbacks:*
        * More onboarding required 




## VMWare Issues


### OVA/OVF issues

1. Location

    Terraform provider required OVF to be referenced either by a local or remote url (vs. datastore). 

    Solution = Content Library 
      - https://www.linkedin.com/pulse/how-deploy-vmware-virtual-machine-from-ova-directly-local-gabra-1
      - https://stackoverflow.com/questions/72908131/terraform-vsphere-official-provider-creating-vm-with-ovf-deploy


    *Workaround:*

    Use Clone from Content Library
    https://stackoverflow.com/questions/72908131/terraform-vsphere-official-provider-creating-vm-with-ovf-deploy


2. Creating Multiple-NICs: 

    OVFs from Content Libraries also don't easily allow hardware customization (ex. multiple NICs)

    - [Creating VM with vsphere_content_library_item template fails when adding 2 networks #1441](https://github.com/hashicorp/terraform-provider-vsphere/issues/1441)
    - [Deploying OVF from content library results in HTTP error 500 #1345](https://github.com/hashicorp/terraform-provider-vsphere/issues/1345)

    ```
    ╷
    │ Error: 400 Bad Request: {"type":"com.vmware.vapi.std.errors.invalid_argument","value":{"error_type":"INVALID_ARGUMENT","messages":[{"args":["network_mappings","com.vmware.vcenter.ovf.library_item.resource_pool_deployment_spec"],"default_message":"Could not convert field 'network_mappings' of structure 'com.vmware.vcenter.ovf.library_item.resource_pool_deployment_spec'","id":"vapi.bindings.typeconverter.fromvalue.struct.field.error"},{"args":[],"default_message":"Element already present in the map.","id":"vapi.bindings.typeconverter.map.duplicate.element"}]}}
    │ 
    ```
    *Workaround:*
    
    Add manual "ovf_mapping" attributes to network blocks.


    For NICs, the official [Terraform VM Module](https://github.com/Terraform-VMWare-Modules/terraform-vsphere-vm) has a map vs. list which caused NICs to pop up in wrong order:
    
    - [Network interfaces attached in wrong order #90](https://github.com/Terraform-VMWare-Modules/terraform-vsphere-vm/issues/90)

    - [Need to disable default netplan and re-apply custom one](https://askubuntu.com/questions/1117496/how-do-i-use-cloud-init-to-apply-netplan)





### Issues List

* [CDROM device is required even when not specifying vApp properties #489](https://github.com/hashicorp/terraform-provider-vsphere/issues/489)
* [Can't change disk type when provisioning from template #562](https://github.com/hashicorp/terraform-provider-vsphere/issues/562)

* [timeout waiting for an available IP address #718](https://github.com/hashicorp/terraform-provider-vsphere/issues/718)
* [When adding a Resource, an uninvolved (via OVF/OVA) deployed VM leads to "Error: this virtual machine requires a client CDROM device to deliver vApp properties" #1292](https://github.com/hashicorp/terraform-provider-vsphere/issues/1292)
* [Deploying OVF from content library results in HTTP error 500 #1345](https://github.com/hashicorp/terraform-provider-vsphere/issues/1345)
* [Creating VM with vsphere_content_library_item template fails when adding 2 networks #1441](https://github.com/hashicorp/terraform-provider-vsphere/issues/1441)
* [Only some vApp properties are set #1455](https://github.com/hashicorp/terraform-provider-vsphere/issues/1455)
* [Waiting for cloud-config/user_data completion](https://github.com/hashicorp/terraform/issues/4668)
* [Terraform can't run remote-exec while normal SSH works as expected #29082](https://github.com/hashicorp/terraform/issues/29082)



##  MISC:
 - https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs
 - https://registry.terraform.io/modules/Terraform-VMWare-Modules/vm/vsphere/latest
 - https://github.com/Terraform-VMWare-Modules/terraform-vsphere-vm
 - https://blogs.vmware.com/cloud/2019/11/19/infrastructure-code-terraform-vmware-vmware-cloud-aws/
 - https://garyflynn.com/post/create-your-first-vsphere-terraform-configuration/
 - https://blog.linoproject.net/cloud-init-with-terraform-in-vsphere-environment/




