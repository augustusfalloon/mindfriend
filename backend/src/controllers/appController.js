// Handles endpoints for app usage (POST /usage, GET /usage/:id, etc.)

const User = require('../models/user');
const UsageLog = require('../models/UsageLog');
const { createUser, restrictApp, updateRestriction, addFriend } = require('./userController');

// need to rewrite to use the user method createnewuser

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

const getAppRestrictions = async (userId) => {
    const user = await User.findbyId(userId);
    if (!user) {
        throw new Error("User not found");
    }
    return user.restrictedApps;
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
  getUsageLogs,
  getAppRestrictions,
};
