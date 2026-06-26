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
- Wrap the three providers behind **one interface** so call sites stay provider-neutral:
  - **.NET** — `Microsoft.Extensions.AI` `IChatClient`.
  - **Python** — `azure-ai-inference` / `openai` client over the OpenAI-compatible surface.
  - **Node** — the OpenAI-compatible SDK pointed at the selected base URL.
- Default to the **OpenAI-compatible Chat Completions** surface all three expose, so switching
  providers is config-only.

| Provider | Endpoint env | Auth | Notes |
|---|---|---|---|
| Azure AI Foundry | `FOUNDRY_ENDPOINT` | Entra ID (`DefaultAzureCredential`) | Foundry Models + Agent Service |
| Azure OpenAI | `AZURE_OPENAI_ENDPOINT` | Entra ID / Managed Identity | Use **Workload Identity** on AKS |
| GitHub Models | `GITHUB_MODELS_ENDPOINT` (`https://models.github.ai/inference`) | `GITHUB_TOKEN` / PAT | Ideal for dev / evaluation |

## In the HLD

Document the inference layer under **Security** (Workload Identity, no keys in code) and the
**application architecture** (provider selection, fall-back, evaluation). This is strong B.3.1
portability evidence and B.3.2 Security / Operational-Excellence evidence.

## Current SDK details

- `microsoft_docs_search(query="Microsoft.Extensions.AI IChatClient")`
- `microsoft_docs_search(query="Azure AI Foundry models inference SDK")`
- `microsoft_docs_search(query="GitHub Models API OpenAI compatible")`
