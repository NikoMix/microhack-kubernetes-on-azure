---
marp: true
theme: microhack
paginate: true
footer: "Kubernetes on Azure - Module B MicroHack"
---

<!-- _class: lead -->
<!-- _paginate: false -->

# M0 · Setup

## Environment readiness · 30 min

Dev container, Azure login, preflight, infra skeleton, Copilot + MCP

<!-- Speaker note: Set the expectation that setup is evidence for readiness, not a throwaway prerequisite. -->

---

# Objectives

- Open the dev container or Codespace
- Authenticate with Azure and GitHub
- Run preflight checks for West Europe
- Locate the infra skeleton and scripts
- Connect Copilot, Azure MCP, GitHub MCP and Docs MCP

<!-- Speaker note: Learners should leave M0 able to run every later lab without environment drift. -->

---

# Primer refresher

- A dev container standardises tools and shell behaviour
- `az login` establishes tenant and subscription context
- Preflight catches quota, region and CLI gaps early
- MCP lets Copilot query approved live systems

<!-- Speaker note: Newcomers may not know why a container matters. Explain that it removes laptop variance from the learning path. -->

---

# Key concepts

| Concept | Trainer emphasis |
| --- | --- |
| Subscription | Use the intended training subscription |
| Region | Secure baseline targets West Europe |
| Placeholders | Resolve values live, do not hard-code |
| Scripts | Use repo contracts, not ad hoc commands |

<!-- Speaker note: Remind trainers that stable setup protects the agenda. Small mistakes here become large delays later. -->

---

# Walkthrough outline

1. Start Codespaces or the local dev container
2. Confirm CLI versions and shell access
3. Run Azure authentication
4. Select the subscription
5. Run `scripts/preflight`
6. Inspect infra outputs expected later
7. Test Copilot + MCP reachability

<!-- Speaker note: Demonstrate steps 1 through 5 once, then let learners drive and compare results. -->

---

# Commands learners recognise

```bash
az login
az account show
scripts/preflight
```

- Keep output snippets for evidence
- Capture failures as teachable moments
- Do not deploy the baseline yet unless instructed

<!-- Speaker note: These commands are examples from the lab flow. Avoid inventing local alternatives during delivery. -->

---

# Copilot + MCP

| Item | Used for |
| --- | --- |
| AKS Engagement Copilot | Setup guidance and checks |
| Azure MCP | Subscription, region, quota facts |
| GitHub MCP | Repo context and branch awareness |
| Microsoft Docs MCP | Tool and AKS references |

<!-- Speaker note: If a live MCP server is unavailable, switch to the manual lab steps without slowing the room. -->

---

# Facilitator pitfalls

- Wrong tenant or subscription selected
- Quota missing in West Europe
- Dev container not fully rebuilt
- GitHub auth works, but Azure auth does not
- Learners paste real secrets into chat or notes

<!-- Speaker note: Have a short recovery script: verify account, subscription, region and tool versions before debugging deeper. -->

---

# Validation checklist

- Dev container or Codespace running
- Azure account context confirmed
- Preflight completed or blockers logged
- Infra skeleton located
- Copilot can reference Azure, GitHub and Docs context

<!-- Speaker note: M0 is the gate. Do not start M1 with half the room missing Azure context. -->

---

# Drive it yourself

Ask Copilot:

```text
Use the AKS Engagement Copilot to verify my Module B lab setup.
Check Azure subscription context, West Europe readiness, repo scripts,
and MCP reachability. Return blockers and next actions.
```

<!-- Speaker note: Encourage learners to compare Copilot output with manual checks. The goal is confidence, not blind trust. -->
