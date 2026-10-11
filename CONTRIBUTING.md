# Contributing

Thanks for helping improve the **Kubernetes on Azure — Module B MicroHack**.

## Principles

- **Train‑the‑Trainer first.** Every module change must keep the four artifacts in sync:
  learner lab, facilitator guide, trainer solution, and slides/docs.
- **Azure‑focused, latest features.** Prefer current AKS capabilities and Azure Verified
  Modules; keep Bicep and Terraform tracks in **parity**.
- **Quality bar.** Code must pass the repo linters and CI (lint, build, scan, CodeQL, IaC
  validate). Use **permissively licensed** (MIT/Apache‑2.0/BSD) dependencies only.
- **Zero known vulnerabilities.** Upgrade dependencies as part of your change.

## Workflow

1. Branch from the integration branch.
2. Keep changes within a single **workstream subtree** where possible
   (`infra/`, `apps/`, `challenges/`, `.github/`, …).
3. Open a PR; CI must be green and at least one CODEOWNER must approve.

## Local checks

See `.github/workflows/` for the authoritative checks. Common entry points:

```bash
# Markdown + links
npx markdownlint-cli2 "**/*.md"
# IaC
az bicep build --file infra/bicep/main.bicep
terraform -chdir=infra/terraform validate
```
