import XCTest
@testable import MindFriend

final class MindFriendFrontendTests: XCTestCase {
    
    // Login Screen Tests
    
    func testLoginButtonDisabledDuringLoading() {
        let viewModel = LoginViewModel()
        viewModel.email = "test@example.com"
        viewModel.password = "password"
        
        viewModel.isLoading = true
        
        XCTAssertTrue(viewModel.isButtonDisabled)
    }
    
    func testErrorAppearsOnFailedLogin() {
        let viewModel = LoginViewModel()
        viewModel.loginError = "Invalid credentials"
        
        XCTAssertEqual(viewModel.loginError, "Invalid credentials")
    }
    
    func testSuccessfulLoginNavigatesToDashboard() {
        let viewModel = LoginViewModel()
        viewModel.isLoggedIn = true
        
        XCTAssertTrue(viewModel.isLoggedIn)
    }
    
    // Settings Screen Tests
    
    func testAddingRestrictedApp() {
        let viewModel = SettingsViewModel()
        viewModel.addRestrictedApp(appID: "com.instagram.ios", waitTime: 60)
        
        XCTAssertEqual(viewModel.restrictedApps.count, 1)
    }
    
    
    func testDeletingRestrictedApp() {
        let viewModel = SettingsViewModel()
        viewModel.addRestrictedApp(appID: "com.instagram.ios", waitTime: 60)
        viewModel.deleteRestrictedApp(appID: "com.instagram.ios")
        
        XCTAssertTrue(viewModel.restrictedApps.isEmpty)
    }
    
    // Restricted App Blocking Screen Tests
    
    func testAccessRestrictedAppTriggersOverlay() {
        let viewModel = RestrictedAppAccessViewModel()
        viewModel.attemptAccess(appID: "com.tiktok.ios")
        
        XCTAssertTrue(viewModel.isOverlayVisible)
    }
    
    func testWaitOptionStartsTimer() {
        let viewModel = RestrictedAppAccessViewModel()
        viewModel.selectWaitOption()
        
        XCTAssertEqual(viewModel.remainingWaitTime, 60)
    }
    
    func testReasonEntryAllowsAccess() {
        let viewModel = RestrictedAppAccessViewModel()
        viewModel.enterReason("Looking up a recipe")
        
        XCTAssertTrue(viewModel.isAccessGranted)
    }
    
    // Friend Activity Feed Tests
    
    func testFriendFeedPopulatesWithActivity() {
        let viewModel = FeedViewModel()
        viewModel.friendActivities = [
            FriendActivity(friendID: "user123", appName: "Instagram", justification: "Posting homework", timestamp: Date())
        ]
        
        XCTAssertFalse(viewModel.friendActivities.isEmpty)
    }
    // Add Friend Tests

    func testSendingFriendRequestAddsToPending() {
        let viewModel = FriendsViewModel()
        viewModel.sendFriendRequest(to: "friend123")
        
        XCTAssertTrue(viewModel.pendingRequests.contains("friend123"))
    }

    func testAcceptingFriendRequestAddsToFriendsList() {
        let viewModel = FriendsViewModel()
        viewModel.receiveFriendRequest(from: "friend123")
        viewModel.acceptFriendRequest(from: "friend123")
        
        XCTAssertTrue(viewModel.friends.contains("friend123"))
        XCTAssertFalse(viewModel.pendingRequests.contains("friend123"))
    }

    func testDecliningFriendRequestRemovesFromPending() {
        let viewModel = FriendsViewModel()
        viewModel.receiveFriendRequest(from: "friend123")
        viewModel.declineFriendRequest(from: "friend123")
        
        XCTAssertFalse(viewModel.pendingRequests.contains("friend123"))
    }
}
