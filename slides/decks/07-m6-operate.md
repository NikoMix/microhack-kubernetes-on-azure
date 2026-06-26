---
marp: true
theme: microhack
paginate: true
footer: "Kubernetes on Azure - Module B MicroHack"
---

<!-- _class: lead -->
<!-- _paginate: false -->

# M6 · Operate

## Control B.5.2 · 45 min

CI/CD lifecycle, SLO/SLA, runbook, platform currency and growth planning

<!-- Speaker note: This module completes the engagement by handing over an operating model. -->

---

# Objectives

- Document the CI/CD lifecycle
- Define SLO/SLA tracking
- Build a Sev1/Sev2 triage runbook
- Define platform currency processes
- Plan capacity and feature growth
- Use Container Insights dashboards and alerts

<!-- Speaker note: B.5.2 evidence is all five operations artifacts plus observability. Do not skip any. -->

---

# Primer refresher

Operations means:

- Know what changed
- Know what broke
- Know who acts
- Know when to upgrade
- Know when to scale
- Know how to prove service health

<!-- Speaker note: Use plain language before introducing process names. -->

---

# CI/CD lifecycle evidence

```text
build -> test -> scan -> sign -> deploy via GitOps
```

- Image provenance
- Security gates
- GitOps reconciliation
- Promotion between environments
- Rollback path

<!-- Speaker note: The lifecycle doc should be understandable by both app and platform teams. -->

---

# SLO/SLA tracking

| Item | Example source |
| --- | --- |
| Availability | Azure Monitor / Container Insights |
| Latency | App metrics / traces |
| Error rate | Logs and metrics |
| Incident trend | Work item or ITSM system |
| Budget impact | Cost report and alerts |

<!-- Speaker note: Separate SLOs the team controls from contractual SLAs promised to the customer. -->

---

# Triage runbook

Must include:

- Sev1 and Sev2 definitions
- First 15-minute actions
- Cluster health checks
- Workload health checks
- Escalation path
- Communication cadence
- Evidence to capture

<!-- Speaker note: Make it runnable under pressure. A runbook full of theory will not help during an incident. -->

---

# Platform currency

- AKS version review cadence
- Node image upgrades
- Add-on and extension updates
- Policy and Defender updates
- Base image patching
- Maintenance windows and rollback plan

<!-- Speaker note: Currency is often forgotten after go-live. Tie it to reliability and security risk. -->

---

# Growth planning

- Node pool scaling strategy
- Namespace and team onboarding model
- Network and IP capacity
- Observability cost growth
- Workload identity and secret growth
- Future environment strategy

<!-- Speaker note: Growth planning is not only more nodes. It includes people, governance and operational cost. -->

---

# Container Insights

- Cluster health dashboards
- Node and pod resource views
- Log Analytics queries
- Alerts for saturation and failures
- Evidence for SLO review

<!-- Speaker note: Show where operators start their investigation. Connect dashboards to runbook steps. -->

---

# Copilot + MCP

| Item | Used for |
| --- | --- |
| `runbook` skill | Triage and operations docs |
| `as-built` skill | Current deployed-state context |
| Azure MCP | Metrics, resources and config facts |
| Microsoft Docs MCP | AKS operations guidance |

<!-- Speaker note: Ask Copilot to draft, then test the runbook against a realistic incident prompt. -->

---

# Facilitator pitfalls

- Writing operations docs as generic templates
- Missing one of the five required evidence areas
- No Sev1/Sev2 distinction
- No upgrade or patch cadence
- Dashboards exist but alerts are not discussed

<!-- Speaker note: Keep asking: who acts, when, using which signal? -->

---

# Validation checklist

- CI/CD lifecycle documented → B.5.2
- SLO/SLA tracking documented → B.5.2
- Sev1/Sev2 triage runbook created → B.5.2
- Platform currency process defined → B.5.2
- Growth planning completed → B.5.2
- Container Insights dashboards/alerts referenced → B.5.2

<!-- Speaker note: B.5.2 requires all five artifacts. Partial operations packs should be marked incomplete. -->

---

# Drive it yourself

```text
Invoke the runbook skill for the Module B AKS deployment.
Use Azure MCP and the as-built context to create B.5.2 evidence:
CI/CD lifecycle, SLO/SLA tracking, Sev1/Sev2 triage runbook,
platform currency process, growth plan, and Container Insights alerts.
```

<!-- Speaker note: Close by asking teams which operational risk they would review with a customer first. -->
