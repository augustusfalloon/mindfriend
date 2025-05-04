const mongoose = require('mongoose');

const usageLogSchema = new mongoose.Schema({
    userID: { type: String, required: true },
    bundleId: { type: String, required: true },
    duration: { type: Number, required: true }, // seconds
    timestamp: { type: Date, required: true }
});

module.exports = mongoose.model('UsageLog', usageLogSchema);
