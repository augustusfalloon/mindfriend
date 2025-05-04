// Handles endpoints for app usage (POST /usage, GET /usage/:id, etc.)


const User = require('../models/User');
const { createUser, restrictApp, updateRestriction, addFriend } = require('./userController');

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
    const statusCode = error.message === 'User already exists' || error.message === 'Invalid credentials' ? 400 : 500;
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

// still need to work with app store permissions


// still need to do friend invites

// need to have some sort of integration with screen time API


module.exports = { signInOrSignUp, signUp, signIn };