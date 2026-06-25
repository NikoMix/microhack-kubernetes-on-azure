# Prep checklist

Use this checklist to prepare the classroom, Azure environment, Copilot/MCP dependencies and trainer dry-run for the Module B MicroHack.

## T-minus 2 weeks

### Azure subscriptions and access

- [ ] Confirm the number of learner teams and whether they share or each receive a subscription.
- [ ] Confirm each subscription can deploy resources in West Europe.
- [ ] Assign trainer break-glass access with Owner permissions.
- [ ] Assign learner access with Owner or Contributor permissions at the subscription or dedicated resource-group scope.
- [ ] Confirm budget, spending limits and cleanup expectations.
- [ ] Document subscription IDs, tenant IDs and approved resource-group naming pattern.

### Quota and region

- [ ] Check vCPU quota in `westeurope` for the planned AKS node sizes.
- [ ] Check that the selected VM SKU family is available in West Europe.
- [ ] Confirm AKS versions available in West Europe.
- [ ] Prepare a fallback subscription or shared trainer cluster in case quota is blocked.

```bash
az vm list-usage --location westeurope -o table
az vm list-skus --location westeurope --size Standard_D --all -o table
az aks get-versions --location westeurope -o table
```

### Microsoft Entra setup

- [ ] Confirm learners can authenticate to the tenant used for the lab.
- [ ] Confirm Conditional Access policies will not block Azure CLI, GitHub Codespaces or browser sign-in.
- [ ] Confirm permissions for AKS Azure RBAC, managed identities and federated identity credentials.
- [ ] Confirm Key Vault data-plane access model and role assignment approach.
- [ ] Prepare an escalation contact for tenant or RBAC issues.

## T-minus 1 week

### Copilot agent and skills

- [ ] Confirm the AKS Engagement Copilot agent from WS4 is available or document that the manual path will be used.
- [ ] Confirm the `workload-assessment` skill is available for M2.
- [ ] Confirm the `hld-generator` skill is available for M3.
- [ ] Confirm the `war-runner` skill is available for M3.
- [ ] Confirm the `as-built` skill is available for M4 and M6.
- [ ] Confirm the `test-plan` skill is available for M5.
- [ ] Confirm the `runbook` skill is available for M6.
- [ ] Prepare a slide or note that explains the fallback when skills are unavailable.

### MCP server connectivity

- [ ] Confirm Azure MCP can authenticate and inspect the lab subscription.
- [ ] Confirm GitHub MCP can read the repository and relevant branches.
- [ ] Confirm Microsoft Docs MCP can retrieve AKS, certification and Azure Well-Architected guidance.
- [ ] Test a simple query against each MCP server from the trainer environment.
- [ ] Prepare a manual documentation fallback using Microsoft Learn and Azure CLI.

### Tooling

- [ ] Install or verify Azure CLI (`az`).
- [ ] Install or verify `kubectl`.
- [ ] Install or verify `kubelogin`.
- [ ] Install or verify Flux CLI (`flux`).
- [ ] Install or verify `k6`.
- [ ] Install or verify Node 24.
- [ ] Install or verify Python 3.14.
- [ ] Install or verify Docker Desktop, a compatible container runtime or GitHub Codespaces.
- [ ] Verify GitHub CLI or browser access for repository operations if used by the trainer.
- [ ] Confirm learners have an approved shell, such as Bash, PowerShell 7 or Codespaces terminal.

```bash
az version
kubectl version --client=true
kubelogin --version
flux --version
k6 version
node --version
python --version
docker version
```

## T-minus 1 day

### Full dry-run

- [ ] Dry-run M0 setup from a clean learner-like environment.
- [ ] Dry-run M1 certification-readiness output for two FTE roles.
- [ ] Dry-run M2 dependency map and remediation backlog.
- [ ] Dry-run M3 design document, architecture diagram and WAR export.
- [ ] Dry-run M4 deployment or delivery narrative, including Flux and ingress checks.
- [ ] Dry-run M5 validation, k6 or equivalent performance evidence and customer sign-off flow.
- [ ] Dry-run M6 operating documentation and Container Insights evidence.
- [ ] Confirm all facilitator guide links and scoring rubric references open.
- [ ] Confirm reference solutions are available for trainer recovery.
- [ ] Confirm cleanup or teardown process is understood but not run before the course.

### Classroom readiness

- [ ] Test projector or display sharing.
- [ ] Test audio if remote or hybrid participants are present.
- [ ] Prepare whiteboard or shared board.
- [ ] Prepare pairing list for mixed experience levels.
- [ ] Prepare evidence drop folders for `M0` through `M6`.
- [ ] Print or bookmark this checklist, [delivery-playbook.md](delivery-playbook.md), [facilitation.md](facilitation.md), [troubleshooting.md](troubleshooting.md) and [scoring.md](scoring.md).
- [ ] Prepare a visible parking-lot area for questions and blockers.

## Day-of checklist

### Before 08:30

- [ ] Trainer signed in to Azure, GitHub and Copilot.
- [ ] Correct Azure subscription selected.
- [ ] Network access verified.
- [ ] Projector or screen share working.
- [ ] Evidence drop location open and visible.
- [ ] Learner repo links ready.
- [ ] Troubleshooting commands ready.
- [ ] Reference environment or reference outputs ready.

### 08:30-09:00 welcome

- [ ] Explain the Train-the-Trainer goal.
- [ ] Explain the Module B control map.
- [ ] Explain evidence collection and scoring.
- [ ] Confirm pairings.
- [ ] Explain Copilot/MCP accelerator plus manual fallback.

### During modules

- [ ] Start each module by naming the control and required evidence.
- [ ] Use demo-vs-drive defaults from [delivery-playbook.md](delivery-playbook.md).
- [ ] Roam and check evidence quality, not only command success.
- [ ] Record common issues for the debrief.
- [ ] Protect M5 and M6 time boxes.

### End of day

- [ ] Confirm B.1.1 evidence collected.
- [ ] Confirm B.2.1 evidence collected.
- [ ] Confirm B.3.1 and B.3.2 evidence collected.
- [ ] Confirm B.4.1 evidence collected.
- [ ] Confirm B.5.1 evidence collected, including customer sign-off.
- [ ] Confirm B.5.2 evidence collected.
- [ ] Capture trainer feedback and curriculum improvements.
- [ ] Remind learners about cleanup timing and ownership.
