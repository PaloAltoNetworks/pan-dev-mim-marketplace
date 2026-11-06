# Snowflake

Snowflake provides developers and builders of data-driven applications and services a ready-made infrastructure and engine to build and run their solutions. However, frictionless access to machine identities does not currently exist. Snowflake developers are required to use existing, antiquated processes. This Development Fund project seeks to remedy that with the integration of Venafi to enable devs to get machine identities when they need them, right in their native environment.

  

**SOLUTION HIGHLIGHTS**

- **Achieve comfortable and easy **machine identity management for developers
- **Work faster** with no need to maintain credentials
- **Request, retrieve**, renew and revoke machine identities
- **Integrate easily** with existing Snowflake datasets
- **Deploy machine identities** with an automated install option

  

**SOLUTION OVERVIEW**

We know from experience that many developers struggle in their daily work, because they often have to use too many tools to maintain and store machine identities. This can easily become uncomfortable. 

  

The goal of this Development Fund project was to help developers who are already familiar with Snowflake to manage their machine identities as first-class Snowflake citizens. The solution uses Snowflake External Functions, which are connected to AWS Lambdas. These Lambdas are integrated with Venafi's vCert Go SDK. In this way developers can use a secure way to request, retrieve, renew, revoke and list machine identities. 

  

Once the Venafi-Snowflake integration is deployed, developers don't have to use any other library or tool to manage machine identities. If they already store application information in Snowflake, they can easily insert the result of these queries to integrate it with their current dataset.

  

**HOW IT WORKS**

The Snowflake External Functions are connected to a Snowflake API Integration. This Snowflake API integration are integrated with an AWS Rest API by using an External ID from Snowflake.

  

The Rest API has permission to call the Lambda functions. The Lambdas are written in Go and wrap Venafi's vCert Go SDK. The developer's Venafi credentials are stored in an S3 Bucket in AWS. The Lambdas will use this bucket to retrieve the credentials, and they will call Venafi's API to manage machine identities. 

  

After a successful request, the Lambda functions will return the result to Snowflake in json format. 

  

By using Snowflake built-in json parser, developers can easily parse their result.
