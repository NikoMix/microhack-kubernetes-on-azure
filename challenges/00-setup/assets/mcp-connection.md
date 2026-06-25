# MCP connection and verification

This guide helps learners connect the three MCP servers used in Module 0.

## Servers to connect

| MCP server | What it verifies | Sample verification prompt |
| --- | --- | --- |
| Azure MCP | Azure subscription, resource groups, and AKS resources | `Use Azure MCP to show the selected subscription ID and list the AKS cluster names I can access for this lab.` |
| GitHub MCP | Repository and branch context | `Use GitHub MCP to confirm you can access the NikoMix/microhack-kubernetes-on-azure repository and identify the challenges folder.` |
| Microsoft Docs MCP | Current product documentation | `Use Microsoft Docs MCP to find the current AKS documentation page for retrieving cluster credentials.` |

## Connection steps

1. Open GitHub Copilot Chat in the dev container or Codespaces environment.
2. Select the AKS Engagement Copilot agent if it is available.
3. Enable or connect Azure MCP, GitHub MCP, and Microsoft Docs MCP in the MCP tools list.
4. Complete any browser or device-code authentication prompts.
5. Run the combined verification prompt.

```text
AKS Engagement Copilot: Use Azure MCP, GitHub MCP, and Microsoft Docs MCP. Confirm the selected Azure subscription, confirm this repository is reachable, and confirm you can retrieve current AKS documentation. Return one line per server with status and evidence.
```

## Expected confirmation shape

```text
Azure MCP: reachable; selected subscription is <subscription-id>.
GitHub MCP: reachable; repository NikoMix/microhack-kubernetes-on-azure is accessible.
Microsoft Docs MCP: reachable; AKS documentation search returned current results.
```

## Recovery tips

- If Azure MCP fails, refresh `az login` and confirm the tenant.
- If GitHub MCP fails, confirm GitHub authentication and repository access.
- If Microsoft Docs MCP fails, retry after checking network access to Microsoft Learn.
- If the AKS Engagement Copilot agent is unavailable, use standard Copilot Chat and follow the manual lab steps.
