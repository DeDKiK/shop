# Shop 🛒

Full-stack e-commerce application deployed on a local Kubernetes cluster — built as a DevOps portfolio project demonstrating infrastructure-as-code, container orchestration, and observability practices.

## Architecture

A complete e-commerce platform featuring:
- Product listing and management
- Shopping cart functionality
- User authentication (login/registration)
- Order management
- Responsive design with CSS modules
- Docker-based local deployment
- Kubernetes and Terraform support for deployment automation

Built as a learning and portfolio project with a modern web stack.

```text
┌─────────────────────────────────────────────┐
│           Minikube (shop-cluster)           │
│                                             │
│  ┌──────────────┐    ┌──────────────────┐   │
│  │  Frontend    │    │   Backend        │   │
│  │  nginx +     │    │   Node.js /      │   │
│  │  exporter    │    │   Express        │   │
│  └──────┬───────┘    └────────┬─────────┘   │
│         │ /metrics             │ /metrics   │
│         ▼                      ▼            │
│  ┌─────────────────────────────────────┐    │
│  │   Prometheus (kube-prometheus-stack)│    │
│  │   ServiceMonitor × 2                │    │
│  └──────────────────┬──────────────────┘    │
│                     ▼                       │
│  ┌─────────────────────────────────┐        │
│  │   Grafana + custom dashboard     │       │
│  └─────────────────────────────────┘        │
│                                             │
│  ┌───────────────────────┐                  │
│  │   MongoDB + PVC 5Gi   │                  │
│  └───────────────────────┘                  │
└─────────────────────────────────────────────┘
```

All resources are managed by Terraform (Kubernetes + Helm providers).

## Technologies

### Frontend
- React 19
- TypeScript
- Webpack + Babel
- CSS Modules
- React Router
- Local storage-based cart state

### Backend
- Node.js + Express
- MongoDB + Mongoose
- CORS enabled
- Request validation with express-validator
- Prometheus metrics endpoint

### DevOps
- Docker & Docker Compose
- Nginx reverse proxy
- Kubernetes manifests in the k8s folder
- Terraform infrastructure definitions in the IaC folder

## Quick Start

### Prerequisites
- Docker & Docker Compose
- Node.js 22+ (for local development)
- Optional: kubectl for Kubernetes deployment
- Optional: Terraform for infrastructure provisioning

### Using Docker (Recommended)

```bash
# 1. Clone repository
git clone https://github.com/DeDKiK/shop.git
cd shop

# 2. Create environment file from example
cp .env.example .env

# 3. Start all services
docker compose up --build
```

## Tech Stack

**Application**
- Frontend: React 18, TypeScript, Webpack, CSS Modules
- Backend: Node.js, Express, MongoDB / Mongoose
- Reverse proxy: nginx (frontend container)

**Infrastructure**
- Container runtime: Docker
- Orchestration: Kubernetes (Minikube for local dev)
- IaC: Terraform — Kubernetes provider + Helm provider
- Package manager: Helm (`kube-prometheus-stack` v65.1.1)

**Observability**
- Metrics collection: Prometheus with two `ServiceMonitor` resources
- Backend instrumentation: `prom-client` — custom HTTP histogram + counter + default Node.js metrics
- Frontend instrumentation: `nginx-prometheus-exporter` sidecar
- Dashboards: Grafana with a provisioned custom dashboard (6 panels)

**CI/CD**
- GitHub Actions: type-check → lint → build → deploy to GitHub Pages

Copy `.env.example` to `.env` and configure:

```env
# MongoDB
MONGODB_URI=mongodb://localhost:27017/shop

# Server
PORT=5000
NODE_ENV=development
```

For Docker Compose, the following variables can also be used:

```env
MONGO_USER=root
MONGO_PASSWORD=password
MONGO_DB=shop
MONGO_PORT=27017
BACKEND_PORT=5000
FRONTEND_PORT=8080
MONGO_EXPRESS_PORT=8081
ME_CONFIG_USER=admin
ME_CONFIG_PASSWORD=admin
```

