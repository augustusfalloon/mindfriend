// App.js: userId, bundleId, dailyUsage: time before warning

const mongoose = require('mongoose');

const AppSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  bundleId: { type: String, required: true }, // App's bundle ID
  dailyUsage: { type: Number, required: true }, // Daily usage limit in minutes
  restricted: { type: Boolean, default: false }, // Whether the app is restricted
});

module.exports = mongoose.model('App', AppSchema);