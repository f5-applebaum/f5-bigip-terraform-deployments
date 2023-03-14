# Terraform vSphere Virtual Machine Module (Example Application)

Deploys a VMware virtual machine from a Ubuntu Server (kinetic-server-cloudimg-amd64). The virtual machine has docker installed and an example application for testing traffic. 

### Features
  * Ability to deploy from an OVA or VM Template from a VMware Content Library
  * Ability to deploy from an OVA from a local file or remote URL
  * Ability to add multiple network cards for the VM
  * Accepts a Static IP for 1st NIC
  * Can provide a custom docker container name to run as the example application
  * Can optionally run an external provisioner to confirm successful deployment and assist with measuring deployment times.

# Requirements

### General
* SSH Public Key (common cloud standard)
### VMware Env:
* 1 VMware Network ( Port Groups )
* Ubuntu Server (kinetic-server-cloudimg-amd64) OVA hosted on a local file, remote URL or VMware Content Library
  * ***NOTE***:
    * If deploying with ovf_deploy, you must provide either the remote url (**ovf_remote_url** parameter) OR a local file path (**local_ovf_path** parameter).
    * If deploying an OVA or VM Template from a VMware Content library, you must provide both the Content Library (**vsphere_content_library** parameter) AND the OVA/VM Template name (**vsphere_virtual_machine** parameter).
