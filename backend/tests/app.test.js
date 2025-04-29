// tests/app.test.js
const App = require('../src/models/app'); // or './src/models/App' depending on your filename

describe('App Class', () => {
  describe('Initialization & property‐setting', () => {
    test('constructs with valid userId, bundleId & dailyUsage', () => {
      const app = new App({ userId: 'u123', bundleId: 'com.foo', dailyUsage: 60 });
      expect(app.userId).toBe('u123');
      expect(app.bundleId).toBe('com.foo');
      expect(app.dailyUsage).toBe(60);
    });

    test('throws if dailyUsage is negative', () => {
      expect(
        () => new App({ userId: 'u1', bundleId: 'com.foo', dailyUsage: -10 })
      ).toThrow();
    });

    test('throws if any field is missing or wrong type', () => {
      expect(() => new App({ bundleId: 'com.foo', dailyUsage: 10 })).toThrow();
      expect(() => new App({ userId: 'u1', dailyUsage: 10 })).toThrow();
      expect(() => new App({ userId: 'u1', bundleId: 'com.foo', dailyUsage: '60' })).toThrow();
    });
  });

  describe('Remaining‐time calculation', () => {
    let app;
    beforeAll(() => {
      app = new App({ userId: 'u', bundleId: 'b', dailyUsage: 100 });
    });

    test('remainingTime = dailyUsage − used', () => {
      expect(app.getRemaining(30)).toBe(70);
      expect(app.getRemaining(0)).toBe(100);
    });

    test('remainingTime never negative', () => {
      expect(app.getRemaining(150)).toBe(0);
    });
  });

  describe('Warning‐trigger logic', () => {
    let app;
    beforeAll(() => {
      app = new App({ userId: 'u', bundleId: 'b', dailyUsage: 50 });
    });

    test('hasExceeded returns false if used < dailyUsage', () => {
      expect(app.hasExceeded(49)).toBe(false);
    });

    test('hasExceeded returns true if used ≥ dailyUsage', () => {
      expect(app.hasExceeded(50)).toBe(true);
      expect(app.hasExceeded(100)).toBe(true);
    });
  });

  describe('Serialization (toJSON)', () => {
    test('toJSON includes only userId, bundleId, dailyUsage', () => {
      const app = new App({ userId: 'u1', bundleId: 'com.bar', dailyUsage: 75 });
      const obj = JSON.parse(JSON.stringify(app));
      expect(obj).toEqual({
        userId: 'u1',
        bundleId: 'com.bar',
        dailyUsage: 75
      });
    });
  });
});
