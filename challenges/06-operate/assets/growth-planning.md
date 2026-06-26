# Growth planning

This document describes how the AKS platform should grow without losing reliability, security, or cost control.

## Planning assumptions

- The platform starts from the secure baseline in West Europe.
- Workloads are deployed through Flux v2 and emit OpenTelemetry to Azure Monitor.
- Node pools include system and user pools, with autoscaling available where appropriate.
- Growth decisions must preserve security controls, observability, and SLO tracking.

## Scaling plan

| Area | Near-term action | Longer-term action | Evidence |
| --- | --- | --- | --- |
| Node pools | Enable or tune cluster autoscaler on user pools. | Add workload-specific node pools for GPU, memory, or isolation needs. | Node pool inventory and autoscaler settings. |
| Pods | Configure HPA for services with CPU, memory, or custom metrics. | Add KEDA or event-driven scaling for queue workloads if needed. | HPA manifests and scaling history. |
| Ingress | Track request rate, 4xx, 5xx, and latency. | Add regional ingress design and failover strategy if business criticality grows. | Ingress dashboard and capacity review. |
| Data and dependencies | Track dependency latency and error rates. | Add dependency resilience patterns and DR runbooks. | Dependency SLO view and incident learnings. |
| Observability | Review Log Analytics retention and ingestion volume monthly. | Split workspaces or add dedicated dashboards for high-volume services. | Cost and ingestion trend. |

## Disaster recovery and multi-region considerations

The lab baseline is single-region. Before production criticality increases, decide whether the service needs active-passive or active-active multi-region architecture.

| Decision | Consideration | Trigger |
| --- | --- | --- |
| Recovery time objective | How quickly service must return after regional failure. | Customer contract or business-critical workload. |
| Recovery point objective | How much data loss is acceptable. | Stateful workload or queue durability requirement. |
| GitOps recovery | Whether a new cluster can be bootstrapped from desired state. | Platform rebuild or regional failover test. |
| Traffic failover | DNS, Front Door, or ingress failover pattern. | Regional availability requirement. |
| Observability continuity | Workspace and dashboard access during regional incident. | Incident-response requirement. |

## Cost growth

Track cost growth before it becomes waste. Use Azure Cost Management, budgets from the `infra/` contract, and the `scripts/cost-report` contract.

| Cost driver | Signal | Control |
| --- | --- | --- |
| Node count | Cluster autoscaler growth and low utilisation. | Right-size node pools, use scale-down settings, and review requests and limits. |
| Log ingestion | Log Analytics GB per day and retention. | Filter noisy logs, tune retention, and move verbose logs to lower-cost storage if appropriate. |
| Image storage | ACR storage growth. | Retention policy and image cleanup after release windows. |
| Egress | Cross-zone, cross-region, or internet traffic. | Review architecture, caching, and private routing. |
| Premium add-ons | Grafana, Defender, monitoring, and gateway costs. | Confirm each add-on has an owner and dashboard consumers. |

## Growth review cadence

- Weekly: check autoscaler events, HPA behaviour, and top resource consumers.
- Monthly: review capacity trend, SLO error-budget burn, Log Analytics ingestion, and Azure cost.
- Quarterly: reassess DR requirements, regional strategy, and major SKU or architecture changes.

## Decision record template

```text
Decision: <growth decision>
Reason: <business or technical driver>
Options considered: <option 1>, <option 2>, <option 3>
Chosen approach: <selected option>
Risks: <known risks>
Cost impact: <expected monthly cost change>
Owner: <name or role>
Review date: <date>
```
