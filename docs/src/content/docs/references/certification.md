---
title: "Certification map"
description: >-
  CKA, CKAD and Red Hat OpenShift mapping and study resources.
---

## Why certification evidence matters

B.1.1 requires a two-FTE readiness story. The goal is not to make everyone certified during the MicroHack. The goal is to show that the delivery team has named people, clear target certifications, and a realistic study plan for Kubernetes and AKS engagements.

## Certification comparison

| Certification or course | What it covers | Best suited for | Official resource |
| --- | --- | --- | --- |
| CKA | Cluster architecture, workloads, services, storage, troubleshooting, security basics, cluster maintenance | Platform engineers and trainers who operate Kubernetes clusters | [Certified Kubernetes Administrator](https://training.linuxfoundation.org/certification/certified-kubernetes-administrator-cka/) |
| CKAD | Application design, configuration, multi-container pods, observability, services, networking, state, pod security context | App engineers and trainers who build and support workloads on Kubernetes | [Certified Kubernetes Application Developer](https://training.linuxfoundation.org/certification/certified-kubernetes-application-developer-ckad/) |
| CKS optional | Runtime security, cluster setup hardening, supply-chain security, monitoring, logging, vulnerability reduction | Security-focused platform engineers after CKA | [Certified Kubernetes Security Specialist](https://training.linuxfoundation.org/certification/certified-kubernetes-security-specialist/) |
| Red Hat DO180 | Containers, Kubernetes basics, and OpenShift introduction | Learners newer to containers or teams that also deliver OpenShift | [Red Hat OpenShift I: Containers and Kubernetes](https://www.redhat.com/en/services/training/do180-red-hat-openshift-i-containers-kubernetes) |
| Red Hat DO280 | OpenShift administration, cluster access, application deployment, networking, storage, templates, operators | Platform engineers who need cross-platform Kubernetes and OpenShift fluency | [Red Hat OpenShift Administration II](https://www.redhat.com/en/services/training/do280-red-hat-openshift-administration-ii-operating-production-kubernetes-cluster) |
| Red Hat EX280 | Performance-based OpenShift administration exam | Engineers validating OpenShift administration capability | [Red Hat Certified Specialist in OpenShift Administration exam](https://www.redhat.com/en/services/training/ex280-red-hat-certified-specialist-openshift-administration-exam) |

## Suggested two-person readiness plan

| FTE role | Target | Rationale | 30-day milestone | 60-day milestone | 90-day evidence |
| --- | --- | --- | --- | --- | --- |
| Platform engineer or trainer | CKA, then optional CKS | Owns AKS cluster operations, upgrades, RBAC, troubleshooting, and reliability | Complete Kubernetes fundamentals labs and `kubectl` drills | Complete CKA practice exams and AKS operations labs | Scheduled or passed CKA; documented operational runbook practice |
| Application engineer or trainer | CKAD plus OpenShift awareness through DO180 or DO280 modules | Owns workload manifests, probes, config, services, and app troubleshooting | Complete deployment, service, config, and probe exercises | Complete CKAD practice exams and review OpenShift differences | Scheduled or passed CKAD; completed OpenShift comparison notes |

## Study resources

| Need | Resource |
| --- | --- |
| Kubernetes certification overview | [CNCF training and certification](https://www.cncf.io/training/certification/) |
| CKA exam details | [Linux Foundation CKA page](https://training.linuxfoundation.org/certification/certified-kubernetes-administrator-cka/) |
| CKAD exam details | [Linux Foundation CKAD page](https://training.linuxfoundation.org/certification/certified-kubernetes-application-developer-ckad/) |
| AKS operations concepts | [AKS documentation](https://learn.microsoft.com/azure/aks/) |
| OpenShift course path | [Red Hat training and certification](https://www.redhat.com/en/services/training-and-certification) |

## Trainer scoring guidance

Accept the B.1.1 evidence when the plan names two roles, maps each role to target certifications, explains why the targets fit the role, and includes dated milestones. A generic list of certifications is not enough.
