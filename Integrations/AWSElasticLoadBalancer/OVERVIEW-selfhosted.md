# AWS Elastic Load Balancer

Elastic Load Balancing is the single point of contact for clients and distributes incoming application traffic across targets such as EC2 instances in multiple Availability Zones. The certificates on those load balancers secure that traffic, and renewing them by hand across accounts and regions leads to outages.

Certificate Manager, Self-Hosted provisions certificates and keys to AWS load balancers. It issues and renews certificates under your policy, installs them into AWS, and binds them to your Application or Classic Load Balancers without manual imports.

**Value Highlights**

- **Scale HTTPS** across load balancers without difficult setup or maintenance.
- **Eliminate outages** with continuous, automated certificate renewal.
- **Reduce the risk** of security incidents caused by improperly handled keys.
- **Keep control of keys** after they are imported into AWS.
- **Work with AWS Certificate Manager** by installing certificates into ACM or IAM, or by using ACM-issued certificates.
- **Stay agile across clouds** with one policy for AWS and the rest of your infrastructure.

**How it Works**

This is a built-in capability of Certificate Manager, Self-Hosted that uses its Amazon Web Services application driver. You create an AWS application object for the certificate, and Certificate Manager, Self-Hosted installs the certificate into the ACM or IAM certificate store and binds it to the Application Load Balancer (ALB) or Classic Load Balancer (ELB) you specify. See the Documentation tab for setup.

**Solution Components**

- Certificate Manager, Self-Hosted
- AWS Elastic Load Balancing (Application or Classic Load Balancer)

**About Amazon Web Services**

[Elastic Load Balancing](https://aws.amazon.com/elasticloadbalancing/) automatically distributes incoming application traffic across multiple targets and Availability Zones.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
