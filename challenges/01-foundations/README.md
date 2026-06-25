# M01 · Kubernetes and AKS foundations

Explore the deployed AKS environment and produce the B.1.1 certification readiness artifacts.

## Metadata

- **Duration:** 45 minutes
- **Control:** B.1.1
- **Evidence produced:** a 2-FTE certification mapping and readiness or study plan
- **You will:** compare AKS with vanilla Kubernetes, inspect namespaces and RBAC, orient with `kubectl`, and use Copilot plus Microsoft Docs MCP to build a certification plan

## Prerequisites

- Module 0 completed with a working AKS kubeconfig context.
- `kubectl get nodes` returns `Ready` nodes.
- Azure CLI is signed in to the lab subscription.
- AKS Engagement Copilot is reachable, with Microsoft Docs MCP connected when available.
- Review the Kubernetes and AKS primer at [/references/primer/](/references/primer/) and the kubectl cheat sheet at [/references/kubectl-cheat-sheet/](/references/kubectl-cheat-sheet/).

## Primer / concepts

AKS is managed Kubernetes on Azure. You still use Kubernetes APIs such as Pods, Deployments, Services, Namespaces, Roles, and RoleBindings, but Azure operates the control plane and integrates the cluster with Azure networking, identity, policy, and monitoring.

Key concepts for this lab:

- **Managed control plane:** Azure runs and patches the Kubernetes API server components for AKS.
- **Node pools:** AKS groups worker nodes into system and user pools so platform add-ons and workloads can be separated.
- **Namespaces:** Kubernetes scopes names and many permissions inside one cluster.
- **RBAC layers:** Entra ID and Azure RBAC decide who can access Azure resources and, when enabled, AKS authorization. Kubernetes RBAC uses Roles, ClusterRoles, RoleBindings, and ClusterRoleBindings inside the cluster.
- **Add-ons:** AKS integrates capabilities such as Azure Policy, Defender for Containers, Container Insights, and ingress options.

See the deeper AKS comparison in [assets/aks-vs-k8s-primer.md](assets/aks-vs-k8s-primer.md).

> **Stretch goal:** Create a custom namespace and least-privilege RoleBinding for a fictional team, then use `kubectl auth can-i` to prove the allowed and denied actions.

## Copilot + MCP usage

> **Copilot + MCP call-out:** Use the AKS Engagement Copilot agent for concept explanation and certification planning. Use Microsoft Docs MCP to ground answers in current AKS and certification documentation. No custom skill is required for M1. If the agent is unavailable, ask standard Copilot Chat the same prompts and verify important facts against Microsoft Docs manually.
>
> Example prompt: `Using Microsoft Docs MCP, explain AKS node pools, namespaces, and the difference between Azure RBAC and Kubernetes RBAC for a learner new to Kubernetes. Then draft a 2-FTE study plan covering CKA, CKAD, and OpenShift EX280 or DO280.`

## Step-by-step instructions

1. Confirm your current AKS context.

   ```bash
   kubectl config current-context
   kubectl get nodes -o wide
   ```

2. Inspect system and user node pools.

   Resolve the resource group and cluster name from Module 0 outputs or trainer guidance.

   ```bash
   export RESOURCE_GROUP="<resource-group>"
   export AKS_NAME="<cluster-name>"
   az aks nodepool list --resource-group "$RESOURCE_GROUP" --cluster-name "$AKS_NAME" --query "[].{name:name,mode:mode,count:count,vmSize:vmSize,osType:osType}" --output table
   ```

   Note which pool is `System` and which pool is intended for user workloads.

3. Explore namespaces and platform add-ons.

   ```bash
   kubectl get namespaces
   kubectl get pods --namespace kube-system
   kubectl get pods --all-namespaces
   ```

   Identify at least two platform components in `kube-system` and one namespace intended for user workloads or future application deployment.

