# Readiness plan example

Trainer-only example for B.1.1 readiness evidence.

## Team readiness summary

- **Engagement team:** AKS delivery pod for Module B customer engagements
- **Date prepared:** 2026-06-26
- **Prepared by:** Trainer reference
- **Overall readiness goal:** Two FTEs can explain AKS foundations, operate core Kubernetes resources, and support cross-platform Kubernetes conversations.

## FTE 1 plan

| Field | Detail |
| --- | --- |
| Name and role | Aisha Khan / AKS Platform Engineer |
| Target certification | Certified Kubernetes Administrator |
| Current strengths | Azure networking, Linux operations, incident response |
| Skill gaps | Kubernetes scheduling, cluster troubleshooting, etcd concepts |
| Weekly study commitment | 5 hours per week for 6 weeks |
| Hands-on practice plan | Complete cluster administration labs, node maintenance drills, and `kubectl` troubleshooting scenarios |
| Target exam or course date | CKA on 2026-08-14 |
| Readiness check | Two timed practice exams above 80% and trainer-observed troubleshooting walkthrough |

## FTE 2 plan

| Field | Detail |
| --- | --- |
| Name and role | Mateo Silva / Application Modernization Engineer |
| Target certification | CKAD plus OpenShift EX280 |
| Current strengths | .NET microservices, CI/CD, container build pipelines |
| Skill gaps | Kubernetes RBAC, probes, resource limits, OpenShift routes and security context constraints |
| Weekly study commitment | 4 hours per week for 8 weeks |
| Hands-on practice plan | Deploy and debug workloads, write manifests, practice Helm or Kustomize overlays, complete OpenShift administration labs |
| Target exam or course date | CKAD and EX280 by 2026-09-04 |
| Readiness check | Application deployment practical completed in 45 minutes and OpenShift practice review with trainer |

## Four-week study schedule

| Week | Focus | Practice | Evidence |
| --- | --- | --- | --- |
| Week 1 | Kubernetes objects, namespaces, and `kubectl` orientation | Inspect AKS cluster, write basic manifests | Command notes and glossary |
| Week 2 | Scheduling, node pools, probes, and resource requests | Deploy workloads with readiness and liveness probes | Working deployment manifest |
| Week 3 | RBAC, configuration, secrets, and troubleshooting | Build least-privilege RoleBinding and debug failed pods | `kubectl auth can-i` output and troubleshooting notes |
| Week 4 | Exam readiness and cross-platform OpenShift concepts | Timed practice tasks and OpenShift comparison review | Practice score and trainer sign-off |

## Trainer follow-up

- Review date: 2026-07-24
- Risks or blockers: Exam booking availability and limited OpenShift lab access
- Support needed: Shared study calendar, office hours, and access to practice clusters
- Ready-for-delivery decision: Conditionally ready after Week 4 practice evidence is reviewed
