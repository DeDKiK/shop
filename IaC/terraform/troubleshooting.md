# Troubleshooting Log — Minikube + Terraform + Kubernetes + Helm

This document records real issues encountered while refactoring the Terraform
configuration for the `shop` project's local development environment
(Minikube cluster, Kubernetes resources, and a `kube-prometheus-stack`
monitoring stack via Helm).

Most of these issues are not "wrong Terraform code" in the traditional sense —
they are mismatches between Terraform's expectations and the quirks of a
specific local environment: provider bugs, state drift, and Docker networking
on a rootless setup. This kind of debugging is a normal (and large) part of
real infrastructure work, so it's documented here as a reference.

---

## 1. HCL Syntax Errors (Manual Editing)

### 1.1 `set {}` blocks outside `helm_release`

**Error**
```
Unexpected block: Blocks of type "set" are not expected here
```

**Cause**
The closing brace of the `helm_release` resource ended up earlier than
intended, leaving several `set {}` blocks declared at the top level of the
file instead of inside the resource.

**Fix**
Replaced all `set {}` blocks with a single `values = [yamlencode({...})]`
block. One nested HCL object is much harder to misplace than ten separate
`set` blocks.

---

### 1.2 Module variables not declared

**Error**
```
Unexpected attribute: An attribute named "namespace" is not expected here
```

**Cause**
`modules/variables.tf` was missing or incomplete. A module has **no implicit
access** to the parent module's variables — every input must be explicitly
declared with `variable {}` inside the module itself.

**Fix**
Declared all expected inputs (`namespace`, `backend_image`, `frontend_image`,
`backend_replicas`, `frontend_replicas`, `mongo_uri`, `mongo_storage_size`) in
`modules/variables.tf`.

---

### 1.3 Wrong type for `kubernetes_config_map.data`

**Error**
```
Inappropriate value for attribute "data": element "panels":
string required, but have tuple.
```

**Cause**
`data` in `kubernetes_config_map` is `map(string)` — every value must be a
string. The Grafana dashboard definition was written as a raw HCL object
directly under `data`, instead of being encoded as JSON text.

**Fix**
Wrapped the entire dashboard definition in `jsonencode({...})` under a single
key, `"shop-dashboard.json"`.

---

## 2. Minikube Provider `certSANs` Bug

**Error**
```
apiServer.certSANs: Invalid value: "": altname is not a valid IP address,
DNS label or a DNS label with subdomain wildcards...
```

**Root cause**
The `scott-the-programmer/minikube` provider (`~> 0.4.x`) generates a
`kubeadm.yaml` with an **empty `certSANs` entry**, which `kubeadm init`
rejects outright. This is a provider bug, not a configuration mistake.

**Attempted fixes that did *not* work**
- Removing `apiserver_name = "minikubeCA"`
- Explicitly setting `apiserver_ips = ["127.0.0.1"]`

**Working fix**
Removed the `minikube_cluster` resource and the `minikube` / `time`
providers from Terraform entirely. The cluster is now created and managed
manually:

```bash
minikube start \
  --profile shop-cluster \
  --driver docker \
  --cpus 4 \
  --memory 8192mb \
  --disk-size 30gb \
  --addons ingress,storage-provisioner \
  --kubernetes-version v1.30.0
```

Terraform now manages only the Kubernetes and Helm resources *inside* the
cluster.

**Takeaway**
For local Minikube setups, letting the Minikube CLI own the cluster lifecycle
is often more reliable than going through a Terraform provider — the CLI is
far more actively maintained than a niche provider.

---

## 3. Terraform State vs. Reality Drift

### 3.1 Renamed resources triggering destroy/create

**Symptom**
`terraform plan` showed `minikube_cluster.shop-cluster`,
`kubernetes_namespace.shop-app`, and `kubernetes_ingress_v1.shop-ingress` as
**to be destroyed**, with new-named equivalents (`shop`, `shop`, `shop`)
**to be created**.

**Cause**
The resources were renamed in code (`shop-cluster` → `shop`, `shop-app` →
`shop`, `shop-ingress` → `shop`). By default, Terraform treats a rename as
*delete the old resource, create a new one* — and destroying a namespace
deletes everything inside it.

**Fix**
```bash
terraform state mv 'minikube_cluster.shop-cluster' 'minikube_cluster.shop'
terraform state mv 'module.shop_app.kubernetes_namespace.shop-app' 'module.shop_app.kubernetes_namespace.shop'
terraform state mv 'module.shop_app.kubernetes_ingress_v1.shop-ingress' 'module.shop_app.kubernetes_ingress_v1.shop'
```
`state mv` renames the resource *in state* without touching real
infrastructure.

---

### 3.2 `EOF` errors / unreachable cluster

**Error**
```
Get "https://127.0.0.1:PORT/api/v1/namespaces/shop": EOF
```

**Cause**
The Minikube cluster was stopped (`minikube status` → `Stopped`), so the
Kubernetes API server wasn't responding to the provider at all.

**Fix**
```bash
minikube start -p shop-cluster
```

---

### 3.3 Phantom provider reference (`hashicorp/minikube`)

**Error**
```
Could not retrieve the list of available versions for provider
hashicorp/minikube: provider registry registry.terraform.io does not have
a provider named registry.terraform.io/hashicorp/minikube
```

