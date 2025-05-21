const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');

// POST /api/users → Create new user
router.post('/', userController.createUser);

// POST /api/users/restrict-app → Restrict an app
router.post('/restrict-app', userController.restrictApp);

// patch /api/users/update-restriction → Update restriction
router.patch('/update-restriction', userController.updateRestriction);


// patch
router.patch('/toggle-restriciton', userController.toggleRestriciton);


// POST /api/users/add-friend → Add a friend
router.post('/add-friend', userController.addFriend);

// GET /api/users/:userID → Get user info (optional)
router.get('/:userID', userController.getUserProfile);

// POST /api/users/login → Login a user
router.post('/login', userController.login);

// POST /api/users/logout → Logout a user
router.post('/logout', userController.logout);

// POST /api/users/add-comment
router.post('/add-comment', userController.addComment);

router.get('/exceeded', userController.getExceeded);

module.exports = router;
