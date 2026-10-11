# Service validation test plan template

Use this template for Module B control B.5.1 evidence. Fill every section before asking for sign-off.

## Engagement summary

| Field | Value |
| --- | --- |
| Customer | `<customer-name>` |
| Date | `<yyyy-mm-dd>` |
| AKS cluster | `<cluster-name>` |
| Resource group | `<resource-group>` |
| Namespace | `<app-namespace>` |
| BFF endpoint | `<base-url>` |
| Tester | `<name>` |
| Customer reviewer | `<name>` |

## SLO and SLI table

| Service or flow | SLI | SLO target | Measurement source | Pass or fail |
| --- | --- | --- | --- | --- |
| BFF health | Availability during validation | `>= 99% successful health checks` | curl, k6, Azure Monitor | `<pass/fail>` |
| BFF request latency | HTTP request duration p95 | `< 500 ms under smoke load` | k6 or Azure Load Testing | `<pass/fail>` |
| BFF error rate | HTTP failed request rate | `< 1%` | k6 or Azure Load Testing | `<pass/fail>` |
| Order flow | End-to-end completion | `>= 95% successful test orders` | BFF response, API logs, worker logs | `<pass/fail>` |
| Recovery | Pod-failure recovery time | `< 5 minutes to healthy replica set` | kubectl events, Azure Monitor | `<pass/fail>` |
| Security | Baseline validation | `No critical open findings for tested release` | Defender, scanner, manifests | `<pass/fail>` |

## Functional tests

| ID | Test | Preconditions | Steps | Expected result | Evidence |
| --- | --- | --- | --- | --- | --- |
| F-01 | BFF health endpoint | `BASE_URL` is known | `curl -fsS $BASE_URL/health` | HTTP 200 with healthy status | `<link-or-output>` |
| F-02 | API readiness | AKS credentials available | `kubectl -n <app-namespace> get deploy dotnet-api` | Deployment ready replicas match desired replicas | `<link-or-output>` |
| F-03 | Worker readiness | AKS credentials available | `kubectl -n <app-namespace> get deploy python-worker` | Deployment ready replicas match desired replicas | `<link-or-output>` |

## Integration tests

| ID | Test | Preconditions | Steps | Expected result | Evidence |
| --- | --- | --- | --- | --- | --- |
| I-01 | End-to-end order submission | BFF can reach API and queue | POST a test order to `node-web` | Accepted response with order identifier | `<link-or-output>` |
| I-02 | API processing evidence | I-01 completed | Inspect `dotnet-api` logs or traces | API records the submitted order | `<link-or-output>` |
| I-03 | Worker processing evidence | I-01 completed | Inspect `python-worker` logs, metrics, or queue depth | Worker consumes or acknowledges the order message | `<link-or-output>` |

## Performance tests

| ID | Tool | Scenario | Load profile | Thresholds | Evidence |
| --- | --- | --- | --- | --- | --- |
| P-01 | k6 or Azure Load Testing | BFF smoke test | 5 virtual users for 2 minutes | p95 latency `< 500 ms`; failed requests `< 1%` | `<run-link-or-output>` |

### Performance evaluation

| Metric | Target | Actual | Pass or fail | Notes |
| --- | --- | --- | --- | --- |
| p95 latency | `< 500 ms` | `<actual>` | `<pass/fail>` | `<notes>` |
| HTTP error rate | `< 1%` | `<actual>` | `<pass/fail>` | `<notes>` |
| Requests per second | `<target>` | `<actual>` | `<pass/fail>` | `<notes>` |
| Pod restarts during test | `0 unexpected` | `<actual>` | `<pass/fail>` | `<notes>` |

## Resilience and chaos tests

| ID | Tool | Fault | Blast radius | Stop condition | Expected result | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| R-01 | Azure Chaos Studio or Litmus | Kill one app pod | One namespace and selected app label | Error rate exceeds SLO for 5 minutes or trainer stops test | Kubernetes replaces pod and service returns healthy within SLO | `<run-link-or-output>` |

## Security validation

| ID | Check | Method | Expected result | Evidence |
| --- | --- | --- | --- | --- |
| S-01 | Image scan status | Defender for Containers, ACR, or approved scanner | No critical findings open for tested image tags | `<link-or-output>` |
| S-02 | Network policy | `kubectl get networkpolicy` | Policies restrict app traffic boundaries | `<link-or-output>` |
| S-03 | Secrets handling | Manifest, pod, and log inspection | No plaintext secrets in manifests, env output, or logs | `<link-or-output>` |
| S-04 | Identity and secret source | Workload Identity or Key Vault CSI evidence | Apps use managed identity or mounted secrets instead of baked-in credentials | `<link-or-output>` |

## Risks and assumptions

- `<risk-or-assumption-1>`
- `<risk-or-assumption-2>`

## Approval to execute

| Role | Name | Approval | Date |
| --- | --- | --- | --- |
| Trainer | `<name>` | `<approved/not approved>` | `<yyyy-mm-dd>` |
| Customer reviewer | `<name>` | `<approved/not approved>` | `<yyyy-mm-dd>` |
