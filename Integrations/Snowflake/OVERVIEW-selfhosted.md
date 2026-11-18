# Snowflake

Snowflake gives developers of data-driven applications a ready-made infrastructure and engine to build and run their solutions, but getting machine identities from inside Snowflake has meant switching to separate tools and older processes. This Development Fund project connects Snowflake to Certificate Manager, Self-Hosted so developers can get machine identities when they need them, right in their native environment.

Once the integration is deployed, developers don't need any other library or tool to manage machine identities. If they already store application information in Snowflake, they can insert query results directly into their current datasets.

**Value Highlights**

- **Simplify machine identity management**: Developers work with certificates as first-class Snowflake objects.
- **Work faster**: No need for each developer to maintain credentials locally.
- **Cover the lifecycle**: Request, retrieve, renew, revoke and list machine identities from Snowflake.
- **Integrate easily**: Combine results with existing Snowflake datasets.
- **Deploy automatically**: Use the automated install option to set up the integration.

**How it Works**

Snowflake External Functions call a Snowflake API Integration, which is connected to an AWS REST API using an External ID from Snowflake. The REST API invokes AWS Lambda functions written in Go that wrap the VCert Go SDK. The Lambdas read the Certificate Manager, Self-Hosted credentials from an S3 bucket, call the Certificate Manager, Self-Hosted API to manage machine identities, and return the result to Snowflake as JSON, which developers can parse with Snowflake's built-in JSON functions.

**Solution Components**

- Certificate Manager, Self-Hosted
- Snowflake External Functions and API Integration
- AWS API Gateway, Lambda and S3
- VCert Go SDK

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
