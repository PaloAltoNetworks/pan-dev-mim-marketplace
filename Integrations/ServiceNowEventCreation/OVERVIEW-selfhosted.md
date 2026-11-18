# ServiceNow Event Creation

Teams that run IT operations in ServiceNow often have no direct access to Certificate Manager, Self-Hosted, so certificate problems reach them late or through ad hoc notifications. This log driver takes any Certificate Manager, Self-Hosted log event and creates a ServiceNow Event Management event from it, so those teams see and act on certificate activity in the tools they already use.

**Value Highlights**

- **Customize completely**: Translate any Certificate Manager, Self-Hosted event into a ServiceNow event and act on it there.
- **Remove manual alerting**: Stop building separate notifications and alerts for different teams.
- **Extend visibility**: Give teams without direct access to Certificate Manager, Self-Hosted insight into certificate activity.
- **Find root causes faster**: Use ServiceNow alerts to understand unexpected behavior and its impact on the business.

**How it Works**

The log driver forwards the Certificate Manager, Self-Hosted log events you associate with it to ServiceNow Event Management. There, [event rules](https://docs.servicenow.com/bundle/rome-it-operations-management/page/product/event-management/concept/create-event-rules.html) turn events into [alerts](https://docs.servicenow.com/bundle/rome-it-operations-management/page/product/event-management/concept/c_EMAlert.html), which you can configure to trigger any number of actions and to help improve the availability of your certificate services.

**Solution Components**

- Certificate Manager, Self-Hosted
- ServiceNow Event Management

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
