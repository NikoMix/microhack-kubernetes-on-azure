---
marp: true
theme: microhack
paginate: true
footer: "Kubernetes on Azure - Module B MicroHack"
---

<!-- _class: lead -->
<!-- _paginate: false -->

# M1 · Foundations

## Control B.1.1 · 45 min

AKS vs Kubernetes, namespaces, RBAC, kubectl and certification readiness

<!-- Speaker note: This module creates shared vocabulary before assessment and design. -->

---

# Objectives

- Explain AKS responsibilities vs upstream Kubernetes
- Use namespaces, RBAC and `kubectl` safely
- Map CKA, CKAD, optional CKS and OpenShift paths
- Produce a 2-FTE certification mapping
- Produce a readiness and study plan

<!-- Speaker note: Tie objectives directly to B.1.1 evidence: named roles, target certs and study plan. -->

---

# Primer refresher

- Kubernetes schedules containers into pods
- Services give stable network access
- Namespaces separate teams and environments
- RBAC controls who can do what
- AKS manages control-plane operations for you

<!-- Speaker note: Keep this simple. Newcomers need the mental model; experts can supply examples. -->

---

# AKS vs Kubernetes

| Area | Kubernetes | AKS adds |
| --- | --- | --- |
| Control plane | API and controllers | Managed service |
| Identity | Service accounts/RBAC | Entra ID + Azure RBAC |
| Networking | CNI patterns | Azure CNI Overlay options |
| Policy | Admission controls | Azure Policy for AKS |
| Monitoring | Metrics/logs integrations | Container Insights |

<!-- Speaker note: Stress shared responsibility. Managed does not mean unmanaged by the platform team. -->

---

# kubectl essentials

```bash
kubectl get nodes
kubectl get pods -A
kubectl auth can-i list pods -n default
kubectl describe pod <pod-name> -n <namespace>
```

- Read before changing
- Scope commands by namespace
- Use `auth can-i` before assuming access

<!-- Speaker note: Trainers should model safe inspection. Avoid making destructive kubectl commands part of foundations. -->

---

# Certification map

| Role | Target |
| --- | --- |
| Platform engineer | CKA |
| App engineer | CKAD |
| Security specialist | CKS optional |
| OpenShift practitioner | DO280 / EX280 |

<!-- Speaker note: The evidence requires two named FTEs. This slide provides the options, not the final answer. -->

---

# 2-FTE readiness plan

- Name the two roles
- Pick target certifications
- Assess current Kubernetes experience
- Identify study hours and blockers
- Schedule practice labs and exam windows
- Include OpenShift cross-platform coverage if relevant

<!-- Speaker note: Make learners write a plan that a manager could approve. Not just a list of exam codes. -->

---

# Copilot + MCP

- Skill: agent Q&A
- MCP: Microsoft Docs
- Accelerates concept explanations and study planning
- Use it to verify current cert names and learning paths
- Manual fallback: Microsoft Learn and CNCF exam guides

<!-- Speaker note: This is a low-risk place to show Copilot as a tutor. Ask it to explain the same concept at beginner and expert levels. -->

---

# Facilitator pitfalls

- Over-teaching Kubernetes internals
- Treating AKS as only hosted Kubernetes
- Forgetting OpenShift cross-platform option
- Producing generic cert plans with no named roles
- Letting experts dominate primer time

<!-- Speaker note: Keep the module moving. The output is readiness evidence, not a full CKA class. -->

---

# Validation checklist

- 2 named FTE roles mapped to cert targets → B.1.1
- CKA/CKAD considered; CKS optional noted → B.1.1
- OpenShift DO280/EX280 option addressed → B.1.1
- Readiness and study plan created → B.1.1
- Basic AKS/Kubernetes vocabulary demonstrated → B.1.1

<!-- Speaker note: Collect concise artifacts. Screenshots of kubectl are useful, but the scoring artifact is the mapping and plan. -->

---

# Drive it yourself

```text
Use Microsoft Docs MCP to help create a B.1.1 readiness plan
for two named FTE roles: one platform engineer and one app engineer.
Map each role to CKA, CKAD, optional CKS, and OpenShift DO280/EX280
where appropriate. Include study steps and risks.
```

<!-- Speaker note: Ask learners to edit the output. The final plan must match their real cohort or customer scenario. -->
