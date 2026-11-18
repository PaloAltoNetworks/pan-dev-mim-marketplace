# AWS CloudFront

Amazon CloudFront is a global content delivery network (CDN) that delivers data, videos, applications and APIs to viewers with low latency. Every distribution that serves HTTPS on a custom domain needs a valid certificate, and an expired one takes your content offline for every viewer.

Certificate Manager, Self-Hosted automates the certificates your CloudFront distributions use. It issues and renews certificates under your policy, installs them into AWS, and binds them to the distribution, so HTTPS stays available without manual imports.

**Value Highlights**

- **Scale HTTPS** across CloudFront distributions without difficult setup or maintenance.
- **Eliminate outages** with continuous, automated certificate renewal.
- **Reduce the risk** of security incidents caused by improperly handled keys.
- **Keep control of keys** after they are imported into AWS.
- **Work with AWS Certificate Manager** by installing certificates into ACM or IAM, or by using ACM-issued certificates.
- **Stay agile across clouds** with one policy for AWS and the rest of your infrastructure.

**How it Works**

Certificate Manager, Self-Hosted includes an Amazon Web Services application driver. You create an AWS application object for the certificate, and Certificate Manager, Self-Hosted installs the certificate into the ACM or IAM certificate store and binds it to the CloudFront distribution you specify. The same driver also supports Application and Classic Load Balancers. See the Documentation tab for setup.

**Solution Components**

- Certificate Manager, Self-Hosted
- Amazon CloudFront, with AWS Certificate Manager or IAM as the certificate store

**About Amazon Web Services**

[Amazon CloudFront](https://aws.amazon.com/cloudfront/) is the AWS content delivery network service. It is connected to the AWS global infrastructure and integrated with other AWS services.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
