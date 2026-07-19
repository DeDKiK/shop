# Shop 🛒

Full-stack e-commerce application with **React** + **TypeScript** frontend and **Express** + **MongoDB** backend.

## About the Project

A complete e-commerce platform featuring:
- Product listing and management
- Shopping cart functionality
- User authentication (login/registration)
- Order management
- Responsive design with CSS modules
- Docker-based local deployment
- Kubernetes and Terraform support for deployment automation

Built as a learning and portfolio project with a modern web stack.

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

Services will be available at:
- 🌐 Frontend: http://localhost:8080
- 🖥️ Backend API: http://localhost:5000
- 📊 Mongo Express: http://localhost:8081 (admin/admin)
- 📦 MongoDB: localhost:27017

### Local Development

#### Frontend
```bash
npm install
npm start    # Dev server with hot reload
npm run build # Production build
```

#### Backend
```bash
cd backend
npm install
npm start    # Production
npm run dev  # Development with auto-reload
```

## Environment Variables

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

## Project Structure

```text
shop/
├── src/                    # React frontend
│   ├── App.tsx            # Main application router
│   ├── index.tsx          # React entry point
│   ├── pages/             # Page components
│   ├── AppComponents/     # UI components and shared data
│   ├── context/           # React contexts (cart state)
│   ├── assets/            # Static assets
│   └── style.css          # Global styles
├── backend/               # Express API
│   ├── models/            # Mongoose schemas
│   ├── routes/            # API routes
│   ├── server.js          # Main server and metrics setup
│   └── package.json
├── webpack/               # Webpack configuration
├── docker-compose.yml     # Local Docker Compose services
├── Dockerfile             # Frontend container build
├── k8s/                   # Kubernetes manifests and deployment files
├── IaC/                   # Terraform infrastructure code
├── README.md              # Main project documentation
└── package.json           # Frontend scripts and dependencies
```

## Testing the Application

### 1. Register a new user
```bash
curl -X POST http://localhost:5000/api/users/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John",
    "email": "john@example.com",
    "password": "password123"
  }'
```

### 2. Create a product
```bash
curl -X POST http://localhost:5000/api/products \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Laptop",
    "price": 1500,
    "category": "electronics",
    "stock": 10
  }'
```

### 3. Check Mongo Express
Visit http://localhost:8081 (admin/admin) to view the database.

## Development Commands

### Frontend
```bash
npm start      # Dev server
npm run build  # Production build
npm run deploy # Deploy to GitHub Pages
npm run lint   # Run ESLint checks
```

### Backend
```bash
cd backend
npm start      # Start server
npm run dev    # Start with nodemon
```

### Docker
```bash
docker compose up --build     # Start all services
docker compose down           # Stop all services
docker compose logs -f        # View logs
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