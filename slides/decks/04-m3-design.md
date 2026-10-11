---
marp: true
theme: microhack
paginate: true
footer: "Kubernetes on Azure - Module B MicroHack"
---

<!-- _class: lead -->
<!-- _paginate: false -->

# M3 · Design

## Controls B.3.1 / B.3.2 · 90 min

AKS landing-zone HLD and Well-Architected Review

<!-- Speaker note: This is the largest thinking module. Protect time for both HLD and WAR evidence. -->

---

# Objectives

- Create an AKS landing-zone high-level design
- Cover every required design area
- Generate an architecture diagram
- Run WAR for Reliability and Security
- Prioritise design and WAR backlog items

<!-- Speaker note: Tell learners that B.3.1 and B.3.2 are scored separately, even though they share design context. -->

---

# Primer refresher

A landing-zone HLD answers:

- Where does AKS live?
- Who can access it?
- How does traffic flow?
- How are workloads secured?
- How is the platform observed and upgraded?

<!-- Speaker note: Newcomers may think design equals diagram. Reinforce that the HLD explains decisions and trade-offs. -->

---

# Required design areas

- Identity and RBAC
- Network topology and ingress/egress
- Cluster and node pool strategy
- Security, policy and secrets
- Observability and diagnostics
- GitOps and release flow
- Resilience, backup and upgrade posture
- Cost, governance and tagging

<!-- Speaker note: Use this as a checklist against the HLD. Missing one area weakens B.3.1 evidence. -->

---

# Secure baseline anchors

- Entra ID + Azure RBAC
- Workload Identity and OIDC issuer
- Azure CNI Overlay
- Azure Firewall egress
- Defender for Containers
- Azure Policy for AKS
- Key Vault CSI Secret Store
- Container Insights, Prometheus and Grafana

<!-- Speaker note: These are contract anchors from the curriculum spec. Use placeholders until lab-time values are resolved. -->

---

# Walkthrough outline

1. Review M2 assessment findings
2. Select target design assumptions
3. Invoke `hld-generator`
4. Review all design areas
5. Create or refine architecture diagram
6. Invoke `war-runner`
7. Prioritise Reliability and Security backlog

<!-- Speaker note: Demo prompt structure, then let teams review and edit the design. The human review is the learning moment. -->

---

# Architecture in slides

Use simple shapes or ASCII in slides:

```text
Users -> Ingress -> AKS Services -> Pods
             |          |
             v          v
        App Gateway   Key Vault CSI
             |
        Azure Firewall -> Required egress
```

<!-- Speaker note: Keep slide diagrams as simple text. The lab artifacts may use richer diagram formats elsewhere. -->

---

# WAR focus

| Pillar | Questions to ask |
| --- | --- |
| Reliability | Failure modes, scaling, upgrades, recovery |
| Security | Identity, secrets, network, policy, image risk |

- Capture rationale
- Do not accept generic recommendations
- Turn findings into a prioritised backlog

<!-- Speaker note: WAR evidence needs rationale. A raw score without reasoning is not sufficient. -->

---

# Copilot + MCP

| Item | Used for |
| --- | --- |
| `hld-generator` skill | HLD and design coverage |
| `war-runner` skill | Reliability + Security review |
| Azure MCP | Platform facts and constraints |
| Microsoft Docs MCP | Design guidance grounding |

<!-- Speaker note: Ask Copilot to cite assumptions and unresolved questions. That makes review easier. -->

---

# Facilitator pitfalls

- Letting Copilot output pass unreviewed
- Missing design areas outside networking
- Using real resource names too early
- Treating WAR as a compliance checkbox
- Producing a diagram with no decision narrative

<!-- Speaker note: Pause after the first HLD draft. Ask each team to name one design trade-off and one risk. -->

---

# Validation checklist

- Design document completed → B.3.1
- Architecture diagram completed → B.3.1
- All design areas covered → B.3.1
- WAR export for Reliability created → B.3.2
- WAR export for Security created → B.3.2
- Pillar rationale and prioritised backlog included → B.3.2

<!-- Speaker note: This is a key scoring checkpoint. Collect both HLD and WAR outputs before lunch if possible. -->

---

# Drive it yourself

```text
Invoke hld-generator for the Module B AKS secure baseline.
Use the M2 assessment findings and cover identity, networking, node pools,
security, policy, secrets, observability, GitOps, resilience, cost and governance.
Then invoke war-runner for Reliability and Security with rationale and backlog.
```

<!-- Speaker note: Encourage teams to challenge assumptions before accepting the final backlog. -->
