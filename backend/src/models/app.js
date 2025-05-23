// App.js: userId, bundleId, dailyUsage: time before warning

const mongoose = require('mongoose');

const AppSchema = new mongoose.Schema({
  userId: { type: String, required: true },
  bundleId: { type: String, required: true }, // App's bundle ID
  dailyUsage: { type: Number, required: true }, // Daily usage limit in minutes
  restricted: { type: Boolean, default: false }, // Whether the app is restricted
  comments: {type: String, default: false},
});


AppSchema.statics.createApp = async function (params) {
    console.log('params: ', params);
  if (!params.userId || !params.bundleId) {
    console.log(`${params.userId}, ${params.bundleId}`);
    throw new Error('All fields are required to create an app');
  }
  console.log(params.dailyUsage);
  let num = parseInt(params.dailyUsage);
  if (typeof num != 'number') {
    throw new Error('Daily usage must be a number');
  }
  const app = new this({ userId: params.userId, bundleId: params.bundleId, dailyUsage: num, restricted: false });
  return await app.save();
};

AppSchema.methods.getRemaining = function (usageMin) {
    // console.log('params: ', params);
    // const { usageMin } = params.usageMin;
    // console.log(this.dailyUsage);
    // console.log(usageMin);
    // console.log(this.dailyUsage - usageMin);
    return this.dailyUsage - usageMin;
};

AppSchema.methods.hasExceeded = function (usageMin) {
    // console.log('params: ', params);
    // const { usageMin } = paramgs.usageMin;
    let remain = this.getRemaining(usageMin);
    console.log("Remain: ", typeof(remain));
    console.log(remain);
    if (remain < 0) {
        return true;
    }
    return false;
};


AppSchema.methods.addComment = async function (comment) {
    if (!comment) {
        throw new Error('You must add a reason');
    }
    this.comments = comment;
    return await this.save();
}

const App = mongoose.model('App', AppSchema);
module.exports = App;
