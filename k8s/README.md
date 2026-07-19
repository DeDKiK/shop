# k8s/ — Legacy Raw Manifests

> **Note:** This directory contains the original hand-written Kubernetes manifests from the first iteration of the project. The infrastructure has since been fully migrated to **Terraform** (`IaC/terraform/`), which is now the single source of truth for all cluster resources.
>
> These files are kept for reference to illustrate the evolution from raw `kubectl apply` to infrastructure-as-code.

## What changed and why

| Area | Raw manifests (this directory) | Terraform (`IaC/terraform/`) |
|---|---|---|
| Secret management | Credentials in `ConfigMap` | `kubernetes_secret` with `sensitive = true` |
| MongoDB storage | `emptyDir` (data lost on restart) | `PersistentVolumeClaim` (5 Gi, `wait_until_bound`) |
| Monitoring | Not included | Prometheus + Grafana via `kube-prometheus-stack` Helm |
| Repeatability | Manual `kubectl apply` per file | `terraform apply` provisions everything |
| State tracking | None | Terraform state file |

## Directory contents

```
k8s/
├── namespace.yml              # Namespace definition
├── backend-deployment.yml     # Backend Deployment + Service
├── frontend-deployment.yml    # Frontend Deployment + Service
├── mongo-deployment.yml       # MongoDB Deployment + Service
├── hpa-backend.yml            # HorizontalPodAutoscaler (backend)
├── hpa-frontend.yml           # HorizontalPodAutoscaler (frontend)
├── ingress.yml                # Ingress resource
├── kustomization.yaml         # Kustomize entry point
└── README.md                  # This file
```

## Current infrastructure

For the live infrastructure, see [`IaC/terraform/`](../IaC/terraform/):

- **Root module** (`dev/`) — providers, Helm release for `kube-prometheus-stack`, `ServiceMonitor` resources, Grafana dashboard `ConfigMap`
- **Child module** (`modules/`) — namespace, MongoDB, backend, frontend, ingress

Refer to the [root README](../README.md) for setup and deployment instructions.
