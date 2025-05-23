// maybe MongoDB mongoose schemas for User.js: name, email, passwordHash, etc.

const mongoose = require('mongoose');
const App = require('./app.js');



const userSchema = new mongoose.Schema({
    email: { type: String, required: true },
    username: { type: String, required: true, unique: true },
    passwordHash: { type: String, required: true },  // <-- Make sure this field exists
    restrictedApps: [{ type: mongoose.Schema.Types.ObjectId, ref: 'App' }],
    friends: [{ type: mongoose.Schema.Types.ObjectId, ref: "User" }], // list of userIDs (string references)
});

userSchema.statics.createNewUser = async function(email, username , passwordHash) {
    console.log(`${email}, ${passwordHash}, ${username}`);
  if (!email || !username || !passwordHash) {
    throw new Error('Missing required fields: email, username, or password');
  }
  const existingUser = await this.findOne({ username });
  if (existingUser) {
    throw new Error('Username already exists');
  }
  const newUser = new this({ email, username, passwordHash});

  //Instagram Youtube, Facebook, TikTok, Twitter, Snapchat, Reddit, Pinterest

  await newUser.restrictApp("instagram", 0);
  await newUser.restrictApp( "youtube",  0);
  await newUser.restrictApp("facebook", 0);
  await newUser.restrictApp( "tiktok", 0);
  await newUser.restrictApp("twitter", 0);
  await newUser.restrictApp("snapchat", 0);
  await newUser.restrictApp("reddit", 0);
  await newUser.restrictApp("pinterest", 0);
  
  return newUser.save();
};

// will add logic in next iteration
userSchema.methods.restrictApp = async function(bundleID, dailyUsage) {
    if (!bundleID) {
        throw new Error('Invalid bundleID');
    }
    const newApp = await App.createApp({
        userId: this._id,
        bundleId: bundleID,
        dailyUsage: dailyUsage,
        restricted: false,
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
      existingApp.restricted = !existingApp.restricted;
        await existingApp.save();
    } else {
      throw new Error("No app found")
    }
    return existingApp;
};

userSchema.methods.addFriend = async function(username) {

    console.log(username);
    const friend = await User.findOne({username: username});

    if (!friend) {
        throw new Error("No friend found");
    }

    if (this._id.equals(friend._id)) {
        throw new Error('You cannot add yourself as a friend');
    }
    
    if (this.friends.some(friendId => friendId.equals(friend._id))) {
        throw new Error("You already have them as a friend")
    }

    this.friends.push(friend._id);
    // friend.friends.push(this._id);


    return await this.save();
};

userSchema.methods.addComment = async function(bundleId, comment) {
    if (!bundleId || typeof bundleId !== 'string') {
        throw new Error('Invalid appID');
    }
    await this.populate("restrictedApps");
    console.log(this.restrictedApps);
    console.log(bundleId);
    const existingApp = this.restrictedApps.find(app => app.bundleId === bundleId);
    if (!existingApp) {
        throw new Error("No bundle ID exists");
    }
    await existingApp.addComment(comment);
    return await existingApp.save();
}

//usage should be a json
userSchema.methods.getExceeded = async function(usage) {
    pd = [];

    if (!usage) {
        throw new Error("no usage data");
    }

    await this.populate("restrictedApps");

    console.log(usage);

    for (const[key, value] of Object.entries(usage)) {
        console.log(`${key}, ${value}`);
        console.log(this.restrictedApps);
        const app = this.restrictedApps.find(app => app.bundleId === key);
        if (!app) {
            throw new Error (`${key} is not a valid bundleId`);
        }
        console.log(app.hasExceeded(value));
        console.log(app.restricted);
        if (app.hasExceeded(value) && app.restricted) {
            pd.push(app);
        }
    }

    console.log(pd);

    return pd;
}

userSchema.methods.getApps = async function() {

    await this.populate("restrictedApps");

    return this.restrictedApps;
}

const User = mongoose.model('User', userSchema);

module.exports = User;
