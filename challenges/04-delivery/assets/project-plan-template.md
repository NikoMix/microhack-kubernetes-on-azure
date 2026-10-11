# Project plan template

Use this template when your evidence pack includes a project plan for Control B.4.1.

## Project summary

| Field | Value |
| --- | --- |
| Project | AKS secure baseline delivery and workload migration |
| Control | B.4.1 Delivery |
| Duration | `<planned-duration>` |
| Delivery owner | `<owner>` |
| Customer contact | `<contact>` |
| Scope | Deploy baseline, publish images, bootstrap GitOps, validate identity, ingress, and observability |

## Work breakdown

| ID | Work item | Owner | Entry criteria | Exit criteria | Evidence |
| --- | --- | --- | --- | --- | --- |
| 1 | Confirm environment readiness | `<owner>` | M0 complete | Subscription, tools, and access confirmed | Preflight output |
| 2 | Deploy AKS secure baseline | `<owner>` | Infra parameters approved | AKS, ACR, Key Vault, network, policy, and observability resources deployed | Deployment output |
| 3 | Build and publish service images | `<owner>` | ACR available | Three tagged images present in ACR | ACR repository tags |
| 4 | Bootstrap Flux app-of-apps | `<owner>` | GitOps repo reachable | Flux source and Kustomizations Ready | Flux output |
| 5 | Verify workload runtime | `<owner>` | Flux reconciled | Pods Running and ingress responds | kubectl and curl output |
| 6 | Verify identity and observability | `<owner>` | Workloads running | Workload Identity and telemetry confirmed | Azure MCP or portal evidence |
| 7 | Produce as-built and diagrams | `<owner>` | Validation complete | Evidence pack ready for scoring | As-built and diagrams |

## Milestones

| Milestone | Target time | Acceptance criteria |
| --- | --- | --- |
| Baseline ready | `<time>` | Cluster and registry outputs resolved |
| Images ready | `<time>` | Three services have traceable tags in ACR |
| GitOps ready | `<time>` | Flux app-of-apps reconciles from Git |
| Workloads ready | `<time>` | Pods Running and ingress test succeeds |
| Evidence ready | `<time>` | As-built plus required diagrams completed |

## Risks and mitigations

| Risk | Impact | Mitigation | Owner |
| --- | --- | --- | --- |
| ACR pull permission missing | Workloads cannot start | Validate `AcrPull` role assignment before Flux reconcile | `<owner>` |
| GitOps repository access blocked | Flux source not Ready | Confirm deploy key, branch, path, and egress | `<owner>` |
| Image platform mismatch | Pods fail on node pool | Build with `--platform linux/amd64` unless ARM64 is confirmed | `<owner>` |
| Ingress DNS or certificate delay | External validation blocked | Test internal service first and capture ingress controller status | `<owner>` |
| Telemetry delay | Observability evidence late | Verify agents first, then use latest available workspace query or screenshot | `<owner>` |

## Communication plan

| Audience | Update | Channel | Frequency |
| --- | --- | --- | --- |
| Trainer | Delivery progress and blockers | Classroom check-in | Every milestone |
| Learner pair | Command ownership and evidence capture | Pair discussion | Continuous |
| Customer role-play | Scope, validation, and evidence handoff | Evidence review | End of module |

## Acceptance

The project plan is complete when every work item has an owner, exit criteria, and evidence location, and the evidence pack proves at least two B.4.1 delivery artifacts plus logical, physical, and sequence diagrams.
