---
title: "Troubleshooting"
description: >-
  Common Azure/AKS/lab failures and fast fixes.
---

This page mirrors the trainer troubleshooting guide. The full canonical file is in GitHub: [trainer-guide/troubleshooting.md](https://github.com/NikoMix/microhack-kubernetes-on-azure/blob/main/trainer-guide/troubleshooting.md).

## Fast triage

Start by confirming subscription, resource group, cluster, namespace and current context.

```bash
az account show --query "{subscription:id, tenant:tenantId, user:user.name}" -o table
kubectl config current-context
kubectl get nodes
kubectl get pods -A
```

## Common issue groups

| Group | Typical symptom | First fix |
| --- | --- | --- |
| Auth, `az login` and subscription | CLI targets the wrong tenant or subscription. | Re-authenticate, set subscription and verify RBAC. |
| Quota and West Europe | AKS deployment fails with vCPU or SKU errors. | Check `westeurope` usage and switch to an approved fallback. |
| AKS credentials and context | `kubectl` is unauthorized or points at the wrong cluster. | Refresh credentials, convert kubeconfig with `kubelogin` and set context. |
| ACR pull and identity | Pods show `ImagePullBackOff`. | Verify tag and grant `AcrPull` to the AKS identity. |
| Flux reconciliation | Sources or Kustomizations are not ready. | Reconcile source and Kustomization, then inspect controller logs. |
| Ingress, DNS and certificates | Endpoint times out, returns 404 or TLS fails. | Check ingress class, service, DNS, certificate and issuer events. |
| Workload Identity | Pods cannot obtain Azure tokens. | Verify service account annotations, OIDC issuer and federated credential. |
| Key Vault CSI | Secret volume is empty or mount fails. | Check SecretProviderClass, identity and Key Vault data-plane access. |
| Container Insights | Logs or dashboards are empty. | Verify monitoring add-on, workspace and agent pods. |
| k6 and Chaos Studio | Tests cannot run or chaos experiment cannot start. | Confirm tools, reachability, provider registration and RBAC. |
| Copilot/MCP connectivity | Agent, skill or MCP query fails. | Use manual path, then verify Azure, GitHub and Docs access separately. |

## Escalation rule

Switch to trainer reference evidence when a quota, tenant, RBAC, private networking or deployment issue cannot be fixed within 10 minutes, or when troubleshooting would consume protected M5 or M6 time.
