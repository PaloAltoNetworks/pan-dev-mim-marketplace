# Machine Identity Management with AWS CloudFormation

A serverless infrastructure-as-code solution for managing policies and delivering machine identities, whenever and wherever they're needed inside your AWS accounts.

  

Customers will use AWS CloudFormation stacks to declare their Venafi resources as a seamless extension of their own AWS resources.

Machine identities will be manufactured with the assistance of Certificate Manager, SaaS and deposited in [Amazon S3](https://aws.amazon.com/s3/) and [Amazon Certificate Manager](https://aws.amazon.com/certificate-manager/) as necessary.

  

**APPLICABILITY**

This solution is currently targeted at Certificate Manager, SaaS users needing to deliver secure public-facing content via AWS services including:

  

- Amazon Elastic Load Balancing (ELB)
- Amazon API Gateway
- Amazon CloudFront

  

**VALUE HIGHLIGHTS**

- Uses [AWS CloudFormation](https://aws.amazon.com/cloudformation/), the native AWS IaC service to support efficient resource **automation**.
- **Prevents misuse and compromise **through support for [Certificate Manager, SaaS policy guardrails](https://venafi.com/resource-library/documents/venafi-tls-protect-cloud-ensures-new-certificates-meet-security-policies/).
- S**tops machine identity outages** by encapsulating the renewal process with the help of [Amazon EventBridge](https://aws.amazon.com/eventbridge/).
- Employs a **modern and agile** serverless paradigm through its use of [AWS Lambda](https://aws.amazon.com/lambda/)

  

  

**HOW IT WORKS**

Github repo: [https://github.com/Venafi/cfn-machine-identity](https://github.com/Venafi/cfn-machine-identity)

  

**Certificate Manager, SaaS is the product formerly known as Venafi TLS Protect Cloud**
