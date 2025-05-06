// maybe MongoDB mongoose schemas for User.js: name, email, passwordHash, etc.

const mongoose = require('mongoose');

const appRestrictionSchema = new mongoose.Schema({
    appID: { type: String, required: true },
    timerDuration: { type: Number, required: true }, // time in seconds
    timerRecurring: { type: Boolean, default: false } //should we recheck later?
});

const userSchema = new mongoose.Schema({
    fullName: { type: String, required: true },
    username: { type: String, required: true, unique: true },
    userID: { type: String, required: true, unique: true }, // UUID or Mongo ObjectId stored as a string?
    restrictedApps: [appRestrictionSchema],
    friends: [{ type: String }], // list of userIDs (string references)
    usageHours: { type: Number, default: 0 }, // total usage hours
    highRiskTimeBlocks: [{ start: Date, end: Date }], // list of time blocks
});

// will add logic in next iteration
userSchema.methods.restrictApp = function(appID) {
    
};

userSchema.methods.updateRestriction = function(appID, time) {
    
};

userSchema.methods.addFriend = function(userID) {
    
};

const User = mongoose.model('User', userSchema);

module.exports = User;
