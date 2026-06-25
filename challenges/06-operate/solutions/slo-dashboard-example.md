# SLO dashboard example

This trainer-only example shows one acceptable SLO dashboard and alert threshold set for Module 6.

## Dashboard layout

| Panel | Query source | Target | Audience |
| --- | --- | --- | --- |
| Service availability | `AppRequests` | `node-web` success rate at or above 99.5 percent over 30 days | Incident commander |
| API latency | `AppRequests` | `dotnet-api` P95 below 500 ms | Service owner |
| API error rate | `AppRequests` | 5xx below 1 percent over 30 days | Service owner |
| Worker freshness | Worker metrics or logs | 95 percent of jobs completed within 5 minutes | Application responder |
| Node readiness | `KubeNodeInventory` | 99.9 percent ready node minutes | Platform responder |
| Pod restarts | `KubePodInventory` | No sustained restart increase | Platform and service responders |
| Error-budget burn | Calculated SLO panel | Less than 50 percent budget consumed in 7 days | Platform owner |

## Example KQL

API availability over 30 days:

```kusto
AppRequests
| where TimeGenerated > ago(30d)
| where AppRoleName == "dotnet-api"
| summarize Total=count(), Failed=countif(Success == false)
| extend AvailabilityPercent = 100.0 * (Total - Failed) / Total
```

API P95 latency:

```kusto
AppRequests
| where TimeGenerated > ago(24h)
| where AppRoleName == "dotnet-api"
| summarize P95DurationMs=percentile(DurationMs, 95) by bin(TimeGenerated, 15m)
| order by TimeGenerated asc
```

Ready node minutes:

```kusto
KubeNodeInventory
| where TimeGenerated > ago(30d)
| summarize ReadySamples=countif(Status == "Ready"), TotalSamples=count() by ClusterName
| extend ReadyPercent = 100.0 * ReadySamples / TotalSamples
```

## Alert thresholds

| Alert | Severity | Threshold | Action |
| --- | --- | --- | --- |
| API error rate | Sev2 | 5xx above 2 percent for 15 minutes | Notify service owner and start application triage. |
| Ingress unavailable | Sev1 | Synthetic or ingress checks fail for all routes for 10 minutes | Page platform on-call and declare incident. |
| Node NotReady | Sev2 | Any user node NotReady for 10 minutes | Start node triage. |
| Multiple nodes NotReady | Sev1 | More than one node pool affected or broad workload impact | Escalate to Azure support path and incident channel. |
| CrashLoopBackOff | Sev2 | Any production deployment affected for 10 minutes | Start workload triage and check recent release. |
| Error-budget burn | Sev2 | More than 50 percent of monthly budget consumed in 7 days | Freeze risky releases until reviewed. |

## Trainer scoring notes

A learner dashboard is acceptable if it makes reliability visible, links alerts to action, and includes node, pod, and ingress health. It does not need the exact same queries as this example.
