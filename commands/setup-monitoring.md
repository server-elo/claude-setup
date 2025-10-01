---
name: setup-monitoring
description: Configure comprehensive monitoring and observability
---

Set up comprehensive monitoring, logging, and observability for the specified system or application.

**Target System:** $ARGUMENTS

**Monitoring Stack Components:**
1. **Application Monitoring**
   - Performance metrics (latency, throughput, errors)
   - Business metrics (user actions, conversions)
   - Custom application metrics
   - Real User Monitoring (RUM)

2. **Infrastructure Monitoring**
   - System resources (CPU, memory, disk, network)
   - Container and orchestration metrics
   - Database performance metrics
   - Load balancer and proxy metrics

3. **Log Management**
   - Centralized log aggregation
   - Log parsing and enrichment
   - Search and analysis capabilities
   - Log retention and archival

4. **Alerting & Notifications**
   - Threshold-based alerts
   - Anomaly detection
   - Alert routing and escalation
   - On-call management integration

**Observability Pillars:**
- **Metrics**: Quantitative measurements over time
- **Logs**: Timestamped event records
- **Traces**: Request flow through distributed systems
- **Synthetic Monitoring**: Proactive availability testing

**Technology Recommendations:**
- **Metrics**: Prometheus + Grafana, Datadog, New Relic
- **Logging**: ELK Stack (Elasticsearch, Logstash, Kibana), Splunk
- **Tracing**: Jaeger, Zipkin, AWS X-Ray
- **APM**: Datadog APM, New Relic, Dynatrace

**Key Metrics to Monitor:**
- **Application**: Response time, error rate, throughput
- **Business**: User engagement, conversion rates, revenue
- **Infrastructure**: CPU, memory, disk, network utilization
- **Database**: Query performance, connection pools, locks

**Alert Configuration:**
- **SLA/SLO Alerts**: Service level objectives breaches
- **Resource Alerts**: High CPU, memory, disk usage
- **Error Alerts**: Application errors, failed requests
- **Business Alerts**: Drop in conversions, user activity

**Dashboard Creation:**
- **Executive Dashboard**: High-level business metrics
- **Operational Dashboard**: System health and performance
- **Application Dashboard**: Service-specific metrics
- **Infrastructure Dashboard**: Resource utilization

**Implementation Steps:**
1. Install and configure monitoring agents
2. Define custom metrics and logging
3. Set up dashboards and visualizations
4. Configure alerting rules and notifications
5. Test monitoring and alerting workflows
6. Document runbooks and procedures

**Example Usage:**
- `/setup-monitoring web-application`
- `/setup-monitoring microservices-cluster`
- `/setup-monitoring database-performance`