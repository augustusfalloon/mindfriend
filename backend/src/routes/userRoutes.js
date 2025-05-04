const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');

// POST /api/users → Create new user
router.post('/', userController.createUser);

// POST /api/users/restrict-app → Restrict an app
router.post('/restrict-app', userController.restrictApp);

// POST /api/users/update-restriction → Update restriction
router.post('/update-restriction', userController.updateRestriction);

// POST /api/users/add-friend → Add a friend
router.post('/add-friend', userController.addFriend);

// GET /api/users/:userID → Get user info (optional)
router.get('/:userID', userController.getUserProfile);

module.exports = router;
