# M05 · Service validation & testing

Validate the deployed polyglot application against agreed SLOs and package the evidence required for customer sign-off.

## Metadata

- **Duration:** 60 minutes
- **Control:** B.5.1 Service Validation & Testing
- **Evidence produced:** Test plan, test results, performance evaluation, remediation log, and customer sign-off
- **You will:** define SLOs and SLIs, run functional and integration checks, execute a performance test, run a controlled resilience experiment, complete a basic security validation, and assemble the sign-off pack.

## Prerequisites

- M0 completed: Azure access, `az`, `kubectl`, AKS credentials, GitHub Copilot, AKS Engagement Copilot, Azure MCP, GitHub MCP, and Microsoft Docs MCP validated.
- M4 completed: the `node-web`, `dotnet-api`, and `python-worker` services deployed through GitOps to the AKS cluster.
- Access to the AKS namespace that contains the deployed apps and permission to read pods, services, logs, events, and metrics.
- One performance option:
  - k6 installed locally or available in your lab shell.
  - Azure Load Testing access if you prefer the managed Azure service.
- One chaos option:
  - Azure Chaos Studio enabled for the AKS target.
  - Litmus installed in a lab namespace if you prefer an Apache-2.0 Kubernetes-native tool.
- Templates from this folder copied into your evidence workspace.

## Primer / concepts

Cloud-native validation is broader than “does the app start?” You test confidence in layers:

1. **Functional tests** prove individual externally visible behaviours, such as `/health` returning `200`.
2. **Integration tests** prove the request path across services, such as `node-web` BFF to `dotnet-api`, then queue processing by `python-worker`.
3. **Performance tests** prove the system meets latency, throughput, and error-rate targets under expected load.
4. **Resilience and chaos tests** prove the platform recovers when pods, nodes, or network paths fail in a controlled way.
5. **Security validation** proves baseline protections are present, such as image scan results, network policy, and no plaintext secrets.

An **SLI** is the measurement, such as p95 HTTP latency or request error rate. An **SLO** is the target you commit to, such as p95 latency below 500 ms for the BFF under smoke load. Sign-off means the customer agrees the scoped validation evidence is complete, understands exceptions, and accepts the remediation plan.

Use the AKS and Kubernetes primers at [/references/primer/](/references/primer/) and the Copilot/MCP reference at [/references/copilot-mcp/](/references/copilot-mcp/) if these terms are new.

> **Stretch goal:** Add an HPA load test that drives `node-web` or `dotnet-api` scaling, or run a CPU-pressure chaos fault and compare recovery time with the pod-kill experiment.

## Copilot + MCP usage

> Use the `test-plan` skill via the AKS Engagement Copilot to draft the validation approach. Use Azure MCP to discover AKS, Azure Load Testing, Azure Monitor, and Azure Chaos Studio context. Use Microsoft Docs MCP for current service guidance. If the skill or MCP servers are unavailable, follow the manual steps below and record that fallback in your results.

Example prompt:

```text
Invoke the test-plan skill for Module B control B.5.1. Draft a service validation plan for the deployed node-web BFF, dotnet-api, queue path, and python-worker on AKS. Include functional, integration, performance, resilience/chaos, and security tests; SLO/SLI targets; Azure Load Testing or k6 options; Azure Chaos Studio or Litmus options; evidence to collect; and a customer sign-off checklist.
```

## Step-by-step instructions

### 1. Define SLOs and SLIs

Open `assets/slo-targets.md` and confirm the default targets with your trainer or customer role-player. Adjust the targets only if the engagement context requires it.

Capture the runtime values you will test against:

```bash
az account show --query "{subscription:id, tenant:tenantId, name:name}" --output table
az aks get-credentials --resource-group <resource-group> --name <cluster-name>
kubectl get namespaces
kubectl get service,ingress -A
```

Set a BFF URL for later commands. Prefer the public ingress host from M4; use port-forwarding only when the service has no reachable test endpoint.

```bash
export BASE_URL="https://<node-web-hostname>"
curl -i "$BASE_URL/health"
```

Record the selected SLOs in `assets/test-plan-template.md` before you run tests. A test without an SLO can show activity, but it cannot prove acceptance.

### 2. Run functional and integration tests

Validate health endpoints for each service. If only `node-web` is externally reachable, use `kubectl port-forward` for internal service checks.

```bash
curl -fsS "$BASE_URL/health"
kubectl -n <app-namespace> get pods -o wide
kubectl -n <app-namespace> get deploy node-web dotnet-api python-worker
```

Run one end-to-end order flow through the BFF. Adjust the path if your deployment exposes a different order route.

