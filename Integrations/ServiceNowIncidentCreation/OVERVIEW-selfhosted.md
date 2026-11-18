# ServiceNow Incident Creation

Certificate problems that only surface in Certificate Manager, Self-Hosted can be missed by the teams responsible for fixing them. This log driver takes any Certificate Manager, Self-Hosted log event you associate with it and creates a ServiceNow incident, so the right team gets a ticket in their normal ITSM queue.

**Value Highlights**

- **Choose what matters**: Decide which Certificate Manager, Self-Hosted log events are worth an incident.
- **Format incidents your way**: Control how incident details are populated.
- **Extend visibility**: Bring machine identity issues to teams that don't have direct access to Certificate Manager, Self-Hosted.
- **Route to the right owner**: Set assignment group, category and configuration item so incidents land with the correct team.
- **Use either API**: Both the ServiceNow table API and scripted APIs are supported.

**How it Works**

When an associated log event occurs, the driver creates a ServiceNow incident. You can control these incident values:

- **Incident description**: name/value pairs added to the description field.
- **Assignment Group**: a required group name or sys_id.
- **Impact**: a number representing impact, for example 1 for High.
- **Urgency**: a number representing urgency, for example 2 for Medium.
- **Category** and **Subcategory**: names of the category and subcategory.
- **Configuration Item**: name or sys_id of the related configuration item, for example from a custom field. If not provided, the name of the component that triggered the event is matched to a CI name or FQDN.

**Solution Components**

- Certificate Manager, Self-Hosted
- ServiceNow IT Service Management

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
