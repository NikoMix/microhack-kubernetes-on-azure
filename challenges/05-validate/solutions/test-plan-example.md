# Service validation test plan example

This completed example shows the expected evidence quality for Module B control B.5.1.

## Engagement summary

| Field | Value |
| --- | --- |
| Customer | Contoso Retail |
| Date | 2026-06-26 |
| AKS cluster | `aks-microhack-weu-01` |
| Resource group | `rg-microhack-aks-weu` |
| Namespace | `apps-prod` |
| BFF endpoint | `https://orders.contoso.example` |
| Tester | Learner Team Blue |
| Customer reviewer | Trainer customer role-player |

## SLO and SLI table

| Service or flow | SLI | SLO target | Measurement source | Pass or fail |
| --- | --- | --- | --- | --- |
| BFF health | Availability during validation | `>= 99% successful health checks` | k6 checks | Pass |
| BFF request latency | HTTP request duration p95 | `< 500 ms under smoke load` | k6 summary | Pass |
| BFF error rate | HTTP failed request rate | `< 1%` | k6 summary | Pass |
| Order flow | End-to-end completion | `>= 95% successful test orders` | BFF response, API logs, worker logs | Pass |
| Recovery | Pod-failure recovery time | `< 5 minutes to healthy replica set` | Chaos run and `kubectl` events | Pass |
| Security | Baseline validation | No critical open findings for tested release | Defender summary and manifests | Pass with exception |

## Functional tests

| ID | Test | Expected result | Actual result | Evidence |
| --- | --- | --- | --- | --- |
| F-01 | BFF health endpoint | HTTP 200 with healthy status | HTTP 200 in 46 ms | `curl-health-20260626.txt` |
| F-02 | API readiness | Desired and ready replicas match | `2/2` ready | `kubectl-deployments-20260626.txt` |
| F-03 | Worker readiness | Desired and ready replicas match | `1/1` ready | `kubectl-deployments-20260626.txt` |

## Integration tests

| ID | Test | Expected result | Actual result | Evidence |
| --- | --- | --- | --- | --- |
| I-01 | End-to-end order submission | Accepted response with order identifier | HTTP 202 with `orderId` | `order-flow-response.json` |
| I-02 | API processing evidence | API records the submitted order | Correlation ID found in API logs | `dotnet-api-order-log.txt` |
| I-03 | Worker processing evidence | Worker consumes the order message | Worker log shows processed order | `python-worker-order-log.txt` |

## Performance tests

| ID | Tool | Scenario | Load profile | Thresholds | Evidence |
| --- | --- | --- | --- | --- | --- |
| P-01 | k6 | BFF health and order smoke | 5 virtual users for 2 minutes | p95 latency `< 500 ms`; failed requests `< 1%` | `k6-smoke-20260626.txt` |

## Resilience and chaos tests

| ID | Tool | Fault | Blast radius | Stop condition | Result | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| R-01 | Azure Chaos Studio | Kill one `dotnet-api` pod | `apps-prod` namespace, `app=dotnet-api` selector | Error rate above SLO for 5 minutes | Replica replaced and endpoint healthy in 74 seconds | `chaos-pod-kill-run.json`, `events-after-chaos.txt` |

## Security validation

| ID | Check | Expected result | Actual result | Evidence |
| --- | --- | --- | --- | --- |
| S-01 | Image scan status | No critical findings open | No critical findings; one medium base-image advisory accepted for next sprint | `defender-image-summary.png` |
| S-02 | Network policy | Policies restrict app traffic boundaries | Namespace has ingress and egress policies for web to API and API to queue | `networkpolicies.yaml` |
| S-03 | Secrets handling | No plaintext secrets | No plaintext secrets found in manifests or sampled logs | `secret-review-notes.md` |
| S-04 | Identity and secret source | Managed identity or Key Vault CSI | Key Vault CSI volume present on API pods | `pod-describe-keyvault-csi.txt` |

## Risks and assumptions

- The k6 run is a smoke performance test, not a production-scale capacity test.
- Azure Load Testing is recommended before production cutover for distributed load evidence.
- One medium image advisory is tracked as remediation `M5-001` and accepted for lab sign-off.

## Approval to execute

| Role | Name | Approval | Date |
| --- | --- | --- | --- |
| Trainer | Pat Facilitator | Approved | 2026-06-26 |
| Customer reviewer | Casey Customer | Approved | 2026-06-26 |
