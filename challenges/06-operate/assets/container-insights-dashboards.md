# Container Insights dashboards and alerts

Use this document to define the required Container Insights and Azure Monitor views for post-deployment operations.

## Dashboard views

| View | Purpose | Primary users |
| --- | --- | --- |
| Cluster health | Node readiness, CPU, memory, disk, restart trend, and pending pods. | Platform responders |
| Workload health | Pod readiness, restarts, CrashLoopBackOff, image pull failures, and deployment status. | Service owners |
| Ingress health | Request volume, latency, 4xx, 5xx, endpoint availability, and certificate signals. | Platform and application responders |
| SLO overview | Availability, latency, error rate, worker freshness, and error-budget burn. | Incident commander and service owners |
| Cost and ingestion | Log Analytics ingestion volume, noisy namespaces, and retention trend. | Platform owner |

## Sample KQL queries

Node readiness:

```kusto
KubeNodeInventory
| where TimeGenerated > ago(15m)
| summarize LastSeen=max(TimeGenerated), ReadyCount=countif(Status == "Ready") by ClusterName, Computer
| where ReadyCount == 0
| order by LastSeen desc
```

Pods in CrashLoopBackOff or waiting states:

```kusto
KubePodInventory
| where TimeGenerated > ago(15m)
| where ContainerStatusReason in ("CrashLoopBackOff", "ErrImagePull", "ImagePullBackOff")
| summarize LastSeen=max(TimeGenerated), Reasons=make_set(ContainerStatusReason) by Namespace, ControllerName, PodName, ContainerName
| order by LastSeen desc
```

Pod restart trend:

```kusto
KubePodInventory
| where TimeGenerated > ago(6h)
| summarize Restarts=max(ContainerRestartCount) by bin(TimeGenerated, 15m), Namespace, ControllerName, ContainerName
| where Restarts > 0
| order by TimeGenerated desc
```

Pending pods:

```kusto
KubePodInventory
| where TimeGenerated > ago(15m)
| where PodStatus == "Pending"
| summarize LastSeen=max(TimeGenerated) by Namespace, ControllerName, PodName
| order by LastSeen desc
```

Ingress 5xx rate from application requests:

```kusto
AppRequests
| where TimeGenerated > ago(30m)
| summarize Total=count(), Failures=countif(ResultCode startswith "5") by bin(TimeGenerated, 5m), AppRoleName
| extend FailureRate = todouble(Failures) / todouble(Total)
| where Total > 20 and FailureRate > 0.05
| order by TimeGenerated desc
```

Container log errors by namespace:

```kusto
ContainerLogV2
| where TimeGenerated > ago(30m)
| where LogMessage has_any ("error", "exception", "failed")
| summarize ErrorLines=count() by NamespaceName, PodName
| order by ErrorLines desc
```

## Alert rule definitions

| Alert | Query or signal | Severity | Threshold | Evaluation | Action |
| --- | --- | --- | --- | --- | --- |
| Node NotReady sustained | Node readiness KQL | Sev2, Sev1 if multi-node or customer impact | Any user node missing Ready for 10 minutes | Every 5 minutes over 15 minutes | Start node triage and notify platform on-call. |
| CrashLoopBackOff sustained | Waiting-state KQL | Sev2 | Any production workload in CrashLoopBackOff for 10 minutes | Every 5 minutes over 15 minutes | Start workload triage and notify service owner. |
| ImagePullBackOff | Waiting-state KQL | Sev2 | Any production pod in image pull failure for 10 minutes | Every 5 minutes over 15 minutes | Check ACR, identity, network, and GitOps digest. |
| Ingress 5xx high | Ingress 5xx KQL or application request metric | Sev2, Sev1 if broad outage | Failure rate greater than 5 percent with more than 20 requests | Every 5 minutes over 30 minutes | Start ingress triage and notify incident channel. |
| Pending pods | Pending pods KQL | Sev2 | Production pods pending for 15 minutes | Every 5 minutes over 30 minutes | Check capacity, quotas, taints, and autoscaler. |
| Error-budget burn | SLO dashboard calculation | Sev2 | 50 percent budget consumed in 7 days | Daily | Review releases and reliability backlog. |

## Alert hygiene

- Alert on sustained symptoms, not single transient events.
- Include runbook link, owner, dashboard link, and severity in every alert description.
- Route Sev1 alerts to paging and incident channels; route Sev2 alerts to the service or platform on-call queue.
- Review noisy alerts weekly and remove alerts that do not lead to action.

## Workbook evidence

Record the following for scoring:

- Workbook or dashboard name.
- Log Analytics workspace ID or placeholder.
- Alert rule names and severities.
- Action group or notification route.
- Screenshots or exported definitions if the trainer requests evidence.
