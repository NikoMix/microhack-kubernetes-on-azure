# M01 facilitator guide · Kubernetes and AKS foundations

Use this guide to lead the 09:30 foundations lab and collect B.1.1 evidence.

## Timing breakdown

| Time | Activity | Facilitation mode |
| --- | --- | --- |
| 5 min | Recap M0 context and frame B.1.1 evidence | Demo |
| 8 min | AKS versus vanilla Kubernetes primer | Demo with questions |
| 8 min | Node pools, namespaces, and add-ons exploration | Learner drive |
| 8 min | Entra ID, Azure RBAC, and Kubernetes RBAC discussion | Demo then drive |
| 10 min | Copilot plus Microsoft Docs MCP certification planning | Learner drive |
| 4 min | Review validation checklist and evidence quality | Group review |
| 2 min | Transition to assessment module | Demo |

Total: 45 minutes.

## Talking points

- AKS is Kubernetes plus Azure-managed operations, identity, networking, policy, and observability integration.
- Node pool mode matters: system pools host critical platform pods, while user pools host application workloads.
- Namespaces are not hard multi-tenant boundaries by themselves; they are a scoping and organization tool.
- Azure RBAC and Kubernetes RBAC are related but not interchangeable. Slow down here for newer learners.
- The certification mapping is delivery evidence, not HR paperwork. It proves the engagement team has a credible skills plan.

## Common pitfalls and fixes

| Pitfall | Symptom | Fix |
| --- | --- | --- |
| Azure RBAC and Kubernetes RBAC are conflated | Learner cannot tell why `az role assignment` differs from `RoleBinding` | Draw the boundary: Azure resource authorization first, Kubernetes API authorization inside the cluster. |
| Namespace scope is misunderstood | Learner expects namespace permissions to apply cluster-wide | Show `Role` versus `ClusterRole` and run `kubectl auth can-i` with `--namespace`. |
| Learners edit shared cluster resources too early | Unexpected objects appear in `default` or `kube-system` | Keep required steps read-only and reserve writes for the stretch goal with trainer approval. |
| Certification plan is generic | Evidence lacks names, dates, or target exams | Require two named FTEs, exam codes, dates, and study resources before accepting evidence. |
| Copilot answer is not grounded | Agent gives broad advice without references | Ask the learner to explicitly use Microsoft Docs MCP and cite the certification or AKS documentation used. |

## Demo-vs-drive guidance

- Demo the AKS versus Kubernetes architecture once, using the primer diagram.
- Let learners drive `kubectl` exploration because command familiarity is part of readiness.
- Demo one `kubectl auth can-i` query, then have learners run the remaining checks.
- Let learners drive Copilot certification planning, but inspect the final map for evidence completeness.

## Cohort-split tips

- Newer learners should use the primer and kubectl cheat sheet before interpreting output.
- Experienced learners can take the stretch goal and coach tablemates on RoleBinding scope.
- Pair an experienced Kubernetes learner with a learner who knows Azure identity so both RBAC layers are covered.

## Evidence the trainer collects

Collect B.1.1 evidence for [trainer scoring](../../trainer-guide/scoring.md):

- Completed 2-FTE certification mapping with names, roles, target certs, exam codes, target dates, and study resources.
- Readiness or study plan with timeline, skill gaps, hands-on practice, and readiness checks.
- Short learner explanation of AKS-managed control plane, namespaces, and RBAC distinction.
- Optional stretch-goal command output for namespace and least-privilege RoleBinding.
