// MongoDB setup and utility functions (e.g., connecting DB, indexing collections).

const request = require('supertest');
const app = require('../app'); // Your Express app (you might need to export it if not yet)
const mongoose = require('mongoose');
const User = require('../models/User');



