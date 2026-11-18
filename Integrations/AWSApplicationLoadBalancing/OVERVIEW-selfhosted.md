# AWS Application Load Balancing

AWS Application Load Balancer (ALB) routes HTTP and HTTPS requests at Layer 7 to targets in your Amazon VPC, including microservices and containers. Each HTTPS listener needs a valid certificate, and renewing those certificates by hand across accounts and regions is slow and leads to outages.

Certificate Manager, Self-Hosted automates the certificates your ALB listeners use. It issues and renews certificates under your policy, installs them into AWS, and binds them to the load balancer, so HTTPS stays available without manual imports.

**Value Highlights**

- **Scale HTTPS** across ALB listeners without difficult setup or maintenance.
- **Eliminate outages** with continuous, automated certificate renewal.
- **Reduce the risk** of security incidents caused by improperly handled keys.
- **Keep control of keys** after they are imported into AWS.
- **Work with AWS Certificate Manager** by installing certificates into ACM or IAM, or by using ACM-issued certificates.
- **Stay agile across clouds** with one policy for AWS and the rest of your infrastructure.

**How it Works**

Certificate Manager, Self-Hosted includes an Amazon Web Services application driver. You create an AWS application object for the certificate, and Certificate Manager, Self-Hosted installs the certificate into the ACM or IAM certificate store and binds it to the Application Load Balancer you specify. The same driver can also bind certificates to Classic Load Balancers and CloudFront distributions. See the Documentation tab for setup.

**Solution Components**

- Certificate Manager, Self-Hosted
- AWS Application Load Balancer, with AWS Certificate Manager or IAM as the certificate store

**About Amazon Web Services**

[Elastic Load Balancing](https://aws.amazon.com/elasticloadbalancing/) automatically distributes incoming application traffic across multiple targets and Availability Zones. Application Load Balancer is the Elastic Load Balancing option for HTTP and HTTPS traffic.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
