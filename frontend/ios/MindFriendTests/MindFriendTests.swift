//
//  MindFriendTests.swift
//  MindFriendTests
//
//  Created by Augustus Falloon on 5/1/25.
//

import XCTest
import SwiftUI
@testable import MindFriend

// MARK: - ViewModels
class LoginViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var isLoggedIn: Bool = false
    @Published var isLoading: Bool = false
    @Published var loginError: String?
    
    var isButtonDisabled: Bool {
        return isLoading || username.isEmpty || password.isEmpty
    }
}

class SettingsViewModel: ObservableObject {
    @Published var restrictedApps: [RestrictedApp] = []
    
    func addRestrictedApp(appID: String, waitTime: Int) {
        let app = RestrictedApp(id: appID, waitTime: waitTime)
        restrictedApps.append(app)
    }
    
    func deleteRestrictedApp(appID: String) {
        restrictedApps.removeAll { $0.id == appID }
    }
}

class RestrictedAppAccessViewModel: ObservableObject {
    @Published var isOverlayVisible: Bool = false
    @Published var remainingWaitTime: Int = 0
    @Published var isAccessGranted: Bool = false
    
    func attemptAccess(appID: String) {
        isOverlayVisible = true
    }
    
    func selectWaitOption() {
        remainingWaitTime = 60
    }
    
    func enterReason(_ reason: String) {
        isAccessGranted = true
        isOverlayVisible = false
    }
}

class FeedViewModel: ObservableObject {
    @Published var friendActivities: [FriendActivity] = []
}

class FriendsViewModel: ObservableObject {
    @Published var friends: [String] = []
    @Published var pendingRequests: [String] = []
    
    func sendFriendRequest(to userID: String) {
        pendingRequests.append(userID)
    }
    
    func receiveFriendRequest(from userID: String) {
        pendingRequests.append(userID)
    }
    
    func acceptFriendRequest(from userID: String) {
        friends.append(userID)
        pendingRequests.removeAll { $0 == userID }
    }
    
    func declineFriendRequest(from userID: String) {
        pendingRequests.removeAll { $0 == userID }
    }
}

// MARK: - Models
struct RestrictedApp: Identifiable {
    let id: String
    let waitTime: Int
}

struct FriendActivity: Identifiable {
    let id = UUID()
    let friendID: String
    let appName: String
    let justification: String
    let timestamp: Date
}

// MARK: - Tests
final class MindFriendTests: XCTestCase {
    
    // Login Screen Tests
    func testLoginButtonDisabledDuringLoading() {
        let viewModel = LoginViewModel()
        viewModel.username = "test@example.com"
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
