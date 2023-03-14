
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
