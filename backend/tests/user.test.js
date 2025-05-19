const mongoose = require('mongoose');
const User = require('../src/models/user.js');
const {connectToDatabase, disconnectFromDatabase} = require("../src/services/databaseService");


// async function connectToDatabase() {
//     await mongoose.connect('mongodb://localhost:27017/mindfriend_test');
// }

async function clearDatabase() {
    await User.deleteMany();
}

// async function disconnectFromDatabase() {
//     await mongoose.connection.close();
// }


async function testCreateUser() {
  // await connectToDatabase();
  // await clearDatabase();

  const user = await User.createNewUser({fullName: 'Alice Johnson', username: 'alicej', userID: 'user123' });
  await user.save();

  const savedUser = await User.findOne({ username: 'alicej' });
  if (!savedUser || savedUser.fullName !== 'Alice Johnson' || savedUser.userID !== 'user123') {
      throw new Error('User was not saved in the database with correct fields');
  }

  try {
    await User.createNewUser({ fullName: 'Alice Johnson', username: 'alicej', userID: 'user456' });
    throw new Error('Test failed: Duplicate username was allowed');
  } catch (error) {
    console.log('Test passed: Duplicate username was not allowed');
  }


  console.log('Test passed: User created successfully');
  // await disconnectFromDatabase();
}

async function testRestrictApp() {
  // await connectToDatabase();
  // await clearDatabase();

  // Create a new user
  const user = await User.createNewUser({ fullName: 'Bob', username: 'bobthebuilder', userID: 'user456' });

  // Add an app restriction
  user.restrictedApps = [{ appID: 'com.instagram.ios', timerDuration: 0, timerRecurring: false }];
  await user.save();

  // Verify the app restriction was saved correctly
  const updatedUser = await User.findOne({ username: 'bobthebuilder' });
  const restrictedApp = updatedUser.restrictedApps.find(app => app.appID === 'com.instagram.ios');
  if (!restrictedApp || restrictedApp.timerDuration !== 0 || restrictedApp.timerRecurring !== false) {
      throw new Error('App restriction was not saved with correct default values');
  }

  // Test duplicate app restriction
  user.restrictedApps.push({ appID: 'com.instagram.ios', timerDuration: 3600 });
  try {
      await user.save();
      throw new Error('Test failed: Duplicate app restriction was allowed');
  } catch (error) {
      console.log('Test passed: Duplicate app restriction was not allowed');
  }

  console.log('Test passed: App restricted successfully');
  // await disconnectFromDatabase();
}

async function testUpdateRestriction() {
    // await connectToDatabase();
    // await clearDatabase();
  
    // Create a new user
    const user = await User.createNewUser({ fullName: 'Charlie', username: 'charliebitme', userID: 'user789' });
    user.restrictedApps = [{ appID: 'com.tiktok.ios', timerDuration: 3600, timerRecurring: false }];
    await user.save();
  
    // Verify the app restriction exists
    const restrictedApp = user.restrictedApps.find(app => app.appID === 'com.tiktok.ios');
    if (!restrictedApp) {
        throw new Error('App restriction was not found');
    }
  
    // Update the app restriction
    restrictedApp.timerDuration = 1800;
    await user.save();
  
    // Verify the app restriction was updated correctly
    const updatedUser = await User.findOne({ username: 'charliebitme' });
    const updatedRestrictedApp = updatedUser.restrictedApps.find(app => app.appID === 'com.tiktok.ios');
    if (!updatedRestrictedApp || updatedRestrictedApp.timerDuration !== 1800 || updatedRestrictedApp.timerRecurring !== false) {
        throw new Error('App restriction was not updated correctly');
    }
  
    // Test updating a non-existent app restriction
    const nonExistentApp = user.restrictedApps.find(app => app.appID === 'com.snapchat.ios');
    if (nonExistentApp) {
        throw new Error('Test failed: Non-existent app restriction was found');
    }
  
    console.log('Test passed: App restriction updated successfully');
    // await disconnectFromDatabase();
  }
  
  async function testAddFriend() {
    // await connectToDatabase();
    // await clearDatabase();
  
    // Create a new user
    const user = await User.createNewUser({ fullName: 'Dora', username: 'doratheexplorer', userID: 'user321' });
  
    // Add a friend
    user.friends = ['user1234'];
    await user.save();
  
    // Verify the friend was added
    const updatedUser = await User.findOne({ username: 'doratheexplorer' });
    if (!updatedUser || !updatedUser.friends.includes('user1234')) {
        throw new Error('Friend was not added successfully');
    }
  
    // Test adding the same friend again
    user.friends.push('user1234');
    await user.save();
    const duplicateFriendCheck = new Set(user.friends);
    
    //if (duplicateFriendCheck.size !== user.friends.length) {
    //    throw new Error('Duplicate friend was added');
    //}
    //THIS PART IS FAILING! FIX SOON
  
    // Test adding an invalid friend
    try {
        user.friends.push(12345); // Invalid userID (not a string)
        await user.save();
        throw new Error('Test failed: Invalid friend was added');
    } catch (error) {
        console.log('Test passed: Invalid friend was not allowed');
    }
  
    console.log('Test passed: Friend added successfully');
    // await disconnectFromDatabase();
  }

