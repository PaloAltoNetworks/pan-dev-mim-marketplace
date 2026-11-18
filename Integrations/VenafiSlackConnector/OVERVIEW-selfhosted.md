# Slack

Engineers and IT admins keep Slack open all day, but certificate actions in Certificate Manager, Self-Hosted usually arrive as emails to an administrator, which are easy to miss and force a switch between tools. Cprime built this chatbot integration through the Development Fund so certificate notifications arrive in Slack and common certificate tasks can be completed there with slash commands such as `/create`, `/renew` and `/revoke`.

**Value Highlights**

- **Work faster**: Spend less time switching between applications.
- **Improve the user experience**: Give developers a modern way to secure machine identities.
- **Act from Slack**: Complete basic and common machine identity management tasks without leaving Slack.
- **Get alerted quickly**: Receive notifications about critical certificate actions in the channels your team already uses.

**How it Works**

A Slack user runs a slash command. The Slack Connector receives the request, processes it and forwards it to Certificate Manager, Self-Hosted. The connector then processes the response, or any error, and posts the result to the Slack channel where the request started. Notifications reach the chatbot through webhook requests from the connector.

**Solution Components**

- Certificate Manager, Self-Hosted
- Slack Connector service
- Slack workspace and chatbot

**About Cprime**

Cprime is a global consulting firm that helps companies with digital and agile transformation. Archer Software, a Cprime Group company, provides technology consulting and custom software development. Learn more at [cprime.com](https://www.cprime.com/).

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
