---
name: test-plan
description: >-
  Produce a Module B.5.1 Service Validation & Testing plan for an AKS workload: load tests,
  chaos/resilience experiments, SLO definition and comparison, and the mandatory customer
  sign-off pack. Use when planning load or chaos testing, defining SLOs/SLIs, comparing measured
  results to targets, or generating the B.5.1 evidence (3 customers, customer sign-off required).
---

# Test Plan (B.5.1 Service Validation & Testing)

Define how the deployed AKS workload is validated against its SLOs, and produce the **customer
sign-off** that B.5.1 mandates. This is the M5 deliverable.

> Evidence requirements: [references/evidence-checklist.md](references/evidence-checklist.md).
> B.5.1 needs **3 customers** and a **signed customer acceptance** — the sign-off is a hard gate.

## Workflow

1. **Define SLIs/SLOs.** Latency (p50/p95/p99), availability, error rate, saturation. Record
   targets and the measurement source (Container Insights, Managed Prometheus, App Gateway).
2. **Plan load tests.** Use **Azure Load Testing** (managed JMeter/Locust). Specify scenarios
   (steady, ramp, soak, spike), virtual users, duration, and pass/fail thresholds tied to SLOs.
3. **Plan chaos/resilience experiments.** Use **Azure Chaos Studio** (or kube-native chaos).
   Cover: pod kill, node drain/cordon, AZ outage, dependency latency/fault, image-pull failure.
   Each experiment states hypothesis, blast radius, abort conditions, and expected steady-state.
4. **Wire safety.** Run against a non-prod overlay; define abort/rollback; confirm PDBs and
   autoscaling are in place before chaos.
5. **Execute & compare.** Capture measured vs. target in the SLO comparison table; attach
   dashboards/exports. Open issues for any SLO miss.
6. **Customer sign-off.** Complete [assets/signoff-template.md](assets/signoff-template.md) with
   results summary, accepted risks, and signatures. **This is required evidence.**
7. **Export** anonymised: `B5.1_TestPlan_CustomerA_v1.pdf`,
   `B5.1_TestResults_CustomerA_v1.pdf`, `B5.1_Signoff_CustomerA_v1.pdf`.

## Output

- Test plan ([assets/test-plan-template.md](assets/test-plan-template.md)), results with SLO
  comparison, and a signed acceptance document.

## Modular AI inference

If an AI endpoint is in scope, include latency/cost/quality SLIs for it and validate that the
provider-agnostic config (Azure AI Foundry / Azure OpenAI / GitHub Models, no image gen) fails
over cleanly between providers.

## Learn More

| Topic | How to find |
|---|---|
| Azure Load Testing | `microsoft_docs_fetch(url="https://learn.microsoft.com/azure/load-testing/overview-what-is-azure-load-testing")` |
| Azure Chaos Studio | `microsoft_docs_search(query="Azure Chaos Studio AKS experiment")` |
| SLO / SLI guidance | `microsoft_docs_search(query="well-architected define reliability targets SLO")` |
| AKS resilience testing | `microsoft_docs_search(query="AKS test resiliency pod node failure")` |

### CLI alternative

| MCP Tool | CLI Command |
|----------|-------------|
| `microsoft_docs_search(query: "...")` | `mslearn search "..."` |
| `microsoft_code_sample_search(query: "...", language: "...")` | `mslearn code-search "..." --language ...` |
| `microsoft_docs_fetch(url: "...")` | `mslearn fetch "..."` |

Run with `npx @microsoft/learn-cli <command>` or install globally via `npm install -g @microsoft/learn-cli`.
