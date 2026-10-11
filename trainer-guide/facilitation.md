# Facilitation

This guide explains how to teach Module B to a mixed Train-the-Trainer cohort while keeping evidence quality high and Copilot/MCP use practical.

## Facilitation stance

Act as an engagement lead, not only a lab instructor. The learners are trainers who need to understand how to redeliver the experience, coach mixed teams and assess evidence against Module B controls.

- Make the control and evidence target visible at the start of every module.
- Explain why a step matters in a real AKS customer engagement.
- Use Copilot and MCP as accelerators, not as magic. Always name the manual fallback.
- Prefer short demos, then learner drive time.
- Coach evidence quality continuously instead of waiting until the end.

## Teaching a mixed cohort

A mixed cohort needs deliberate support for both confidence and challenge.

| Cohort need | Facilitation move | Example |
| --- | --- | --- |
| Newer to Kubernetes or AKS | Use primers, cheat sheets and paired navigation before commands. | Ask Copilot to explain namespaces, contexts or Workload Identity in plain language before applying manifests. |
| Experienced with Kubernetes | Give stretch goals tied to evidence quality. | Ask for a stronger failure-mode analysis, policy rationale or extra k6 scenario. |
| Newer to Azure | Provide subscription, resource group and role vocabulary early. | Draw the relationship between subscription, resource group, AKS cluster, ACR and Key Vault. |
| Experienced with Azure | Ask them to coach without taking over the keyboard. | Make them the reviewer who checks command output and evidence completeness. |
| Trainers learning to redeliver | Narrate your facilitation choices. | Say, "I am demoing this because identity failures can block the entire room." |

## Demo-vs-drive decision rules

Use the default module guidance in [delivery-playbook.md](delivery-playbook.md), then adjust based on room conditions.

### Demo when

- A mistake would break many learners or consume more than 10 minutes to recover.
- The task introduces a new mental model, such as GitOps reconciliation or Workload Identity.
- Copilot/MCP behavior is being introduced for the first time.
- You need to show evidence quality, not just command syntax.
- More than 25 percent of teams hit the same blocker.

### Let learners drive when

- The task produces assessment, design, validation or operations judgement.
- Teams can recover safely with documented commands.
- Learners need practice interpreting output.
- Evidence needs to be owned by the team.
- Experienced learners can pursue stretch goals without blocking newcomers.

## Supporting newcomers

Use a layered support model.

- Primer first: give the concept in two minutes before the command.
- Cheat sheet second: point to the relevant `kubectl`, Azure CLI or certification reference.
- Pairing third: pair with an experienced learner, but rotate who drives.
- Copilot explanation fourth: ask the AKS Engagement Copilot to explain output, risks or next steps.
- Trainer escalation last: intervene when the team cannot classify the issue or risks falling behind.

Sample newcomer prompt:

```text
Explain this AKS command output for someone new to Kubernetes. Focus on what is healthy, what is risky and what I should check next.
```

## Keeping experts engaged

Do not give experts unrelated work. Give them deeper evidence work that improves the team outcome.

- M1: compare CKA, CKAD, CKS and Red Hat OpenShift certification paths for two real delivery roles.
- M2: add non-functional dependencies, hidden state and failure domains to the map.
- M3: strengthen the WAR rationale with explicit trade-offs and prioritized mitigations.
- M4: add an extra diagram or as-built section that explains identity, ingress or GitOps sequencing.
- M5: expand validation with negative tests, k6 thresholds or chaos hypotheses.
- M6: add escalation paths, SLO burn-rate thinking or upgrade-ring planning.

## Managing Copilot and MCP live

Copilot/MCP should be visible, auditable and optional.

1. State the skill and MCP server before invoking it.
2. Show the prompt on screen.
3. Ask learners what evidence the output should produce.
4. Review the response for assumptions, missing values and hallucinated resource names.
5. Convert the response into a learner-owned artifact.
6. If the agent, skill or MCP server fails, switch to the manual lab path without apology.

Use these prompts as patterns.

```text
Use the workload-assessment skill to identify upstream and downstream dependencies for this AKS migration scenario. Return a dependency map and a remediation backlog with effort and risk.
```

```text
Use Microsoft Docs MCP to verify the current AKS Workload Identity guidance. Summarize only the steps relevant to this lab and cite the documentation source.
```

```text
Use Azure MCP to inspect the current AKS cluster context and highlight anything that may affect ingress, identity, observability or GitOps reconciliation.
```

## Questioning techniques

Ask questions that reveal understanding and evidence quality.

| Moment | Question | What it surfaces |
| --- | --- | --- |
| Before commands | What control are we proving? | Keeps work tied to Module B. |
| After Copilot output | Which assumption must we verify in Azure or GitHub? | Prevents unverified AI output from becoming evidence. |
| During assessment | What dependency would break the service first? | Exposes operational risk. |
| During design | Which trade-off did you choose and why? | Builds defensible architecture rationale. |
| During validation | Would a customer sign this result? Why? | Prepares for M5 gating. |
| During operations | Who owns this runbook action at 02:00? | Converts documentation into operations reality. |

## Time-boxing and recovery

Use clear time boxes and visible checkpoints.

- Announce the module evidence target and the hard stop time.
- Put a midpoint checkpoint on the board.
- Use the 70 percent rule: if a team has a usable artifact at 70 percent quality, move forward and log improvements.
- Keep a parking lot for non-blocking platform debates.
- Use reference outputs only as recovery aids or scoring calibration, not as a replacement for learner work.
- Protect M5 and M6 time. Do not let M4 deployment troubleshooting consume validation and operations.

## Handling B.1.1 certification-readiness discussion

B.1.1 is about organizational readiness, not memorizing exam codes. Keep the discussion practical and respectful.

- Require two named FTE roles, such as platform engineer and application engineer.
- Map each role to target certifications: CKA, CKAD, optional CKS and Red Hat OpenShift EX280 or DO280 as the cross-platform option.
- Discuss current skill level, target role, study timeline, lab practice and mentoring plan.
- Avoid shaming gaps. Treat gaps as delivery risks with mitigations.
- Connect certification readiness to customer confidence, supportability and partner specialization evidence.

## Evidence coaching

Evidence should be specific, reviewable and customer-ready.

- Replace generic claims with named artifacts, command output, diagrams or decision records.
- Check that placeholders are resolved or clearly marked as environment-specific.
- Require rationale for backlog priority, WAR findings and sign-off decisions.
- Make learners store artifacts as they go, not after the day ends.
- Use [scoring.md](scoring.md) to calibrate pass, partial and fail decisions.

## Trainer narration moments

Because this is Train-the-Trainer, periodically explain your own teaching decisions.

- "I am using a demo here because identity errors are hard to recover from under time pressure."
- "I am letting you drive here because the assessment judgement is the evidence."
- "I am rejecting this artifact as a full pass because it lacks customer sign-off."
- "I am using Copilot to accelerate structure, then requiring you to verify every concrete Azure value."
