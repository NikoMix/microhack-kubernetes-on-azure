---
mode: agent
description: Drive Module M5 (B.5.1 Service Validation & Testing) — build a load + chaos test plan, compare SLOs, and capture sign-off.
tools: ['codebase', 'search', 'fetch']
---

# Module M5 — Service Validation & Testing

## Goal

Validate the delivered service against its targets through load and chaos testing and obtain customer
sign-off. This module maps 1:1 to Module B control **B.5.1 (Service Validation & Testing)**.

## Deliverable

- A load + chaos test plan.
- An SLO comparison (measured vs. target).
- A customer sign-off record.

## Use the agent and skill

- Drive this lab with the **AKS Engagement Copilot** agent: [`.github/agents/aks-engagement-copilot.agent.md`](../agents/aks-engagement-copilot.agent.md).
- Build the plan with the **Test Plan** skill: [`.github/skills/test-plan/SKILL.md`](../skills/test-plan/SKILL.md).

## Steps with Copilot

1. Ask Copilot to read [`challenges/05-validate/README.md`](../../challenges/05-validate/README.md) and
   the M3 SLO targets.
2. Invoke the Test Plan skill to define load scenarios (throughput, latency, scale) and chaos
   experiments (node, pod, dependency failure).
3. Execute the plan against the deployed apps and collect telemetry from Azure Monitor / Container
   Insights and Managed Prometheus.
4. Have Copilot produce an SLO comparison table (measured vs. target) and flag any breaches with
   remediation notes.
5. Capture the customer sign-off and export all artifacts into
   [`challenges/05-validate/solutions/`](../../challenges/05-validate/solutions/).

## MCP server calls

- `azure`: query Monitor / Prometheus metrics and cluster health during tests.
- `microsoft.docs.mcp`: confirm load and chaos testing guidance for AKS.
- `github`: record test runs and the sign-off in the M5 lab issue.

## Validation / evidence

- [ ] Load + chaos test plan documents scenarios, tooling, and pass criteria.
- [ ] SLO comparison shows measured vs. target with breach analysis.
- [ ] Customer sign-off recorded.
- [ ] M5 lab issue references B.5.1 and links the evidence.
