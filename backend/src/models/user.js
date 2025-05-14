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

userSchema.statics.createNewUser = async function({ fullName, username, userID }) {
  if (!fullName || !username || !userID) {
    throw new Error('Missing required fields: fullName, username, or userID');
  }
  const existingUser = await this.findOne({ username });
  if (existingUser) {
    throw new Error('Username already exists');
  }
  const newUser = new this({ fullName, username, userID });
  return newUser.save();
};

// will add logic in next iteration
userSchema.methods.restrictApp = function(appID) {
    if (!appID || typeof appID !== 'string') {
        throw new Error('Invalid appID');
    }
    const existingRestriction = this.restrictedApps.find(restriction => restriction.appID === appID);
    if (!existingRestriction) {
      this.restrictedApps.push({ appID, timerDuration: 0, timerRecurring: false });
    }
    return this.save();
};

userSchema.methods.updateRestriction = function(appID, time) {
    if (!appID || typeof appID !== 'string') {
        throw new Error('Invalid appID');
    }
    const restriction = this.restrictedApps.find(restriction => restriction.appID === appID);
    if (restriction) {
      restriction.timerDuration = time;
    } else {
      this.restrictedApps.push({ appID, timerDuration: time, timerRecurring: false });
    }
    return this.save();
};

userSchema.methods.addFriend = function(userID) {
    if (!userID || typeof userID !== 'string') {
        throw new Error('Invalid userID');
    }
    if (!this.friends.includes(userID)) {
      this.friends.push(userID);
    }
    return this.save();
};

const User = mongoose.model('User', userSchema);

module.exports = User;
