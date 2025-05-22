// Handles login, signup, user retrieval.

const User = require('../models/user');

// new user onboarding&signup
const bcrypt = require('bcrypt');
exports.createUser = async (req, res) => {
    try {
        const { email, username, password } = req.body;
        if (!email || !username || !password) {
            throw new Error('Missing required fields');
        }
        
        // check for duplicate user
        const existingUser = await User.findOne({ username });
        if (existingUser) {
            throw new Error('Username already exists');
        }
        
        // hash the password
        const passwordHash = await bcrypt.hash(password, 10);
        const newUser = new User({ email, username, passwordHash, restrictedApps: [], friends: [] });
        await newUser.save();
        res.status(201).json(newUser);
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
};
// restrict an app for a user
exports.restrictApp = async (req, res) => {
    try {
        const { _id, bundleID, dailyUsage } = req.body;
        const user = await User.findById({ _id });
        if (!user) throw new Error('User not found.');

        await user.restrictApp(bundleID, dailyUsage);
        await user.save();

        res.status(200).json({ message: 'App restricted successfully.' });
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
};

// update a restriction for an app
exports.updateRestriction = async (req, res) => {
    try {
        const { userID, bundleID, newTime } = req.body;
        const user = await User.findOne({ userID });
        if (!user) throw new Error('User not found.');

        await user.updateRestriction(bundleID, newTime);
        await user.save();

        res.status(200).json({ message: 'Restriction updated successfully.' });
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
};


exports.toggleRestriciton = async (req, res) => {
    try {
        const { userID, bundleID } = req.body;
        const user = await User.findOne({ userID });
        if (!user) throw new Error('User not found.');

        await user.toggleRestriciton(bundleID);

        res.status(200).json({ message: 'Restriction toggled successfully.' });
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
}

exports.getElapsed = async (req, res) => {
    try {
        let pd = [];
        const {userID} = req.body;
        const user = await User.findOne({userID});
        await user.populate('restrictedApps');
        for (const app of user.restrictedApps) {
            if (app.dailyUsage < 0) {
                pd.push(app);
            }
        }
        res.status(200).json(pd);
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
};

// add friend
exports.addFriend = async (req, res) => {
    try {
        const { userId, friendID } = req.body;
        const user = await User.findOne({ userId });
        if (!user) throw new Error('User not found.');
  
        await user.addFriend(friendID);
        //await user.save();

        res.status(200).json({ message: 'Friend added successfully.' });
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
};

// get a user's profile by userID
exports.getUserProfile = async (req, res) => {
    try {
        const { username } = req.params;
        const user = await User.findOne({ username });
        if (!user) {
            return res.status(404).json({ error: 'User not found.' });
        }
        res.status(200).json(user);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.addComment = async (req, res) => {
    try {
        const { username, comment, bundleID } = req.params;
        const user = await User.findOne({ username });
        if (!user) {
            return res.status(404).json({ error: 'User not found.' });
        }
        await user.addComment(comment, bundleID);

    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.getExceeded = async (req, res) => {
    try {
        const {usage, username} = req.params;
        const user = await User.findOne({ username });
        if (!user) {
            return res.status(404).json({ error: 'User not found.' });
        }

        const exceeded = user.getExceeded(usage);
        res.status(200).json(exceeded);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.getApps = async(req, res) => {
    try {
        const {username} = req.params;
        const user = await User.findOne({username});
        if (!user) {
            return res.status(404).json({ error: 'User not found.' });
        }
        const apps = user.getApps();
        res.status(200).json(apps);

    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

//handle login

const jwt = require('jsonwebtoken');

exports.login = async (req, res) => {
    try {
        const { username, password } = req.body;

        // Find the user by username
        const user = await User.findOne({ username });
        if (!user) {
            return res.status(401).json({ error: 'Invalid credentials' });
        }

        // Verify the provided password with the stored hash
        const isPasswordValid = await bcrypt.compare(password, user.passwordHash);
        if (!isPasswordValid) {
            return res.status(401).json({ error: 'Invalid credentials' });
        }

        // Generate a JWT token
        const token = jwt.sign({ userId: user._id }, process.env.JWT_SECRET, { expiresIn: '1h' });

        return res.status(200).json({ token, message: 'Login successful' });
    } catch (error) {
        console.error(error);
        return res.status(500).json({ error: 'Internal server error' });
    }
};

// cursory logout - should be handled on client side 
exports.logout = async (req, res) => {
    return res.status(200).json({ message: 'Logout successful' });
};

/**
 * Get all app restrictions and their associated times for a user.
 */
exports.getAppRestrictions = async (req, res) => {
  try {
    const { userID } = req.params;
    const user = await User.findOne({ userID });
    if (!user) {
      return res.status(404).json({ error: 'User not found.' });
    }
    res.status(200).json({ restrictedApps: user.restrictedApps });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

/**
 * Get all friends for a user.
 */
exports.getFriends = async (req, res) => {
  try {
    const { userID } = req.params;
    const user = await User.findOne({ userID });
    if (!user) {
      return res.status(404).json({ error: 'User not found.' });
    }
    res.status(200).json({ friends: user.friends });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

/**
 * Get all user data (excluding sensitive info like passwordHash).
 */
exports.getUserData = async (req, res) => {
  try {
    const { userID } = req.params;
    const user = await User.findOne({ userID }).select('-passwordHash -__v -_id');
    if (!user) {
      return res.status(404).json({ error: 'User not found.' });
    }
    res.status(200).json(user);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};