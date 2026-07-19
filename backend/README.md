# Shop Backend API

Express.js + MongoDB REST API for the Shop e-commerce platform.

## Structure

```
backend/
├── models/          # Mongoose schemas
│   ├── Product.js   # Product model
│   ├── User.js      # User model
│   └── Order.js     # Order model
├── routes/          # API routes
│   ├── products.js  # Product endpoints
│   ├── users.js     # User endpoints
│   └── orders.js    # Order endpoints
├── server.js        # Express app
├── Dockerfile       # Container config
├── .env             # (Git ignored)
├── .env.example     # Environment template
└── package.json     # Dependencies
```

## Quick Start

### Docker
```bash
docker compose up --build
```

### Local Development
```bash
npm install
npm run dev        # Auto-reload with nodemon
npm start          # Production mode
```

## Configuration

Create `.env` file:

```env
# Docker environment
MONGODB_URI=mongodb://root:password@mongodb:27017/shop?authSource=admin

# Local development
# MONGODB_URI=mongodb://localhost:27017/shop

PORT=5000
NODE_ENV=development
```

## API Endpoints

### Products
- `GET /api/products` - List all
- `GET /api/products/:id` - Get by ID
- `POST /api/products` - Create (requires: name, price)
- `PUT /api/products/:id` - Update
- `DELETE /api/products/:id` - Delete

### Users
- `GET /api/users` - List all (password hidden)
- `POST /api/users/register` - Create account
  - Required: name, email, password
- `POST /api/users/login` - Authenticate
  - Required: email, password

### Orders
- `GET /api/orders` - List all
- `GET /api/orders/user/:userId` - User's orders
- `POST /api/orders` - Create
  - Required: userId, items, totalPrice
- `PUT /api/orders/:id` - Update status

## Database

MongoDB is included in docker-compose.yml:
- **Host**: `mongodb` (in Docker) or `localhost`
- **Port**: 27017

View data in Mongo Express: http://localhost:8081

## Example Requests

### Create Product
```bash
curl -X POST http://localhost:5000/api/products \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Laptop",
    "price": 1500,
    "category": "electronics",
    "stock": 10,
    "description": "High-performance laptop"
  }'
```

### Register User
```bash
curl -X POST http://localhost:5000/api/users/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "password": "SecurePass123"
  }'
```

### Login
```bash
curl -X POST http://localhost:5000/api/users/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "SecurePass123"
  }'
```

### Create Order
```bash
curl -X POST http://localhost:5000/api/orders \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "user_id_here",
    "items": [
      {
        "productId": "product_id",
        "quantity": 2,
        "price": 1500
      }
    ],
    "totalPrice": 3000
  }'
```

## Health Check

```bash
curl http://localhost:5000/api/health
# Response: {"status":"OK"}
```

## Dependencies

- **express** ^4.18.2 - Web framework
- **mongoose** ^7.5.0 - MongoDB ODM
- **cors** ^2.8.5 - Cross-origin requests
- **dotenv** ^16.3.1 - Environment variables
- **express-validator** ^7.0.0 - Input validation
- **nodemon** ^3.0.1 (dev) - Auto-reload

## Features

- ✅ RESTful API design
- ✅ MongoDB integration
- ✅ Input validation
- ✅ CORS enabled
- ✅ Error handling
- ✅ Environment configuration
- ✅ Docker support

## Troubleshooting

### MongoDB Connection Error
```
Error: Authentication failed
Solution: Ensure ?authSource=admin in connection string
```

### Port 5000 in Use
```bash
lsof -i :5000
kill -9 <PID>
```

### Database Reset
```bash
docker compose down -v
docker compose up --build
```

## TODO Features

- [ ] JWT authentication
- [ ] Password hashing (bcrypt)
- [ ] Email verification
- [ ] Request logging
- [ ] Rate limiting
- [ ] API documentation (Swagger)
- [ ] Unit tests
- [ ] Image upload

## Security Notes

⚠️ **For Production:**
- Change default MongoDB credentials
- Use strong passwords
- Enable HTTPS
- Add authentication middleware
- Implement rate limiting
- Add input sanitization
- Use JWT tokens
- Hash passwords with bcrypt

## Support

- Check [main README](../README.md) for full project info

---

Built with Node.js & Express 🚀
