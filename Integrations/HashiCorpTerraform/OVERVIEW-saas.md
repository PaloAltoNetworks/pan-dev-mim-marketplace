# HashiCorp Terraform

This integration is a _provider for Hashicorp Terraform_ that allows Terraform to interact with Certificate Manager to provision machine identities to DevOps infrastructure through workflows that are being set up and configured by Hashicorp Terraform. 
Modern DevOps practices and processes demand a level of speed ad-hoc security practices cannot match, often driving DevOps teams adopting shadow security practices such as acquiring certificates for services, applications, servers and code from unmanaged, unapproved tools and software, creating huge security risks for the organization and headache for the InfoSec team. 
The integration of Venafi machine identity management service into Terraform offers the speed and convenience to DevOps teams through automation when it comes to acquiring and consuming machine identities by abstracting away details about certificates and PKI infrastructure. The InfoSec team still maintains visibility, intelligence and automation capability for all the machine identities that are embedded in the infrastructure across the organization they do not own or have control over. Such enabling of better security practices without additional work from the DevOps teams not only significantly reduces the security risks for the organization but also helps DevOps go faster by reducing time spent on machine identity processes. 
**Applicability**
Any organization that has DevOps teams or Application Development teams using Hashicorp Terraform to stand up and configure their development, test, deployment infrastructure should take advantage of this Venafi Provider for Terraform to speed up software development while significantly reduce the security risk and potentially outages in production services due to mismanaged machine identities.  
**Limitations and special notes**
This Venafi provider for Terraform supports HashiCorp Terraform 0.13 or higher. 
**ADDITIONAL RESOURCES**
Github repo: [https://github.com/Venafi/terraform-provider-venafi](https://github.com/Venafi/terraform-provider-venafi)
**GETTING STARTED**
Venafi provider for Terraform is an open source software leveraging Terraform’s plugin framework and runs on the Terraform engine. It is implemented as a customer “pki provider” in Terraform’s parlance by exposing a “Venafi provider” for direct inclusion within Terraform plan files. Machine identities can be injected into upstream API’s during the build process. 
The Venafi Provider for HashiCorp Terraform is an officially verified integration. As such, releases are published to the [Terraform Registry](https://registry.terraform.io/providers/Venafi/venafi/latest) where they are available for terraform init to automatically download whenever the provider is referenced by a configuration file. No setup steps are required to use an official release of this provider other than to download and install Terraform itself.
**Example usage**
Detailed step-by-step usage instructions can be found on the Github repo provided in Additional resources section above. You can also view a demo in the accompanying demo video. 
**ABOUT Venafi**
Venafi is the cybersecurity market leader in machine identity management, securing the cryptographic keys and digital certificates on which every business and government depends to deliver safe machine-to-machine communication. Organizations use Venafi key and certificate security to protect communications, commerce, critical systems and data, and mobile and user access.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
