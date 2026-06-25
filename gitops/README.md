# `gitops/` — Flux v2 (app‑of‑apps)

Declarative deployment of the polyglot workloads to AKS, demonstrating the **GitOps**
delivery model required for B.4.1 / B.5.2.

## Layout
```text
gitops/
├── clusters/microhack/        # Flux Kustomizations + sources for the lab cluster
├── infrastructure/            # ingress, cert, observability add‑ons (HelmReleases)
└── apps/                      # per‑service Kustomizations (dev/prod overlays)
```

## Conventions
- App‑of‑apps pattern; environment promotion via overlays.
- Pin chart/image versions; reconcile from the repo's `main`.
- Manifests pass **kubeconform** + **kustomize build** in CI.

> Owned by workstream **WS2 (Apps)**.
