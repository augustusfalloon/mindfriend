// App.js: userId, bundleId, dailyUsage: time before warning

const mongoose = require('mongoose');

const AppSchema = new mongoose.Schema({
  userId: { type: String, required: true },
  bundleId: { type: String, required: true }, // App's bundle ID
  dailyUsage: { type: Number, required: true }, // Daily usage limit in minutes
  restricted: { type: Boolean, default: false }, // Whether the app is restricted
});

AppSchema.statics.createApp = async function (params) {
    console.log('params: ', params);
  if (!params.userId || !params.bundleId || !params.dailyUsage) {
    throw new Error('All fields are required to create an app');
  }
  if (typeof params.dailyUsage != 'number') {
    throw new Error('Daily usage must be a number');
  }
  const app = new this({ userId: params.userId, bundleId: params.bundleId, dailyUsage: params.dailyUsage, restricted: false });
  return await app.save();
};
const App = mongoose.model('App', AppSchema);
module.exports = App;
