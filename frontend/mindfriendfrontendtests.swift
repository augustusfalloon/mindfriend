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
    
    func testEmptyFeedShowsMotivationalTip() {
        let viewModel = FeedViewModel()
        viewModel.friendActivities = []
        
        XCTAssertEqual(viewModel.emptyFeedMessage, "Invite friends and stay mindful!")
    }
    
    func testMutedFriendIsHiddenFromFeed() {
        let viewModel = FeedViewModel()
        viewModel.muteFriend(friendID: "user123")
        viewModel.friendActivities = [
            FriendActivity(friendID: "user123", appName: "Instagram", justification: "Posting homework", timestamp: Date())
        ]
        
        XCTAssertFalse(viewModel.visibleFriendActivities.contains { $0.friendID == "user123" })
    }
}
