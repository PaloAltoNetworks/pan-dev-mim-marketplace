# ServiceNow Incident Creation

This log driver will take any Certificate Manager, Self-Hosted log event you associate with it and create a ServiceNow incident from it.
**SOLUTION HIGHLIGHTS**
- **Fully customize** which Certificate Manager, Self-Hosted events trigger ServiceNow incidents AND how specific details are formatted
- **Provides visibility** **and machine identity automation** to teams that don't have direct access to Venafi
**SOLUTION OVERVIEW**
This log driver will take any Certificate Manager, Self-Hosted log event you associate with it and create a ServiceNow incident from it. You can choose which Certificate Manager, Self-Hosted log events are worthy of an incident or not.
Both table and scripted APIs are supported.
With this script you will have the ability to control the following incident values:
- Incident description - name/value pairs to be added to the description field
- Assignment Group - this mandatory value can either be a group name or sysid
- Impact - number which represents the impact, eg. 1 for High
- Urgency - number which represents the urgency, eg. 2 for Medium
- Category - name of the category
- Subcategory - name of the subcategory
- Configuration Item - name or sysid of the configuration item this incident should be associated with. This could be provided by a custom field for example. If not provided, a lookup will be performed on the name of the component that triggered the event and matched to either the ci name or fqdn.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
