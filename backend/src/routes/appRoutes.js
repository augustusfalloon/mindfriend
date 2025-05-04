const express = require('express');
const router = express.Router();
const appController = require('../controllers/appController');

console.log('appController.uploadUsage:', typeof appController.uploadUsage);

// POST /api/apps/upload-usage → Upload screen time usage
router.post('/upload-usage', appController.uploadUsage);

// GET /api/apps/usage/:userID → Get usage log for a user (might add next iteration)
router.get('/usage/:userID', appController.getUsageLogs);

module.exports = router;
