# M6 · Operate & document

Turn a deployed AKS secure baseline into a documented day-2 operating model that trainers can score against control B.5.2.

## Lab metadata

| Item | Detail |
| --- | --- |
| Duration | 45 minutes |
| Control | B.5.2 — Post-deployment documentation |
| Evidence produced | CI/CD lifecycle, SLO/SLA tracking, triage runbook, platform-currency process, growth plan, Container Insights dashboards and alerts |
| You will | Document operations, define service targets, write incident triage steps, plan AKS currency, plan growth, and wire monitoring evidence |

## Prerequisites

- M0 completed with Azure access, `az`, `kubectl`, and repository tooling verified.
- The deployed environment from the curriculum contracts is available or represented by placeholders:
  - `infra/` AKS secure baseline in West Europe with Container Insights, Managed Prometheus, Grafana, Defender for Containers, Azure Policy, Log Analytics, and diagnostic settings.
  - `gitops/` Flux v2 app-of-apps reconciling from `main`.
  - `apps/` microservices emitting OpenTelemetry to Azure Monitor and exposing health endpoints.
- Access to the AKS cluster, Log Analytics workspace, Azure Monitor alerts, and the GitOps repository.
- Use placeholders until Azure MCP or `az` resolves concrete values: `<subscription-id>`, `<resource-group>`, `<cluster-name>`, `<acr-login-server>`, and `<workspace-id>`.

## Primer / concepts

Day-2 operations start after deployment. Your goal is to make the platform supportable: everyone knows how releases flow, what healthy service behaviour means, how to triage incidents, when to upgrade AKS, and how growth will be handled.

A runbook is a repeatable operating procedure. It says when to use it, what symptoms to check, what commands or dashboards to inspect, who owns each action, and when to escalate. A good runbook reduces stress during incidents because responders do not invent the process while the service is impaired.

An SLO is a measurable service reliability target, such as 99.5 percent successful requests over 30 days. An SLA is the customer-facing commitment and may include contractual consequences. SLIs are the measurements behind the SLO, such as availability, latency, error rate, saturation, or freshness.

Platform currency keeps AKS supported and secure. AKS support follows a version skew policy where supported Kubernetes minor versions are bounded; teams commonly plan around current minus two minor versions, often called N-2. If you fall outside the support window, upgrades become urgent, add-ons drift, and node images may miss security fixes. Confirm the current policy with Microsoft Docs MCP during delivery.

For a refresher, use the docs references at `/references/primer/`, `/references/kubectl-cheat-sheet/`, `/references/copilot-mcp/`, and `/references/glossary/`.

### Stretch goal

If you finish early, add a planned-maintenance configuration proposal, or run a cost-optimization review that compares current node pool, autoscaler, and Log Analytics ingestion settings against projected growth.

## Copilot + MCP usage

> Invoke the `runbook` and `as-built` skills via the AKS Engagement Copilot. If the skills are unavailable, follow the manual steps in this lab. Use Azure MCP for Container Insights, Azure Monitor, alert rules, and cluster state. Use Microsoft Docs MCP for AKS upgrade and support-policy guidance.

Example prompt for the AKS Engagement Copilot:

```text
Use the runbook and as-built skills for Module B control B.5.2. Draft post-deployment operations documentation for the AKS secure baseline. Include CI/CD lifecycle build→test→scan→sign→deploy via Flux GitOps, SLO/SLA tracking with error budgets, Sev1/Sev2 triage for nodes NotReady, CrashLoopBackOff, ingress down, and image pull failures, platform-currency cadence for AKS upgrades, node images, add-ons, and patches, growth planning, and Container Insights dashboard and alert evidence. Use Azure MCP for live cluster and Monitor details, and Microsoft Docs MCP for AKS support and upgrade policy.
```

## Step-by-step instructions

1. Resolve environment values.

   Use Azure MCP or run read-only commands to capture the cluster and monitoring context. Keep values in your notes; do not hard-code them into reusable templates.

   ```bash
   az account show --query '{subscriptionId:id, tenantId:tenantId, name:name}' --output table
   az aks show --resource-group <resource-group> --name <cluster-name> --query '{name:name,kubernetesVersion:kubernetesVersion,nodeResourceGroup:nodeResourceGroup}' --output table
   az monitor log-analytics workspace show --resource-group <resource-group> --workspace-name <workspace-name> --query '{name:name,customerId:customerId,retentionInDays:retentionInDays}' --output table
   ```

2. Document the CI/CD lifecycle.

   Open `assets/cicd-lifecycle.md` and complete the narrative for the deployed contract: build container images, run tests, scan images and manifests, sign artifacts, update the GitOps desired state, and let Flux reconcile into AKS.

   Include or adapt this diagram in the document:

   ```mermaid
   flowchart LR
     A[Developer merge to main] --> B[Build images]
     B --> C[Test application and manifests]
     C --> D[Scan images and IaC]
     D --> E[Sign images and attestations]
     E --> F[Update GitOps desired state]
     F --> G[Flux reconcile]
     G --> H[AKS workloads running]
   ```

   Reference the source contracts with GitHub URLs, for example `https://github.com/NikoMix/microhack-kubernetes-on-azure/tree/main/gitops`.

