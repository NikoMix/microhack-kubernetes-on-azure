# Security Policy

This repository is **training content**. It contains Infrastructure‑as‑Code, sample
applications, and lab guides intended to be deployed into **disposable lab subscriptions**.

## Reporting a vulnerability

If you find a security issue in the lab content, IaC, or sample apps, please open a
**private security advisory** on the repository (Security → Advisories → Report a
vulnerability) rather than a public issue.

## Lab safety guardrails

- Sample apps and clusters are **not hardened for production**; they demonstrate the AKS
  secure‑baseline pattern for teaching purposes.
- **Never** commit real secrets. Use Azure Key Vault, Workload Identity, and the provided
  `.env.example` files. Secret scanning (gitleaks) runs in CI.
- Always run `scripts/teardown` after a lab day to remove billable resources.
- All third‑party dependencies are pinned and scanned; we target **zero known
  vulnerabilities** in shipped lockfiles.
