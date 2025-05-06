const request = require('supertest');
const app = require('../app'); // Your Express app (you might need to export it if not yet)
const mongoose = require('mongoose');
const User = require('../models/User');

// NOTE: lots of these tests are filled out with generic fields until we better flesh out the backend-frontend
// connection and the screentime API for milestone 3B.

// Connect to test database
async function connectToDatabase() {
    await mongoose.connect('mongodb://localhost:27017/mindfriend_test');
}

// Clear test database
async function clearDatabase() {
    await User.deleteMany();
}

// Disconnect from database
async function disconnectFromDatabase() {
    await mongoose.connection.close();
}

// Test: Create a user and verify it is saved in the database
async function testCreateUser() {
    console.log('Connecting to test database...');
    await connectToDatabase();
    await clearDatabase();
    console.log('Running test: Create User');

    const user = new User({ fullName: 'Alice Johnson', username: 'alicej', userID: 'user123' });
    await user.save();

    const savedUser = await User.findOne({ username: 'alicej' });
    if (!savedUser) {
        throw new Error('User was not saved in the database');
    }

    console.log('✅ Test passed: User created successfully');
    await disconnectFromDatabase();
}

// Run all tests
async function runTests() {
    console.log('Running tests...');
    await testCreateUser();
    console.log('All tests completed!');
}

runTests().catch(error => {
    console.error('Test failed:', error.message);
});