## API Endpoints

### Products
- `GET /api/products` - All products
- `GET /api/products/:id` - Product details
- `POST /api/products` - Create product
- `PUT /api/products/:id` - Update product
- `DELETE /api/products/:id` - Delete product

### Users
- `POST /api/users/register` - Register
- `POST /api/users/login` - Login
- `GET /api/users` - All users

### Orders
- `GET /api/orders` - All orders
- `GET /api/orders/user/:userId` - User orders
- `POST /api/orders` - Create order
- `PUT /api/orders/:id` - Update order

### Health and Metrics
- `GET /api/health` - Backend health check
- `GET /metrics` - Prometheus metrics

## Frontend Routes

The React application uses client-side routes:
- `/` or `/home` - Home page
- `/category/:category` - Category page
- `/login` - Login page
- `/register` - Registration page
- `/cart` - Cart page
- `/search` - Search page

## Repository Structure

```text
shop/
├── src/                          # React frontend
│   ├── App.tsx                  # Main application router
│   ├── index.tsx                # React entry point
│   ├── pages/                   # Page components
│   ├── AppComponents/           # Shared UI components
│   ├── context/                 # React Context (cart state)
│   ├── assets/                  # Static assets
│   └── style.css                # Global styles
├── backend/                     # Express API
│   ├── models/                  # Mongoose schemas (User, Product, Order)
│   ├── routes/                  # REST route handlers
│   └── server.js                # App entrypoint + prom-client setup
├── webpack/                     # Webpack configuration
├── IaC/
│   └── terraform/
│       ├── dev/                 # Root module (entry point)
│       │   ├── main.tf          # Module call + Helm release (prometheus stack)
│       │   ├── monitoring.tf    # ServiceMonitors + Grafana dashboard ConfigMap
│       │   ├── provider.tf      # kubernetes + helm providers
│       │   ├── variables.tf     # All input variables
│       │   ├── outputs.tf       # Access instructions output
│       │   ├── versions.tf      # Provider version constraints
│       │   └── terraform.tfvars.example
│       ├── modules/             # Child module: app resources
│       │   ├── namespace.tf     # Namespace + MongoDB Secret
│       │   ├── mongo.tf         # PVC + Deployment + Service
│       │   ├── backend.tf       # Deployment + Service + HPA
│       │   ├── frontend.tf      # Deployment + Service (nginx + sidecar)
│       │   ├── ingress.tf       # Ingress resource
│       │   ├── variables.tf     # Module input declarations
│       │   └── outputs.tf       # Exported resource names
│       └── troubleshooting.md  # Real debugging log
├── k8s/                         # Legacy raw manifests (pre-Terraform)
├── docker-compose.yml           # Local dev without Kubernetes
├── Dockerfile                   # Frontend image
├── backend/Dockerfile           # Backend image
├── nginx.conf                   # nginx config for frontend container
├── .github/workflows/ci-cd.yml  # GitHub Actions pipeline
└── eslint.config.mjs           # ESLint flat config (frontend + backend)
```

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- [Minikube](https://minikube.sigs.k8s.io/docs/start/) v1.30+
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Terraform](https://developer.hashicorp.com/terraform/install) ~> 1.7
- [Helm](https://helm.sh/docs/intro/install/) ~> 3.x

## Quick Start — Kubernetes (Terraform)

### 1. Start Minikube

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

### 2. Build Docker images inside Minikube's daemon

```bash
eval $(minikube docker-env -p shop-cluster)

docker build -t shop-backend:latest ./backend
docker build -t shop-frontend:latest .
```

### 3. Check Mongo Express
Visit http://localhost:8081 (admin/admin) to view the database.

> Images must be built inside Minikube's Docker daemon because `imagePullPolicy: Never` is set — the cluster will not pull from a registry.

### 3. Configure Terraform variables

```bash
cd IaC/terraform/dev
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` — at minimum set:

```hcl
mongo_uri              = "mongodb://mongo-service:27017/shop"
grafana_admin_password = "your-secure-password"
```

### 4. Apply infrastructure

```bash
terraform init
terraform apply
```

Terraform will provision: namespace, MongoDB (PVC + deployment), backend, frontend, nginx Ingress, Prometheus stack (via Helm), two `ServiceMonitor` resources, and a Grafana dashboard `ConfigMap`.

After `apply`, Terraform prints access instructions:

```text
Grafana:    kubectl -n monitoring port-forward svc/prometheus-grafana 3000:80
            http://localhost:3000  (admin / <your password>)

Prometheus: kubectl -n monitoring port-forward \
              svc/prometheus-kube-prometheus-prometheus 9090:9090
            http://localhost:9090

Shop app:   kubectl port-forward -n ingress-nginx \
              svc/ingress-nginx-controller 8080:80
            http://localhost:8080
```

## Quick Start — Docker Compose (no Kubernetes)

For local development without Kubernetes:

```bash
cp .env.example .env
docker compose up --build
```

| Service       | URL                              |
|---------------|----------------------------------|
| Frontend      | http://localhost:8080            |
| Backend API   | http://localhost:5000            |
| Mongo Express | http://localhost:8081 (admin/admin) |

## API Reference

| Method | Endpoint                     | Description       |
|--------|------------------------------|-------------------|
| GET    | /api/products                | List products     |
| GET    | /api/products/:id            | Product details   |
| POST   | /api/products                | Create product    |
| PUT    | /api/products/:id            | Update product    |
| DELETE | /api/products/:id            | Delete product    |
| POST   | /api/users/register          | Register user     |
| POST   | /api/users/login             | Login             |
| GET    | /api/orders                  | List orders       |
| POST   | /api/orders                  | Create order      |
| PUT    | /api/orders/:id              | Update order      |
| GET    | /api/health                  | Health check      |
| GET    | /metrics                     | Prometheus metrics|

## Observability

The backend exposes custom Prometheus metrics at `/metrics`:

- `shop_backend_http_request_total` — request count, labelled by `method`, `route`, `status_code`
- `shop_backend_http_request_duration_seconds` — latency histogram, same labels
- Default Node.js process metrics (`shop_backend_nodejs_*`)

The frontend nginx container runs an `nginx-prometheus-exporter` sidecar on port `9113`, scraped by a dedicated `ServiceMonitor`.

Grafana is provisioned automatically with a custom dashboard (6 panels): backend request rate, p95 latency, Node.js heap, nginx active connections, nginx request rate, and pod restart count.
## Development Commands

```bash
```bash
# Frontend
npm start           # webpack dev server with hot reload
npm run build       # production build → dist/
npm run deploy      # deploy to GitHub Pages
npm run lint        # ESLint (frontend + backend)

# Backend
cd backend
npm run dev         # nodemon auto-reload
npm start           # production

# Terraform
cd IaC/terraform/dev
terraform plan      # preview changes
terraform apply     # apply
terraform destroy   # tear down all resources

# Kubernetes
kubectl get all -n shop
kubectl get all -n monitoring
kubectl logs -n shop deployment/shop-backend -f
```

### Kubernetes
```bash
kubectl apply -k k8s/
```

### Terraform
```bash
cd IaC/terraform/infra
terraform init
terraform apply
```

## Troubleshooting

### MongoDB Connection Error
If the backend cannot connect to MongoDB:
- Ensure the MongoDB service is running: `docker compose ps`
- Check credentials in `.env` or Docker environment variables
- Verify that the MongoDB URI includes `authSource=admin` when needed

### Port Already in Use
Change ports in `.env` or in the Docker Compose environment:
```env
FRONTEND_PORT=3000
BACKEND_PORT=3001
MONGO_EXPRESS_PORT=8082
```

### Build Issues
Clean and rebuild:
```bash
docker compose down -v
docker compose up --build
```

See [`IaC/terraform/troubleshooting.md`](IaC/terraform/troubleshooting.md) for a detailed log of real issues encountered during development: provider bugs, state drift recovery, rootless Docker networking, and image availability inside Minikube.
