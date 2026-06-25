# SLO and SLI targets

Use these defaults unless your trainer or customer role-player provides stricter engagement targets.

## Target table

| Area | Service or flow | SLI | Default SLO target | Evidence source |
| --- | --- | --- | --- | --- |
| Availability | `node-web` BFF health | Successful health checks during validation window | `>= 99%` | curl, k6 checks, Azure Monitor availability |
| Latency | `node-web` BFF requests | HTTP request duration p95 | `< 500 ms` under smoke load | k6 or Azure Load Testing |
| Reliability | `node-web` BFF requests | HTTP request failure rate | `< 1%` under smoke load | k6 or Azure Load Testing |
| Integration | Order flow through BFF, API, queue, and worker | Successful test orders | `>= 95%` of submitted test orders accepted and processed | BFF response, API logs, worker logs, queue depth |
| Resilience | Pod failure recovery | Time from injected fault to healthy desired replica count | `< 5 minutes` | Azure Chaos Studio or Litmus run, `kubectl`, Azure Monitor |
| Security | Tested release baseline | Critical security exceptions | `0 open critical findings` at sign-off | Defender for Containers, image scanner, manifests, network policies |

## Notes

- These SLOs are lab targets, not production promises.
- If a metric is unavailable, record the gap in the remediation log instead of inventing a value.
- Keep the same SLO table in the test plan, results, and sign-off so the evidence pack is consistent.
