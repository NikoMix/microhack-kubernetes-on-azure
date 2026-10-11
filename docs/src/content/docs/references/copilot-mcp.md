---
title: "Copilot agent, skills and MCP"
description: >-
  How the AKS Engagement Copilot accelerates each module.
---

## Agent model

The AKS Engagement Copilot is a course-specific GitHub Copilot agent provided by WS4. It can invoke skills from `.github/skills/` and use live MCP servers when they are available. Each lab also includes manual fallback steps so the MicroHack remains teachable without the agent or a server connection.

## Skills

| Skill | Primary output |
| --- | --- |
| `workload-assessment` | Dependency map and remediation backlog |
| `hld-generator` | AKS high-level design and architecture rationale |
| `war-runner` | Reliability and Security Well-Architected Review export |
| `test-plan` | Validation plan, expected results, and sign-off language |
| `runbook` | Incident triage, SLO/SLA, platform currency, and growth documentation |
| `as-built` | Delivery narrative, deployed-state summary, and operating evidence |

## MCP servers

| MCP server | Typical use |
| --- | --- |
| Azure MCP | Inspect subscription, resource group, AKS, ACR, Key Vault, networking, policy, Defender, and observability resources |
| GitHub MCP | Inspect repository structure, GitOps source, manifests, issues, and pull request context |
| Microsoft Docs MCP | Ground explanations and recommendations in official AKS, Kubernetes, and Well-Architected documentation |

## Module mapping

| Module | Skill or agent use | MCP server use | Manual fallback |
| --- | --- | --- | --- |
| M0 | Agent connection check | Azure, GitHub, Microsoft Docs | CLI preflight and documentation checks |
| M1 | Agent Q&A for concepts and certification plan | Microsoft Docs | Primer, certification page, official curricula |
| M2 | `workload-assessment` | Azure, Microsoft Docs | Source review, Azure CLI, dependency-map template |
| M3 | `hld-generator`, `war-runner` | Azure, Microsoft Docs | HLD template, WAR questions, official docs |
| M4 | `as-built` | Azure, GitHub | Azure CLI, kubectl, Flux CLI, as-built template |
| M5 | `test-plan` | Azure, Microsoft Docs | Test-plan template and captured test output |
| M6 | `runbook`, `as-built` | Azure, Microsoft Docs | Operating-document templates and monitoring output |

## Example prompt pattern

```text
Use the AKS Engagement Copilot for this module. Invoke the relevant skill if it is available. Ground recommendations with Azure MCP and Microsoft Docs MCP. If a tool is unavailable, tell me what manual evidence I need to collect and keep the output aligned to the Module B control.
```

## Modular inference note

Optional AI features in the sample application use a modular inference provider pattern across Azure AI Foundry, Azure OpenAI, or GitHub Models. Image generation is excluded. Treat provider choice as an implementation detail to document in design and operations evidence when the optional AI endpoint is enabled.

## Trainer guidance

Copilot accelerates drafting and inspection; it does not replace trainer scoring. Trainers should verify that generated outputs cite the right control, match observed Azure or GitHub state, and include enough rationale for a customer-facing evidence package.
