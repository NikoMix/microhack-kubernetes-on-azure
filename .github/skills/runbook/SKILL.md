---
name: runbook
description: >-
  Generate Module B.5.2 operational documentation for an AKS workload: incident-triage runbooks
  and a platform-currency (lifecycle/upgrade) plan, plus the CI/CD + SLA/SLO operations record.
  Use when writing triage or operational runbooks, an on-call guide, a Kubernetes/node-image
  upgrade plan, or generating the B.5.2 post-deployment evidence.
---

# Runbook (B.5.2 Post-deployment Documentation)

Produce the operational documentation an auditor expects for **B.5.2**: incident **triage
runbooks**, a **platform-currency** plan (keeping AKS and node images current), and the CI/CD +
SLA/SLO operating record. This is the M6 deliverable (with `as-built`).

> Evidence requirements: [references/evidence-checklist.md](references/evidence-checklist.md).
> B.5.2 needs **3 customers**: CI/CD + post-deployment operations (SLA, triage, growth/currency).

## Workflow

1. **Map the service.** Components, owners, dashboards (Container Insights / Grafana), alert
   rules, escalation paths, and the SLOs from `test-plan` (B.5.1).
2. **Write triage runbooks** with [assets/triage-runbook-template.md](assets/triage-runbook-template.md).
   Ship these by default: pod CrashLoopBackOff, image-pull failure, node NotReady, OOMKilled,
   ingress 5xx, certificate expiry, Workload Identity token failure, PVC/CSI mount failure,
   Defender for Containers alert. Each includes detect → diagnose → mitigate → verify → rollback.
3. **Cluster-lifecycle runbooks.** cordon-and-drain, node-image upgrade, control-plane upgrade,
   blue/green cluster cutover, secret rotation (CSI), cert renewal, Backup-for-AKS restore drill.
4. **Platform-currency plan.** Fill
   [assets/platform-currency-template.md](assets/platform-currency-template.md): Kubernetes
   version support policy (N-2), auto-upgrade channels, maintenance windows, deprecated-API
   tracking, add-on/extension currency, dependency & image patch cadence (zero known vulns).
5. **CI/CD + SLA record.** Point to `.github/workflows/` as the CI/CD evidence (build, scan,
   CodeQL, IaC validate, image scan) and document the SLA/SLO, on-call, and growth plan.
6. **Export** anonymised: `B5.2_TriageRunbook_CustomerA_v1.pdf`,
   `B5.2_PlatformCurrency_CustomerA_v1.pdf`, `B5.2_OpsRecord_CustomerA_v1.pdf`.

## Runbook quality bar

Every runbook states: **prerequisites, blast radius, dry-run, rollback path, observability
checks** (Container Insights / Prometheus queries), **customer comms**, and a **sign-off** step.

## Modular AI inference

If an AI capability is operated, add triage steps for provider failover (Azure AI Foundry /
Azure OpenAI / GitHub Models, no image gen) and token/quota exhaustion; keys must come from
Key Vault / Workload Identity, never config.

## Learn More

| Topic | How to find |
|---|---|
| AKS upgrade & maintenance | `microsoft_docs_fetch(url="https://learn.microsoft.com/azure/aks/upgrade-cluster")` |
| AKS supported versions | `microsoft_docs_search(query="AKS supported Kubernetes versions support policy")` |
| Container Insights queries | `microsoft_docs_search(query="Container Insights log queries KQL AKS")` |
| Backup for AKS | `microsoft_docs_search(query="Azure Backup for AKS restore")` |

### CLI alternative

| MCP Tool | CLI Command |
|----------|-------------|
| `microsoft_docs_search(query: "...")` | `mslearn search "..."` |
| `microsoft_code_sample_search(query: "...", language: "...")` | `mslearn code-search "..." --language ...` |
| `microsoft_docs_fetch(url: "...")` | `mslearn fetch "..."` |

Run with `npx @microsoft/learn-cli <command>` or install globally via `npm install -g @microsoft/learn-cli`.
