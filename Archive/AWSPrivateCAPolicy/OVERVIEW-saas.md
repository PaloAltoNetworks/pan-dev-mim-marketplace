# AWS Private CA Policy

This solution implements two AWS Lambda functions that allow enforcement of enterprise security policy for certificate requests directed at an Amazon Certificate Manager Private CA. The solution uses the VCert-Go library to retrieve enterprise security policy from Venafi Certificate Manager or Venafi as a Service.

  

**SOLUTION HIGHLIGHTS**

- **Get certificate visibility **by maintaining a certificate inventory across many AWS instances for audit and compliance purposes
- **Enforce security policy **by ensuring all certificates are compliant with corporate security and audit policies
- **Enforces security team policies **for certificate requests/renewals directed at AWS Private CA
- **Eliminates complexity and errors **by automating the entire certificate lifecycle

  

**SOLUTION OVERVIEW**

This solution implements two AWS Lambda functions that allow enforcement of enterprise security policy for certificate requests directed at an Amazon Certificate Manager Private CA. The solution uses the VCert-Go library to retrieve enterprise security policy from both Certificate Manager, Self-Hosted and Certificate Manager, SaaS. 

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**

**Certificate Manager, SaaS is the product formerly known as Venafi TLS Protect Cloud**
