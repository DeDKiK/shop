# Shop 🛒

Full-stack e-commerce application deployed on AWS with Kubernetes (k3s) — a DevOps portfolio project demonstrating infrastructure-as-code, configuration management, container orchestration, CI/CD, and observability.

## Architecture

A complete e-commerce platform featuring:
- Product listing, search and category filtering
- Shopping cart with `localStorage` persistence
- User authentication (login/registration)
- Order management
- Responsive design with CSS modules

Infrastructure is provisioned in two layers:

1. **Cloud infrastructure** (`IaC/terraform/infra`) — VPC, public subnet, Internet Gateway, security groups, Elastic IP, and EC2 instances for the k3s control plane, a k3s agent node, and a dedicated GitLab Runner host. Configuration (k3s install, node joining, kubeconfig retrieval, Runner registration) is handled by **Ansible**, using a dynamic inventory generated from Terraform outputs.
2. **Application resources** (`IaC/terraform/dev`) — namespace, MongoDB, backend, frontend, Ingress, and the Prometheus/Grafana observability stack, all deployed onto the k3s cluster via Terraform's Kubernetes and Helm providers.

```text
┌───────────────────────────────────────────────────────────────┐
│                      AWS (eu-central-1)                       │
│                                                                 │
│   VPC / public subnet / IGW / security groups                  │
│                                                                 │
│   ┌──────────────────┐   ┌──────────────────┐   ┌───────────┐ │
│   │  EC2: k3s server │   │  EC2: k3s agent  │   │  EC2:     │ │
│   │  (control plane) │◄──┤                  │   │  GitLab   │ │
│   │  + Elastic IP    │   │                  │   │  Runner   │ │
│   └────────┬─────────┘   └──────────────────┘   └───────────┘ │
│            │  k3s cluster (namespace: shop)                    │
│            ▼                                                   │
│   ┌──────────────┐    ┌──────────────────┐                     │
│   │  Frontend    │    │   Backend        │                     │
│   │  nginx +     │    │   Node.js /      │                     │
│   │  exporter    │    │   Express        │                     │
│   └──────┬───────┘    └────────┬─────────┘                     │
│          │ /metrics             │ /metrics                     │
│          ▼                      ▼                              │
│   ┌──────────────────────────────────────┐                     │
│   │  Prometheus (kube-prometheus-stack)  │                     │
│   │  ServiceMonitor × 2                  │                     │
│   └──────────────────┬───────────────────┘                     │
│                       ▼                                        │
│   ┌───────────────────────────────┐                            │
│   │  Grafana + custom dashboard    │                           │
│   └───────────────────────────────┘                            │
│                                                                  │
│   ┌───────────────────────┐                                    │
│   │  MongoDB (Deployment)  │                                    │
│   └───────────────────────┘                                    │
│                                                                  │
│   nginx Ingress ── routes /api/* → backend, / → frontend        │
└───────────────────────────────────────────────────────────────┘
```

Cluster resources are managed by Terraform (Kubernetes + Helm providers). Configuration management (installing k3s, joining nodes, fetching kubeconfig, registering the GitLab Runner) is handled by Ansible.

## Technologies

### Frontend
- React 19
- TypeScript
- Webpack + Babel
- CSS Modules
- React Router
- `localStorage`-based cart and session persistence

### Backend
- Node.js + Express
- MongoDB + Mongoose
- CORS enabled
- Request validation with `express-validator`
- Prometheus metrics endpoint (`prom-client`)

### DevOps
- **Cloud**: AWS (EC2, VPC, Security Groups, Elastic IP, S3, DynamoDB)
- **IaC**: Terraform — AWS, Kubernetes and Helm providers, remote state in S3 with DynamoDB locking
- **Configuration management**: Ansible, dynamic inventory from Terraform outputs
- **Orchestration**: k3s
- **CI/CD**: GitLab CI/CD (primary app pipeline), GitHub Actions (on-demand infra provisioning)
- **Containers**: Docker & Docker Compose (local dev), GitLab Container Registry (image storage)
- **Observability**: Helm-based `kube-prometheus-stack`, Prometheus ServiceMonitors, Grafana

## Quick Start — Local Development (Docker Compose)

No AWS account or Kubernetes needed — this runs the whole stack (frontend, backend, MongoDB, Mongo Express) locally.

