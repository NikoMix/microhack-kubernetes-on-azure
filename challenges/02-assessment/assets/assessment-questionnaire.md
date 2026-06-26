# Workload assessment questionnaire

Use these discovery questions before and during dependency mapping. They follow the Azure Migrate pattern of discovery, dependency analysis, and readiness planning.

## Application ownership

- Who owns each service: `node-web`, `dotnet-api`, and `python-worker`?
- Who approves downtime, migration windows, and rollback decisions?
- Which teams own queue, data store, Key Vault, ACR, Azure Monitor, ingress, and firewall configuration?

## Runtime and deployment

- What runtime and version does each service require?
- How is each container image built, scanned, signed, and promoted?
- Which Kubernetes namespace, deployment, service, and service account does each workload use?
- Are images distroless or chiseled, running as non-root, and pinned by digest or immutable tag?

## Interfaces and dependencies

- Which upstream callers reach `node-web`?
- Which endpoints does `node-web` call on `dotnet-api`?
- Which queue or broker does `dotnet-api` publish to?
- Which queue does `python-worker` consume from?
- Which SQL, cache, object storage, or durable state stores are used?
- Which dependencies are synchronous, asynchronous, optional, or critical?

## Network and security

- Which ports and protocols are exposed by each service?
- Which ingress controller or gateway routes external traffic?
- Which outbound destinations must be allowed for ACR, Key Vault, Azure Monitor, queue, database, and DNS?
- Are Kubernetes NetworkPolicies present for service-to-service and egress traffic?
- Is private networking, Azure Firewall, or application gateway in the path?

## Secrets and identity

- Which secrets are required by each service?
- Are secrets mounted through Key Vault CSI rather than injected as plain environment variables?
- Which managed identity or Entra Workload Identity is bound to each service account?
- Who owns secret rotation and access review?
- Are registry pulls authorised by managed identity?

## Reliability and operations

- Which liveness, readiness, and startup probes exist?
- Are resource requests and limits set for every container?
- What metrics, traces, and logs are emitted through OpenTelemetry and Azure Monitor?
- What alerts prove user impact, dependency failures, or queue backlog?
- What backup, restore, and replay expectations exist for durable state?

## Readiness and remediation

- Which findings must be remediated before migration or production release?
- Which findings can be accepted temporarily with a documented risk owner?
- What is the effort and risk rating for each remediation?
- What evidence will show each backlog item is complete?