**Cause**
After removing the `minikube_cluster` resource (see §2), `outputs.tf` still
referenced `minikube_cluster.shop.cluster_name`. Terraform inferred a
provider requirement from this dangling reference and resolved it to the
wrong registry namespace (`hashicorp/minikube`, which doesn't exist — the
correct one is `scott-the-programmer/minikube`).

**Fix**
Replaced the reference with `var.cluster_name`.

---

### 3.4 "already exists" after an interrupted `apply`

**Error**
```
Error: cannot re-use a name that is still in use
Error: namespaces "shop" already exists
```

**Cause**
A previous `terraform apply` was cancelled (Ctrl+C) mid-run. By that point it
had already sent create requests to Kubernetes and Helm — the `shop`
namespace and the `prometheus` Helm release existed in the cluster — but the
cancellation happened before Terraform recorded them in state.

**Fix**
```bash
helm uninstall prometheus -n monitoring
kubectl delete namespace shop
```
Then a clean `apply` from an empty, accurate state.

**Lesson**
Avoid cancelling `apply` mid-run when possible. If you must, verify the
*actual* cluster state afterward (`kubectl get ns`, `helm list -A`) — not
just `terraform state list`.

---

### 3.5 "Unexpected Identity Change" on imported resources

**Error**
```
Error: Unexpected Identity Change: During the read operation, the Terraform
Provider unexpectedly returned a different identity than the previously
stored one.

Current Identity: cty.ObjectVal(map[string]cty.Value{... NullVal ...})
New Identity:     cty.ObjectVal(map[string]cty.Value{"api_version":
                  cty.StringVal("apps/v1"), "kind": cty.StringVal("Deployment")...})
```

**Cause**
A bug in `hashicorp/kubernetes` provider `2.38.0`'s "resource identity"
feature. `terraform import` stores the identity fields as `null`; the next
`read` returns the real values from the cluster, and the provider treats this
as an illegal change rather than a normal population of previously-unknown
data.

**Fix**
```bash
terraform state rm 'module.shop_app.kubernetes_deployment.backend'
terraform state rm 'module.shop_app.kubernetes_deployment.frontend'
kubectl delete deployment shop-backend shop-frontend -n shop
```
Then let Terraform `create` the resources normally (not `import`) — a fresh
`create` populates identity correctly from the start.

---

## 4. Runtime Issues After Cluster Recreation

### 4.1 Deployments stuck at "0 replicas Ready"

**Error**
```
Error: Waiting for rollout to finish: 2 replicas wanted; 0 replicas Ready
```

**Cause**
`image_pull_policy = "Never"` requires the image to already exist in
Minikube's *internal* Docker daemon. After deleting and recreating the
Minikube VM, that daemon was empty — pods failed with `ErrImageNeverPull`,
so the rollout never reached `Ready`.

**Fix**
```bash
eval $(minikube docker-env -p shop-cluster)
docker build -t shop-backend:latest ./backend
docker build -t shop-frontend:latest ./frontend
```

---

### 4.2 `minikube tunnel` vs `minikube ip` confusion

**Issue**
`minikube tunnel` does **not** print an IP address — it's a long-running
foreground process (primarily for `LoadBalancer`-type services). The node IP
comes from a different, separate command.

**Fix**
```bash
minikube ip -p shop-cluster
```
`tunnel` and `ip` solve different problems; don't combine them in one step.

---

### 4.3 Ingress IP unreachable (`Connection timed out`)

**Symptom**
```bash
curl http://192.168.49.2
# Connection timed out

ping -c 3 192.168.49.2
# 100% packet loss
```
...while `kubectl` worked perfectly against the same cluster.

**Diagnosis**
```bash
ip route get 192.168.49.2
# routed via the WiFi gateway (10.22.94.67 dev wlp4s0) — not a docker bridge

ip -br addr show
# no br-xxxxxxxx interface for 192.168.49.0/24 exists at all
```

**Cause**
Rootless Docker. Container networks aren't exposed to host routing directly —
only through port-mapped `127.0.0.1:<port>`, which is exactly how `kubectl`
reaches the API server. The Minikube node's "real" IP (`192.168.49.2`) is
simply unreachable from the host, by design.

**Fix**
```bash
kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 8080:80
```
Then access the app at `http://localhost:8080`. The same approach works for
Grafana and Prometheus (`kubectl port-forward -n monitoring svc/... <port>:80`).

---

## General Lessons

- **State drift recovery tools matter.** `terraform state mv` and
  `terraform state rm` turned three potentially destructive situations into
  safe, non-disruptive fixes.
- **Provider maturity varies wildly.** When a provider behaves
  inconsistently across versions (the Minikube provider here), the pragmatic
  fix is often to shrink its scope and let a more mature, dedicated CLI own
  that part of the stack.
- **`kubectl port-forward` is the most portable access method** for a local
  cluster — it works regardless of the underlying Docker network
  configuration (rootless or not), unlike direct IP access or `minikube
  tunnel`.
- **Interrupting `apply` has real consequences.** Cancelling mid-run can
  leave the cluster and Terraform state out of sync in ways that produce
  confusing "already exists" errors later.