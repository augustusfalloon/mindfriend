const mongoose = require('mongoose');
const assert = require('assert');
const User = require('../src/models/user.js');
const {connectToDatabase, disconnectFromDatabase} = require("../src/services/databaseService");

async function clearDatabase() {
    await User.deleteMany();
}


async function runTests() {
    console.log('Running App class tests…');

    await disconnectFromDatabase();
    
    await connectToDatabase();

    await clearDatabase();
    

    const user = await User.create({email: 'Alice Johnson', username: 'alicej', userID: 'user123', passwordHash: 'someHashedPassword' });
    await user.save();

    await user.restrictApp('com.foo', 60);

    const populatedUser = await User.findById(user._id).populate('restrictedApps');

    assert.strictEqual(populatedUser.restrictedApps.length, 1);

    // Now you can search by bundleId on populated objects:
    const app = populatedUser.restrictedApps.find(app => app.bundleId === 'com.foo');
    assert.ok(app, "App with bundleId 'com.foo' should exist");
    assert.strictEqual(app.dailyUsage, 60);


    await user.restrictApp('face.com', 45);

    assert.strictEqual(user.restrictedApps.length,  2);

    await user.updateRestriction('face.com', 80);

    const populatedUser2 = await User.findById(user._id).populate('restrictedApps');
    const app2 = populatedUser2.restrictedApps.find(app => app.bundleId === 'face.com');
    assert.ok(app2, "App with bundleId 'com.foo' should exist");
    assert.strictEqual(app2.dailyUsage, 80);
    console.log(app2.restricted);
    assert.strictEqual(app2.getRemaining(30), 50);
    assert.strictEqual(app2.getRemaining(0), 80);
    assert.strictEqual(app2.getRemaining(150), -70);
    assert.strictEqual(app2.hasExceeded(49), false);
      assert.strictEqual(app2.hasExceeded(50), false);
      assert.strictEqual(app2.hasExceeded(100), true);

    await user.updateRestriction('com.foo', 20);
    const populatedUser3 = await User.findById(user._id).populate('restrictedApps');
    const app3 = populatedUser3.restrictedApps.find(app => app.bundleId === 'com.foo');
    assert.ok(app3, "App with bundleId 'com.foo' should exist");
    assert.strictEqual(app3.dailyUsage, 20);

    await user.toggleRestriction('face.com');
    const populatedUser4 = await User.findById(user._id).populate('restrictedApps');
    const app4 = populatedUser4.restrictedApps.find(app => app.bundleId === 'face.com');
    assert.ok(app4, "App with bundleId 'com.foo' should exist");
    assert.strictEqual(app4.restricted, true);

    await disconnectFromDatabase();

}

runTests();