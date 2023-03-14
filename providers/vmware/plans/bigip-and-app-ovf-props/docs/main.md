# Example BIG-IP Standalone Deployment using BIG-IP Terraform module.

Deploys VMWare virtual machine(s) from a BIG-IP VM Template using the BIG-IP module contained in this project. The BIG-IP module leverages [OVF Properties](https://clouddocs.f5.com/cloud/public/v1/vmware/vmware_setup.html#set-the-big-ip-ve-management-ip-address-and-passwords).

*NOTE:* this solution uses count at the module level to deploy N number of instances and hence leverages different variables then the modules themselves to facilitate deploying multiple instances (ex. hostname prefixes vs. hostnames, arrays of IPs vs. single IPs, etc).

This solution deploys Day 0 (VM) and Day 1 (virtual service via AS3) in one plan to facilitate testing deploy times and traffic vs. a more realistic pattern of seperating Day 0 and Day 1-N. See the bigip-standalone plan(s) without the example application VMs and virtual service (AS3) deployments for example of strictly Day 0 deployment.

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