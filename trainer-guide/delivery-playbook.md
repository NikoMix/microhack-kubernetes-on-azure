# Delivery playbook

This playbook is the trainer run-of-day for the 1-day Train-the-Trainer MicroHack, Kubernetes on Azure - Module B. Use it with the module facilitator guides and the scoring rubric.

## Trainer goals

- Keep the day aligned to the Module B controls and evidence requirements.
- Help a mixed cohort move together: newcomers get primers, cheat sheets and pairing; experienced learners get stretch goals and evidence-quality coaching.
- Make Copilot, the AKS Engagement Copilot skills and MCP servers visible as accelerators, while preserving a manual path when a service is unavailable.
- Collect clean evidence at each handoff so M5 customer sign-off and M6 operating documentation are grounded in earlier artifacts.

## Room and setup

Use a classroom layout that supports short trainer demos and longer paired work.

- Main screen with reliable HDMI or wireless display.
- Trainer machine signed in to Azure, GitHub and Copilot before learners arrive.
- Stable network with access to Azure portal, Azure CLI, GitHub, container registries and Microsoft Learn.
- Whiteboard or shared digital board for dependency maps, risks, parking-lot questions and decision logs.
- Pairing plan: one newer learner with one experienced learner where possible.
- Evidence drop location, such as a shared folder or GitHub issue template, with module folders named `M0` through `M6`.

## Pre-stage before learners arrive

Complete the detailed steps in [prep-checklist.md](prep-checklist.md). At minimum, pre-stage the following:

- Azure subscription access with Owner or Contributor permissions and quota in West Europe.
- Tooling checks for `az`, `kubectl`, `kubelogin`, `flux`, `k6`, Node 24, Python 3.14 and Docker or Codespaces.
- AKS Engagement Copilot availability, with WS4 skills visible if they have shipped.
- Azure MCP, GitHub MCP and Microsoft Docs MCP connectivity.
- A working reference path through M0, M2, M4 and M5 so you can recover quickly if learner environments drift.
- Links to the learner labs, facilitator guides and scoring rubric.

## Full-day agenda

The agenda runs from 08:30 to 17:00 and sums to exactly 510 minutes.

| Time | Duration | Segment | Trainer intent | Evidence handoff |
| --- | --- | --- | --- | --- |
| 08:30-09:00 | 30 min | Welcome and Train-the-Trainer orientation | Set expectations, explain Module B controls, introduce mixed-cohort support and evidence discipline. | Attendance, pairing plan, shared evidence location. |
| 09:00-09:30 | 30 min | M0 - Setup | Verify tools, Azure access, repo orientation and Copilot/MCP reachability. | Environment readiness notes. |
| 09:30-10:15 | 45 min | M1 - Foundations and certification readiness | Ground AKS concepts and build the certification readiness discussion for B.1.1. | 2-FTE certification mapping and readiness/study plan. |
| 10:15-11:15 | 60 min | M2 - Workload assessment | Turn the app context into dependencies, risks and remediation work. | Dependency map and prioritised remediation backlog. |
| 11:15-12:45 | 90 min | M3 - Solution design and Well-Architected Review | Produce design evidence and WAR rationale for Reliability and Security. | Design document, architecture diagram, WAR export and backlog. |
| 12:45-13:30 | 45 min | Lunch | Keep the room open for optional help, but protect the break. | Trainer checks evidence completeness. |
| 13:30-15:00 | 90 min | M4 - Delivery | Deploy or narrate delivery, generate as-built evidence and diagrams. Include a short break around 14:30 inside this module buffer. | At least two delivery artifacts, logical/physical/sequence diagrams, as-built notes. |
| 15:00-16:00 | 60 min | M5 - Service validation and testing | Validate the service and obtain customer sign-off. | Test plan, results, performance evaluation, remediation log and customer sign-off. |
| 16:00-16:45 | 45 min | M6 - Operate | Convert the delivered system into operating documentation. | CI/CD lifecycle, SLO/SLA tracking, triage runbook, platform-currency process, growth plan and monitoring evidence. |
| 16:45-17:00 | 15 min | Wrap and Train-the-Trainer debrief | Review scoring, discuss how trainers will redeliver, capture improvements. | Final evidence checklist and trainer action list. |
| **Total** | **510 min** | **08:30-17:00** | **Full course day** | **All Module B evidence collected.** |

## Pacing model for the mixed cohort

Use one shared backbone and two speeds.

- Guided path: learners follow the lab steps, use primers and cheat sheets, and ask Copilot for explanations before commands.
- Fast-track path: experienced learners run the same evidence contract but add stretch goals, such as deeper failure-mode analysis, tighter WAR rationale, additional policies, extra k6 scenarios or improved runbook automation.
- Pairing rule: rotate the keyboard every 10 to 15 minutes. The non-driver validates evidence quality against [scoring.md](scoring.md).
- Intervention rule: if 25 percent of the room is blocked on the same issue, pause and demo the fix. If fewer are blocked, use roaming support.
- Evidence rule: never let a team leave a module without naming the artifact they produced and where it was saved.

