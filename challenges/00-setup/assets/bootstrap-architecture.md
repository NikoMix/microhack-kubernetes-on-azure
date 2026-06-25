# Bootstrap architecture

The setup path moves from a prepared development environment to a validated AKS context and grounded Copilot workflow.

```mermaid
flowchart LR
  A[Dev container or Codespaces] --> B[az login]
  B --> C[scripts/preflight]
  C --> D[scripts/deploy Bicep track]
  D --> E[AKS secure baseline]
  E --> F[az aks get-credentials]
  F --> G[kubeconfig context]
  G --> H[kubectl get nodes]
  A --> I[AKS Engagement Copilot]
  I --> J[Azure MCP]
  I --> K[GitHub MCP]
  I --> L[Microsoft Docs MCP]
  J --> M[Reachability confirmed]
  K --> M
  L --> M
```

## Flow notes

- `scripts/preflight` catches missing access or tools before deployment.
- `scripts/deploy` provisions the secure baseline through the infrastructure contract.
- `az aks get-credentials` writes the cluster access profile into kubeconfig.
- Copilot plus MCP verification confirms that agent-assisted labs can use Azure, GitHub, and Microsoft Docs context.
