# Shop 🛒

Full-stack e-commerce application with **React** + **TypeScript** frontend and **Express** + **MongoDB** backend.

## About the Project

A complete e-commerce platform featuring:  
- Product listing and management
- Shopping cart functionality  
- User authentication (login/registration)
- Order management
- Admin dashboard with Mongo Express
- Responsive design with CSS modules

Built as a learning and portfolio project with modern web stack.

## Technologies

### Frontend
- React 18
- TypeScript
- Webpack + Babel
- CSS Modules
- React Router

### Backend
- Node.js + Express
- MongoDB + Mongoose
- CORS enabled
- Input validation

### DevOps
- Docker & Docker Compose
- Nginx reverse proxy
- MongoDB Atlas ready

## Quick Start

### Prerequisites
- Docker & Docker Compose
- Node.js 22+ (for local development)

### Using Docker (Recommended)

```bash
# 1. Clone repository
git clone https://github.com/DeDKiK/shop.git
cd shop

# 2. Create .env file from example
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
MONGO_USER=root
MONGO_PASSWORD=password
MONGO_DB=shop
MONGO_PORT=27017

# Backend
BACKEND_PORT=5000
NODE_ENV=development

# Frontend
FRONTEND_PORT=8080

# Mongo Express
MONGO_EXPRESS_PORT=8081
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

## Project Structure

```
shop/
├── src/                    # React frontend
│   ├── pages/             # Page components
│   ├── AppComponents/     # UI components
│   ├── context/           # React Context
│   └── assets/            # Static files
├── backend/               # Express API
│   ├── models/            # Mongoose schemas
│   ├── routes/            # API routes
│   ├── server.js          # Main server
│   └── package.json
├── webpack/               # Webpack config
├── docker-compose.yml     # Services
├── Dockerfile             # Frontend Docker
└── README.md
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
Visit http://localhost:8081 (admin/admin) to view database

## Development Commands

### Frontend
```bash
npm start      # Dev server
npm run build  # Production build
npm run deploy # Deploy to GitHub Pages
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

## Troubleshooting

### MongoDB Connection Error
If backend can't connect to MongoDB:
- Ensure MongoDB service is running: `docker compose ps`
- Check credentials in `.env`
- Verify `authSource=admin` in connection string

### Port Already in Use
Change ports in `.env`:
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

## Contributing

Feel free to fork and submit PRs!

## License

ISC

## Author

[Your Name] - Portfolio Project

---

**Questions?** Open an issue on GitHub!

# 2. Install dependencies
npm install

# 3. Start development server
npm start
