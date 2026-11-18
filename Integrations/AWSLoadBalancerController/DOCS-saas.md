# AWS Load Balancer Controller

## Prerequisites

- An Amazon EKS cluster.
- Certificate Manager, SaaS with an active VSatellite.
- An AWS account that Certificate Manager, SaaS can access through an IAM role.

## Installation

1. Install the AWS Load Balancer Controller in the cluster. See [Route internet traffic with AWS Load Balancer Controller](https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html) or the [Helm chart](https://github.com/kubernetes-sigs/aws-load-balancer-controller/tree/main/helm/aws-load-balancer-controller).
2. Connect Certificate Manager, SaaS to AWS and add an AWS cloud keystore. See the AWS Certificate Manager documentation for Certificate Manager, SaaS.

## Configuration

1. Issue the certificate for your application hostname in Certificate Manager, SaaS and provision it to ACM in the region of the cluster.
2. Create an Ingress that uses the controller, either with `spec.ingressClassName` set to your ALB ingress class or with the ingress class annotation.
3. Add the `alb.ingress.kubernetes.io/listen-ports: '[{"HTTPS":443}]'` annotation to create an HTTPS listener.
4. Attach the certificate in one of two ways:
   - Set the `alb.ingress.kubernetes.io/certificate-arn` annotation to the ACM certificate ARN.
   - Leave the annotation unset and list the hostname in the Ingress `tls` or `rules[].host` fields, so the controller discovers the matching ACM certificate.

See [Certificate Discovery](https://kubernetes-sigs.github.io/aws-load-balancer-controller/latest/guide/ingress/cert_discovery/) for details.
