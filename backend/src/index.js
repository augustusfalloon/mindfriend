// maybe entry point of the server. Sets up Express app, middleware (like CORS, JSON parser), routes, and starts the server.

const express = require('express');
const mongoose = require('mongoose');
const dotenv = require('dotenv');
const cors = require('cors');

// load environment variables
dotenv.config();

// initialize Express
const app = express();

// load middleware
app.use(cors());
app.use(express.json());

// import routes
const userRoutes = require('./routes/userRoutes');
const appRoutes = require('./routes/appRoutes');

// mount routes
app.use('/api/users', userRoutes);
app.use('/api/apps', appRoutes);

// connect to db
const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/mindfriend';

mongoose.connect(MONGODB_URI, {
    useNewUrlParser: true,
    useUnifiedTopology: true
})
.then(() => {
    console.log('Connected to MongoDB');

    // start server
    const PORT = process.env.PORT || 3000;
    app.listen(PORT, () => {
        console.log(`Server running on port ${PORT}`);
    });
})
.catch((err) => {
    console.error('MongoDB connection error:', err);
});

module.exports = app; // for testing?
