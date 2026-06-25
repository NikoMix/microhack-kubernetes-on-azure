# M00 facilitator guide · Setup and toolchain

Use this guide to keep the 09:00 setup lab on time and to collect environment evidence.

## Timing breakdown

| Time | Activity | Facilitation mode |
| --- | --- | --- |
| 3 min | Frame the day, environment outcome, and evidence | Demo |
| 5 min | Open Codespaces or dev container and check CLIs | Drive with room support |
| 5 min | Azure login, tenant, and subscription selection | Demo then drive |
| 5 min | Run `scripts/preflight` and interpret failures | Drive |
| 6 min | Run `scripts/deploy` for the Bicep track | Demo if slow, drive if ready |
| 3 min | Get AKS credentials and run `kubectl get nodes` | Drive |
| 3 min | Connect AKS Engagement Copilot and MCP servers | Demo then drive |

Total: 30 minutes.

## Talking points

- This is an enablement gate, not a deep AKS design lab.
- The infrastructure comes from the secure baseline contract in `infra/`; learners should not edit it.
- Kubeconfig is local client state. A correct Azure deployment is not enough until `kubectl` points at the right context.
- MCP servers let Copilot ground answers in Azure, GitHub, and Microsoft Docs rather than relying only on chat context.

## Common pitfalls and fixes

| Pitfall | Symptom | Fix |
| --- | --- | --- |
| Wrong tenant during `az login` | Subscription is missing from `az account list` | Re-run `az login --tenant <tenant-id>` or choose the correct directory in the browser. |
| Wrong subscription selected | Preflight reports an unexpected subscription | Run `az account set --subscription <subscription-id>` and rerun preflight. |
| West Europe quota issue | Preflight reports regional capacity or quota failure | Move the learner to a trainer-provided subscription or reduce assigned capacity if the trainer has approved it. |
| Kubeconfig context mismatch | `kubectl get nodes` reaches another cluster or fails | Run `az aks get-credentials --resource-group <resource-group> --name <cluster-name> --overwrite-existing`, then check `kubectl config current-context`. |
| MCP auth or token failure | Copilot says a server is unavailable | Reconnect the MCP server, refresh GitHub or Azure authentication, and retry the verification prompt. |

## Demo-vs-drive guidance

- Demo the first Azure login and subscription selection so learners see the expected tenant prompts.
- Let learners drive preflight and kubeconfig because these are individual evidence points.
- If deployment time varies, demo one successful run while slower learners continue with help from table coaches.
- Demo MCP verification once, then ask learners to run the prompt and paste the three confirmation lines into their notes.

## Cohort-split tips

- Newer learners should pair with someone comfortable reading terminal output.
- Experienced learners can explain kubeconfig contexts and MCP grounding to their table.
- Keep a visible parking lot for deployment issues so the main cohort can continue.

## Evidence the trainer collects

Collect setup evidence for the scoring workflow in [trainer scoring](../../trainer-guide/scoring.md):

- Screenshot or copied output of `kubectl get nodes` showing `Ready` nodes.
- Current AKS context name from `kubectl config current-context`.
- Copilot response showing Azure MCP, GitHub MCP, and Microsoft Docs MCP reachability.
- Any unresolved access or quota exception for follow-up before Module 1.
