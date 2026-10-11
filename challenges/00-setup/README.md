# M00 · Setup and toolchain

Prepare your Azure, AKS, Copilot, and MCP environment for the MicroHack day.

## Metadata

- **Duration:** 30 minutes
- **Control:** env
- **Evidence produced:** working AKS context, reachable MCP servers, and a responding AKS Engagement Copilot agent
- **You will:** open the provided toolchain, sign in to Azure, run preflight, deploy the AKS secure baseline skeleton, connect kubeconfig, and verify Copilot plus MCP access

## Prerequisites

- Access to the MicroHack repository in a GitHub Codespace or local dev container.
- Azure access with permission to create the Module B lab resources in West Europe.
- GitHub Copilot Chat access and permission to use the AKS Engagement Copilot agent when it is available.
- Network access to Azure, GitHub, and Microsoft Docs MCP endpoints.

## Primer / concepts

A Kubernetes context is the named connection profile that tells `kubectl` which cluster, user, and namespace to use. Contexts live in your kubeconfig file, usually at `~/.kube/config`. In this lab, `az aks get-credentials` adds the AKS cluster to kubeconfig and sets a usable context.

Keep these mental checks in mind:

- `kubectl config current-context` shows where commands will run.
- `kubectl config get-contexts` lists available contexts.
- `kubectl get nodes` proves your context can reach the cluster API.
- The AKS secure baseline is provisioned from the infrastructure contract in `infra/`; do not edit it during this lab.

For source context, use the repository folders on GitHub: [infra](https://github.com/NikoMix/microhack-kubernetes-on-azure/tree/main/infra) and [scripts](https://github.com/NikoMix/microhack-kubernetes-on-azure/tree/main/scripts).

> **Stretch goal:** If you already know kubeconfig well, explain to a partner how `current-context`, cluster credentials, and namespaces interact before running the validation checklist.

## Copilot + MCP usage

> **Copilot + MCP call-out:** Use the AKS Engagement Copilot agent for setup Q&A. Connect Azure MCP, GitHub MCP, and Microsoft Docs MCP so the agent can verify subscriptions, repository context, and current product documentation. If the agent or a server is unavailable, complete the manual steps below and record the gap for the trainer.
>
> Example prompt: `Using Azure MCP, GitHub MCP, and Microsoft Docs MCP, confirm my Azure subscription is selected, this repository is reachable, and the AKS setup guidance is available. Then tell me what I should validate before Module 1.`

## Step-by-step instructions

1. Open the dev container or GitHub Codespaces toolchain.

   Confirm the expected CLIs are available in the terminal. Version differences are acceptable; missing tools are not.

   ```bash
   az version
   kubectl version --client=true
   helm version
   bicep --version
   terraform version
   gh --version
   ```

2. Sign in to Azure and select the subscription for the lab.

   Use the subscription assigned by your trainer. Keep the value in an environment variable so later commands are repeatable.

   ```bash
   az login
   az account list --output table
   export SUBSCRIPTION_ID="<subscription-id>"
   az account set --subscription "$SUBSCRIPTION_ID"
   az account show --query "{name:name,id:id,tenantId:tenantId}" --output table
   ```

3. Run preflight from the repository root.

   The `scripts/preflight` contract checks Azure login, subscription selection, West Europe region and quota readiness, and required CLIs.

   ```bash
   scripts/preflight
   ```

   If preflight fails, fix the reported issue before continuing. Do not edit the script.

4. Deploy the infrastructure skeleton using the Bicep primary track.

   The `scripts/deploy` contract provisions the AKS secure baseline from `infra/`, including the AKS cluster, system and user node pools, Entra ID and Azure RBAC integration, Azure CNI Overlay, security add-ons, observability, and required contract outputs such as `<cluster-name>` and `<resource-group>`.

   ```bash
   scripts/deploy --track bicep
   ```

   If your trainer provides a different flag shape for the current branch, use the trainer-provided invocation while keeping Bicep as the primary track.

5. Get cluster credentials and verify the AKS context.

   Resolve concrete values from Azure instead of hard-coding them. If your trainer provides exact names, substitute them for the placeholder discovery commands.

   ```bash
   export RESOURCE_GROUP="<resource-group>"
   export AKS_NAME="<cluster-name>"
   az aks get-credentials --resource-group "$RESOURCE_GROUP" --name "$AKS_NAME" --overwrite-existing
   kubectl config current-context
   kubectl get nodes
   ```

   Successful output shows one or more nodes in `Ready` state.

6. Connect the AKS Engagement Copilot agent and the three MCP servers.

   In Copilot Chat, select the AKS Engagement Copilot agent when it is available. Connect or enable these MCP servers:

   - Azure MCP
   - GitHub MCP
   - Microsoft Docs MCP

   Verify reachability with a prompt that requires each server to answer from its own domain.

   ```text
   AKS Engagement Copilot: Verify Azure MCP can see my selected subscription, GitHub MCP can see this repository, and Microsoft Docs MCP can retrieve current AKS documentation. Return one short confirmation line per MCP server.
   ```

   Record any server that cannot authenticate so the facilitator can help before Module 1.

## Validation checklist

- [ ] `kubectl get nodes` returns one or more `Ready` nodes → env: working AKS context.
- [ ] `kubectl config current-context` points to the lab AKS cluster → env: kubeconfig is usable.
- [ ] Azure MCP, GitHub MCP, and Microsoft Docs MCP each return a confirmation → env: MCP servers reachable.
- [ ] AKS Engagement Copilot responds with setup guidance → env: Copilot agent connected.

## Success criteria

You are ready for Module 1 when the AKS cluster is deployed, your terminal can reach it with `kubectl`, and Copilot plus the MCP servers can answer the sample verification prompt.

## What you produced

- A selected Azure subscription for the lab.
- A deployed AKS secure baseline skeleton.
- A kubeconfig context for the AKS cluster.
- A Copilot and MCP reachability confirmation.

## Clean-up note

Do not tear down resources now. The same environment is used throughout the day. Run `scripts/teardown` only when the trainer announces end-of-day clean-up.

## Next module

Continue to [M01 · Foundations](../01-foundations/).
