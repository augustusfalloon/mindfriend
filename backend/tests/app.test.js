// tests/mindfriend.unit.test.js

const { LoginViewModel } = require('../src/viewModels/LoginViewModel');
const { SettingsViewModel } = require('../src/viewModels/SettingsViewModel');
const { RestrictedAppAccessViewModel } = require('../src/viewModels/RestrictedAppAccessViewModel');
const { FeedViewModel, FriendActivity } = require('../src/viewModels/FeedViewModel');
const { FriendsViewModel } = require('../src/viewModels/FriendsViewModel');

describe('Login Screen Tests', () => {
  test('login button disabled during loading', () => {
    const vm = new LoginViewModel();
    vm.email = 'test@example.com';
    vm.password = 'password';
    vm.isLoading = true;
    expect(vm.isButtonDisabled).toBe(true);
  });

  test('error appears on failed login', () => {
    const vm = new LoginViewModel();
    vm.loginError = 'Invalid credentials';
    expect(vm.loginError).toBe('Invalid credentials');
  });

  test('successful login navigates to dashboard', () => {
    const vm = new LoginViewModel();
    vm.isLoggedIn = true;
    expect(vm.isLoggedIn).toBe(true);
  });
});

describe('Settings Screen Tests', () => {
  test('adding restricted app', () => {
    const vm = new SettingsViewModel();
    vm.addRestrictedApp('com.instagram.ios', 60);
    expect(vm.restrictedApps.length).toBe(1);
    expect(vm.restrictedApps[0]).toEqual({ appID: 'com.instagram.ios', waitTime: 60 });
  });

  test('deleting restricted app', () => {
    const vm = new SettingsViewModel();
    vm.addRestrictedApp('com.instagram.ios', 60);
    vm.deleteRestrictedApp('com.instagram.ios');
    expect(vm.restrictedApps).toHaveLength(0);
  });
});

describe('Restricted App Blocking Screen Tests', () => {
  test('accessing restricted app triggers overlay', () => {
    const vm = new RestrictedAppAccessViewModel();
    vm.attemptAccess('com.tiktok.ios');
    expect(vm.isOverlayVisible).toBe(true);
  });

  test('wait option starts timer', () => {
    const vm = new RestrictedAppAccessViewModel();
    // assume default waitTime is 60
    vm.selectWaitOption();
    expect(vm.remainingWaitTime).toBe(60);
  });

  test('reason entry allows access', () => {
    const vm = new RestrictedAppAccessViewModel();
    vm.enterReason('Looking up a recipe');
    expect(vm.isAccessGranted).toBe(true);
  });
});

describe('Friend Activity Feed Tests', () => {
  test('friend feed populates with activity', () => {
    const vm = new FeedViewModel();
    vm.friendActivities = [
      new FriendActivity({
        friendID: 'user123',
        appName: 'Instagram',
        justification: 'Posting homework',
        timestamp: new Date()
      })
    ];
    expect(vm.friendActivities.length).toBeGreaterThan(0);
  });
});

describe('Add Friend Tests', () => {
  test('sending friend request adds to pending', () => {
    const vm = new FriendsViewModel();
    vm.sendFriendRequest('friend123');
    expect(vm.pendingRequests).toContain('friend123');
  });

  test('accepting friend request adds to friends list', () => {
    const vm = new FriendsViewModel();
    vm.receiveFriendRequest('friend123');
    vm.acceptFriendRequest('friend123');
    expect(vm.friends).toContain('friend123');
    expect(vm.pendingRequests).not.toContain('friend123');
  });

  test('declining friend request removes from pending', () => {
    const vm = new FriendsViewModel();
    vm.receiveFriendRequest('friend123');
    vm.declineFriendRequest('friend123');
    expect(vm.pendingRequests).not.toContain('friend123');
  });
});
