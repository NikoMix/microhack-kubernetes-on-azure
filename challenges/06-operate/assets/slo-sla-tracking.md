# SLO and SLA tracking

This document defines measurable reliability targets for the AKS-hosted microservices and explains how the operations team reviews them.

## Definitions

- SLI: a service-level indicator, or the measurement used to evaluate reliability.
- SLO: a service-level objective, or the internal target for an SLI over a window.
- SLA: a service-level agreement, or the customer-facing commitment. This lab records an SLA stance but does not create a contract.
- Error budget: the allowed unreliability within the SLO window.

## Service targets

| Service | SLI | Measurement source | SLO target | SLA stance |
| --- | --- | --- | --- | --- |
| `node-web` | Availability of successful HTTP responses | Azure Monitor application telemetry and ingress logs | 99.5 percent over 30 days | No external SLA in lab; candidate customer SLA is lower than the SLO. |
| `dotnet-api` | P95 request latency | OpenTelemetry to Azure Monitor | P95 below 500 ms over 30 days | Internal platform SLO only. |
| `dotnet-api` | Error rate | OpenTelemetry request result codes | Fewer than 1 percent 5xx responses over 30 days | Internal platform SLO only. |
| `python-worker` | Queue processing freshness | Worker metrics and logs | 95 percent of jobs completed within 5 minutes | Internal platform SLO only. |
| AKS platform | Node readiness | Container Insights `KubeNodeInventory` | 99.9 percent ready node minutes over 30 days | Platform underpinning target. |

## Error-budget policy

| SLO | Budget window | Budget allowed | Burn trigger | Response |
| --- | --- | --- | --- | --- |
| `node-web` availability | 30 days | 0.5 percent unavailable requests | 50 percent budget consumed in 7 days | Review release changes, freeze risky deployments, and prioritise reliability work. |
| `dotnet-api` latency | 30 days | 5 percent requests above target | P95 above target for 3 consecutive hours | Investigate saturation, dependencies, and recent deployments. |
| `dotnet-api` error rate | 30 days | 1 percent 5xx responses | Error rate above 2 percent for 15 minutes | Start Sev2 triage; escalate to Sev1 if customer impact is broad. |
| `python-worker` freshness | 30 days | 5 percent late jobs | Backlog age above target for 30 minutes | Scale worker, check dependencies, and pause non-critical batch work. |
| AKS node readiness | 30 days | 0.1 percent not-ready node minutes | Any user node pool has sustained NotReady nodes for 10 minutes | Start cluster triage and check Azure resource health. |

## Review cadence

- Daily: review active alerts, failed reconciliations, and error-budget burn.
- Weekly: review SLO trend, release correlation, noisy alerts, and top reliability risks.
- Monthly: review SLA suitability, target changes, incident learnings, and platform-currency status.
- Quarterly: review whether targets still match business expectations and growth forecasts.

## Dashboard requirements

The SLO dashboard should show:

- Availability, latency, and error rate per service.
- Worker freshness and backlog age.
- Node readiness, pod restart trend, and ingress error trend.
- Current error-budget burn and remaining budget.
- Links to the triage runbook and current release record.

## Example KQL

Availability by service:

```kusto
AppRequests
| where TimeGenerated > ago(30d)
| summarize Total=count(), Failed=countif(Success == false) by AppRoleName
| extend Availability = 100.0 * (Total - Failed) / Total
| order by Availability asc
```

Pod restarts by namespace:

```kusto
KubePodInventory
| where TimeGenerated > ago(24h)
| summarize Restarts=max(ContainerRestartCount) by Namespace, ControllerName, ContainerName
| where Restarts > 0
| order by Restarts desc
```
