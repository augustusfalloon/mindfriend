// Handles endpoints for app usage (POST /usage, GET /usage/:id, etc.)

const User = require('../models/user');
const UsageLog = require('../models/UsageLog');
const { createUser, restrictApp, updateRestriction, addFriend } = require('./userController');

// need to rewrite to use the user method createnewuser

const signUp = async (email, password, name) => {
  const existingUser = await User.findOne({ email });
  if (existingUser) {
    throw new Error('User already exists');
  }

  const newUser = new User({ email, password, name });
  await newUser.save();
  await createUser(newUser);
  return newUser;
};

const signIn = async (email, password) => {
  const user = await User.findOne({ email });
  if (!user || user.password !== password) {
    throw new Error('Invalid credentials');
  }

  return user;
};

const signInOrSignUp = async (req, res) => {
  const { email, password, name, signUp: isSignUp } = req.body;

  try {
    if (isSignUp) {
      const newUser = await signUp(email, password, name);
      return res.status(201).json(newUser);
    } else {
      const user = await signIn(email, password);
      return res.status(200).json(user);
    }
  } catch (error) {
    const statusCode =
      error.message === 'User already exists' || error.message === 'Invalid credentials'
        ? 400
        : 500;
    return res.status(statusCode).json({ message: error.message });
  }
};

const setUsageHours = async (userId, usageHours) => {
  const user = await User.findById(userId);
  if (!user) {
    throw new Error('User not found');
  }

  user.usageHours = usageHours;
  await user.save();
  return user;
};

const setHighRiskTimeBlocks = async (userId, timeBlocks) => {
  const user = await User.findById(userId);
  if (!user) {
    throw new Error('User not found');
  }

  user.highRiskTimeBlocks = timeBlocks;
  await user.save();
  return user;
};

const setRestrictedApps = async (userId, apps) => {
  const user = await User.findById(userId);
  if (!user) {
    throw new Error('User not found');
  }

  user.restrictedApps = apps;
  await user.save();
  return user;
};

const uploadUsage = async (req, res) => {
  try {
    const { userID, bundleId, duration, timestamp } = req.body;

    if (!userID || !bundleId || !duration || !timestamp) {
      return res.status(400).json({ error: 'Missing required fields.' });
    }

    const newLog = new UsageLog({
      userID,
      bundleId,
      duration,
      timestamp: new Date(timestamp),
    });

    await newLog.save();
    res.status(200).json({ message: 'Usage data saved successfully.' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

const getUsageLogs = async (req, res) => {
  try {
    const { userID } = req.params;
    const logs = await UsageLog.find({ userID }).sort({ timestamp: -1 });
    res.status(200).json(logs);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};


module.exports = {
  signInOrSignUp,
  signUp,
  signIn,
  setUsageHours,
  setHighRiskTimeBlocks,
  setRestrictedApps,
  uploadUsage,
  getUsageLogs
};
