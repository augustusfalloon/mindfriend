// tests/app.test.js
const assert = require('assert');
const App = require('../src/models/app'); // adjust path as needed
const {connectToDatabase, disconnectFromDatabase} = require("../src/services/databaseService");

async function runTests() {
  console.log('Running App class tests…');

  await disconnectFromDatabase();

  await connectToDatabase();

//   const result = await connectToDatabase();
//   client = result.client

  // 1) Initialization & property‐setting
  let app = await App.createApp({userId: 'u123', bundleId: 'com.foo', dailyUsage: 60});
  assert.strictEqual(app.userId, 'u123');
  assert.strictEqual(app.bundleId, 'com.foo');
  assert.strictEqual(app.dailyUsage, 60);


  await assert.rejects(
    () => App.createApp({ userId: 'u123', bundleId: 'com.foo' }),
    {
        name: 'Error',
        message: 'All fields are required to create an app'
    }
  );
  await assert.rejects(
    () => App.createApp({ bundleId: 'com.foo', dailyUsage: 10 }),
    {
        name: 'Error',
        message: 'All fields are required to create an app'
    }
  );
  await assert.rejects(
    () => App.createApp({ userId: 'u1', dailyUsage: 10 }),
    {
        name: 'Error',
        message: 'All fields are required to create an app'
    }
  );
  await assert.rejects(
    () => App.createApp({ userId: 'u1', bundleId: 'com.foo', dailyUsage: '60' }),
    {
        name: 'Error',
        message: 'Daily usage must be a number'
    }
  );

  // 2) Remaining‐time calculation
  const app2 = await App.createApp({ userId: 'u', bundleId: 'b', dailyUsage: 100 });
  assert.strictEqual(app2.getRemaining(30), 70);
  assert.strictEqual(app2.getRemaining(0), 100);
  assert.strictEqual(app2.getRemaining(150), -50);

  // 3) Warning‐trigger logic
  const app3 = await App.createApp({ userId: 'u', bundleId: 'b', dailyUsage: 50 });
  assert.strictEqual(app3.hasExceeded(49), false);
  assert.strictEqual(app3.hasExceeded(50), false);
  assert.strictEqual(app3.hasExceeded(100), true);

  // 4) Serialization
  const app4 = await App.createApp({ userId: 'u1', bundleId: 'com.bar', dailyUsage: 75 });
  const json = JSON.parse(JSON.stringify(app4));
  assert.deepStrictEqual(json.userId, 'u1');
  assert.deepStrictEqual(json.bundleId, 'com.bar');
  assert.deepStrictEqual(json.dailyUsage, 75);
//   assert.deepStrictEqual(json.userId, {
//     userId: 'u1',
//     bundleId: 'com.bar',
//     dailyUsage: 75
//   });

  console.log('✅ All App class tests passed!');
  
  await disconnectFromDatabase();
    process.exit(0);    
}

runTests();