### Prerequisites
- Docker & Docker Compose
- Node.js 22+ (for running things outside containers, e.g. the seed script)

```bash
# 1. Clone repository
git clone https://github.com/DeDKiK/shop.git
cd shop

# 2. Create environment file from example
cp backend/.env.example backend/.env

# 3. Start all services
docker compose up --build
```

| Service       | URL                                  |
|---------------|--------------------------------------|
| Frontend      | http://localhost:8080                |
| Backend API   | http://localhost:5000                |
| Mongo Express | http://localhost:8081 (admin/admin)  |

## Quick Start — AWS Deployment

This is how the project actually gets deployed; it's driven by two separate pipelines rather than manual `terraform apply` from a laptop.

### 1. Provision cloud infrastructure

Triggered manually via GitHub Actions (`.github/workflows/infra.yml`, `workflow_dispatch`), or locally:

```bash
cd IaC/terraform/infra
terraform init
terraform apply
```

This creates the VPC, security groups, Elastic IP, and the three EC2 instances (k3s server, k3s agent, GitLab Runner).

### 2. Configure the cluster with Ansible

```bash
cd IaC/ansible
ansible-playbook -i inventory/terraform_inventory.py playbooks/site.yml
```

Installs k3s on the server node, joins the agent node, fetches the kubeconfig to `~/.kube/shop-aws-config`, and registers the GitLab Runner.

### 3. Deploy the application

Handled by GitLab CI/CD (`.gitlab-ci.yml`) on every push to `main`: type-check/lint/build → Docker build and push to the GitLab Container Registry → `terraform apply` against `IaC/terraform/dev` from the self-hosted runner. This provisions the namespace, MongoDB, backend, frontend, nginx Ingress, and the full Prometheus/Grafana stack via Helm.

### 4. Access the cluster

The Ingress and MongoDB service are internal (`ClusterIP`) — access is via `kubectl port-forward` with the kubeconfig from step 2:

```bash
kubectl --kubeconfig ~/.kube/shop-aws-config -n shop port-forward svc/shop-backend-service 5000:5000
kubectl --kubeconfig ~/.kube/shop-aws-config -n monitoring port-forward svc/prometheus-grafana 3000:80
```

## API Reference

| Method | Endpoint                      | Description       |
|--------|-------------------------------|-------------------|
| GET    | /api/products                 | List products     |
| GET    | /api/products/:id             | Product details   |
| POST   | /api/products                 | Create product    |
| PUT    | /api/products/:id             | Update product    |
| DELETE | /api/products/:id             | Delete product    |
| GET    | /api/users                    | List users        |
| POST   | /api/users/register           | Register user     |
| POST   | /api/users/login              | Login             |
| GET    | /api/orders                   | List orders       |
| GET    | /api/orders/user/:userId      | User's orders     |
| POST   | /api/orders                   | Create order      |
| PUT    | /api/orders/:id               | Update order      |
| GET    | /api/health                   | Health check      |
| GET    | /metrics                      | Prometheus metrics|

## Frontend Routes

- `/` — Home page (products from the database)
- `/category/:category` — Category page
- `/search` — Search page
- `/login` — Login page
- `/register` — Registration page
- `/cart` — Cart page

## Observability

The backend exposes custom Prometheus metrics at `/metrics`:
- `shop_backend_http_request_total` — request count, labelled by `method`, `route`, `status_code`
- `shop_backend_http_request_duration_seconds` — latency histogram, same labels
- Default Node.js process metrics (`shop_backend_nodejs_*`)

The frontend's nginx container runs an `nginx-prometheus-exporter` sidecar on port `9113`, scraped by a dedicated `ServiceMonitor`.

Grafana ships with a provisioned custom dashboard (6 panels): backend request rate, p95 latency, Node.js heap, nginx active connections, nginx request rate, and pod restart count.

## CI/CD

Two separate pipelines, each with its own job:

- **GitLab CI/CD** (`.gitlab-ci.yml`) — the application pipeline. Runs on every push to `main`:
  1. `test` — `npm ci`, `tsc --noEmit`, lint, build
  2. `build` — Docker build for backend and frontend, pushed to the GitLab Container Registry
  3. `deploy` — `terraform apply` against `IaC/terraform/dev` from a self-hosted runner living inside the AWS VPC
