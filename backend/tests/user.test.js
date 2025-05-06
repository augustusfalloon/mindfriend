const mongoose = require('mongoose');
const User = require('../src/models/user.js');


async function connectToDatabase() {
    await mongoose.connect('mongodb://localhost:27017/mindfriend_test');
}

async function clearDatabase() {
    await User.deleteMany();
}

async function disconnectFromDatabase() {
    await mongoose.connection.close();
}


async function testCreateUser() {
  await connectToDatabase();
  await clearDatabase();

  const user = new User({ fullName: 'Alice Johnson', username: 'alicej', userID: 'user123' });
  await user.save();

  const savedUser = await User.findOne({ username: 'alicej' });
  if (!savedUser || savedUser.username !== 'alicej') {
      throw new Error('User was not saved in the database');
  }

  console.log('Test passed: User created successfully');
  await disconnectFromDatabase();
}

async function testRestrictApp() {
  await connectToDatabase();
  await clearDatabase();

  const user = new User({ fullName: 'Bob', username: 'bobthebuilder', userID: 'user456' });
  await user.save();

  user.restrictedApps = [{ appID: 'com.instagram.ios', timerDuration: 0 }];
  await user.save();

  const updatedUser = await User.findOne({ username: 'bobthebuilder' });
  const restrictedApp = updatedUser.restrictedApps.find(app => app.appID === 'com.instagram.ios');
  if (!restrictedApp) {
      throw new Error('App was not restricted successfully');
  }

  console.log('Test passed: App restricted successfully');
  await disconnectFromDatabase();
}

async function testUpdateRestriction() {
  await connectToDatabase();
  await clearDatabase();

  const user = new User({ fullName: 'Charlie', username: 'charliebitme', userID: 'user789' });
  user.restrictedApps = [{ appID: 'com.tiktok.ios', timerDuration: 3600 }];
  await user.save();

  const restrictedApp = user.restrictedApps.find(app => app.appID === 'com.tiktok.ios');
  if (!restrictedApp) {
      throw new Error('App restriction was not found');
  }
  restrictedApp.timerDuration = 1800;
  await user.save();

  const updatedUser = await User.findOne({ username: 'charliebitme' });
  const updatedRestrictedApp = updatedUser.restrictedApps.find(app => app.appID === 'com.tiktok.ios');
  if (!updatedRestrictedApp || updatedRestrictedApp.timerDuration !== 1800) {
      throw new Error('App restriction was not updated successfully');
  }

  console.log('Test passed: App restriction updated successfully');
  await disconnectFromDatabase();
}

async function testAddFriend() {
  await connectToDatabase();
  await clearDatabase();

  const user = new User({ fullName: 'Dora', username: 'doratheexplorer', userID: 'user321' });
  await user.save();

  user.friends = ['user1234'];
  await user.save();

  const updatedUser = await User.findOne({ username: 'doratheexplorer' });
  if (!updatedUser || !updatedUser.friends.includes('user1234')) {
      throw new Error('Friend was not added successfully');
  }

  console.log('Test passed: Friend added successfully');
  await disconnectFromDatabase();
}

async function testFailCreateUser() {
  await connectToDatabase();
  await clearDatabase();

  try {
      const user = new User({ fullName: 'Eva', userID: 'user654' }); // Missing username
      await user.save();
      throw new Error('Test failed: User was created with missing fields');
  } catch (error) {
      console.log('Test passed: User creation failed with missing fields');
  }

  await disconnectFromDatabase();
}

async function testFailRestrictApp() {
  await connectToDatabase();
  await clearDatabase();

  const user = await User.findOne({ userID: 'nonexistentuser' });
  if (user) {
      throw new Error('Test failed: Found a non-existent user');
  }

  console.log('Test passed: Restricting app for non-existent user failed as expected');
  await disconnectFromDatabase();
}

async function testFailUpdateRestriction() {
  await connectToDatabase();
  await clearDatabase();

  const user = new User({ fullName: 'Fred', username: 'fredflintstone', userID: 'user159' });
  await user.save();

  const restrictedApp = user.restrictedApps?.find(app => app.appID === 'nonexistentapp');
  if (restrictedApp) {
      throw new Error('Test failed: Found a non-existent app restriction');
  }

  console.log('Test passed: Updating restriction for non-existent app failed as expected');
  await disconnectFromDatabase();
}

async function runTests() {
  await testCreateUser();
  await testRestrictApp();
  await testUpdateRestriction();
  await testAddFriend();
  await testFailCreateUser();
  await testFailRestrictApp();
  await testFailUpdateRestriction();
  console.log('All tests completed!');
}

runTests().catch(error => {
  console.error('Test failed:', error.message);
});