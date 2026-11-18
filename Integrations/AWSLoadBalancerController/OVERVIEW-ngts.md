# AWS Load Balancer Controller

Amazon EKS clusters often expose web applications through Application Load Balancers (ALBs) that the AWS Load Balancer Controller creates from Kubernetes Ingress resources. TLS is terminated on the ALB, so the certificates that matter live in AWS Certificate Manager (ACM), outside the cluster and often outside security policy.

This reference solution combines Next-Gen Trust Security with the AWS Load Balancer Controller. Next-Gen Trust Security issues and renews certificates under policies defined by your security team and provisions them to ACM. The controller then attaches the matching certificate to each ALB listener, extending your certificate policy to Kubernetes ingress traffic.

**Value Highlights**

- **Automate TLS for EKS ingress** without handling certificates by hand.
- **Enforce security team policy** on the certificates that ALBs present to clients.
- **Prevent outages** by renewing certificates in ACM before they expire.
- **Attach certificates automatically** through the controller's hostname-based certificate discovery.
- **Configure through Kubernetes resources** with no custom code.

**How it Works**

Next-Gen Trust Security provisions certificates to ACM through its AWS connection and an AWS cloud keystore. In the cluster, an Ingress with an HTTPS listener either names the ACM certificate ARN in an annotation or lets the AWS Load Balancer Controller discover a matching ACM certificate from the Ingress host or tls fields. When Next-Gen Trust Security renews a certificate in ACM, the ALB continues to serve a valid certificate. See the Documentation tab for setup.

**Applicability**

This solution suits organizations that run workloads on Amazon EKS and use Application Load Balancers as Layer 7 load balancers for HTTPS traffic.

**Solution Components**

- Next-Gen Trust Security with a VSatellite
- AWS Certificate Manager
- AWS Load Balancer Controller on Amazon EKS

**Additional Resources**

- [What is an Application Load Balancer?](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html)
- [Route internet traffic with AWS Load Balancer Controller](https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html)
- [AWS Load Balancer Controller certificate discovery](https://kubernetes-sigs.github.io/aws-load-balancer-controller/latest/guide/ingress/cert_discovery/)
