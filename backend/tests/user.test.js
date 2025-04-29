const request = require('supertest');
const app = require('../app'); // Your Express app (you might need to export it if not yet)
const mongoose = require('mongoose');
const User = require('../models/User');

// NOTE: lots of these tests are filled out with generic fields until we better flesh out the backend-frontend
// connection and the screentime API for milestone 3B.

// Connect to test database
beforeAll(async () => {
    await mongoose.connect('mongodb://localhost:27017/mindfriend_test', {
        useNewUrlParser: true,
        useUnifiedTopology: true,
    });
});

// Clear test database before each test
beforeEach(async () => {
    await User.deleteMany();
});

// Disconnect after all tests are done
afterAll(async () => {
    await mongoose.connection.close();
});

// Create a user successfully
describe('POST /users', () => {
    it('should create a new user', async () => {
        const res = await request(app)
            .post('/users')
            .send({
                fullName: 'Alice Johnson',
                username: 'alicej',
                userID: 'user123'
            });

        expect(res.statusCode).toEqual(201);
        expect(res.body.username).toBe('alicej');
    });
});

// Restrict an app successfully
describe('POST /users/restrictApp', () => {
    it('should restrict an app for a user', async () => {
        const user = new User({ fullName: 'Bob', username: 'bobthebuilder', userID: 'user456' });
        await user.save();

        const res = await request(app)
            .post('/users/restrictApp')
            .send({
                userID: 'user456',
                appID: 'com.instagram.ios'
            });

        expect(res.statusCode).toEqual(200);
        expect(res.body.message).toBe('App restricted successfully.');
    });
});

// Update app restriction successfully
describe('POST /users/updateRestriction', () => {
    it('should update a restriction for an app', async () => {
        const user = new User({ fullName: 'Charlie', username: 'charliebitme', userID: 'user789' });
        await user.save();

        await user.restrictApp('com.tiktok.ios');
        await user.save();

        const res = await request(app)
            .post('/users/updateRestriction')
            .send({
                userID: 'user789',
                appID: 'com.tiktok.ios',
                newTime: 3600
            });

        expect(res.statusCode).toEqual(200);
        expect(res.body.message).toBe('Restriction updated successfully.');
    });
});

// Add a friend successfully (note - this is more for iteration 2)
describe('POST /users/addFriend', () => {
    it('should add a friend successfully', async () => {
        const user = new User({ fullName: 'Dora', username: 'doratheexplorer', userID: 'user321' });
        await user.save();

        const res = await request(app)
            .post('/users/addFriend')
            .send({
                userID: 'user321',
                friendID: 'user1234'
            });

        expect(res.statusCode).toEqual(200);
        expect(res.body.message).toBe('Friend added successfully.');
    });
});

// Fail to create a user with missing fields
describe('POST /users', () => {
    it('should fail to create user without username', async () => {
        const res = await request(app)
            .post('/users')
            .send({
                fullName: 'Eva',
                userID: 'user654'
            });

        expect(res.statusCode).toEqual(400);
        expect(res.body.error).toBeDefined();
    });
});

// Fail to restrict app for non-existing user
describe('POST /users/restrictApp', () => {
    it('should fail to restrict app for non-existent user', async () => {
        const res = await request(app)
            .post('/users/restrictApp')
            .send({
                userID: 'nonexistentuser',
                appID: 'com.snapchat.ios'
            });

        expect(res.statusCode).toEqual(400);
        expect(res.body.error).toBe('User not found.');
    });
});

// Fail to update restriction for non-existing app
describe('POST /users/updateRestriction', () => {
    it('should fail to update a non-existing restriction', async () => {
        const user = new User({ fullName: 'Fred', username: 'fredflintstone', userID: 'user159' });
        await user.save();

        const res = await request(app)
            .post('/users/updateRestriction')
            .send({
                userID: 'user159',
                appID: 'nonexistentapp',
                newTime: 500
            });

        expect(res.statusCode).toEqual(400);
        expect(res.body.error).toBeDefined();
    });
});
