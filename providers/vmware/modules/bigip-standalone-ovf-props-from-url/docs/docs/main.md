# Terraform vSphere Virtual Machine Module (BIG-IP Next)

Deploys a VMWare virtual machine from a BIG-IP Next OVA (Ubuntu). 

### Features
  * Ability to deploy from a local file, remote URL or Vmware Content Library
  * Ability to add multiple network cards for the VM
  * Accepts a Static IP for 1st NIC
  * Can optionally run an external provisioner to confirm successful deployment and assist with measuring deployment times.

# Requirements

### General

* SSH Public Key (common cloud standard)

### VMWare Env:

* 1 VMWare Network ( Port Groups )
* BIG-IP Next OVA hosted on a local file, remote URL or VMware Content Library. 
  * ***NOTE***:
    * If deploying with ovf_deploy, you must provide either the remote url (**ovf_remote_url** parameter) OR a local file path (**local_ovf_path** parameter).
    * If deploying from a VMWare Content library, you must provide both the Content Library (**vsphere_content_library** parameter) AND the OVA name (**vsphere_virtual_machine** parameter).
