const express = require('express');
const router = express.Router();
const appController = require('../controllers/appController');
const { saveAppRestrictions, getAppRestrictions } = require('../controllers/appController');

// Route to save app restrictions
router.post('/restrictions', saveAppRestrictions);

// Route to get app restrictions for a user
router.get('/restrictions/:userId', getAppRestrictions);


// POST /api/apps/upload-usage → Upload screen time usage
router.post('/upload-usage', appController.uploadUsage);

// GET /api/apps/usage/:userID → Get usage log for a user (might add next iteration)
router.get('/usage/:userID', appController.getUsageLogs);

module.exports = router;
