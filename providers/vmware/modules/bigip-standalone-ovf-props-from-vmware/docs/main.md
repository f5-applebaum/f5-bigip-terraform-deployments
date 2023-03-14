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