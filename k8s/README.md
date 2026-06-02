# Kubernetes Deployment Guide 🚀

## Directory Structure

```
k8s/
├── namespace.yml        # Namespace for resource isolation
├── configmap.yml        # Non-sensitive configuration
├── deployment.yml       # Backend & MongoDB deployments
├── service.yml          # Services & Ingress
├── autoscaling.yml      # HPA & Pod Disruption Budget
├── kustomization.yaml   # Kustomize configuration
└── README.md           # This file
```

## Prerequisites

- Kubernetes cluster (v1.24+)
- kubectl configured
- Docker image `shop-backend` in registry
- (Optional) Ingress Controller

## Quick Start

### 1. Create Namespace and Secrets

```bash
# Apply namespace
kubectl apply -f k8s/namespace.yml

# Verify namespace
kubectl get ns shop
```

### 2. Deploy Everything with Kustomize

```bash
# Apply all resources
kubectl apply -k k8s/

# Or apply individual files
kubectl apply -f k8s/configmap.yml
kubectl apply -f k8s/deployment.yml
kubectl apply -f k8s/service.yml
kubectl apply -f k8s/autoscaling.yml
```

### 3. Verify Status

```bash
# Check Deployments
kubectl get deployments -n shop

# Check Pods
kubectl get pods -n shop

# View logs
kubectl logs -n shop deployment/shop-backend -f

# Check Services
kubectl get svc -n shop
```

## Detailed Configuration

### Backend Deployment
- **Replicas**: 2 (by default)
- **Strategy**: RollingUpdate (zero downtime)
- **Resources**:
  - Requests: 100m CPU, 128Mi Memory
  - Limits: 500m CPU, 512Mi Memory
- **Health Checks**: Liveness & Readiness probes

### MongoDB Deployment
- **Image**: mongo:7-alpine
- **Volume**: EmptyDir (for development)
- **Production**: Replace with PersistentVolumeClaim

### Autoscaling (HPA)
- **Min replicas**: 2
- **Max replicas**: 10
- **Trigger**: CPU > 70% or Memory > 80%

## Cluster Management

### Scaling

```bash
# Manual scaling
kubectl scale deployment shop-backend -n shop --replicas=5

# Check HPA status
kubectl get hpa -n shop

# Watch HPA metrics
kubectl get hpa shop-backend-hpa -n shop --watch
```

### Updates

```bash
# Update image
kubectl set image deployment/shop-backend \
  backend=shop-backend:v2 -n shop

# Check rollout status
kubectl rollout status deployment/shop-backend -n shop

# Rollback (if something goes wrong)
kubectl rollout undo deployment/shop-backend -n shop
```

### Logs & Debugging

```bash
# Deployment logs
kubectl logs -n shop deployment/shop-backend

# Specific pod logs
kubectl logs -n shop pod/shop-backend-xxxx

# Describe pod
kubectl describe pod -n shop shop-backend-xxxx

# Execute command in pod
kubectl exec -it -n shop pod/shop-backend-xxxx -- /bin/sh
```

## Production Considerations

### Security

- ⚠️ **Replace base64 with Sealed Secrets**
  ```bash
  # Install Sealed Secrets Controller
  kubectl apply -f https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.24.0/controller.yaml
  
  # Encrypt secret
  echo -n 'password' | kubectl create secret generic shop-secret \
    --dry-run=client --from-file=/dev/stdin \
    -o yaml | kubeseal -o yaml > sealed-secret.yaml
  ```

### Persistence

- ⚠️ **MongoDB requires PersistentVolumeClaim**
  ```yaml
  volumeMounts:
  - name: mongodb-storage
    mountPath: /data/db
  volumes:
  - name: mongodb-storage
    persistentVolumeClaim:
      claimName: mongodb-pvc
  ```

### Monitoring

- Add **Prometheus** for metrics
- Add **Loki** for logs
- Add **Grafana** for dashboards

### Networking

- Configure **Ingress** for external access
- Use **TLS** (cert-manager)
- **Network Policies** for segmentation

## Troubleshooting

### Pods Not Starting

```bash
# Check pod status
kubectl describe pod -n shop <pod-name>

# Check events
kubectl get events -n shop

# Check image
kubectl get pods -n shop -o jsonpath='{.items[*].spec.containers[*].image}'
```

### MongoDB Connection Error

```bash
# Check MongoDB pod logs
kubectl logs -n shop deployment/shop-mongodb

# Connect with MongoDB client
kubectl exec -it -n shop deployment/shop-mongodb -- mongosh

# Check credentials
kubectl get secret -n shop shop-backend-secret -o yaml
```

### HPA Not Scaling

```bash
# Check metrics-server
kubectl get deployment metrics-server -n kube-system

# Check HPA status
kubectl describe hpa -n shop shop-backend-hpa
```

## Cleanup

```bash
# Delete all resources in namespace
kubectl delete namespace shop

# Delete individual resources
kubectl delete -f k8s/deployment.yml -n shop
```

## Useful Links

- [Kubernetes Docs](https://kubernetes.io/docs/)
- [Sealed Secrets](https://github.com/bitnami-labs/sealed-secrets)
- [Kustomize](https://kustomize.io/)
- [Ingress Controller](https://kubernetes.github.io/ingress-nginx/)

---

Ready for production deployment! 🚀

