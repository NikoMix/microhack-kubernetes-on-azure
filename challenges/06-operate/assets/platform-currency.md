# Platform-currency process

This process keeps the AKS platform supported, patched, and predictable after deployment.

## Currency principles

- Confirm current AKS support, version skew, and upgrade rules with Microsoft Docs MCP before each planning cycle.
- Keep the cluster within the supported Kubernetes minor-version window, planning around the current minus two minor version expectation when applicable.
- Prefer planned, tested upgrades over emergency upgrades.
- Separate discovery, validation, rollout, and post-upgrade monitoring.
- Use maintenance windows and GitOps change records for traceability.

## Cadence

| Item | Cadence | Owner | Evidence |
| --- | --- | --- | --- |
| AKS Kubernetes version review | Monthly | Platform owner | Supported-version check and upgrade backlog item. |
| AKS control-plane and node pool upgrade | At least quarterly or when nearing support boundary | Platform owner | Change record, test result, rollback plan, post-upgrade validation. |
| Node image upgrade | Monthly or faster for critical fixes | Platform responder | Node image version before and after upgrade. |
| Add-ons and extensions | Monthly | Platform owner | Version inventory for Azure Policy, Defender, CSI driver, monitoring, ingress, and Flux. |
| Operating-system patches | Monthly and emergency as needed | Platform responder | Node image, base image, and vulnerability scan evidence. |
| Application base images | Per release and monthly review | Service owner | Rebuilt image digest and scan result. |

## Discovery commands

Use Azure MCP or read-only CLI commands to gather current state.

```bash
az aks get-upgrades --resource-group <resource-group> --name <cluster-name> --output table
az aks nodepool list --resource-group <resource-group> --cluster-name <cluster-name> --query '[].{name:name,mode:mode,version:orchestratorVersion,nodeImageVersion:nodeImageVersion,count:count}' --output table
kubectl get pods -A -o wide
kubectl get helmreleases -A
kubectl get kustomizations -A
```

## Upgrade workflow

1. Confirm supported target versions and known issues with Microsoft Docs MCP.
2. Review release notes for AKS, Kubernetes, add-ons, ingress, CNI, CSI, monitoring, Defender, Policy, and Flux.
3. Validate application compatibility in a non-production environment or maintenance rehearsal.
4. Check quotas, PodDisruptionBudgets, autoscaler settings, and node pool capacity.
5. Create a change record with owner, target version, risk, rollback path, and maintenance window.
6. Upgrade the control plane, then node pools according to AKS guidance.
7. Upgrade node images and add-ons if they are not covered by the Kubernetes version upgrade.
8. Confirm Flux reconciliation, workload health, Container Insights, SLO dashboards, and alert state.
9. Record evidence and update the currency register.

## Checklist

- [ ] Current AKS version and supported target version recorded.
- [ ] Node pool versions and node image versions recorded.
- [ ] Add-on and extension versions recorded.
- [ ] Maintenance window approved and communicated.
- [ ] Backups, rollback plan, and emergency contacts confirmed.
- [ ] PodDisruptionBudgets and replica counts reviewed.
- [ ] Post-upgrade validation commands prepared.
- [ ] SLO dashboard monitored during and after the change.
- [ ] Currency register updated after completion.

## Maintenance-window guidance

Use a predictable monthly platform window for low-risk patching and reserve an additional quarterly window for Kubernetes minor-version upgrades. Emergency security fixes may bypass the normal window with incident-commander approval and post-change review.

## Post-upgrade validation

```bash
az aks show --resource-group <resource-group> --name <cluster-name> --query '{name:name,kubernetesVersion:kubernetesVersion,provisioningState:provisioningState}' --output table
kubectl get nodes -o wide
kubectl get pods -A
kubectl get kustomizations -A
kubectl get helmreleases -A
```

Validation is complete only when workloads are healthy, alerts are clear or explained, and SLO dashboards show no sustained regression.