```bash
curl -fsS -X POST "$BASE_URL/orders" \
  -H "content-type: application/json" \
  -d '{"sku":"trainer-kit","quantity":1,"customerId":"m5-lab"}'

kubectl -n <app-namespace> logs deploy/dotnet-api --tail=50
kubectl -n <app-namespace> logs deploy/python-worker --tail=50
```

In your results, include the command, timestamp, expected result, actual result, and evidence link or pasted output excerpt.

### 3. Run the performance test

Use k6 for the local open-source path, or Azure Load Testing for the managed service path. The same `assets/k6-smoke.js` script can be used by Azure Load Testing.

Run the local k6 smoke test:

```bash
BASE_URL="$BASE_URL" k6 run assets/k6-smoke.js
```

If you use Azure Load Testing, create or select a test resource with Azure MCP or Azure CLI, upload `assets/k6-smoke.js`, set `BASE_URL`, and run the test. Save the run summary and metrics export as evidence.

```bash
az load test list --resource-group <resource-group> --output table
az load test-run list --load-test-resource <load-test-name> --resource-group <resource-group> --output table
```

Compare the run to the SLOs:

- p95 BFF latency meets the selected target.
- HTTP request failure rate meets the selected target.
- Throughput is sufficient for the smoke scenario.
- No service pods restart unexpectedly during the test.

### 4. Run a resilience or chaos experiment

Pick one controlled experiment and announce the blast radius before you start. For a 60-minute lab, pod kill is the recommended default because it is visible and reversible.

Option A: use Azure Chaos Studio with an AKS pod-failure fault. Use Azure MCP to confirm the target, experiment identity, namespace, selector, duration, and permissions before starting the experiment.

```bash
az chaos experiment list --resource-group <resource-group> --output table
az chaos experiment start --resource-group <resource-group> --name <experiment-name>
az chaos experiment execution list --resource-group <resource-group> --experiment-name <experiment-name> --output table
```

Option B: use Litmus in a lab namespace with an approved pod-delete or network-loss experiment.

Observe self-healing while the fault runs:

```bash
kubectl -n <app-namespace> get pods --watch
kubectl -n <app-namespace> get events --sort-by=.lastTimestamp
curl -fsS "$BASE_URL/health"
```

Record recovery time, failed requests, pod restarts, and whether readiness probes prevented bad pods from receiving traffic.

### 5. Complete a basic security validation

Collect enough evidence to show the deployment still meets the security baseline after testing.

```bash
kubectl -n <app-namespace> get networkpolicy
kubectl -n <app-namespace> get secret -o name
kubectl -n <app-namespace> describe pods | grep -i "Image:"
az acr repository show-tags --name <acr-name> --repository <repository-name> --output table
```

Record:

- Image scan or Defender for Containers status for the tested images.
- Network policy presence for app traffic boundaries.
- No plaintext secrets in Kubernetes manifests, container environment output, or application logs.
- Workload Identity or Key Vault CSI use where secrets are required.

### 6. Assemble results, remediations, and sign-off

Complete these evidence files for your team:

- `assets/test-plan-template.md` copied as your filled test plan.
- A results record with functional, integration, performance, resilience/chaos, and security outcomes.
- A performance evaluation that compares k6 or Azure Load Testing metrics to the SLO table.
- `assets/remediation-log-template.csv` with every exception, owner, and status.
- `assets/sign-off-template.md` completed with the customer role-player.

If a test fails, do not hide it. Log the remediation, assign an owner, and mark the sign-off exception clearly.

## Validation checklist

- [ ] Test plan covers functional, integration, performance, resilience/chaos, and security tests. → B.5.1: test plan
- [ ] Results include commands, timestamps, expected outcomes, actual outcomes, and evidence links or excerpts. → B.5.1: results
- [ ] Performance evaluation compares p95 latency, error rate, and throughput to SLOs. → B.5.1: performance evaluation
- [ ] Remediation log lists every failed or partial test with owner, fix, severity, and status. → B.5.1: remediation log
- [ ] Customer sign-off template is complete, including scope, exceptions, and signatures. → B.5.1: customer sign-off

## Success criteria

You can explain which SLOs were tested, show evidence for every validation category, and state whether the service is accepted, accepted with exceptions, or not accepted pending remediation.

## What you produced

- A filled test plan.
- Functional and integration test results for the `node-web` to `dotnet-api` to queue to `python-worker` path.
- k6 or Azure Load Testing output with SLO comparison.
- Chaos or resilience evidence with recovery observations.
- Security validation notes.
- A remediation log and customer sign-off pack.

## Clean-up note

Do not tear down shared lab resources during this module. The end-of-day clean-up is coordinated after M6 with `scripts/teardown` from the repository contract.

## Next module

Continue to [M06 · Operate](../06-operate/README.md), where you turn validation evidence into post-deployment operations documentation.
