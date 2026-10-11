# M2 facilitator guide · Workload assessment and dependency mapping

Use this guide to keep the 60-minute B.2.1 lab focused on evidence collection, not exhaustive architecture archaeology.

## Timing breakdown

| Time | Activity | Facilitator action |
| --- | --- | --- |
| 0-5 min | Frame B.2.1 evidence | Explain that the scoring artifacts are a dependency map and a prioritised remediation backlog. |
| 5-12 min | Primer | Walk through Azure Migrate discovery, dependency analysis, and readiness planning. |
| 12-20 min | Copilot/MCP demo | Demo the `workload-assessment` prompt, Microsoft Docs MCP grounding, and Azure MCP inspection. |
| 20-32 min | Service inventory | Let learners identify runtimes, ports, health endpoints, identities, and observability paths. |
| 32-45 min | Dependency mapping | Coach teams as they fill the Mermaid diagram and category tables. |
| 45-55 min | Remediation backlog | Facilitate risk/effort prioritisation and challenge vague findings. |
| 55-60 min | Evidence check | Collect artifacts and connect scoring to `../../trainer-guide/scoring.md`. |

## Talking points

- Workload assessment converts unknowns into migration decisions: what runs, what it talks to, what state it owns, and what must be remediated.
- Azure Migrate uses discovery and dependency analysis before readiness decisions; this lab mirrors that pattern for AKS workloads.
- The app set is intentionally polyglot: Node 24 front door, .NET 10 API, and Python 3.14 worker.
- Dependency maps should include platform dependencies such as ACR, Key Vault, Azure Monitor, DNS, Entra Workload Identity, and egress controls.
- Backlog quality matters more than item count: each finding needs risk, effort, priority, remediation, owner, and status.

## Common pitfalls and fixes

| Pitfall | Fix |
| --- | --- |
| Over-mapping every Kubernetes object | Keep the map at service, platform dependency, and data-flow level. Put object details in tables only when they affect readiness. |
| Missing implicit dependencies such as DNS, identity, registry pulls, or telemetry | Ask learners what must work before the first HTTP request succeeds. Add platform dependencies explicitly. |
| Confusing state with configuration | State is durable business or processing data; configuration controls runtime behaviour. Secrets are sensitive configuration and need their own category. |
| Treating Copilot output as final evidence | Require learners to verify generated findings with Azure MCP, kubectl output, source contracts, or Microsoft Docs MCP. |
| Writing vague backlog items | Convert each item into an actionable remediation with an owner and status. |

## Demo-vs-drive guidance

Demo the first five minutes of Copilot and MCP usage so learners see the expected pattern: ask the AKS Engagement Copilot to invoke `workload-assessment`, ground with Microsoft Docs MCP, then inspect live resources with Azure MCP. After that, let learners drive their own prompts and manual checks.

If the Copilot skill is unavailable, demo the manual path: copy the templates, run the inventory commands, fill the map, and prioritise the CSV. Avoid solving the whole lab live unless the cohort is blocked.

## Cohort-split tips

- Newer learners: assign the inventory and classification tables first. Pair them with an experienced learner for the Mermaid diagram.
- Experienced learners: ask them to validate network policy gaps, workload identity assumptions, probe coverage, and image security posture.
- Mixed tables: use one scribe for the dependency map and one reviewer for the backlog so both artifacts progress in parallel.

## Evidence collected

Collect these files or screenshots for scoring:

- Completed dependency map with upstream/downstream services, data flows, network, state, and secrets.
- Completed remediation backlog prioritised by risk and effort.
- Optional questionnaire notes if the trainer wants to assess discovery quality.

Use the scoring expectations in `../../trainer-guide/scoring.md` when giving feedback.
