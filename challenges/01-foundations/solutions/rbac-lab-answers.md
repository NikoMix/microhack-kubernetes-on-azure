# RBAC lab answers

Trainer-only reference answers for the Module 1 RBAC and namespace exercises.

## Namespace exploration

Expected findings vary by cluster build, but learners should identify these patterns:

- `kube-system` hosts platform components and should not be used for application workloads.
- Additional namespaces may exist for policy, observability, ingress, GitOps, or security add-ons.
- User workloads should be placed in dedicated namespaces that match team or application boundaries.

## Role interpretation

A generated `pod-reader` Role should be namespace-scoped and should grant only `get`, `list`, and `watch` on pods.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader
  namespace: default
rules:
  - apiGroups:
      - ""
    resources:
      - pods
    verbs:
      - get
      - list
      - watch
```

## RoleBinding interpretation

A generated RoleBinding should bind the namespaced Role to the named subject in the same namespace.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: pod-reader-binding
  namespace: default
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: pod-reader
subjects:
  - apiGroup: rbac.authorization.k8s.io
    kind: User
    name: user@example.com
```

## Authorization discussion

Good learner explanations mention these points:

- Azure RBAC can govern Azure resource access and, when AKS Azure RBAC is enabled, Kubernetes API authorization integration.
- Kubernetes RBAC evaluates Kubernetes verbs, resources, and scopes through Roles, ClusterRoles, RoleBindings, and ClusterRoleBindings.
- Namespace RoleBindings do not grant cluster-wide permissions.
- `kubectl auth can-i` is a quick way to test an effective permission for the current identity or an impersonated subject.
