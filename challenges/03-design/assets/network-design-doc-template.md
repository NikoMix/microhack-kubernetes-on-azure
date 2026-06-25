# Network design document template

Complete this document as supporting B.3.1 design evidence.

## Scope

| Item | Value |
| --- | --- |
| Region | `westeurope` |
| Topology | Hub and spoke |
| AKS network model | Azure CNI Overlay |
| Ingress | App Gateway for Containers or managed NGINX |
| Egress | Azure Firewall with UDR |
| DNS | Private DNS zones and forwarding through hub DNS |

## Address plan

| Network element | CIDR or address | Notes |
| --- | --- | --- |
| Hub VNet | `<hub-cidr>` | Shared connectivity, firewall, DNS |
| Spoke VNet | `<spoke-cidr>` | AKS and workload resources |
| AKS subnet | `<aks-subnet-cidr>` | Node IPs and overlay routing |
| Ingress subnet | `<ingress-subnet-cidr>` | App Gateway for Containers or ingress controller |
| Private endpoint subnet | `<private-endpoint-cidr>` | ACR, Key Vault, monitoring endpoints where used |
| Pod CIDR | `<pod-cidr>` | Overlay pod addresses |
| Service CIDR | `<service-cidr>` | Kubernetes services |

## Ingress flow

- Public or private entry point:
- TLS termination:
- WAF or ingress policy:
- Routing to `node-web`, `dotnet-api`, and internal services:
- Health probe path:

## Egress flow

- Route table association:
- Azure Firewall policy:
- Allowed FQDNs or service tags:
- Container image pulls from `<acr-login-server>`:
- Azure Monitor, Defender, Key Vault, and control-plane dependencies:

## DNS and name resolution

- Private DNS zones:
- Hub resolver or forwarder:
- AKS cluster DNS:
- Private endpoint records:
- External name resolution:

## Network security controls

| Control | Decision | Owner |
| --- | --- | --- |
| Network policy | `<decision>` | `<owner>` |
| NSGs | `<decision>` | `<owner>` |
| Firewall policy | `<decision>` | `<owner>` |
| Private endpoints | `<decision>` | `<owner>` |
| DDoS protection | `<decision>` | `<owner>` |

## Validation commands

```bash
az network vnet list --resource-group <resource-group> --output table
az network route-table route list --resource-group <resource-group> --route-table-name <route-table-name> --output table
az network firewall policy rule-collection-group list --resource-group <resource-group> --policy-name <firewall-policy-name> --output table
```
