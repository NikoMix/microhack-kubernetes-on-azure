# Customer sign-off template

Use this template after the validation evidence is complete. Sign-off can be accepted, accepted with exceptions, or rejected pending remediation.

## Engagement details

| Field | Value |
| --- | --- |
| Customer | `<customer-name>` |
| Engagement | Kubernetes on Azure Module B service validation |
| Control | B.5.1 Service Validation & Testing |
| AKS cluster | `<cluster-name>` |
| Namespace | `<app-namespace>` |
| Tested release | `<release-or-image-tags>` |
| Validation date | `<yyyy-mm-dd>` |

## Scope validated

- `node-web` BFF health and request path.
- `dotnet-api` order API readiness and processing evidence.
- Queue-based handoff to `python-worker`.
- Performance smoke test with k6 or Azure Load Testing.
- Resilience or chaos experiment with Azure Chaos Studio or Litmus.
- Basic security validation for image scan status, network policy, and secrets handling.

## Results summary

| Evidence item | Result | Evidence reference |
| --- | --- | --- |
| Test plan | `<complete/incomplete>` | `<link-or-file>` |
| Functional results | `<pass/fail>` | `<link-or-file>` |
| Integration results | `<pass/fail>` | `<link-or-file>` |
| Performance evaluation | `<pass/fail>` | `<link-or-file>` |
| Resilience or chaos results | `<pass/fail>` | `<link-or-file>` |
| Security validation | `<pass/fail>` | `<link-or-file>` |
| Remediation log | `<complete/incomplete>` | `<link-or-file>` |

## Exceptions and remediations

| ID | Exception | Severity | Owner | Target date | Accepted for sign-off |
| --- | --- | --- | --- | --- | --- |
| `<id>` | `<exception>` | `<severity>` | `<owner>` | `<yyyy-mm-dd>` | `<yes/no>` |

## Acceptance decision

- [ ] Accepted with no exceptions.
- [ ] Accepted with exceptions listed above.
- [ ] Not accepted; remediation required before sign-off.

## Signatures

| Role | Name | Signature | Date |
| --- | --- | --- | --- |
| Customer sponsor | `<name>` | `<signature>` | `<yyyy-mm-dd>` |
| Customer technical approver | `<name>` | `<signature>` | `<yyyy-mm-dd>` |
| Delivery lead | `<name>` | `<signature>` | `<yyyy-mm-dd>` |
| Trainer or facilitator | `<name>` | `<signature>` | `<yyyy-mm-dd>` |
