# Slack

Cprime has delivered an alternative and more streamlined certificate notification flow by integrating Venafi with Slack via chatbot. Instead of switching back and forth between tools, this integration provides notifications sent to Slack and specific actions to be completed within Slack using slash commands. Now Venafi users can perform basic and common machine identity management tasks without leaving a favorite communication channel.

  

**VALUE HIGHLIGHTS**

- **Increase product workflow **with less switching between applications
- **Secure machine identities **through improved and modern development user experience
- **Enables basic and common machine identity management** tasks without leaving Slack
- **Slack Chatbot communicates with service **getting messages through webhook requests from connector

  

Typically, software engineers and IT admins work in several tools at any one time, including Slack, which is always open as the primary communication and engagement platform. Context switching is incredibly costly as it drops productivity.

  

Today, if an action is required for any certificate, an email is generated and sent to the appropriate Venafi admin to take the appropriate action. To reduce context switching, limit missed emails, and improve overall efficiency, Venafi customers can now take advantage of a notification system that will allow team members to be alerted about critical actions quickly, and in the tools that are already being used.

  

As part of the Development Fund, Cprime has delivered a streamlined notification flow by integrating Venafi with Slack via chatbot. Venafi users no longer need to switch amongst different environments for a complete machine identity lifecycle. They can perform basic and common machine identity management within Slack using slash commands (/create, /renew, /revoke, etc.).

  

**HOW IT WORKS**

- Slack user initiates a Slash command (e. g. /create, /renew, /revoke) in Slack 
- Slack Connector for Venafi receives command request from Slack and processes accordingly 
- Slack Connector for Venafi forwards the processed request to Venafi Platform 
- Venafi Platform responds to Slack Connector for Venafi 
- Slack Connector for Venafi processes the response and sends to the Slack channel where the initial request originated 
- In case of an error in Venafi Platform, Venafi Platform forwards it to Slack Connector for Venafi 
- Slack Connector for Venafi handles the error and sends a response to the Slack channel

  

**About Cprime**

Cprime, is a global consulting firm helping transforming businesses get in sync. Cprime is the partner of choice for Fortune 100 companies looking to achieve value and agility through their digital transfor-mations.

  

Archer Software, a Cprime Group Company, is an innovative technology consulting and custom software development company that helps startups and enterprises digitize healthcare, automotive, and fintech domains.

  

We help our global high-tech clients deliver life-changing solutions providing technology consulting, prod-uct design, and digital solutions development as well as agile transformation powered by the Cprime team.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**

**Certificate Manager, SaaS is the product formerly known as Venafi TLS Protect Cloud**
