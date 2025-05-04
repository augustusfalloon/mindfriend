// Handles login, signup, user retrieval.

const User = require('../models/user');

// new user onboarding&signup
exports.createUser = async (req, res) => {
    try {
        const { fullName, username, userID } = req.body;
        const newUser = new User({ fullName, username, userID, restrictedApps: [], friends: [] });
        await newUser.save();
        res.status(201).json(newUser);
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
};

// restrict an app for a user
exports.restrictApp = async (req, res) => {
    try {
        const { userID, appID } = req.body;
        const user = await User.findOne({ userID });
        if (!user) throw new Error('User not found.');

        await user.restrictApp(appID);
        await user.save();

        res.status(200).json({ message: 'App restricted successfully.' });
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
};

// update a restriction for an app
exports.updateRestriction = async (req, res) => {
    try {
        const { userID, appID, newTime } = req.body;
        const user = await User.findOne({ userID });
        if (!user) throw new Error('User not found.');

        await user.updateRestriction(appID, newTime);
        await user.save();

        res.status(200).json({ message: 'Restriction updated successfully.' });
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
};

// add friend
exports.addFriend = async (req, res) => {
    try {
        const { userID, friendID } = req.body;
        const user = await User.findOne({ userID });
        if (!user) throw new Error('User not found.');

        await user.addFriend(friendID);
        await user.save();

        res.status(200).json({ message: 'Friend added successfully.' });
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
};
