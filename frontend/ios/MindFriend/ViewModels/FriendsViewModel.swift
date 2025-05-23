import Foundation
import Combine

class FriendsViewModel: ObservableObject {
    @Published var friends: [String] = []
    @Published var isLoading = false
    @Published var error: String?
    
    // Keep other properties if needed, but remove old mock data ones if they conflict
    // @Published var pendingRequests: [String] = []
    // @Published var searchResults: [String] = []
    // @Published var foundUser: String?
    
    init() {
        // Initialization moved to onAppear in the View, where username is available
    }
    
    // private var cancellables = Set<AnyCancellable>() // Remove if not used
    
    // MARK: - Backend Integration Functions
    
    func loadFriends(username: String) async {
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        // Use the getFriends function from backEndIntegration.swift
        MindFriend.getFriends(userId: username) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let friendsList):
                    self.friends = friendsList
                    self.error = nil // Clear any previous error
                case .failure(let error):
                    self.error = error.localizedDescription
                    print("Error loading friends: \(error)")
                }
            }
        }
    }
    
    func addFriendButton(userId: String, friendId: String, completion: @escaping (Bool) -> Void) async {
        // Use the addFriend function from backEndIntegration.swift
        MindFriend.addFriend(userId: userId, friendId: friendId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("Friend added successfully.")
                    // Reload friends list after successful addition
                    Task {
                        await self.loadFriends(username: userId)
                    }
                    self.error = nil // Clear any previous error
                    completion(true)
                case .failure(let backendError):
                    self.error = backendError.localizedDescription
                    print("Error adding friend: \(backendError)")
                    completion(false)
                }
            }
        }
    }
    
    // Add other backend integration functions here as needed (e.g., for requests)
    // func loadPendingRequests() { ... }
    // func acceptFriendRequest(from userID: String) { ... }
    // func declineFriendRequest(from userID: String) { ... }
    // func searchUsers(query: String) { ... }
} 
