# Modular inference (course standing rule)

Any AI capability added to a workload, lab, or deliverable **must** be provider-agnostic across:

- **Azure AI Foundry** (Foundry Models / Agent Service)
- **Azure OpenAI** (Azure OpenAI in Foundry Models)
- **GitHub Models**

…selectable at runtime via configuration. **Image generation is out of scope** for this course.

## Pattern

Select the provider with an environment variable; never hard-code a provider or a key.

```text
AI_PROVIDER = foundry | azure-openai | github-models
```

- Resolve credentials from environment / Key Vault (CSI) / **Managed Identity** — never embed keys.
- Wrap the three providers behind **one interface** so call sites stay provider-neutral
  (`.NET` `Microsoft.Extensions.AI` `IChatClient`; Python `azure-ai-inference`/`openai`; Node
  OpenAI-compatible SDK).
- Default to the **OpenAI-compatible Chat Completions** surface all three expose.

| Provider | Endpoint env | Auth |
|---|---|---|
| Azure AI Foundry | `FOUNDRY_ENDPOINT` | Entra ID (`DefaultAzureCredential`) |
| Azure OpenAI | `AZURE_OPENAI_ENDPOINT` | Entra ID / Managed Identity (Workload Identity on AKS) |
| GitHub Models | `GITHUB_MODELS_ENDPOINT` | `GITHUB_TOKEN` / PAT |

## In the as-built

Record the deployed provider, the selection config, and that credentials resolve via Key Vault /
Workload Identity (no keys in images or manifests). Note any deviation from the HLD inference
design.
