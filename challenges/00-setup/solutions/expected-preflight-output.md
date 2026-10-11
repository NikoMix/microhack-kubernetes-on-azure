# Expected preflight and validation output

This trainer-only sample shows the shape of successful Module 0 evidence. Exact names vary by cohort.

## Successful preflight

```text
MicroHack preflight
Azure CLI: found
kubectl: found
helm: found
bicep: found
terraform: found
gh: found
Azure login: signed in
Subscription: <subscription-id>
Region: westeurope
Quota: sufficient for AKS secure baseline
Result: PASS
```

## Successful kubeconfig validation

```text
$ kubectl config current-context
<cluster-name>

$ kubectl get nodes
NAME                                STATUS   ROLES    AGE   VERSION
aks-system-00000000-vmss000000      Ready    <none>   12m   v1.30.x
aks-user-11111111-vmss000000        Ready    <none>   11m   v1.30.x
```

## Successful MCP confirmation

```text
Azure MCP: reachable; selected subscription is <subscription-id>.
GitHub MCP: reachable; repository NikoMix/microhack-kubernetes-on-azure is accessible.
Microsoft Docs MCP: reachable; AKS documentation search returned current guidance.
AKS Engagement Copilot: responding with environment setup guidance.
```
