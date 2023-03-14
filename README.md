# f5-bigip-terraform-deployments

This repo aims to take a cloud-like approach, leveraging terraform and cloud-init to deploy BIG-IPs:

Similar to goal described here:
- https://grantorchard.com/terraform-vsphere-cloud-init/


Go to:
- **providers/[provider]/plans** for deployment details.
- **providers/[provider]/modules** for various modules used.


## NOTES

### Creating multiple instances

These examples create multiple instances leveraging *counts* on the module level (vs. built into the module itself). 
  * ex. https://blog.ktz.me/terraform-0-13-count-modules/ 

### Use of External Provisioners

As terraform is client clode and not a hosted service, there's no elegant way to signal deployment is complete (safe to login, etc.) to terraform itself. For example, cfn-init which sends webhook to Cloudformation. 

  * ex. [Waiting for cloud-config/user_data completion #4668](https://github.com/hashicorp/terraform/issues/4668)

Hence to report success and measure onboarding times, a common workaround is using the last resort provisioner approach. 

### Full Stack Examples

*Disclaimer:* For simplicity/illustration purposes, example full-stack plans (w/ application) currently have non-realistic patterns to facilitate various tests (vs. a prod like approach you would seperate Day 0 (infrastructure as code to deploy instances / cloud resources) vs. Day 1-N (traditional ongoing Config Mgmt that is required with maintaining infrastructure). The modules do however strictly provide traditional Day 0 functionality.

## Links

 **Official**
 - https://github.com/F5Networks/terraform-aws-bigip-module
 - https://github.com/F5Networks/terraform-azure-bigip-module
 - https://github.com/F5Networks/terraform-gcp-bigip-module

 **Solutions**
 - https://github.com/JeffGiroux/f5_terraform

 **Day 0 vs. Day 1**
  - https://github.com/megamattzilla/azure_terraform_waf
  - https://gitlab.wirelessravens.org/f5labs/tf-client-poc
  - https://github.com/f5devcentral/terraform-bigip-postbuild-config


