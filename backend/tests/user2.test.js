const mongoose = require('mongoose');
const assert = require('assert');
const User = require('../src/models/user.js');
const App = require('../src/models/app.js');
const {connectToDatabase, disconnectFromDatabase} = require("../src/services/databaseService");

async function clearDatabaseUser() {
    await User.deleteMany();
}

async function clearDatabaseApp() {
    await App.deleteMany();
}


async function runTests() {
    console.log('Running App class tests…');

    await disconnectFromDatabase();
    
    await connectToDatabase();

    await clearDatabaseUser();

    await clearDatabaseApp();
    

    const user = await User.createNewUser({email: 'Alice Johnson', username: 'Alicej', passwordHash: 'someHashedPassword' });
    await user.save();
    //create new user

    await user.updateRestriction('facebook', 60);
    //change facebook restriction to 60

    const populatedUser = await User.findById(user._id).populate('restrictedApps');
    //populate the field with real items

    assert.strictEqual(populatedUser.restrictedApps.length, 8);

    // Now you can search by bundleId on populated objects:
    const app = populatedUser.restrictedApps.find(app => app.bundleId === 'facebook');
    assert.ok(app, "App with bundleId 'facebook' should exist");
    assert.strictEqual(app.dailyUsage, 60);


    await user.updateRestriction('instagram', 45);

    assert.strictEqual(user.restrictedApps.length,  8);

    await user.updateRestriction('facebook', 80);

    const populatedUser2 = await User.findById(user._id).populate('restrictedApps');
    const app2 = populatedUser2.restrictedApps.find(app => app.bundleId === 'facebook');
    assert.ok(app2, "App with bundleId 'facebook' should exist");
    assert.strictEqual(app2.dailyUsage, 80);
    console.log(app2.restricted);
    assert.strictEqual(app2.getRemaining(30), 50);
    assert.strictEqual(app2.getRemaining(0), 80);
    assert.strictEqual(app2.getRemaining(150), -70);
    assert.strictEqual(app2.hasExceeded(49), false);
    assert.strictEqual(app2.hasExceeded(50), false);
    assert.strictEqual(app2.hasExceeded(100), true);


    await user.updateRestriction('instagram', 20);
    const populatedUser3 = await User.findById(user._id).populate('restrictedApps');
    const app3 = populatedUser3.restrictedApps.find(app => app.bundleId === 'instagram');
    assert.ok(app3, "App with bundleId 'instagram' should exist");
    assert.strictEqual(app3.dailyUsage, 20);

    await user.toggleRestriction('instagram');
    const populatedUser4 = await User.findById(user._id).populate('restrictedApps');
    const app4 = populatedUser4.restrictedApps.find(app => app.bundleId === 'instagram');
    assert.ok(app4, "App with bundleId 'instagram' should exist");
    assert.strictEqual(app4.restricted, true);

    await user.addComment("instagram", "I messed up bad");
    const populatedUser5 = await User.findById(user._id).populate('restrictedApps');
    const app5 = populatedUser5.restrictedApps.find(app => app.bundleId ==='instagram');
    assert.ok(app5, "App with bundleId 'instagram' should exist");
    console.log(app5.comments);
    assert.strictEqual(app5.comments, "I messed up bad");

    const exceeded = await user.getExceeded({"instagram": 40, "facebook": 90});
    console.log(exceeded);


    const user2 = await User.createNewUser({email: 'stuff', username: 'stuff', passwordHash: 'stuff' });
    await user.addFriend(user2.username) 
    console.log(user.friends);
    console.log(user.friends.length);
    await disconnectFromDatabase();

}

runTests();