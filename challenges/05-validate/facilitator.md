# M05 facilitator guide · Service validation & testing

Use this guide to keep the 60-minute validation lab focused on evidence, not tool exploration.

## Timing breakdown

| Time | Activity | Facilitation notes |
| --- | --- | --- |
| 0-5 min | Frame B.5.1 evidence | Show the required evidence pack and remind learners that sign-off is gated by evidence. |
| 5-12 min | SLO and SLI primer | Drive one example: p95 latency is the SLI, `p95 < 500 ms` is the SLO. |
| 12-22 min | Functional and integration validation | Let learners run health and order-flow checks. Demo only if the endpoint discovery is slow. |
| 22-37 min | Performance validation | Run the k6 smoke path live. Use Azure Load Testing as the managed-service alternative if the cohort already has it provisioned. |
| 37-48 min | Resilience or chaos validation | Demo the blast-radius review, then let teams observe pod recovery or review a prepared Chaos Studio run. |
| 48-55 min | Security validation and remediation log | Ask each team to log at least one realistic exception, even if all tests pass. |
| 55-60 min | Sign-off and evidence handoff | Collect evidence and connect it to the scoring rubric. |

## Talking points

- Validation starts with customer-visible outcomes: availability, latency, error rate, recovery, and security baseline.
- A passing test without evidence is not useful in an engagement review.
- k6 is open-source and keeps the lab permissive; Azure Load Testing is acceptable when the customer wants a managed Azure run history.
- Chaos experiments must have a declared blast radius, rollback path, and observer.
- Customer sign-off is not a celebration slide. It is a formal acceptance record with exceptions and owners.

## Common pitfalls and fixes

| Pitfall | Fix |
| --- | --- |
| Testing without SLOs | Pause the team and have them fill the SLO table before running load or chaos tests. |
| Ignoring readiness gates during chaos | Ask learners to watch endpoints and pod readiness at the same time; recovery is not just a new pod existing. |
| Running load from a single underpowered client | Use this as a teachable limitation; keep local k6 as smoke only and recommend Azure Load Testing for distributed evidence. |
| Sign-off without evidence | Require links, command output, screenshots, or exported metrics for every acceptance statement. |
| Treating security as a scanner-only step | Include network policy, secret handling, image provenance, and Defender or scanner status. |
| Starting chaos before stakeholder consent | Require a blast-radius statement and stop condition before any fault is executed. |

## Demo-vs-drive guidance

Demo endpoint discovery and the first health check if the cohort is newer to AKS. Let learners drive the test-plan skill prompt because the discussion helps them understand evidence categories. For performance, demo local k6 once, then let teams run or inspect their own output. For chaos, choose based on readiness: demo Azure Chaos Studio setup if permissions are inconsistent; let experienced teams run Litmus or a prepared Chaos Studio pod-kill experiment.

## Cohort-split tips

- **Newer learners:** give them the default SLO table, the BFF URL, and the recommended pod-kill path. Pair them with someone comfortable reading `kubectl get pods --watch` output.
- **Experienced learners:** ask them to add HPA validation, compare local k6 and Azure Load Testing evidence quality, or design a CPU-pressure or network-fault experiment with a safe blast radius.
- **Mixed teams:** assign roles: test lead, evidence recorder, Azure observer, and customer sign-off reviewer.

## Evidence collected for scoring

Collect one evidence pack per team and score it with [the trainer scoring guide](../../trainer-guide/scoring.md).

- Test plan covering functional, integration, performance, resilience/chaos, and security categories.
- Results with evidence for health checks, end-to-end order flow, performance run, chaos or resilience run, and security validation.
- Performance evaluation against p95 latency, error rate, and throughput SLOs.
- Remediation log with owners and status for exceptions.
- Customer sign-off template showing acceptance, acceptance with exceptions, or rejection pending remediation.