- **GitHub Actions** (`.github/workflows/`) — `ci-cd.yml` runs the same test/build/Docker-push checks on GitHub for visibility; `infra.yml` is a manually-triggered (`workflow_dispatch`) job that provisions the AWS infrastructure via Terraform and Ansible, for cases where infra needs to be (re)created outside of a laptop.

## Repository Structure

```text
shop/
├── src/                              # React frontend
│   ├── App.tsx                       # Main application router
│   ├── index.tsx                     # React entry point
│   ├── pages/                        # Page components
│   ├── AppComponents/                # Shared UI components
│   ├── context/                      # React Context (cart state)
│   ├── hooks/                        # Data-fetching hooks (useProducts)
│   ├── assets/                       # Static assets
│   └── style.css                     # Global styles
├── backend/                          # Express API
│   ├── models/                       # Mongoose schemas (User, Product, Order)
│   ├── routes/                       # REST route handlers
│   ├── scripts/seed.js               # Faker-based MongoDB seeding script
│   └── server.js                     # App entrypoint + prom-client setup
├── webpack/                          # Webpack configuration (incl. dev-server API proxy)
├── IaC/
│   ├── terraform/
│   │   ├── infra/                    # Layer 1: VPC, EC2 (k3s server/agent, GitLab Runner), Elastic IP
│   │   ├── dev/                      # Layer 2: root module — calls modules/, deploys Prometheus stack via Helm
│   │   ├── modules/                  # Child module: namespace, MongoDB, backend, frontend, Ingress
│   │   └── troubleshooting.md        # Real debugging log from development
│   └── ansible/
│       ├── inventory/terraform_inventory.py  # Dynamic inventory from Terraform state
│       ├── roles/                    # k3s_common, k3s_server, k3s_agent, kubeconfig_fetch
│       └── playbooks/site.yml
├── k8s/                              # Legacy raw manifests, superseded by IaC/terraform — kept for history
├── docker-compose.yml                # Local dev without Kubernetes
├── Dockerfile                        # Frontend image
├── backend/Dockerfile                # Backend image
├── nginx.conf                        # nginx config for frontend container
├── .gitlab-ci.yml                    # Primary CI/CD pipeline (test → build → deploy)
├── .github/workflows/                # ci-cd.yml (test/build) + infra.yml (on-demand provisioning)
└── eslint.config.mjs                 # ESLint flat config (frontend + backend)
```

## Environment Variables

Copy `backend/.env.example` to `backend/.env` and configure:

```env
# MongoDB
MONGODB_URI=mongodb://localhost:27017/shop

# Server
PORT=5000
NODE_ENV=development
```

For Docker Compose, the following variables can also be set at the root `.env`:

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

On the AWS deployment, the equivalent values are injected via the `mongo-secret`/`shop-backend-config` Kubernetes resources, created by Terraform from the CI/CD pipeline's variables — nothing is hardcoded in the cluster manifests.

## Development Commands

```bash
# Frontend
npm start           # webpack dev server with hot reload (proxies /api to localhost:5000)
npm run build        # production build → dist/
npm run lint          # ESLint (frontend + backend)

# Backend
cd backend
npm run dev            # nodemon auto-reload
npm start                # production
npm run seed               # populate MongoDB with faker-generated products

# Terraform — cloud infrastructure
cd IaC/terraform/infra
terraform plan
terraform apply

# Terraform — application resources
cd IaC/terraform/dev
terraform plan
terraform apply

# Kubernetes (against the AWS cluster)
kubectl --kubeconfig ~/.kube/shop-aws-config -n shop get all
kubectl --kubeconfig ~/.kube/shop-aws-config -n monitoring get all
kubectl --kubeconfig ~/.kube/shop-aws-config -n shop logs deployment/shop-backend -f
```

## Troubleshooting

### MongoDB Connection Error (local Docker Compose)
- Ensure the MongoDB service is running: `docker compose ps`
- Check credentials in `.env` or Docker Compose environment variables
- Verify that the MongoDB URI includes `authSource=admin` when needed

### Port Already in Use
Change ports in `.env`, or find and stop whatever's holding the port:
```bash
lsof -i :8080
kill <PID>
```

### Build Issues
Clean and rebuild:
```bash
docker compose down -v
docker compose up --build
```

See [`IaC/terraform/troubleshooting.md`](IaC/terraform/troubleshooting.md) for a log of real issues hit during development — provider bugs, state drift recovery, and networking quirks.