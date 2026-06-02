const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
require('dotenv').config();

const app = express();

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routes
app.use('/api/products', require('./routes/products'));
app.use('/api/users', require('./routes/users'));
app.use('/api/orders', require('./routes/orders'));

// Health check
app.get('/api/health', (req, res) => {
  const dbStatus = mongoose.connection.readyState === 1 ? 'connected' : 'disconnected';
  res.json({ status: 'OK', db: dbStatus });
});

// Database connection
const connectDB = async () => {
  const maxRetries = 5;
  let retries = 0;

  while (retries < maxRetries) {
    try {
      const uri = process.env.MONGODB_URI ||
        `mongodb://${process.env.MONGODB_USER}:${process.env.MONGODB_PASSWORD}@${process.env.MONGODB_HOST}:${process.env.MONGODB_PORT}/${process.env.MONGODB_DB}?authSource=admin`;

      await mongoose.connect(uri, {
        serverSelectionTimeoutMS: 10000,
      });
      console.log('MongoDB connected successfully');
      return;
    } catch (error) {
      retries++;
      console.error(`MongoDB connection attempt ${retries}/${maxRetries} failed:`, error.message);

      if (retries === maxRetries) {
        console.error('All connection attempts failed. Exiting...');
        process.exit(1);
      }

      await new Promise(resolve => setTimeout(resolve, 3000));
    }
  }
};

// Connect to DB and start server (single startup)
connectDB().then(() => {
  const PORT = process.env.PORT || 5000;
  app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
  });
}).catch(err => {
  console.error('Failed to connect to MongoDB:', err);
  process.exit(1);
});