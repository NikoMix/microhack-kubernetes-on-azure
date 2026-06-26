---
marp: true
theme: microhack
paginate: true
footer: "Kubernetes on Azure - Module B MicroHack"
---

<!-- _class: lead -->
<!-- _paginate: false -->

# Kubernetes on Azure

## Module B Train-the-Trainer MicroHack

From engagement story to evidence-ready delivery

<!-- Speaker note: Welcome trainers. Set the frame: this is not only an AKS class; it is a repeatable customer engagement rehearsal. -->

---

# Why Kubernetes on Azure?

- AKS is the managed Kubernetes platform for Azure workloads
- Azure adds identity, policy, networking, security and observability
- Module B proves partners can run the full lifecycle
- Trainers must connect technology to customer outcomes

<!-- Speaker note: Emphasise Azure integration. The customer does not buy kubectl; they buy a reliable operating model. -->

---

# The engagement story

```text
Foundations -> Assess -> Design -> Deliver -> Validate -> Operate
```

- Start with shared language
- Inspect the workload honestly
- Design before deploying
- Validate with evidence
- Leave the customer able to operate

<!-- Speaker note: Use this flow repeatedly. It helps learners understand why modules appear in this order. -->

---

# Module B control overview

| Module | Control | Outcome |
| --- | --- | --- |
| M0 | env | Ready lab environment |
| M1 | B.1.1 | K8s foundations + cert plan |
| M2 | B.2.1 | Assessment backlog |
| M3 | B.3.1/B.3.2 | HLD + WAR backlog |
| M4 | B.4.1 | Secure delivery evidence |
| M5 | B.5.1 | Test results + sign-off |
| M6 | B.5.2 | Operations pack |

<!-- Speaker note: This table is the scoring spine. Every trainer should be able to map a lab output to a control. -->

---

# Train-the-Trainer model

Each module keeps four artifacts in sync:

1. Learner lab
2. Facilitator guide
3. Trainer-only solutions
4. Slides + docs page

<!-- Speaker note: Explain that trainers should never improvise evidence expectations. The four artifacts tell the same story for different audiences. -->

---

# Mixed-cohort approach

- Newer learners get primers, cheat sheets and safe commands
- Experienced learners get stretch goals
- Pair mixed skill levels when possible
- Demo the risky step; let teams drive the evidence

<!-- Speaker note: Avoid splitting the room into experts and beginners. The best learning happens when experts explain choices and newcomers ask why. -->

---

# Agenda at a glance

| Time | Segment |
| --- | --- |
| 08:30 | Welcome + TtT orientation |
| 09:00 | M0 setup |
| 09:30 | M1 foundations |
| 10:15 | M2 assessment |
| 11:15 | M3 design |
| 12:45 | Lunch |
| 13:30 | M4 delivery |
| 15:00 | M5 validate |
| 16:00 | M6 operate |
| 16:45 | Wrap |

<!-- Speaker note: Call out that M3 includes a short break and M4 begins immediately after lunch. Timeboxing is critical. -->

---

# Copilot + MCP usage

- AKS Engagement Copilot provides guided prompts
- Skills accelerate repeatable artifacts
- Azure MCP resolves live platform facts
- GitHub MCP supports repo and GitOps context
- Microsoft Docs MCP grounds concepts and references

<!-- Speaker note: Position Copilot as an accelerator, not a substitute for trainer judgement. Every lab has a manual path if a skill is unavailable. -->

---

# Ground rules

- Protect subscriptions and credentials
- Use placeholders until values are resolved live
- Keep evidence concise and reviewable
- Ask for intent before debugging commands
- Defer teardown until the end of day

<!-- Speaker note: Reinforce safety: no secrets in slides, images, commits or screenshots. -->

---

<!-- _class: invert -->

# Trainer mindset

Teach the engagement pattern.

The cluster is the practice field.

<!-- Speaker note: Close the orientation by shifting focus from tool execution to repeatable consulting behaviour. -->
