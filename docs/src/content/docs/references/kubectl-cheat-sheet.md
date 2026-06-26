---
title: "kubectl cheat sheet"
description: >-
  The commands learners reach for most during the labs.
---

## Context and cluster access

```bash
az account show --output table
az account set --subscription <subscription-id>
az aks get-credentials --resource-group <resource-group> --name <cluster-name> --overwrite-existing
kubectl config current-context
kubectl config get-contexts
kubectl cluster-info
```

| Task | Command |
| --- | --- |
| Show current context | `kubectl config current-context` |
| Switch context | `kubectl config use-context <context-name>` |
| Show API resources | `kubectl api-resources` |
| Show cluster version | `kubectl version --short` |

## Inspect resources

```bash
kubectl get nodes -o wide
kubectl get namespaces
kubectl get pods -A
kubectl get deploy,svc,ingress -n <namespace>
kubectl describe pod <pod-name> -n <namespace>
kubectl get events -n <namespace> --sort-by=.lastTimestamp
```

| Task | Command |
| --- | --- |
| Wide pod view | `kubectl get pods -n <namespace> -o wide` |
| YAML output | `kubectl get deploy <name> -n <namespace> -o yaml` |
| Labels | `kubectl get pods -n <namespace> --show-labels` |
| Filter by label | `kubectl get pods -n <namespace> -l app=<app-name>` |

## Logs and exec

```bash
kubectl logs deploy/<deployment-name> -n <namespace>
kubectl logs <pod-name> -n <namespace> --previous
kubectl logs <pod-name> -n <namespace> -c <container-name>
kubectl exec -it <pod-name> -n <namespace> -- /bin/sh
```

| Task | Command |
| --- | --- |
| Follow logs | `kubectl logs -f deploy/<name> -n <namespace>` |
| Last 100 lines | `kubectl logs <pod> -n <namespace> --tail=100` |
| Exec command | `kubectl exec <pod> -n <namespace> -- printenv` |

## Debugging

```bash
kubectl describe node <node-name>
kubectl describe pod <pod-name> -n <namespace>
kubectl get events -A --sort-by=.lastTimestamp
kubectl top nodes
kubectl top pods -n <namespace>
kubectl debug node/<node-name> -it --image=mcr.microsoft.com/cbl-mariner/base/core:2.0
```

| Symptom | First checks |
| --- | --- |
| Pod pending | `kubectl describe pod`, node capacity, taints, PVCs |
| CrashLoopBackOff | `kubectl logs --previous`, probes, config, secrets |
| Image pull error | ACR permissions, image name, tag, managed identity pull |
| Service unreachable | Service selector, endpoints, ingress, network policy |

## Rollout and scale

```bash
kubectl rollout status deploy/<deployment-name> -n <namespace>
kubectl rollout history deploy/<deployment-name> -n <namespace>
kubectl rollout undo deploy/<deployment-name> -n <namespace>
kubectl scale deploy/<deployment-name> -n <namespace> --replicas=3
kubectl autoscale deploy/<deployment-name> -n <namespace> --min=2 --max=5 --cpu-percent=70
```

## RBAC checks

```bash
kubectl auth can-i get pods -n <namespace>
kubectl auth can-i create deployments -n <namespace> --as <user-or-service-account>
kubectl get role,rolebinding -n <namespace>
kubectl get clusterrole,clusterrolebinding
```

| Task | Command |
| --- | --- |
| Check own access | `kubectl auth can-i '*' '*' -A` |
| List namespace bindings | `kubectl get rolebinding -n <namespace>` |
| Inspect a role | `kubectl describe role <role-name> -n <namespace>` |

## Azure AKS commands

```bash
az aks show --resource-group <resource-group> --name <cluster-name> --output table
az aks check-acr --resource-group <resource-group> --name <cluster-name> --acr <acr-login-server>
az aks nodepool list --resource-group <resource-group> --cluster-name <cluster-name> --output table
az aks get-upgrades --resource-group <resource-group> --name <cluster-name> --output table
az aks command invoke --resource-group <resource-group> --name <cluster-name> --command "kubectl get nodes"
```

## Troubleshooting workflow

1. Confirm context and namespace.
2. Inspect desired resources with `kubectl get`.
3. Describe the failing object.
4. Read events and logs.
5. Check Azure dependencies such as ACR, Key Vault, identity, networking, and monitoring.
6. Record the finding in the module evidence, especially for M2, M5, and M6.
