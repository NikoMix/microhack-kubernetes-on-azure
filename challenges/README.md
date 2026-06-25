# `challenges/` — MicroHack labs (M0–M6)

Hands‑on labs, one folder per module, each mapped to Module B control(s).

| Folder | Module | Control(s) |
| --- | --- | --- |
| `00-setup/` | M0 Setup & landing‑zone bootstrap | env |
| `01-foundations/` | M1 K8s/AKS foundations + cert readiness | B.1.1 |
| `02-assessment/` | M2 Workload assessment & dependency mapping | B.2.1 |
| `03-design/` | M3 Solution design + Well‑Architected Review | B.3.1 / B.3.2 |
| `04-delivery/` | M4 Deploy AKS baseline + migrate workloads | B.4.1 |
| `05-validate/` | M5 Service validation & testing | B.5.1 |
| `06-operate/` | M6 Post‑deployment docs & operations | B.5.2 |

## Per‑lab structure

```text
NN-name/
├── README.md            # Learner lab: objectives, steps, validation, success criteria
├── facilitator.md       # Trainer guide: timing, talking points, common pitfalls
├── assets/              # Diagrams, manifests, sample inputs
└── solutions/           # Trainer‑only reference outputs
```

## Authoring rules

- Each lab states **duration**, **prerequisites**, **Copilot/MCP usage**, and a
  **validation checklist** that ties back to the Module B evidence list.
- Steps must be runnable by the **newer‑to‑AKS** cohort (primers + cheat sheets linked).

> Owned by workstream **WS3 (Curriculum)**.
