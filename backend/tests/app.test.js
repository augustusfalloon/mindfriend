// tests/app.test.js
const assert = require('assert');
const App = require('../src/models/app'); // adjust path as needed

async function runTests() {
  console.log('Running App class tests…');

  // 1) Initialization & property‐setting
  let app = await App.createApp({
    userId: 'u123',
    bundleId: 'com.foo',
    dailyUsage: 60
  });
  assert.strictEqual(app.userId, 'u123');
  assert.strictEqual(app.bundleId, 'com.foo');
  assert.strictEqual(app.dailyUsage, 60);

  assert.throws(
    () => App.createApp({ userId: 'u123', bundleId: 'com.foo' }),
    Error
  );
  assert.throws(
    () => App.createApp({ bundleId: 'com.foo', dailyUsage: 10 }),
    Error
  );
  assert.throws(
    () => App.createApp({ userId: 'u1', dailyUsage: 10 }),
    Error
  );
  assert.throws(
    () => App.createApp({ userId: 'u1', bundleId: 'com.foo', dailyUsage: '60' }),
    Error
  );

  // 2) Remaining‐time calculation
  app = App.createApp({ userId: 'u', bundleId: 'b', dailyUsage: 100 });
  assert.strictEqual(app.getRemaining(30), 70);
  assert.strictEqual(app.getRemaining(0), 100);
  assert.strictEqual(app.getRemaining(150), 0);

  // 3) Warning‐trigger logic
  app = App.createApp({ userId: 'u', bundleId: 'b', dailyUsage: 50 });
  assert.strictEqual(app.hasExceeded(49), false);
  assert.strictEqual(app.hasExceeded(50), true);
  assert.strictEqual(app.hasExceeded(100), true);

  // 4) Serialization
  app = App.createApp({ userId: 'u1', bundleId: 'com.bar', dailyUsage: 75 });
  const json = JSON.parse(JSON.stringify(app));
  assert.deepStrictEqual(json, {
    userId: 'u1',
    bundleId: 'com.bar',
    dailyUsage: 75
  });

  console.log('✅ All App class tests passed!');
}

runTests();