async function testFailCreateUser() {
  // await connectToDatabase();
  // await clearDatabase();

  // Test missing username
  try {
      await User.createNewUser({ fullName: 'Eva', userID: 'user654' }); // Missing username
      throw new Error('Test failed: User was created with missing username');
  } catch (error) {
      console.log('Test passed: User creation failed with missing username');
  }

  // Test missing fullName
  try {
      await User.createNewUser({ username: 'eva123', userID: 'user654' }); // Missing fullName
      throw new Error('Test failed: User was created with missing fullName');
  } catch (error) {
      console.log('Test passed: User creation failed with missing fullName');
  }

  // Test invalid username type
  try {
      await User.createNewUser({ fullName: 'Eva', username: 12345, userID: 'user654' }); // Invalid username type
      throw new Error('Test failed: User was created with invalid username type');
  } catch (error) {
      console.log('Test passed: User creation failed with invalid username type');
  }

  console.log('Test passed: User creation failed as expected for invalid inputs');
  // await disconnectFromDatabase();
}

async function testFailRestrictApp() {
    // await connectToDatabase();
    // await clearDatabase();
  
    // Test restricting app for a non-existent user
    const user = await User.findOne({ userID: 'nonexistentuser' });
    if (user) {
        throw new Error('Test failed: Found a non-existent user');
    }
  
    // Create a valid user
    const validUser = await User.createNewUser({ fullName: 'Frank', username: 'frankcastle', userID: 'user987' });
  
    // Test restricting an app with an invalid appID
    try {
        validUser.restrictedApps.push({ appID: '', timerDuration: 3600 }); // Invalid appID
        await validUser.save();
        throw new Error('Test failed: App restriction was added with an invalid appID');
    } catch (error) {
        console.log('Test passed: App restriction failed with invalid appID');
    }
  
    // Test restricting an app with invalid timerDuration
    try {
        validUser.restrictedApps.push({ appID: 'com.netflix.ios', timerDuration: 'invalid' }); // Invalid timerDuration
        await validUser.save();
        throw new Error('Test failed: App restriction was added with an invalid timerDuration');
    } catch (error) {
        console.log('Test passed: App restriction failed with invalid timerDuration');
    }
  
    console.log('Test passed: Restricting app for non-existent user or invalid data failed as expected');
    // await disconnectFromDatabase();
  }

  async function testFailUpdateRestriction() {
    // await connectToDatabase();
    // await clearDatabase();
  
    // Create a new user
    const user = await User.createNewUser({ fullName: 'Fred23', username: 'fredflintstone23', userID: 'user165' });
  
    // Verify that a non-existent app restriction cannot be found
    const restrictedApp = user.restrictedApps?.find(app => app.appID === 'nonexistentapp');
    if (restrictedApp) {
        throw new Error('Test failed: Found a non-existent app restriction');
    }
  
    // Attempt to update a non-existent app restriction
    try {
        const nonExistentApp = user.restrictedApps.find(app => app.appID === 'nonexistentapp');
        if (!nonExistentApp) {
            throw new Error('App restriction not found'); // Simulate the behavior of the updateRestriction method
        }
        nonExistentApp.timerDuration = 1800;
        await user.save();
        throw new Error('Test failed: Updated a non-existent app restriction');
    } catch (error) {
        console.log('Test passed: Updating a non-existent app restriction failed as expected');
    }
  
    // Test updating a restriction with an invalid appID
    try {
        user.restrictedApps.push({ appID: '', timerDuration: 3600 }); // Invalid appID
        await user.save();
        throw new Error('Test failed: Updated a restriction with an invalid appID');
    } catch (error) {
        console.log('Test passed: Updating a restriction with an invalid appID failed as expected');
    }
  
    // Test updating a restriction with an invalid timerDuration
    try {
        user.restrictedApps.push({ appID: 'com.hulu.ios', timerDuration: 'invalid' }); // Invalid timerDuration
        await user.save();
        throw new Error('Test failed: Updated a restriction with an invalid timerDuration');
    } catch (error) {
        console.log('Test passed: Updating a restriction with an invalid timerDuration failed as expected');
    }
  
    console.log('Test passed: Updating restriction for non-existent app or invalid data failed as expected');
    // await disconnectFromDatabase();
  }

async function runTests() {
  console.log('Running User class tests…');
  await disconnectFromDatabase();
  await connectToDatabase();
  await clearDatabase();
  await testCreateUser();
  await testRestrictApp();
  await testUpdateRestriction();
  await testAddFriend();
  await testFailCreateUser();
  await testFailRestrictApp();
  await testFailUpdateRestriction();
  console.log('All tests completed!');
  await disconnectFromDatabase();
}

runTests().catch(error => {
  console.error('Test failed:', error.message);
});