---
marp: true
theme: microhack
paginate: true
footer: "Kubernetes on Azure - Module B MicroHack"
---

<!-- _class: lead -->
<!-- _paginate: false -->

# M2 · Assessment

## Control B.2.1 · 60 min

Polyglot workload assessment, dependency map and remediation backlog

<!-- Speaker note: This module shifts from platform basics to customer discovery discipline. -->

---

# Objectives

- Assess the polyglot sample application
- Identify upstream and downstream dependencies
- Capture data flows, network paths, state and secrets
- Prioritise remediation by risk and effort
- Produce B.2.1 evidence artifacts

<!-- Speaker note: The goal is not to find every code smell. It is to create a credible migration and modernization backlog. -->

---

# Primer refresher

The sample application includes:

- .NET 10 Minimal API for orders
- Python 3.14 FastAPI worker
- Node 24 Fastify web BFF
- OpenTelemetry to Azure Monitor
- Config via environment and Key Vault CSI

<!-- Speaker note: Explain the app shape enough for non-developers to understand dependencies. Avoid deep code walkthroughs. -->

---

# Assessment lens

| Area | What to capture |
| --- | --- |
| Services | APIs, workers, front doors |
| Data | State, queues, persistence |
| Network | Ingress, egress, service calls |
| Secrets | Source, rotation, access path |
| Runtime | Health, metrics, resource needs |

<!-- Speaker note: Use this as the interview checklist. If a learner cannot place a dependency in this table, probe further. -->

---

# Azure Migrate concepts

- Discovery before dependency mapping
- Readiness before migration waves
- Risk drives sequencing
- Remediation backlog bridges assessment to design
- Evidence must be explainable to stakeholders

<!-- Speaker note: We are not running a full Azure Migrate appliance here; we borrow its assessment thinking and language. -->

---

# Walkthrough outline

1. Review app services and runtime contracts
2. Trace service-to-service calls
3. Capture data flow and state assumptions
4. Locate configuration and secrets patterns
5. Identify AKS readiness gaps
6. Rank remediation items by risk and effort
7. Export dependency map and backlog

<!-- Speaker note: Let teams drive the map. Demo only how to start and how to judge a good backlog item. -->

---

# Dependency map evidence

Must include:

- Upstream and downstream services
- Data flows
- Network paths
- Stateful components
- Secret sources and consumers
- Observability dependencies

<!-- Speaker note: A box-and-arrow sketch is acceptable if it captures the required content clearly. -->

---

# Remediation backlog evidence

Each item should include:

- Finding
- Impacted service
- Risk
- Effort
- Priority
- Suggested owner
- Link to design consideration

<!-- Speaker note: Push learners away from vague items like "fix security". Evidence needs actionable backlog rows. -->

---

# Copilot + MCP

| Item | Used for |
| --- | --- |
| `workload-assessment` skill | Dependency map + backlog draft |
| Azure MCP | Target platform constraints |
| Microsoft Docs MCP | AKS migration guidance |

<!-- Speaker note: If the skill is unavailable, run the same prompts manually and fill the templates by inspection. -->

---

# Facilitator pitfalls

- Mapping only containers, not dependencies
- Missing state and secrets
- Confusing findings with remediations
- Prioritising by preference instead of risk
- Producing a diagram with no backlog traceability

<!-- Speaker note: The most common miss is secrets. Ask explicitly where each service gets configuration and credentials. -->

---

# Validation checklist

- Dependency map completed → B.2.1
- Upstream/downstream services listed → B.2.1
- Data, network, state and secrets captured → B.2.1
- Remediation backlog prioritised → B.2.1
- Effort and risk assigned per item → B.2.1

<!-- Speaker note: Score for completeness and prioritisation, not artistic diagram quality. -->

---

# Drive it yourself

```text
Invoke the workload-assessment skill for the Module B polyglot app.
Create a dependency map covering services, data flows, network, state,
secrets and observability. Then create a prioritised remediation backlog
with risk and effort for B.2.1 evidence.
```

<!-- Speaker note: Have teams challenge the generated backlog. The trainer should ask: what would you fix before design sign-off? -->
