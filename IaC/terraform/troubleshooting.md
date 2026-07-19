# Troubleshooting Log — Minikube + Terraform + Kubernetes + Helm

Real issues encountered while building and refactoring the `shop` project's local infrastructure: Minikube cluster provisioning, Terraform state management, Docker networking on a rootless setup, and Helm / Kubernetes provider quirks.

These are not abstract examples — every entry below is something that actually broke and required investigation to fix. The goal of keeping this log is to show that infrastructure work involves a lot of debugging, and that knowing *how* to recover from failures is as important as writing the initial configuration.

---

## Table of Contents

1. [HCL Syntax Errors](#1-hcl-syntax-errors)
2. [Minikube Provider certSANs Bug](#2-minikube-provider-certsans-bug)
3. [Terraform State vs. Reality Drift](#3-terraform-state-vs-reality-drift)
4. [Runtime Issues After Cluster Recreation](#4-runtime-issues-after-cluster-recreation)

---

## 1. HCL Syntax Errors

### 1.1 `set {}` blocks outside `helm_release`

**Error**
```
Unexpected block: Blocks of type "set" are not expected here
```

**Cause**
The closing brace of a `helm_release` resource ended up in the wrong place during manual editing. Several `set {}` blocks were left declared at the file's top level instead of inside the resource body.

**Fix**
Replaced all `set {}` blocks with a single `values = [yamlencode({...})]` block. One nested HCL object is harder to accidentally misplace than ten separate `set` blocks, and produces cleaner diffs in version control.

---

### 1.2 Module variables not declared

**Error**
```
Unexpected attribute: An attribute named "namespace" is not expected here
```

**Cause**
`modules/variables.tf` was missing. A child module has no implicit access to the parent module's variables — every input must be explicitly declared with a `variable {}` block inside the module itself.

**Fix**
Added all expected inputs to `modules/variables.tf`:
```hcl
variable "namespace"          { type = string }
variable "backend_image"      { type = string }
variable "frontend_image"     { type = string }
variable "backend_replicas"   { type = number }
variable "frontend_replicas"  { type = number }
variable "mongo_storage_size" { type = string }
variable "mongo_uri" {
  type      = string
  sensitive = true
}
```

---

### 1.3 Wrong type for `kubernetes_config_map.data`

**Error**
```
Inappropriate value for attribute "data": element "panels":
string required, but have tuple.
```

**Cause**
The `data` attribute in `kubernetes_config_map` is `map(string)` — every value must be a plain string. The Grafana dashboard JSON was written as a raw HCL object directly under `data` instead of being serialised to a string first.

**Fix**
Wrapped the dashboard definition in `jsonencode({...})` under a single key:

```hcl
data = {
  "shop-dashboard.json" = jsonencode({
    title  = "Shop Application"
    panels = [ ... ]
  })
}
```

---

## 2. Minikube Provider certSANs Bug

**Error**
```
apiServer.certSANs: Invalid value: "": altname is not a valid IP address,
DNS label or a DNS label with subdomain wildcards...
```

**Root cause**
The `scott-the-programmer/minikube` Terraform provider (`~> 0.4.x`) generates a `kubeadm.yaml` with an **empty `certSANs` entry**, which `kubeadm init` rejects. This is a provider bug, not a configuration mistake.

**Attempted fixes that did not work**
- Removing `apiserver_name = "minikubeCA"`
- Explicitly setting `apiserver_ips = ["127.0.0.1"]`

**Working fix**
Removed the `minikube_cluster` resource and the `minikube` / `time` providers from Terraform entirely. The cluster is now created with the Minikube CLI directly:

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

Terraform now manages only the Kubernetes and Helm resources *inside* the already-running cluster.

**Takeaway**
For local Minikube setups, letting the Minikube CLI own the cluster lifecycle is more reliable than going through a Terraform provider. The CLI is actively maintained; the provider is not. Knowing when to drop a tool in favour of a simpler alternative is a real infrastructure skill.

---

## 3. Terraform State vs. Reality Drift

### 3.1 Renamed resources triggering destroy/recreate

**Symptom**
`terraform plan` showed `minikube_cluster.shop-cluster`, `kubernetes_namespace.shop-app`, and `kubernetes_ingress_v1.shop-ingress` as **to be destroyed**, with new equivalents **to be created**.

**Cause**
Resources were renamed in code (e.g. `shop-app` → `shop`). Terraform treats a rename as *delete old, create new* — and destroying a namespace deletes everything inside it.

**Fix**
```bash
terraform state mv \
  'minikube_cluster.shop-cluster' \
  'minikube_cluster.shop'

terraform state mv \
  'module.shop_app.kubernetes_namespace.shop-app' \
  'module.shop_app.kubernetes_namespace.shop'

terraform state mv \
  'module.shop_app.kubernetes_ingress_v1.shop-ingress' \
  'module.shop_app.kubernetes_ingress_v1.shop'
```

`state mv` renames the resource in state without touching real infrastructure.

---

### 3.2 EOF errors / unreachable cluster

**Error**
```
Get "https://127.0.0.1:PORT/api/v1/namespaces/shop": EOF
```

**Cause**
The Minikube cluster was stopped (`minikube status` → `Stopped`), so the Kubernetes API server was not responding.

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
After removing the `minikube_cluster` resource, `outputs.tf` still referenced `minikube_cluster.shop.cluster_name`. Terraform inferred a provider requirement from this dangling reference, resolving it to the wrong registry namespace (`hashicorp/minikube` does not exist — the correct one is `scott-the-programmer/minikube`).

**Fix**
Replaced the reference with `var.cluster_name`.

---

### 3.4 "already exists" after a cancelled apply

**Error**
```
Error: cannot re-use a name that is still in use
Error: namespaces "shop" already exists
```

**Cause**
A previous `terraform apply` was cancelled mid-run (Ctrl+C). Terraform had already sent create requests to Kubernetes and Helm — the `shop` namespace and `prometheus` Helm release existed in the cluster — but the cancellation happened before Terraform recorded them in state. The next `apply` tried to create them again.

**Fix**
```bash
helm uninstall prometheus -n monitoring
kubectl delete namespace shop
```

Then a clean `apply` from an accurate, empty state.

**Lesson**
Avoid cancelling `apply` mid-run. If you must, always verify the *actual* cluster state afterward — not just `terraform state list`:

```bash
kubectl get ns
helm list -A
```

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
A bug in `hashicorp/kubernetes` provider `2.38.0`. The `terraform import` command stores identity fields as `null`; the next `read` returns real values from the cluster, and the provider treats this as an illegal change rather than a normal initial population.

**Fix**
```bash
terraform state rm 'module.shop_app.kubernetes_deployment.backend'
terraform state rm 'module.shop_app.kubernetes_deployment.frontend'
kubectl delete deployment shop-backend shop-frontend -n shop
```

Then let Terraform `create` the resources from scratch — a fresh `create` populates the identity fields correctly from the start.

---

## 4. Runtime Issues After Cluster Recreation

### 4.1 Deployments stuck at "0 replicas Ready"

**Error**
```
Error: Waiting for rollout to finish: 2 replicas wanted; 0 replicas Ready
```

**Cause**
`image_pull_policy = "Never"` requires the image to exist in Minikube's *internal* Docker daemon. After deleting and recreating the Minikube VM, that daemon was empty — pods failed with `ErrImageNeverPull`.

**Fix**
```bash
# Point shell at Minikube's Docker daemon
eval $(minikube docker-env -p shop-cluster)

# Rebuild images inside it
docker build -t shop-backend:latest ./backend
docker build -t shop-frontend:latest .
```

This is a required step any time the Minikube VM is recreated.

---

### 4.2 `minikube tunnel` vs `minikube ip` confusion

**Issue**
`minikube tunnel` does **not** print an IP address — it is a long-running foreground process intended for `LoadBalancer`-type services. The node IP comes from a different command.

**Correct commands**
```bash
minikube ip -p shop-cluster     # prints the node IP
minikube tunnel -p shop-cluster # exposes LoadBalancer services (blocks terminal)
```

---

### 4.3 Ingress IP unreachable (rootless Docker)

**Symptom**
```bash
curl http://192.168.49.2   # Connection timed out
ping 192.168.49.2          # 100% packet loss
```

While `kubectl` worked perfectly against the same cluster.

**Diagnosis**
```bash
ip route get 192.168.49.2
# → routed via the WiFi gateway (wlp4s0), not a docker bridge

ip -br addr show
# → no br-xxxxxxxx interface for 192.168.49.0/24
```

**Cause**
Rootless Docker. Container networks are not exposed to host routing directly — only through port-mapped `127.0.0.1:<port>`. The Minikube node IP (`192.168.49.2`) is unreachable from the host by design.

**Fix**
Use `kubectl port-forward` for all local access:

```bash
# Shop app (via Ingress controller)
kubectl port-forward -n ingress-nginx \
  svc/ingress-nginx-controller 8080:80
# → http://localhost:8080

# Grafana
kubectl -n monitoring port-forward \
  svc/prometheus-grafana 3000:80
# → http://localhost:3000

# Prometheus
kubectl -n monitoring port-forward \
  svc/prometheus-kube-prometheus-prometheus 9090:9090
# → http://localhost:9090
```

`kubectl port-forward` is the most portable access method for local clusters — it works regardless of Docker network configuration (rootless or not), unlike direct IP access or `minikube tunnel`.

---

## General Lessons

**State drift recovery tools matter.** `terraform state mv` and `terraform state rm` turned three potentially destructive situations into safe, non-disruptive fixes. Knowing these commands before you need them is important.

**Provider maturity varies.** When a provider behaves inconsistently, the pragmatic fix is often to shrink its scope and let a more mature, dedicated CLI own that part of the stack. Recognising this trade-off early saves time.

**Interrupting `apply` has real consequences.** A cancelled mid-run `apply` can leave cluster state and Terraform state out of sync in ways that produce confusing errors later. Always verify both sides.

**`kubectl port-forward` is the safest local access method.** It works in any networking configuration. Save `minikube tunnel` for `LoadBalancer` services specifically.
