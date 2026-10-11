# Platform-currency plan — &lt;Customer A&gt;

> B.5.2 evidence (growth / currency). Export as `B5.2_PlatformCurrency_CustomerA_v1.pdf`.

## Kubernetes version management

- **Support policy:** stay within **N-2** of the latest AKS-supported minor version.
- **Auto-upgrade channel:** `patch` / `stable` / `rapid` — choose and justify.
- **Maintenance windows:** day/time; surge settings; PDBs verified before upgrade.
- **Upgrade runbook:** control-plane then node pools; canary user pool first.

## Node image currency

- **Node-image auto-upgrade** channel (`NodeImage` / `SecurityPatch`).
- Cadence and verification (drain-safe, PDB-aware).

## Deprecated API tracking

- Run `kubectl` deprecation checks / `kube-no-trouble` before each upgrade.
- Track removed APIs against manifests in `gitops/` and `apps/` charts.

## Add-ons & extensions

| Component | Current version | Latest | Action | Owner |
|---|---|---|---|---|
| Flux v2 extension | | | | |
| Defender for Containers | | | | |
| CSI Secret Store | | | | |
| Managed Prometheus / Grafana | | | | |

## Dependency & image patch cadence (zero known vulns)

- **Dependabot** (`.github/dependabot.yml`) covers nuget, npm, pip, github-actions, terraform,
  docker — review weekly.
- **Trivy** image/fs scan in CI fails on fixable HIGH/CRITICAL.
- **CodeQL** for csharp / python / javascript-typescript.
- Base images rebuilt on a fixed cadence; SBOM regenerated.

## Review cadence

| Activity | Frequency | Owner |
|---|---|---|
| AKS version review | Monthly | |
| Node-image review | Monthly | |
| Dependency / CVE review | Weekly | |
| DR drill | Quarterly | |
