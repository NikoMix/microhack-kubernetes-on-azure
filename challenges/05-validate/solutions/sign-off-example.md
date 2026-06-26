# Customer sign-off example

This example shows a completed sign-off for trainer reference.

## Engagement details

| Field | Value |
| --- | --- |
| Customer | Contoso Retail |
| Engagement | Kubernetes on Azure Module B service validation |
| Control | B.5.1 Service Validation & Testing |
| AKS cluster | `aks-microhack-weu-01` |
| Namespace | `apps-prod` |
| Tested release | `node-web:1.0.3`, `dotnet-api:1.0.3`, `python-worker:1.0.3` |
| Validation date | 2026-06-26 |

## Scope validated

- `node-web` BFF health and request path.
- `dotnet-api` order API readiness and processing evidence.
- Queue-based handoff to `python-worker`.
- k6 smoke performance test.
- Azure Chaos Studio pod-kill experiment.
- Basic security validation for image scan status, network policy, and secrets handling.

## Results summary

| Evidence item | Result | Evidence reference |
| --- | --- | --- |
| Test plan | Complete | `test-plan-example.md` |
| Functional results | Pass | `results-example.md#functional-and-integration-evidence` |
| Integration results | Pass | `results-example.md#functional-and-integration-evidence` |
| Performance evaluation | Pass | `results-example.md#performance-evaluation` |
| Resilience or chaos results | Pass | `results-example.md#resilience-and-chaos-results` |
| Security validation | Pass with exception | `results-example.md#security-validation-results` |
| Remediation log | Complete | `results-example.md#remediation-log-excerpt` |

## Exceptions and remediations

| ID | Exception | Severity | Owner | Target date | Accepted for sign-off |
| --- | --- | --- | --- | --- | --- |
| M5-001 | Medium base-image advisory reported by scanner | Medium | App platform owner | 2026-07-10 | Yes |

## Acceptance decision

- [ ] Accepted with no exceptions.
- [x] Accepted with exceptions listed above.
- [ ] Not accepted; remediation required before sign-off.

## Signatures

| Role | Name | Signature | Date |
| --- | --- | --- | --- |
| Customer sponsor | Casey Customer | Casey Customer | 2026-06-26 |
| Customer technical approver | Taylor Techlead | Taylor Techlead | 2026-06-26 |
| Delivery lead | Jordan Delivery | Jordan Delivery | 2026-06-26 |
| Trainer or facilitator | Pat Facilitator | Pat Facilitator | 2026-06-26 |
