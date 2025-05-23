const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');

// POST /api/users → Create new user
router.post('/', userController.createUser);

// POST /api/users/restrict-app → Restrict an app
//WE SHOULD NEVER USE THIS, ONLY DO UPDATE
router.post('/restrict-app', userController.restrictApp);

// patch /api/users/update-restriction → Update restriction
router.patch('/update-restriction', userController.updateRestriction);


router.get('/all-apps', userController.getApps);

// patch
router.patch('/toggle-restriciton', userController.toggleRestriciton);


// POST /api/users/add-friend → Add a friend
router.post('/add-friend', userController.addFriend);

// GET /api/users/:userID → Get user info (optional)
router.get('/:username', userController.getUserProfile);

// POST /api/users/login → Login a user
router.post('/login', userController.login);

// POST /api/users/logout → Logout a user
router.post('/logout', userController.logout);

// POST /api/users/add-comment
router.post('/add-comment', userController.addComment);

router.post('/exceeded', userController.getExceeded);

router.get('/:username/friends', userController.getFriends);



module.exports = router;
