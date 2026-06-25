# RBAC and namespaces guided lab

Use these exercises to understand namespace scope and Kubernetes RBAC without modifying shared resources unless the trainer allows the stretch goal.

## Exercise 1: Read namespace state

Run these commands and identify which namespaces are platform-owned.

```bash
kubectl get namespaces
kubectl get pods --namespace kube-system
kubectl get pods --all-namespaces
```

Expected observations:

- `kube-system` contains platform components.
- Workload namespaces are separate from Kubernetes system namespaces.
- Namespace names scope many object names but do not automatically isolate every security boundary.

## Exercise 2: Generate a namespaced Role

Generate a read-only Role for pods in `default` without applying it.

```bash
kubectl create role pod-reader --verb=get,list,watch --resource=pods --namespace default --dry-run=client --output yaml
```

Expected shape:

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

## Exercise 3: Generate a RoleBinding

Generate a RoleBinding that attaches the Role to a sample user without applying it.

```bash
kubectl create rolebinding pod-reader-binding --role=pod-reader --user=user@example.com --namespace default --dry-run=client --output yaml
```

Expected shape:

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

## Exercise 4: Reason about permissions

Use `kubectl auth can-i` to ask authorization questions for your current identity.

```bash
kubectl auth can-i get pods --namespace default
kubectl auth can-i create rolebindings --namespace default
kubectl auth can-i get pods --all-namespaces
```

Expected interpretation:

- A `yes` result means your current identity is authorized for that verb and scope.
- A `no` result can come from Kubernetes RBAC, Azure RBAC for AKS, or identity configuration depending on the cluster mode.
- Namespace-scoped permissions do not imply cluster-wide permissions.
