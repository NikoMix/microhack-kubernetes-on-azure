# Cluster design document template

Complete this document as supporting B.3.1 design evidence.

## Scope

| Item | Value |
| --- | --- |
| AKS cluster | `<cluster-name>` |
| Region | `westeurope` |
| Resource group | `<resource-group>` |
| Kubernetes version | `<version>` |
| Network plugin | Azure CNI Overlay |
| Identity model | Microsoft Entra ID, Azure RBAC, Workload Identity |

## Node pools

| Pool | Purpose | VM size | Minimum | Maximum | Zones | Taints and labels |
| --- | --- | --- | --- | --- | --- | --- |
| system | Critical system pods | `<vm-size>` | `<min>` | `<max>` | `1,2,3` | `CriticalAddonsOnly=true:NoSchedule` |
| user-general | Application workloads | `<vm-size>` | `<min>` | `<max>` | `1,2,3` | `<labels>` |

## Capacity and autoscaling

- Expected pod count:
- Expected CPU and memory requests:
- Cluster autoscaler settings:
- Horizontal Pod Autoscaler assumptions:
- Pod disruption budget requirements:

## Upgrade and maintenance strategy

- AKS version skew policy:
- Planned maintenance window:
- Node image upgrade cadence:
- Surge settings:
- Rollback approach:

## Add-ons and extensions

- Azure Policy for AKS:
- Defender for Containers:
- Workload Identity:
- Key Vault CSI Secret Store:
- Container Insights:
- Managed Prometheus:
- Grafana:

## Security configuration

- API server access model:
- Azure RBAC roles:
- Kubernetes RBAC model:
- Network policy:
- Admission controls:

## Operational ownership

| Area | Owner | Evidence |
| --- | --- | --- |
| Cluster platform | `<team>` | `<link-or-note>` |
| Application namespaces | `<team>` | `<link-or-note>` |
| Security monitoring | `<team>` | `<link-or-note>` |
| Backup and recovery | `<team>` | `<link-or-note>` |
