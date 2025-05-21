// maybe MongoDB mongoose schemas for User.js: name, email, passwordHash, etc.

const mongoose = require('mongoose');
const App = require('./app.js');



const userSchema = new mongoose.Schema({
    email: { type: String, required: true },
    username: { type: String, required: true, unique: true },
    userID: { type: String, required: true, unique: true }, // UUID or Mongo ObjectId stored as a string?
    passwordHash: { type: String, required: true },  // <-- Make sure this field exists
    restrictedApps: [{ type: mongoose.Schema.Types.ObjectId, ref: 'App' }],
    friends: [{ type: String }], // list of userIDs (string references)
});

userSchema.statics.createNewUser = async function({ email, username, userID , password}) {
  if (!email || !username || !userID) {
    throw new Error('Missing required fields: email, username, or userID');
  }
  const existingUser = await this.findOne({ username });
  if (existingUser) {
    throw new Error('Username already exists');
  }
  const newUser = new this({ email, username, userID });
  return newUser.save();
};

// will add logic in next iteration
userSchema.methods.restrictApp = async function(bundleID, dailyUsage) {
    if (!bundleID || typeof bundleID !== 'string') {
        throw new Error('Invalid bundleID');
    }
    const existingApp = await App.findOne({ userId: this.userID, bundleId: bundleID });
    if (existingApp && this.restrictedApps.includes(existingApp._id)) {
        throw new Error('App is already restricted');
    }
    const newApp = await App.createApp({
        userId: this.userID,
        bundleId: bundleID,
        dailyUsage: dailyUsage,
        restricted: true,
    });

  // Save the reference in the user's restrictedApps
  this.restrictedApps.push(newApp._id);
  return this.save();

};

userSchema.methods.updateRestriction = async function(bundleId, time) {
    if (!bundleId || typeof bundleId !== 'string') {
        throw new Error('Invalid appID');
    }
    await this.populate("restrictedApps");

    const existingApp = this.restrictedApps.find(app => app.bundleId === bundleId);
    if (existingApp) {
      existingApp.dailyUsage = time;
        await existingApp.save();
    } else {
      throw new Error("No app found")
    }
    return existingApp;
};

userSchema.methods.toggleRestriction = async function(bundleId) {
    if (!bundleId || typeof bundleId !== 'string') {
        throw new Error('Invalid appID');
    }
    await this.populate("restrictedApps");
    const existingApp = this.restrictedApps.find(app => app.bundleId === bundleId);
    if (existingApp) {
    console.log(existingApp.restricted);
      existingApp.restricted = !existingApp.restricted;
      console.log(existingApp.restricted);
        await existingApp.save();
    } else {
      throw new Error("No app found")
    }
    return existingApp;
};

userSchema.methods.addFriend = async function(userID) {
    if (!userID || typeof userID !== 'string') {
        throw new Error('Invalid userID');
    }
    if (!this.friends.includes(userID)) {
      this.friends.push(userID);
    }
    return await this.save();
};

userSchema.methods.addComment = async function(bundleId, comment) {
    if (!bundleId || typeof bundleId !== 'string') {
        throw new Error('Invalid appID');
    }
    await this.populate("restrictedApps");
    const existingApp = this.restrictedApps.find(app => app.bundleId === bundleId);
    if (!existingApp) {
        throw new Error("No bundle ID exists");
    }
    await existingApp.addComment(comment);
    return await existingApp.save();
}

const User = mongoose.model('User', userSchema);

module.exports = User;
