# Triage runbook example

This trainer-only example shows a complete pattern for a Module 6 triage runbook.

## Severity definitions

| Severity | Definition | Response |
| --- | --- | --- |
| Sev1 | Broad customer outage, data-loss risk, critical security exposure, or no safe workaround. | Page platform and service owners, update every 15 minutes, executive escalation within 30 minutes. |
| Sev2 | Partial outage, degraded service, or SLO burn with workaround or limited blast radius. | Notify platform and service owners, update every 30 minutes, escalate if not mitigated within 60 minutes. |

## Standard triage flow

1. Declare severity, incident commander, responders, start time, and affected services.
2. Freeze non-emergency releases.
3. Capture cluster state, alert state, Flux state, and recent release history.
4. Triage customer-impacting symptoms first.
5. Mitigate with the least risky reversible action.
6. Validate service recovery through health checks and SLO dashboards.
7. Complete communications and post-incident review.

## Worked Sev2 scenario

Scenario: after a GitOps release, `dotnet-api` pods enter `CrashLoopBackOff` in production. `node-web` is still available but orders fail for a subset of users. Error-budget burn is increasing.

### Response

1. Declare Sev2 and assign roles.

   ```text
   Severity: Sev2
   Incident commander: platform lead
   Platform responder: AKS on-call
   Application responder: orders service owner
   Communications: incident commander
   Customer impact: partial order API failure
   ```

2. Capture current state.

   ```bash
   kubectl get pods -n <namespace> -o wide
   kubectl describe pod <pod-name> -n <namespace>
   kubectl logs <pod-name> -n <namespace> --previous
   kubectl get kustomizations -A
   ```

3. Check recent GitOps changes and running image digest.

   ```bash
   kubectl get deployment dotnet-api -n <namespace> -o jsonpath='{.spec.template.spec.containers[0].image}'
   kubectl rollout history deployment dotnet-api -n <namespace>
   ```

4. Identify cause.

   The previous container logs show a configuration exception. The GitOps change updated the image digest and a required environment variable was not present in Key Vault CSI configuration.

5. Mitigate.

   Revert the GitOps commit to the previous known-good digest and allow Flux to reconcile. If a safe configuration-only fix is approved, apply it through GitOps instead.

6. Validate recovery.

   ```bash
   kubectl get pods -n <namespace>
   kubectl rollout status deployment dotnet-api -n <namespace>
   kubectl get kustomizations -A
   ```

7. Close when:

   - `dotnet-api` replicas are ready.
   - `node-web` order flow succeeds.
   - Error rate returns below threshold for 30 minutes.
   - The incident channel has a final update.
   - Corrective actions are assigned.

## Corrective actions

| Action | Owner | Due |
| --- | --- | --- |
| Add pre-release configuration validation for required Key Vault CSI values. | Service owner | Next sprint |
| Add alert link to CrashLoopBackOff runbook. | Platform owner | 7 days |
| Add release checklist item for environment variable changes. | Delivery lead | 7 days |
