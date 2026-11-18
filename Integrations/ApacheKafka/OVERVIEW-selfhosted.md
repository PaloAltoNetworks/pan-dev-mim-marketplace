# Apache Kafka

Security events from Certificate Manager, Self-Hosted are valuable to SIEMs, analytics platforms and machine learning pipelines, but each of those tools would otherwise need its own integration. A standard event stream makes the data available to all of them at once.

The Kafka connector for Certificate Manager, Self-Hosted, developed by OpenCredo, extracts security events and publishes them to Kafka. Any Kafka consumer can then filter, analyze and process machine identity events in real time.

**Value Highlights**

- **Process events in real time** with configurable analysis in the Kafka ecosystem.
- **Integrate flexibly** with any downstream tool that can consume data from Kafka, such as a SIEM or a machine learning platform.
- **Cover every event** that Certificate Manager, Self-Hosted writes to its event log.
- **Use open source** licensed under Apache 2.0 and verified by Confluent.

**How it Works**

The connector is a Kafka Connect source connector. It connects over HTTP to the Certificate Manager, Self-Hosted WebSDK, pulls log events, and writes them to a Kafka topic. Each record carries the event fields, including timestamps, component, severity, event ID, name and message text. On first start, the connector processes all past events before new ones.

**Special Notes and Limitations**

The [kafka-connect-venafi](https://github.com/opencredo/kafka-connect-venafi) repository is archived and no longer under development. Its latest release was tested with version 20.4 and Confluent Platform 5.0 or later.

**Solution Components**

- Certificate Manager, Self-Hosted
- Apache Kafka with Kafka Connect, or Confluent Platform

**About OpenCredo**

[OpenCredo](https://opencredo.com/) is a software engineering consultancy that specializes in cloud native and data platform technologies. It is now part of Trifork.

**Certificate Manager, Self-Hosted is the product formerly known as Venafi Trust Protection Platform**