## Demo-vs-drive defaults

| Module | Default | Why | Trainer move |
| --- | --- | --- | --- |
| M0 | Demo then drive | Environment drift can consume the day. | Demo the happy path once, then let learners verify their own setup. |
| M1 | Guided discussion | The output is judgement-based, not command-heavy. | Use Copilot Q&A for explanations, then have learners build their own cert map. |
| M2 | Drive with checkpoints | Assessment quality improves when teams explore the workload themselves. | Demo one dependency and one backlog item, then roam. |
| M3 | Demo design framing, drive artifacts | Learners need to see the expected design breadth before creating their own HLD and WAR. | Demo prompts for `hld-generator` and `war-runner`; teams own rationale. |
| M4 | Demo risky deployment steps, drive evidence | Delivery failures are likely but are teachable. | Demo credential/context checks, then let teams deploy or narrate from reference outputs. |
| M5 | Drive with trainer acting as customer | Customer sign-off is gating evidence. | Learners run validation; trainer challenges results and signs only when criteria are met. |
| M6 | Drive from templates | Operations documentation must fit the delivered design. | Demo one runbook prompt, then require teams to tailor all five evidence items. |

## Module handoff checklist

Use this sequence at the end of every module.

1. Ask each team to name the control they just addressed.
2. Ask where the evidence artifact is stored.
3. Check one sample artifact against the pass criteria in [scoring.md](scoring.md).
4. Capture unresolved risks in the remediation log or parking lot.
5. Preview the next module and explain which previous artifact it consumes.

## Per-module trainer notes

### M0 - Setup

Facilitator guide: [M0 setup](../challenges/00-setup/facilitator.md).

- Keep the setup demo under 10 minutes.
- Validate Azure subscription, region, tool versions and Copilot/MCP reachability.
- If the custom agent or a skill is unavailable, explicitly switch to the manual path so learners trust the lab remains achievable.
- Handoff: ready environment, known subscription, current Kubernetes context status and any access issues.

### M1 - Foundations and certification readiness

Facilitator guide: [M1 foundations](../challenges/01-foundations/facilitator.md).

- Start with a short AKS and Kubernetes concept primer for newer learners.
- Use Microsoft Docs MCP for current certification references and let Copilot explain role-to-cert fit.
- Keep the discussion practical: two named FTE roles, target certs, timeline, study activities and gaps.
- Handoff: B.1.1 certification mapping and readiness/study plan.

### M2 - Workload assessment

Facilitator guide: [M2 assessment](../challenges/02-assessment/facilitator.md).

- Demo one upstream/downstream dependency and one risk-to-backlog conversion.
- Let teams drive the assessment with the `workload-assessment` skill if available.
- Push for specificity: data flows, network paths, state, secrets, operational risks and owners.
- Handoff: B.2.1 dependency map and prioritised remediation backlog.

### M3 - Solution design and WAR

Facilitator guide: [M3 design](../challenges/03-design/facilitator.md).

- Frame the design areas before learners write: identity, network, ingress, secrets, observability, GitOps, resilience, security and operations.
- Use `hld-generator` to accelerate structure, not to replace design judgement.
- Use `war-runner` for Reliability and Security rationale; require teams to defend trade-offs.
- Handoff: B.3.1 design document and architecture diagram; B.3.2 WAR export and prioritised backlog.

### M4 - Delivery

Facilitator guide: [M4 delivery](../challenges/04-delivery/facilitator.md).

- Use a short post-lunch reset and verify contexts before deployment.
- Plan a short break around 14:30 while long-running deployment or reconciliation checks run.
- Demo only the high-risk sequence: credentials, cluster context, Flux status and ingress checks.
- Handoff: B.4.1 delivery evidence, including at least two required artifacts and logical, physical and sequence diagrams.

### M5 - Service validation and testing

Facilitator guide: [M5 validate](../challenges/05-validate/facilitator.md).

- Make the trainer or a designated learner play the customer.
- Require test evidence before sign-off: functional, integration, performance, resilience/chaos and security coverage.
- The customer sign-off gates completion. Partial technical success without sign-off is not a full pass.
- Handoff: B.5.1 test plan, results, performance evaluation, remediation log and customer sign-off.

### M6 - Operate

Facilitator guide: [M6 operate](../challenges/06-operate/facilitator.md).

- Convert the day into operating practice: release lifecycle, SLOs, incidents, upgrades, growth and dashboards.
- Use `runbook` and `as-built` skills to accelerate drafts, then force ownership-specific tailoring.
- Close by checking that each operations artifact references the actual design and validation evidence.
- Handoff: B.5.2 operating documentation and Container Insights dashboard or alert evidence.

## End-of-day debrief

Use the final 15 minutes to make the Train-the-Trainer outcome explicit.

- What would you demo when redelivering this module?
- Where would you let learners drive?
- Which evidence artifact was hardest to assess?
- What fallback would you use if Copilot or MCP were unavailable?
- Which improvement should be fed back to the curriculum backlog?
