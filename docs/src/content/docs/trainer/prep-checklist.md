---
title: "Prep checklist"
description: >-
  T-minus preparation for subscriptions, quota and Copilot.
---

This page mirrors the trainer prep checklist. The full canonical file is in GitHub: [trainer-guide/prep-checklist.md](https://github.com/NikoMix/microhack-kubernetes-on-azure/blob/main/trainer-guide/prep-checklist.md).

## T-minus preparation

- [ ] Confirm Azure subscriptions, tenant IDs and Owner or Contributor access.
- [ ] Check West Europe vCPU quota, SKU availability and AKS versions.
- [ ] Confirm Microsoft Entra access, Conditional Access compatibility, AKS Azure RBAC, managed identities and Key Vault access model.
- [ ] Confirm the AKS Engagement Copilot agent and WS4 skills are available, or prepare the manual path.
- [ ] Confirm Azure MCP, GitHub MCP and Microsoft Docs MCP connectivity.
- [ ] Verify `az`, `kubectl`, `kubelogin`, `flux`, `k6`, Node 24, Python 3.14 and Docker or Codespaces.
- [ ] Dry-run M0 through M6 the day before delivery.
- [ ] Prepare evidence folders, pairing plan, room display and reference recovery outputs.

## Useful verification commands

```bash
az vm list-usage --location westeurope -o table
az aks get-versions --location westeurope -o table
az version
kubectl version --client=true
kubelogin --version
flux --version
k6 version
node --version
python --version
docker version
```

## Day-of checklist

- [ ] Trainer signed in to Azure, GitHub and Copilot.
- [ ] Correct subscription selected.
- [ ] Network and display verified.
- [ ] Evidence drop location open.
- [ ] Learner links and troubleshooting commands ready.
- [ ] Start each module by naming the control and evidence target.
- [ ] Protect M5 validation and M6 operations time.
- [ ] Confirm all Module B evidence before wrap, especially M5 customer sign-off.
