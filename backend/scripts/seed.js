require('dotenv').config();
const mongoose = require('mongoose');
const { faker } = require('@faker-js/faker');
const Product = require('../models/Product');


const PRODUCTS_COUNT = 50;


function createFakeProduct(){
    return {
        name: faker.commerce.productName(),
        description: faker.commerce.productDescription(),
        price: parseFloat(faker.commerce.price({ min: 10, max: 1000, dec: 2 })),
        category: faker.helpers.arrayElement(['Electronics', 'Clothes']),
        image: faker.image.url({category: 'technics'}),
        stock: faker.number.int({ min: 0 , max: 100})
    }
}

async function seed() {
    try {
        console.log('Connecting to db');
        await mongoose.connect(process.env.MONGODB_URI)

        console.log('Cleaning collections');
        await Product.deleteMany({});

        console.log(`Generating ${PRODUCTS_COUNT} products`);
        const products = Array.from({ length: PRODUCTS_COUNT }, createFakeProduct)

        await Product.insertMany(products);
        console.log(`Succesfully inserted ${products.length} products into db`);
        
        
    }
    catch(error){
        console.error('Error seeding', error);
        
    }
    finally{
        await mongoose.disconnect();
        console.log('Disconected form db');
    }
}

seed();