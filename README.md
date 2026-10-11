<!-- markdownlint-disable MD033 MD041 -->
<div align="center">

# 🚀 Kubernetes on Azure — Module B MicroHack

## A 1‑Day Classroom‑Led, Train‑the‑Trainer Course with Hands‑On Labs

**Covers every Module B control of the _Kubernetes on Microsoft Azure Advanced Specialization_**
**· powered by GitHub Copilot agents, Copilot skills & MCP servers · focused on Microsoft Azure**

![Day length](https://img.shields.io/badge/format-1--day_classroom-blue)
![Mode](https://img.shields.io/badge/delivery-Train--the--Trainer-7B42BC)
![Cloud](https://img.shields.io/badge/cloud-Microsoft_Azure-0078D4)
![IaC](https://img.shields.io/badge/IaC-Bicep_%2B_Terraform_(AVM)-844FBA)
![AKS](https://img.shields.io/badge/Azure_Kubernetes_Service-secure_baseline-326CE5)
![License](https://img.shields.io/badge/license-MIT-green)

</div>

---

## 🎯 What this is

This repository is a **complete, ready‑to‑deliver MicroHack** that takes a **mixed‑skill**
cohort of Azure platform engineers / consultants through the full **engagement lifecycle**
of delivering Kubernetes on Azure — mapped 1:1 to the **seven Module B audit controls** of
the [Kubernetes on Microsoft Azure Advanced Specialization](https://github.com/NikoMix/specialization-kubernetes-on-azure).

It is built **Train‑the‑Trainer**: every module ships **learner labs**, a **facilitator
guide** (timing, talking points, pitfalls), **trainer‑only solutions**, **slides**, and a
**published docs site** — plus a purpose‑built **GitHub Copilot "AKS Engagement Copilot"**
(custom agent + skills + MCP servers) that accelerates each Module B deliverable.

## 👥 Audience & prerequisites

- **Who:** trainers/consultants who will _deliver_ this course. Mixed Kubernetes experience —
  primers and cheat sheets are included for the newer cohort.
- **Bring:** an **Azure subscription (Owner)**, a **GitHub account** (Copilot enabled),
  and the [dev container / Codespaces](.devcontainer) toolchain (`az`, `kubectl`, `helm`,
  `bicep`, `terraform`, `gh`).
- **Region:** default **West Europe** (a preflight script checks quota/region).

## 🗺️ Module B coverage → course modules

| Control | Title | Module | Lab outcome |
|---|---|---|---|
| **B.1.1** | Certification & K8s foundations | **M1** | AKS/`kubectl`/RBAC primer; CKA/CKAD map |
| **B.2.1** | Workload Assessment | **M2** | Dependency map + remediation backlog (Copilot‑assisted) |
| **B.3.1** | Solution Design | **M3** | AKS landing‑zone HLD across all design areas |
| **B.3.2** | Well‑Architected Review | **M3** | WAR export (2 pillars) + backlog |
| **B.4.1** | Delivery | **M4** | Deploy AKS secure baseline; migrate polyglot apps via GitOps |
| **B.5.1** | Service Validation & Testing | **M5** | Load + chaos tests; SLO comparison; sign‑off |
| **B.5.2** | Post‑deployment Documentation | **M6** | CI/CD, SLO, triage runbook, as‑built, platform currency |

## 🕘 One‑day agenda (timeboxed)

| Time | Block | Control(s) |
|---|---|---|
| 08:30 | Welcome + Train‑the‑Trainer orientation | — |
| 09:00 | **M0** Setup & landing‑zone bootstrap | env |
| 09:30 | **M1** K8s/AKS foundations + certification map | B.1.1 |
| 10:15 | **M2** Assessment & dependency mapping | B.2.1 |
| 11:15 | **M3** Solution Design + Well‑Architected Review | B.3.1 / B.3.2 |
| 12:45 | Lunch | — |
| 13:30 | **M4** Delivery: AKS baseline + migrate workloads | B.4.1 |
| 15:00 | **M5** Validate & test (load + chaos + sign‑off) | B.5.1 |
| 16:00 | **M6** Operate & document (CI/CD, SLO, runbook, as‑built) | B.5.2 |
| 16:45 | Wrap: deliver‑the‑course playbook + scoring | — |

## 🤖 The "AKS Engagement Copilot" (latest GitHub features)

Threaded through every lab:

- **GitHub Copilot custom agent** — `.github/agents/aks-engagement-copilot.agent.md`
- **Copilot skills** — assessment, HLD, WAR, test plan, runbook, as‑built generators
- **MCP servers** used live — **Azure MCP**, **GitHub MCP**, **Microsoft Docs MCP**
- Wherever AI capability is added, it ships **modular inference** across
  **Azure AI Foundry / Azure OpenAI / GitHub Models** (image generation excepted).

## 📁 Repository structure

```text
.
├── README.md                     # You are here — course landing
├── docs/                         # Astro + Starlight published curriculum site
├── challenges/                   # MicroHack labs M0–M6 (+ solutions/ trainer‑only)
├── slides/                       # Marp slide decks (HTML/PDF export)
├── trainer-guide/                # Facilitation, timing, scoring, troubleshooting
├── infra/
│   ├── bicep/                    # AKS secure baseline — Azure Verified Modules
│   └── terraform/                # Parity track — Azure Verified Modules
├── scripts/                      # preflight, deploy, teardown, cost helpers
├── apps/                         # Polyglot sample workloads (.NET, Python, Node)
├── gitops/                       # Flux v2 app‑of‑apps manifests
└── .github/                      # Copilot agents, skills, prompts, CI, MCP config
```

## 🚦 How to use this repo

- **As a trainer:** start with [`trainer-guide/`](trainer-guide/) and the slides, then
  run each `challenges/MNN-*` with its facilitator guide and `solutions/`.
- **As a learner:** follow `challenges/` in order from **M0**; the docs site mirrors it.
- **Cost hygiene:** always run `scripts/teardown` at the end of the day.

## 🧰 Tech & quality bar

- Latest stacks: **.NET 10**, **Python 3.14**, **Node 24**; **AVM‑first** IaC.
- All dependencies kept current with **zero known vulnerabilities**; **MIT/Apache‑2.0/BSD**
  libraries only.
- CI runs lint + build + container/image scan + **CodeQL** + IaC validation (PSRule,
  tflint, checkov) + Markdown link‑check, with findings surfaced as SARIF.

## 📜 License

[MIT](LICENSE). Content is provided for partner enablement; defer to your Microsoft Partner
Agreement for specialization usage terms.
