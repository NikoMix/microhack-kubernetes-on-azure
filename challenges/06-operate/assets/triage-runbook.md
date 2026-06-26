# Triage runbook

Use this runbook for AKS platform incidents after the secure baseline and GitOps workloads are deployed.

## Roles and channels

| Role | Responsibility | Backup |
| --- | --- | --- |
| Incident commander | Owns severity, timeline, decisions, and communications. | Platform lead |
| Platform responder | Runs AKS, node, add-on, and network triage. | Cloud engineer |
| Application responder | Runs workload, dependency, and release triage. | Service owner |
| Communications owner | Posts status updates and customer-facing summaries. | Incident commander |

Primary channel: `<incident-channel>`. Escalation contact: `<platform-on-call>`. Customer communications path: `<customer-status-channel>`.

## Severity matrix

| Severity | Definition | Examples | Response target |
| --- | --- | --- | --- |
| Sev1 | Broad production outage, data-loss risk, or critical security exposure with no safe workaround. | Ingress down for all users, cluster API unavailable during active incident, multiple node pools unavailable, active secret exposure. | Acknowledge in 5 minutes, update every 15 minutes, executive escalation within 30 minutes. |
| Sev2 | Significant degradation, partial outage, or high risk to SLOs with workaround or limited blast radius. | One service in `CrashLoopBackOff`, one node pool degraded, image pull failures for a new release, latency SLO burn. | Acknowledge in 15 minutes, update every 30 minutes, escalation within 60 minutes if not mitigated. |

## Initial incident procedure

1. Declare severity, incident commander, start time, affected services, and customer impact.
2. Freeze non-emergency deployments unless the incident commander approves a mitigation release.
3. Capture evidence before changing state.
4. Check Azure Service Health, AKS resource health, Flux status, Container Insights, and recent releases.
5. Mitigate customer impact first, then identify root cause.
6. Validate recovery with SLO dashboards, health endpoints, and Flux status.
7. Close the incident only after monitoring is stable and communications are complete.
8. Create a post-incident review with timeline, contributing factors, corrective actions, and evidence links.

## Evidence capture commands

Run read-only commands first. Add timestamps to copied output.

```bash
kubectl get nodes -o wide
kubectl get pods -A -o wide
kubectl get events -A --sort-by=.lastTimestamp
kubectl get kustomizations -A
kubectl get helmreleases -A
az aks show --resource-group <resource-group> --name <cluster-name> --query '{name:name,powerState:powerState,kubernetesVersion:kubernetesVersion,provisioningState:provisioningState}' --output json
```

## Nodes NotReady

1. Confirm scope.

   ```bash
   kubectl get nodes -o wide
   kubectl describe node <node-name>
   ```

2. Check whether impact is isolated to one node, one node pool, one availability zone, or the full cluster.
3. Review Container Insights node CPU, memory, disk, PID pressure, and restart signals.
4. Check Azure resource health for the AKS cluster, VM scale set, and region.
5. If only one node is unhealthy and replicas are safe, cordon and drain according to change policy.
6. If multiple nodes are unhealthy, escalate to platform on-call and Azure support path.
7. Validate recovery when nodes are `Ready`, workloads reschedule, and SLO burn stops.

## Pod CrashLoopBackOff

1. Identify affected pods and recent changes.

   ```bash
   kubectl get pods -A | grep CrashLoopBackOff
   kubectl describe pod <pod-name> -n <namespace>
   kubectl logs <pod-name> -n <namespace> --previous
   ```

2. Check configuration, secrets, image digest, probes, resource limits, and dependencies.
3. Compare the running image digest with the last known-good GitOps commit.
4. If the issue came from a new release, revert or promote the previous digest through GitOps.
5. If the issue is dependency-related, escalate to the service owner and dependency owner.
6. Validate recovery when restart count stops increasing, readiness passes, and service SLOs recover.

## Ingress down

1. Determine whether the failure is global, path-specific, hostname-specific, or backend-specific.
2. Check ingress controller or App Gateway for Containers health and recent changes.

   ```bash
   kubectl get ingress -A
   kubectl get services -A
   kubectl get endpointslices -A
   kubectl describe ingress <ingress-name> -n <namespace>
   ```

3. Validate DNS, certificate, listener, route, service, and endpoint health.
4. Review ingress 5xx and 4xx trends in Azure Monitor.
5. If all entry points are down, treat as Sev1 and escalate to platform and network owners.
6. Validate recovery with external health checks, ingress metrics, and application SLOs.

## Image pull failures

1. Identify affected pods and error details.

   ```bash
   kubectl get pods -A | grep ImagePull
   kubectl describe pod <pod-name> -n <namespace>
   ```

2. Confirm the image repository, tag or digest, and pull secret or managed identity path.
3. Check ACR availability, firewall rules, private endpoint or egress rules, and managed-identity pull permissions.
4. Confirm the image exists in `<acr-login-server>` and the GitOps desired state references the intended digest.
5. Revert the GitOps change or publish the missing image if a release artifact is incomplete.
6. Validate recovery when pods pull successfully and all replicas become ready.

## Escalation

Escalate when any of these conditions is true:

- Sev1 is declared or customer impact is expanding.
- Sev2 is not mitigated within 60 minutes.
- Azure regional, AKS control-plane, ACR, Key Vault, or network health appears degraded.
- A security exposure or data-loss risk is suspected.
- The required mitigation needs access or approval the current responders do not have.

## Recovery validation

Before closing the incident, confirm:

- All affected nodes, pods, ingress routes, and Flux resources are healthy.
- Alerts have cleared or are acknowledged with a follow-up action.
- SLO dashboards show recovery and error-budget burn has stopped.
- Customer or stakeholder communications include current status and next update.
- Corrective actions are assigned owners and due dates.
