const express = require('express');
const router = express.Router();
const appController = require('../controllers/appController');
const { setRestrictedApps, getAppRestrictions} = require('../controllers/appController');
const ScreenTime = require('../models/UsageLog');

// Route to save app restrictions
router.post('/restrictions', setRestrictedApps);

// Route to get app restrictions for a user
router.get('/restrictions/:userId', getAppRestrictions);

console.log('appController.uploadUsage:', typeof appController.uploadUsage);

// POST /api/apps/upload-usage → Upload screen time usage
router.post('/upload-usage', appController.uploadUsage);

// GET /api/apps/usage/:userID → Get usage log for a user (might add next iteration)
router.get('/usage/:userID', appController.getUsageLogs);

// POST /api/screen-time - Frontend sends screen time data
router.post('/', async (req, res) => {
    try {
        const { userId, appId, usage, date } = req.body;
        if (!userId || !appId || usage == null || !date) {
            return res.status(400).json({ error: 'Missing required fields' });
        }
        const record = await ScreenTime.create({ userId, appId, usage, date });
        res.status(201).json(record);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// GET /api/screen-time/:userId - Get all screen time for a user
router.get('/:userId', async (req, res) => {
    try {
        const { userId } = req.params;
        const records = await ScreenTime.find({ userId });
        res.json(records);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;