3. Define SLO/SLA tracking.

   Open `assets/slo-sla-tracking.md`. Select the SLIs that matter for the microservices: availability, latency, error rate, saturation, and job freshness. Set SLO targets, explain whether an SLA exists, and define an error-budget policy.

   Use Container Insights, Managed Prometheus, Azure Monitor, or application telemetry as the measurement source.

4. Author the triage runbook.

   Open `assets/triage-runbook.md`. Define Sev1 and Sev2 clearly, then add cluster-level triage for these conditions:

   - Nodes `NotReady`.
   - Pods `CrashLoopBackOff`.
   - Ingress unavailable or returning errors.
   - Image pull failures.

   Include escalation paths, communications, evidence capture, mitigation, recovery validation, and post-incident review steps. Use `solutions/triage-runbook-example.md` only if the facilitator allows trainer reference material to be shown.

5. Define the platform-currency process.

   Open `assets/platform-currency.md`. Use Microsoft Docs MCP to confirm the current AKS support policy, supported versions, upgrade guardrails, and maintenance-window capabilities. Capture cadence and owners for:

   - AKS Kubernetes version upgrades.
   - Node image upgrades.
   - AKS add-ons and extensions.
   - Operating-system and base-image patches.
   - Policy, Defender, and monitoring-agent updates.

   Suggested read-only discovery commands:

   ```bash
   az aks get-upgrades --resource-group <resource-group> --name <cluster-name> --output table
   az aks nodepool list --resource-group <resource-group> --cluster-name <cluster-name> --query '[].{name:name,version:orchestratorVersion,nodeImageVersion:nodeImageVersion,mode:mode,count:count}' --output table
   ```

6. Write the growth plan.

   Open `assets/growth-planning.md`. Document near-term and longer-term growth across scaling, resilience, data, observability, and cost. Include node pool scaling, HPA, cluster autoscaler, multi-region and disaster-recovery considerations, Azure Monitor ingestion growth, and cost controls.

7. Wire Container Insights dashboards and alert rules.

   Open `assets/container-insights-dashboards.md`. Use Azure MCP to inspect existing dashboards or workbooks and create or update the required views. Add alert rules for node, pod, and ingress health. Include KQL samples and severity mappings.

   Example KQL for unavailable nodes:

   ```kusto
   KubeNodeInventory
   | where TimeGenerated > ago(15m)
   | summarize LastState=max(TimeGenerated), Ready=maxif(Status, Status == "Ready") by ClusterName, Computer
   | where isempty(Ready)
   ```

8. Package the evidence.

   Ensure your final lab folder contains these learner artifacts:

   - `assets/cicd-lifecycle.md`
   - `assets/slo-sla-tracking.md`
   - `assets/triage-runbook.md`
   - `assets/platform-currency.md`
   - `assets/growth-planning.md`
   - `assets/container-insights-dashboards.md`

   Trainer-only references live under `solutions/`.

## Validation checklist

- [ ] CI/CD lifecycle document covers build→test→scan→sign→deploy via Flux GitOps. → B.5.2: CI/CD lifecycle.
- [ ] SLO/SLA tracking defines SLIs, SLO targets, SLA stance, error budgets, owners, and review cadence. → B.5.2: SLO/SLA tracking.
- [ ] Triage runbook includes Sev1/Sev2 definitions, cluster-level procedures, evidence capture, escalation, and recovery validation. → B.5.2: triage runbook.
- [ ] Platform-currency process covers AKS version upgrades, node image upgrades, add-ons, OS patches, cadence, owners, and maintenance windows. → B.5.2: platform-currency process.
- [ ] Growth plan covers scaling, resilience, DR, observability growth, and cost growth. → B.5.2: growth planning.
- [ ] Container Insights dashboards and alert rules are documented or configured for node, pod, and ingress health. → B.5.2: dashboards and alerts.

## Success criteria

You can explain how the deployed AKS platform is released, monitored, triaged, upgraded, and scaled. Another engineer can use your documents to support the environment without relying on tribal knowledge.

## What you produced

- A CI/CD lifecycle document with a valid Mermaid diagram.
- An SLO/SLA tracking model with error-budget policy.
- A Sev1/Sev2 triage runbook for common AKS cluster failures.
- A platform-currency process for AKS and supporting components.
- A growth plan covering scale, DR, and cost.
- Container Insights dashboard and alert definitions.

## Clean-up note

Do not tear down the environment during this lab. Defer cleanup to the end-of-day instructions and the repository `scripts/teardown` contract.

## Next module

This is the final hands-on module. Continue to the wrap-up, evidence review, and scoring guidance in `../../trainer-guide/scoring.md`.
