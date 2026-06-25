# AKS high-level design template

Use this template to produce the B.3.1 design document. Keep every section, even when the decision is to defer or use the secure-baseline default.

## Document control

| Item | Value |
| --- | --- |
| Customer | `<customer-name>` |
| Environment | `<environment-name>` |
| Region | `westeurope` |
| Subscription | `<subscription-id>` |
| Resource group | `<resource-group>` |
| AKS cluster | `<cluster-name>` |
| Author | `<name>` |
| Date | `<date>` |

## Executive summary

Describe the workload, target AKS landing zone, major constraints, and the most important Reliability and Security design choices.

## Requirements and constraints

- Business requirements:
- Technical requirements:
- Regulatory constraints:
- Operational constraints:
- Assumptions:
- Open decisions:

## 1. IAM/RBAC with Microsoft Entra ID

- How will cluster authentication use Microsoft Entra ID?
- Which Azure RBAC roles are required for platform, operations, and application teams?
- How will Workload Identity use `<oidc-issuer>` and federated credentials?
- What least-privilege controls prevent over-broad access?

## 2. Network architecture

- What hub/spoke topology, private-cluster option, and peering model are used?
- Which ingress option is selected: App Gateway for Containers or managed NGINX?
- How does egress flow through Azure Firewall, UDRs, and approved FQDN or service tags?
- How are Azure CNI Overlay, DNS, private endpoints, and name resolution handled?

## 3. Security

- Which Microsoft Defender for Containers capabilities are enabled?
- Which Azure Policy for AKS and Deployment Safeguards assignments apply?
- How are image, runtime, admission, and configuration risks controlled?

## 4. Governance and cost

- What tags, budgets, policy guardrails, and ownership model apply?
- How are Log Analytics retention and diagnostic settings configured?
- How will cost be reviewed after deployment?

## 5. Backup and business continuity

- What does Azure Backup for AKS protect?
- When would Velero be used?
- How are etcd and control-plane responsibilities explained?
- How are stateful data, manifests, secrets, and recovery objectives handled?

## 6. Regulatory compliance

- How is West Europe data residency maintained?
- Which policy initiatives, CIS controls, or AKS benchmark requirements are mapped?
- What evidence proves compliance controls are active?

## 7. Cluster RBAC

- Which Kubernetes namespaces represent tenants or environments?
- Which Roles, ClusterRoles, RoleBindings, and ClusterRoleBindings are required?
- How is privileged access requested, approved, and audited?

## 8. Continuous image vulnerability scanning

- How are Defender and ACR scanning signals reviewed?
- Which severity blocks deployment?
- How does admission gating or GitOps policy prevent vulnerable images from running?

## 9. Resource requests, limits, namespaces, ResourceQuotas, and LimitRanges

- Which namespaces exist for platform and applications?
- What default requests, limits, ResourceQuotas, and LimitRanges apply?
- How are burst, autoscaling, and noisy-neighbour risks handled?

## 10. Monitoring and alerting

- How are Container Insights, Managed Prometheus, and Grafana enabled?
- Which alert rules matter for cluster, node, pod, ingress, egress, and application health?
- Who owns alert response?

## 11. Liveness, readiness, and startup probes

- Which probes use the apps' `/health` endpoints?
- How are startup delays, readiness dependencies, and failure thresholds tuned?
- How do probes protect rolling upgrades?

## 12. Secrets in Key Vault

- How does CSI Secret Store mount secrets from `<key-vault-name>`?
- How is rotation enabled and tested?
- How are secrets excluded from images, manifests, logs, and source control?

## 13. Cluster design document

- Which system and user node pools are required?
- What sizing, autoscaling, availability zones, taints, tolerations, and labels apply?
- What upgrade, maintenance, add-on, and node-image strategy is used?

## 14. Network design document

- What address spaces, subnets, route tables, and NSGs are required?
- What firewall rules, ingress paths, egress paths, and DNS rules are required?
- What private endpoints or service endpoints are required?

## Architecture diagram

Link to the adapted architecture diagram and summarise the major flows.

## Risks and decisions

| ID | Risk or decision | Impact | Mitigation or owner |
| --- | --- | --- | --- |
| D-001 | `<decision>` | `<impact>` | `<owner>` |

## References

- [AKS baseline architecture](https://learn.microsoft.com/azure/architecture/reference-architectures/containers/aks/baseline-aks)
- [Well-Architected Framework service guide for AKS](https://learn.microsoft.com/azure/well-architected/service-guides/azure-kubernetes-service)
- [AKS Workload Identity](https://learn.microsoft.com/azure/aks/workload-identity-overview)
- [Azure CNI Overlay](https://learn.microsoft.com/azure/aks/azure-cni-overlay)
- [Secrets Store CSI Driver for AKS](https://learn.microsoft.com/azure/aks/csi-secrets-store-driver)
