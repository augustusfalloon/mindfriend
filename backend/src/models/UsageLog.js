const mongoose = require('mongoose');

const usageLogSchema = new mongoose.Schema({
    userID: { type: String, required: true },
    bundleId: { type: String, required: true },
    duration: { type: Number, required: true }, // seconds
    timestamp: { type: Date, required: true }
});

const ScreenTimeRecordSchema = new mongoose.Schema({
    userId: { type: String, required: true },
    appId: { type: String, required: true },
    usage: { type: Number, required: true }, // seconds
    date: { type: Date, required: true }
});


module.exports = mongoose.model('UsageLog', usageLogSchema);
module.exports = mongoose.model('ScreenTimeRecord', ScreenTimeRecordSchema);
