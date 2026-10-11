# Triage runbook — &lt;Symptom / Alert&gt;

> B.5.2 evidence. One file per failure mode. Export as `B5.2_TriageRunbook_CustomerA_v1.pdf`.

| Field | Value |
|---|---|
| Service / component | |
| Severity mapping | Sev1 / Sev2 / Sev3 |
| Owner / on-call | |
| Related SLO | |

## Prerequisites

- Access: Azure RBAC for Kubernetes role, `kubectl` context, Azure portal.
- Tools: Container Insights, Managed Grafana, Defender for Containers.

## Detect

- Alert source / signal: &lt;alert rule, dashboard panel&gt;.
- Confirming query (KQL / PromQL):

```kusto
// Container Insights example
KubePodInventory
| where Namespace == "<ns>" and PodStatus != "Running"
| summarize count() by Name, ContainerStatusReason, bin(TimeGenerated, 5m)
```

## Diagnose

1. `kubectl describe pod <pod> -n <ns>` — events, last state, exit code.
2. `kubectl logs <pod> -n <ns> --previous` — crash cause.
3. Check resource pressure, image pull, probes, secrets/CSI mounts, Workload Identity token.

## Mitigate

- Immediate action(s): scale, restart, roll back deployment, cordon node, etc.
- **Blast radius:** &lt;scope&gt;. **Dry-run:** &lt;command&gt;.

## Verify

- SLO back within target; alert cleared; no error-rate regression.

## Rollback

- `kubectl rollout undo deployment/<name> -n <ns>` (or GitOps revert in `gitops/`).

## Customer comms

- Notify channel / contact; status-page update; post-incident summary.

## Sign-off

- Resolver: ______________  Date: ________  Post-incident review scheduled: Y/N
