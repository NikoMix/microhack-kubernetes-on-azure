# Service validation results example

This sample result pack demonstrates how to compare evidence to SLOs for B.5.1.

## Summary

| Category | Result | Notes |
| --- | --- | --- |
| Functional | Pass | All health and readiness checks passed. |
| Integration | Pass | Test order flowed from BFF to API and worker. |
| Performance | Pass | p95 latency and error rate met smoke SLOs. |
| Resilience and chaos | Pass | Pod-kill recovery completed within target. |
| Security | Pass with exception | One medium image advisory recorded for remediation. |

## Functional and integration evidence

| Test ID | Timestamp | Expected | Actual | Pass or fail |
| --- | --- | --- | --- | --- |
| F-01 | 2026-06-26T15:14:08+02:00 | BFF health returns HTTP 200 | HTTP 200, body `{"status":"healthy"}` | Pass |
| F-02 | 2026-06-26T15:15:10+02:00 | `dotnet-api` ready replicas match desired | `2/2` ready | Pass |
| F-03 | 2026-06-26T15:15:18+02:00 | `python-worker` ready replicas match desired | `1/1` ready | Pass |
| I-01 | 2026-06-26T15:18:44+02:00 | Order accepted | HTTP 202 with order ID `mh-10042` | Pass |
| I-02 | 2026-06-26T15:19:05+02:00 | API logs show order | Correlation ID `mh-10042` found | Pass |
| I-03 | 2026-06-26T15:19:38+02:00 | Worker processes message | Worker log shows completed processing | Pass |

## Performance evaluation

The team ran `assets/k6-smoke.js` against the `node-web` BFF with 5 virtual users for 2 minutes. This is a smoke validation, not a full capacity test.

| Metric | SLO target | Actual | Pass or fail | Evidence |
| --- | --- | --- | --- | --- |
| HTTP request duration p95 | `< 500 ms` | `214 ms` | Pass | `k6-smoke-20260626.txt` |
| HTTP failed request rate | `< 1%` | `0.00%` | Pass | `k6-smoke-20260626.txt` |
| Checks passed | `> 99%` | `100%` | Pass | `k6-smoke-20260626.txt` |
| Unexpected pod restarts | `0` | `0` | Pass | `kubectl-pods-after-k6.txt` |

## Resilience and chaos results

| Metric | Target | Actual | Pass or fail |
| --- | --- | --- | --- |
| Fault type | Pod kill in app namespace | `dotnet-api` pod killed by Azure Chaos Studio | Pass |
| Recovery time | `< 5 minutes` | `74 seconds` | Pass |
| Health endpoint after recovery | HTTP 200 | HTTP 200 | Pass |
| Readiness behaviour | Failed pod removed from service endpoints | Replacement pod became ready before receiving traffic | Pass |

## Security validation results

| Check | Expected | Actual | Pass or fail |
| --- | --- | --- | --- |
| Image scan | No critical findings | No critical findings | Pass |
| Network policy | App namespace has explicit policies | Policies present for ingress and egress | Pass |
| Plaintext secrets | No plaintext secrets in manifests or logs | None found in sampled evidence | Pass |
| Identity and secret source | Workload Identity or Key Vault CSI | Key Vault CSI volume present | Pass |

## Remediation log excerpt

| ID | Issue | Severity | Test | Fix | Status | Owner |
| --- | --- | --- | --- | --- | --- | --- |
| M5-001 | Medium base-image advisory reported by scanner | Medium | S-01 | Rebuild image when patched base is available | Accepted risk | App platform owner |

## Final assessment

The validation pack supports **accepted with exceptions**. The only exception is medium severity, has an owner, and does not block lab sign-off.