4. Inspect AKS identity and RBAC configuration.

   ```bash
   az aks show --resource-group "$RESOURCE_GROUP" --name "$AKS_NAME" --query "{enableAzureRBAC:enableAzureRBAC,aadProfile:aadProfile,oidcIssuerProfile:oidcIssuerProfile}" --output json
   kubectl auth can-i get pods --namespace default
   kubectl auth can-i create rolebindings --namespace default
   ```

   Discuss with your table which checks relate to Azure RBAC and which checks relate to Kubernetes RBAC.

5. Inspect a sample Kubernetes Role and RoleBinding without changing the cluster.

   ```bash
   kubectl create role pod-reader --verb=get,list,watch --resource=pods --namespace default --dry-run=client --output yaml
   kubectl create rolebinding pod-reader-binding --role=pod-reader --user=user@example.com --namespace default --dry-run=client --output yaml
   ```

   Compare the generated YAML with [assets/rbac-namespaces-lab.md](assets/rbac-namespaces-lab.md).

6. Use Copilot and Microsoft Docs MCP to build the certification mapping.

   Copy [assets/certification-map-template.csv](assets/certification-map-template.csv) into your notes or spreadsheet. Fill two named FTE rows. Include CKA and CKAD as target certifications across the two people, and include Red Hat OpenShift EX280 or DO280 as the cross-platform option. CKS is optional if one role already has strong security experience.

   ```text
   AKS Engagement Copilot: Using Microsoft Docs MCP, help me fill a 2-FTE certification map for an AKS engagement team. Include role names, current skills, CKA, CKAD, and an OpenShift EX280 or DO280 cross-platform target. Suggest realistic target dates and study resources.
   ```

7. Create the readiness and study plan.

   Use [assets/readiness-plan-template.md](assets/readiness-plan-template.md). Include baseline skill gaps, weekly study activities, hands-on practice, exam readiness checks, and trainer follow-up.

   ```text
   AKS Engagement Copilot: Turn the certification map into a four-week readiness plan. Include weekly outcomes, hands-on labs, Microsoft Learn or Kubernetes documentation references from Microsoft Docs MCP, and evidence that the two FTEs are ready for customer delivery.
   ```

8. Optional stretch goal for experienced learners.

   Apply a least-privilege namespace example only if your trainer confirms the cluster is safe for learner writes.

   ```bash
   kubectl create namespace team-a
   kubectl create role pod-reader --verb=get,list,watch --resource=pods --namespace team-a
   kubectl create rolebinding pod-reader-binding --role=pod-reader --user=user@example.com --namespace team-a
   kubectl auth can-i list pods --namespace team-a --as=user@example.com
   kubectl auth can-i delete pods --namespace team-a --as=user@example.com
   ```

## Validation checklist

- [ ] Certification map has two named FTEs and role descriptions → B.1.1: 2-FTE certification mapping.
- [ ] Target certifications include CKA and CKAD across the two FTEs → B.1.1: Kubernetes foundations certification mapping.
- [ ] OpenShift EX280 or DO280 is included as the cross-platform option → B.1.1: Red Hat OpenShift mapping.
- [ ] Readiness plan includes timeline, study resources, hands-on practice, and readiness checks → B.1.1: readiness/study plan.
- [ ] Learner can explain one AKS-managed capability, one namespace concept, and one RBAC distinction → B.1.1: foundations readiness.

## Success criteria

You can describe how this AKS cluster differs from self-managed Kubernetes, read basic cluster state with `kubectl`, explain the two RBAC layers, and submit the B.1.1 certification mapping plus readiness plan.

## What you produced

- A completed 2-FTE certification mapping artifact.
- A readiness and study plan for the mapped FTEs.
- Notes from AKS exploration commands.
- Optional namespace and RoleBinding evidence if you completed the stretch goal.

## Clean-up note

Do not tear down the AKS environment. If you created stretch-goal namespace resources, remove only those resources when your trainer asks. Full environment clean-up is deferred to end of day with `scripts/teardown`.

## Next module

Continue to [M02 · Assessment](../02-assessment/).
